local _, Icetip = ...
local mod = Icetip:NewModule("MouseTarget");
local db
local GameTooltipStatusBar = _G.GameTooltipStatusBar
local L = LibStub("AceLocale-3.0"):GetLocale("Icetip")
local unit
local targetLine
local Icetip_InspectTalent = setmetatable({}, {__mode="kv"});
local CLASS_COLORS = {}
for class, color in pairs(RAID_CLASS_COLORS) do
	CLASS_COLORS[class] = ("%2x%2x%2x"):format(color.r*255, color.g*255, color.b*255)
end

local UnitReactionColor = {
	{r = 1.0, g = 0.0, b = 0.0},
	{r = 1.0, g = 0.0, b = 0.0},
	{r = 1.0, g = 0.5, b = 0.0},
	{r = 1.0, g = 1.0, b = 0.0},
	{r = 0.0, g = 1.0, b = 0.0},
	{r = 0.0, g = 1.0, b = 0.0},
	{r = 0.0, g = 1.0, b = 0.0},
	{r = 0.0, g = 1.0, b = 0.0},
}

local function GetTargetLine(unit)
	if not UnitExists(unit) then return end
	if UnitIsUnit(unit, "player") then
		return L["|cffff0000>YOU<|r"];
	elseif UnitIsPlayer(unit) then
		return "|cff"..CLASS_COLORS[select(2, UnitClass(unit))]..UnitName(unit).."|r"
	else
		unitreaction = UnitReactionColor[UnitReaction(unit, "player")];
		if not unitreaction then
			return
		end
		return format("|cff%2x%2x%2x%s|r", unitreaction.r*255, unitreaction.g*255, unitreaction.b*255, UnitName(unit))
	end
end

function mod:SetUnit()
        local _, unit = GameTooltip:GetUnit();
	if not Icetip.db["mousetarget"].showTarget then return end
	if not unit or not GameTooltip:IsVisible() then return end

	if not unit or not UnitExists(unit.."target") then
		targetLine = nil
		return
	end
	
	if unit and UnitExists(unit) then
		GameTooltip:AddLine(L["[Target] "]..GetTargetLine(unit.."target"));
		targetLine = GameTooltip:NumLines()
	end
end

local updateTime = 0
function mod:Update(elapsed)
	updateTime = updateTime + elapsed;
	if updateTime > 0.1 then
		local unit = select(2, GameTooltip:GetUnit());
		if not unit or not GameTooltip:IsVisible() then return end
		if not UnitExists(unit) then return end
		if UnitExists(unit.."target") then
			for i = 1, GameTooltip:NumLines() do
				if (_G["GameTooltipTextLeft"..i]:GetText()) then
					if (_G["GameTooltipTextLeft"..i]:GetText():find(TARGET)) then
						_G["GameTooltipTextLeft"..i]:SetText(L["[Target] "]..GetTargetLine(unit.."target"))
						GameTooltip:Show()
						break;
					end
				elseif i == GameTooltip:NumLines() then
					GameTooltip:AddLine(L["[Target] "]..GetTargetLine(unit.."target"))
					GameTooltip:Show()
				end
			end
		end
	end
end

function mod:OnTooltipShow()
	if GameTooltip:GetUnit() then
		self:MouseOverInfo(select(2, GameTooltip:GetUnit()))
	end
end

function mod:OnTooltipHide()
	self:UnregisterEvent("INSPECT_READY");
end

--rgb
local function GetDiffLevelColor(level)
	local playerLevel = UnitLevel("player")
	local levelDiff = level - playerLevel;
	local levRange = GetQuestGreenRange();
	--player80 85
	if (levelDiff >= 5 or level == -1) then
		color = {1, 0.2, 0.2}
	elseif (levelDiff >= 3) then
		color = {1, 0.4, 0};
	elseif (levelDiff >= -2) then
		color = {1, 1, 0}
	elseif (-levelDiff <= levRange) then
		color = {0, 1, 0}
	else
		color = {0.53, 0.53, 0.53}
	end
	
	if color then
		hexcolor = format("%2x%2x%2x", color[1]*255, color[2]*255, color[3]*255)
	end
	return hexcolor
end

local lastMouseUnit = nil
function mod:MouseOverInfo(unit)
	local db = self.db["mousetarget"];
	if not unit or not unit == "mouseover" then return end
	isPlayer = UnitIsPlayer(unit);
	unitname = UnitName(unit)
	reaction = UnitReaction(unit, "player")
	lastMouseUnit = GameTooltip:GetUnit()

	local tooltipLines;
	local levelline
	tooltipLines = GameTooltip:NumLines();
	for i=2, tooltipLines do
		leftText = _G["GameTooltipTextLeft"..i];
		tipText = leftText:GetText();
		if tipText then
			if not levelline or strfind(tipText, LEVEL) then
				levelline = i
			elseif (tipText == PVP) then
				leftText:SetText();
			elseif (tipText == TAMEABLE) then
				leftText:SetText(format("|cff00FF00%s|r", tipText))
			elseif  (tipText == NOT_TAMEABLE) then
				leftText:SetText(format("|cffFF6035%s|r", tipText))
			else
				otherInfo = tipText
			end
		end
	end
	
	if levelline then
		local tmpString;
		unitLevel = UnitLevel(unit);
		unitIsDead = UnitHealth(unit) < 0 and (not isPlayer or UnitIsDeadOrGhost(unit));
		if unitIsDead then
			if unitLevel > 0 then
				tmpString = LEVEL..(format(" |cff888888%d %s|r", unitLevel, CORPSE));
			else
				tmpString = LEVEL..(format(" |cff888888%s %s|r", "??", CORPSE));
			end
		elseif (unitLevel > 0) then
			if UnitCanAttack("player", unit) or UnitCanAttack(unit, "player") then
				tmpString = LEVEL..(format(" |cff%s%d|r", GetDiffLevelColor(unitLevel), unitLevel));
			else
				tmpString = LEVEL..(format(" |cff3377CC%d|r", unitLevel));
			end
		else
			tmpString = LEVEL..(" |cffFF0000 ??|r")
		end

		unitRace = UnitRace(unit);
		creatureType = UnitCreatureType(unit);

		if unitRace and isPlayer then
			local factionColor;
			if UnitFactionGroup(unit) == UnitFactionGroup("player") then
				factionColor = "00ff33"
			else
				factionColor = "ff3300"
			end
			tmpString = format("%s |cff%s%s|r", tmpString, factionColor, unitRace);

			local class, enClass = UnitClass(unit)
			tmpString = format("%s |cff%s%s|r", tmpString, CLASS_COLORS[enClass], class);
		elseif UnitPlayerControlled(unit) then
			tmpString = format("%s %s", tmpString, (UnitCreatureFamily(unit) or creatureType or ""));
		elseif creatureType then
			--reaction>4
			if db.showFaction and reaction and reaction>4 then--faction 
				reactionColor = UnitReactionColor[reaction];
				local factionLabel = _G["FACTION_STANDING_LABEL"..reaction]
				factionLabel = format("|cff%2x%2x%2x(%s)|r", reactionColor.r*255, reactionColor.g*255, reactionColor.b*255, factionLabel)
				--print(factionLabel)
				tmpString = format("%s |cffFFFFFF%s|r %s" , tmpString, creatureType, factionLabel)
				--print(tmpString)
			elseif creatureType == L["Not Specified"] then
				tmpString = format("%s %s", tmpString, UNKNOWN);
			else
				tmpString = format("%s %s", tmpString, creatureType);
			end
		else
			tmpString = format("%s %s", tmpString, UKNOWNBEING)
		end
		tipString = tmpString
		
		tmpString = ""
		if isPlayer then
			tmpString = " ("..PLAYER..") ";
		elseif not UnitPlayerControlled(unit) then
			classType = UnitClassification(unit);
			if classType and classType ~= "normal" and UnitHealth(unit) > 0 then
				if classType == "elite" then
					tmpString = format("|cffffff33(%s)|r", ELITE);
				elseif classType == "worldboss" then
					tmpString = format("|cffFF0000(%s)|r", BOSS);
				elseif classType == "rare" then
					tmpString = format("|cffFF66FF(%s)|r", L["Rare"]);
				elseif classType == "rareelite" then
					tmpString = (L["|cffFFAAFF(Rare Boss)|r"]);
				else
					tmpString = classType
				end
			end
		end

		_G["GameTooltipTextLeft"..levelline]:SetText(format("%s %s", tipString, tmpString))
	end

	unitGuild, unitGuildRank = GetGuildInfo(unit);
	local playerGuild = GetGuildInfo("player")
	if isPlayer then
		if unitGuild and playerGuild then
			if unitGuild == playerGuild then
				gTipString = format("|cff%2x%2x%2x< %s > - %s|r", db.SGuildColor.r*255, db.SGuildColor.g*255, db.SGuildColor.b*255, unitGuild, unitGuildRank)
			else
				gTipString = format("|cff%2x%2x%2x< %s > - %s|r", db.DGuildColor.r*255, db.DGuildColor.g*255, db.DGuildColor.b*255, unitGuild, unitGuildRank)
			end
		elseif unitGuild then
			gTipString = format("|cff%2x%2x%2x< %s > - %s|r", db.DGuildColor.r*255, db.DGuildColor.g*255, db.DGuildColor.b*255, unitGuild, unitGuildRank)
		end
		local _, unitServer = UnitName(unit)
		if (db.showServer) and (unitServer or gTipString) then
			if (unitServer and gTipString) then
				realmTag = " @ "
			else
				realmTag = ""
			end
			gTipString = format("%s |cffFFAA50%s%s|r", gTipString or "", realmTag, unitServer or "");
		end
		if gTipString then
			if unitGuild then
				_G["GameTooltipTextLeft2"]:SetText(gTipString);
			else
				--其余状态暂时不处理
			end
		end
	end

	--talent
	if isPlayer and db.showTalent and UnitIsConnected(unit) then
		if UnitLevel(unit) >= 10 then
			local name = UnitName(unit);
			mod:RegisterEvent("INSPECT_READY");
			--save it
			if not Icetip_InspectTalent[name] then
				Icetip_InspectTalent[name] = {}
			end
			NotifyInspect(unit)
		end
	end

	--update target
	self:SetUnit();

        local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))];
        if db.colorBorderByClass and isPlayer then
            GameTooltip:SetBackdropBorderColor(color.r, color.g, color.b)
        end

	GameTooltip:Show();
end

do
	function mod:GetTalentTabInfo(...)
		if (select(4, GetBuildInfo()) >= 40000) then
			local uniqueId, tabName, description, icon, pointsSpent, background, previewPointsSpent, bool = GetTalentTabInfo(...);
			return tabName, icon, pointsSpent, background, previewPointsSpent;
		else
			return GetTalentTabInfo(...);
		end
	end

	local MAX_TALENT_POINT = 36 
	local function ColorTalent(point)
		local r, g, b
		local minpoint, maxpoint = 0, MAX_TALENT_POINT
		point = max(0, min(point, MAX_TALENT_POINT));
		if (maxpoint - minpoint) > 0 then
			percent = (point - minpoint)/(maxpoint- minpoint)
		else
			percent = 0
		end
		
		if percent > 0.5 then
			r = 0.1 + (((1-percent)*2) * (1-0.1))
			g = 0.9
		else
			r = 1.0
			g = (0.9) - (0.5-percent)* 2 * (0.9)
		end
		local hexColor = format("|cff%2x%2x18", r*255, g*255);
		return hexColor.."%s|r";
	end

	local function TalentSpecName(names, nums, colors)
		if type(names) ~= "table" then return end
		if type(nums) ~= "table" then return end
		if type(colors) ~= "table" then return end

		if nums[1] == 0 and nums[2] == 0 and nums[3] == 0 then
			return _G.NONE, _G.NONE
		else
			local first, second, third, name, text, point
			if (nums[1] >= nums[2]) then
				if nums[1] >= nums[3] then
					first = 1
					if nums[2] >= nums[3] then 
						second = 2; third=3;
					else
						second = 3; third = 2; 
					end
				else
					first = 3; second = 1; third = 2
				end
			else
				if nums[2] >= nums[3] then
					first = 2;
					if nums[1] >= nums[3] then
						second = 1; third = 3;
					else
						second = 3; third = 1;
					end
				else
					first = 3; second = 2; third = 1
				end
			end
			local first_num = nums[first]
			local second_num = nums[second]
			if (first_num * 3/4) <= second_num then
				if (first_num * 3/4) < nums[third] then
					name = colors[first]:format(names[first]).."/"..colors[second]:format(names[second]).."/"..colors[third]:format(names[third])
					text = names[first].."/"..names[second].."/"..names[third]
				else
					name = colors[first]:format(names[first]).."/"..colors[second]:format(names[second])
					text = names[first].."/"..names[second]
				end
			else
				name = colors[first]:format(names[first])
				text = names[first]
			end
			point = (" |cc8c8c8c8(%s|cc8c8c8c8/%s|cc8c8c8c8/%s|cc8c8c8c8)"):format(colors[1]:format(nums[1]), colors[2]:format(nums[2]), colors[3]:format(nums[3]))
			return name..point, text..(" (%s/%s/%s)"):format(nums[1], nums[2], nums[3])
		end
	end

	function mod:INSPECT_READY()
		self:UnregisterEvent("INSPECT_READY");
		local currTalentGroupId = GetActiveTalentGroup(true)

		local name1,_,point1 = self:GetTalentTabInfo(1,true, nil, currTalentGroupId)
		local name2,_,point2 = self:GetTalentTabInfo(2,true, nil, currTalentGroupId)
		local name3,_,point3 = self:GetTalentTabInfo(3,true, nil, currTalentGroupId)

		local pcolor1, pcolor2, pcolor3 = ColorTalent(point1), ColorTalent(point2),ColorTalent(point3)
		local talent_name, talent_text = TalentSpecName({name1,name2,name3}, {point1,point2,point3},{pcolor1, pcolor2, pcolor3})

		--sec talent
		local secTalentGroupId = (currTalentGroupId == 1) and 2 or 1;
		local name1,_,point1 = self:GetTalentTabInfo(1,true, nil, secTalentGroupId);
		local name2,_,point2 = self:GetTalentTabInfo(2,true, nil, secTalentGroupId);
		local name3,_,point3 = self:GetTalentTabInfo(3,true, nil, secTalentGroupId);
		local pcolor1, pcolor2, pcolor3 = ColorTalent(point1), ColorTalent(point2),ColorTalent(point3);
		local talent_name2, talent_text2 = TalentSpecName({name1,name2,name3}, {point1,point2,point3},{pcolor1, pcolor2, pcolor3})

		local tooltipunit = GameTooltip:GetUnit()
		if UnitExists("mouseover") and Icetip_InspectTalent[tooltipunit] then
			GameTooltip:AddDoubleLine(L["Active Talent: "], talent_name);
			if (talent_name2 ~= _G["NONE"] and talent_text2 ~= _G["NONE"]) then
				GameTooltip:AddDoubleLine(L["Sec Talent: "], talent_name2);
			end
			GameTooltip:Show();

			--clear tbl
			wipe(Icetip_InspectTalent);
		end
	end
end