local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("mousetarget", L["TooltipInfo"]);
mod.order = 1
local Icetip_InspectTalent = setmetatable({}, {__mode="kv"});

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

local defaults = {
    profile = {
	showTalent = true,
	showTarget = true,
	showFaction = true,
	showServer = true,
	showItemLevel = true,
	SGuildColor = {
	    r = 0.9,
	    g = 0.45,
	    b = 0.7,
	},
	DGuildColor = {
	    r = 0.8,
	    g = 0.8,
	    b = 0.8,
	}
    }
}
local db

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
end

function mod:PreTooltipSetUnit()
    if GameTooltip:GetUnit() then
        self:SetTooltipInfo(select(2, GameTooltip:GetUnit()));
    end
end

function mod:OnTooltipHide()
    if self.targetFrame then
        self.targetFrame:Hide()
    end
    self:UnregisterEvent("INSPECT_READY");
end

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
        hexcolor = Icetip:Hex(color);
    end
    return hexcolor
end

local function GetTarget(unit)
    if not UnitExists(unit) then return end
    if UnitIsUnit(unit, "player") then
        return L["|cffff0000>YOU<|r"];
    elseif UnitIsPlayer(unit) then
        return Icetip:GetClassColor(unit)..UnitName(unit).."|r"
    else
        unitreaction = UnitReactionColor[UnitReaction(unit, "player")];
        if not unitreaction then
            return
        end
        return format("%s%s|r", Icetip:Hex(unitreaction), UnitName(unit))
    end
end

local updateTime = 0
local function targetFrameUpdate(self, elapsed)
    updateTime = updateTime + elapsed;
    if updateTime > 0.5 then
        local unit = select(2, GameTooltip:GetUnit());
        if not unit or not GameTooltip:IsVisible() then return end
        if not UnitExists(unit) then return end
        if UnitExists(unit.."target") then
            local targetLine;
            local targetName = GetTarget(unit.."target");

            for i = 1, GameTooltip:NumLines() do
                local tip = _G["GameTooltipTextLeft"..i]:GetText()
                if (tip and tip:find(TARGET)) then
                    targetLine = true;
                    if targetName then
                        _G["GameTooltipTextLeft"..i]:SetText("["..TARGET.."] "..GetTarget(unit.."target"))
                    else
                        --_G["GameTooltipTextLeft"..i]:SetText();
                    end
                    GameTooltip:Show()
                    break;
                end
            end
            if (not targetLine) and targetName then
                GameTooltip:AddLine("["..TARGET.."] "..GetTarget(unit.."target"))
                GameTooltip:Show()
            end
        end
    end
end

function mod:GetTargetLine(unit)
    if not db.showTarget then return end
    if not unit or not GameTooltip:IsVisible() then return end

    if not self.targetFrame then
        self.targetFrame = CreateFrame("Frame");
        self.targetFrame:SetScript("OnUpdate", targetFrameUpdate)
        self.targetFrame:Hide();
    end

    if unit and UnitExists(unit) then
        self.targetFrame:Show();
    else
        self.targetFrame:Hide();
    end
end

function mod:SetTooltipInfo(unit)
    if (not unit) or (not UnitExists(unit)) then return end

    local isPlayer = UnitIsPlayer(unit);
    local unitname = UnitName(unit)
    local reaction = UnitReaction(unit, "player")

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
            end
        end
    end
    
    if levelline then
        local tmpString;
        local unitLevel = UnitLevel(unit);
        local unitIsDead = UnitHealth(unit) < 0 and (not isPlayer or UnitIsDeadOrGhost(unit));

        if unitIsDead then
            if unitLevel > 0 then
                tmpString = LEVEL..(format(" |cff888888%d %s|r", unitLevel, CORPSE));
            else
                tmpString = LEVEL..(format(" |cff888888%s %s|r", "??", CORPSE));
            end
        elseif (unitLevel > 0) then
            if UnitCanAttack("player", unit) or UnitCanAttack(unit, "player") then
                tmpString = LEVEL..(format(" %s%d|r", GetDiffLevelColor(unitLevel), unitLevel));
            else
                tmpString = LEVEL..(format(" |cff3377CC%d|r", unitLevel));
            end
        else
            tmpString = LEVEL..(" |cffFF0000 ??|r")
        end

        local unitRace = UnitRace(unit);
        local creatureType = UnitCreatureType(unit);

        if unitRace and isPlayer then
            local factionColor;
            if UnitFactionGroup(unit) == UnitFactionGroup("player") then
                factionColor = "00ff33"
            else
                factionColor = "ff3300"
            end
            tmpString = format("%s |cff%s%s|r", tmpString, factionColor, unitRace);

            local class, enClass = UnitClass(unit)
            tmpString = format("%s %s%s|r", tmpString, Icetip:GetClassColor(unit), class);
        elseif UnitPlayerControlled(unit) then
            tmpString = format("%s %s", tmpString, (UnitCreatureFamily(unit) or creatureType or ""));
        elseif creatureType then
            if db.showFaction and reaction and reaction>4 then--faction 
                reactionColor = UnitReactionColor[reaction];
                local factionLabel = _G["FACTION_STANDING_LABEL"..reaction]
                factionLabel = format("%s(%s)|r", Icetip:Hex(reactionColor) , factionLabel)
                tmpString = format("%s |cffFFFFFF%s|r %s" , tmpString, creatureType, factionLabel)
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
            local classType = UnitClassification(unit);
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

    local unitGuild, unitGuildRank = GetGuildInfo(unit);
    local playerGuild = GetGuildInfo("player")
    local gTipString;
    if isPlayer then
        if unitGuild and playerGuild then
            if unitGuild == playerGuild then
                gTipString = format("%s< %s > - %s|r", Icetip:Hex(db.SGuildColor), unitGuild, unitGuildRank)
            else
                gTipString = format("%s< %s > - %s|r", Icetip:Hex(db.DGuildColor), unitGuild, unitGuildRank)
            end
        elseif unitGuild then
            gTipString = format("%s< %s > - %s|r", Icetip:Hex(db.DGuildColor), unitGuild, unitGuildRank)
	end

	--After 4.0,  GameTooltip displayed ServerName
	--TODO: need FIXME
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
            end
        end
    end

    self:GetTargetLine(unit)

    if isPlayer and UnitIsConnected(unit) then
        if UnitLevel(unit) >= 10 and CanInspect(unit) then
            local guid = UnitGUID(unit);
            mod:RegisterEvent("INSPECT_READY");
            --save it
            if not Icetip_InspectTalent[guid] then
                Icetip_InspectTalent[guid] = {}
	    end

	    --Ends inspection of another character. After this function is called, data about the inspected unit may not be available or valid.
	    ClearInspectPlayer();
            NotifyInspect(unit)
        end
    end

    GameTooltip:Show();
end

do
    local function round(num, dec)
        dec = dec or 0
        return tonumber(string.format("%."..dec.."f", num))
    end

    local function GetUnitItemLevel(unit)
	if not db.showItemLevel then
	    return
	end
        local sum, count = 0, 0;
        if unit and UnitIsPlayer(unit) and CheckInteractDistance(unit, 1) then
            for i = 1, 18, 1 do
                local itemLink = GetInventoryItemLink(unit, i) or 0
                local itemLevel = select(4, GetItemInfo(itemLink))

                if itemLevel and itemLevel > 0 and i ~= 4 then
                    count = count + 1;
                    sum = sum    + (itemLevel or 0)
                end
            end
            
            if GetInventoryItemLink(unit, 17) then
                count = 17
            else
                count = 16
            end
        end

        if sum >= count and count > 0 then
            GameTooltip:AddDoubleLine("iLvl: ", round(sum/count, 0));
	    --flash
	    if GameTooltip:IsShown() then
		GameTooltip:Show()
	    end
            return round(sum/count, 0)
        else
            return nil
        end
    end

    --------------------- 
    --old
    ---------------------
    function mod:GetTalentTabInfo(...)
        local uniqueId, tabName, description, icon, pointsSpent, background, previewPointsSpent, bool = GetTalentTabInfo(...);
        return tabName, icon, pointsSpent, background, previewPointsSpent;
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

    
    --async
    function mod:INSPECT_READY(event, guid)
        self:UnregisterEvent("INSPECT_READY");
        local unit = Icetip:GetUnitByGUID(guid);
        local iLvl = GetUnitItemLevel(unit);
	
	if select(4, GetBuildInfo()) <= 40300 then
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

	    if UnitExists(unit) and Icetip_InspectTalent[guid] then
		GameTooltip:AddDoubleLine(L["Active Talent: "], talent_name);
		if (talent_name2 ~= _G["NONE"] and talent_text2 ~= _G["NONE"]) then
		    GameTooltip:AddDoubleLine(L["Sec Talent: "], talent_name2);
		end

		--GameTooltip:Show();

		--clear tbl
		wipe(Icetip_InspectTalent);
	    end
	else
	    if UnitExists(unit) and Icetip_InspectTalent[guid] and db.showTalent then
		local spec = GetInspectSpecialization(unit);
		local role1 = GetSpecializationRoleByID(spec)
		local _, name = GetSpecializationInfoByID(spec);
		if role1 then
		    GameTooltip:AddDoubleLine(L["Active Talent: "], name.." (".._G[role1]..")");
		end
		--if (talent_name2 ~= _G["NONE"] and talent_text2 ~= _G["NONE"]) then
		--    GameTooltip:AddDoubleLine(L["Sec Talent: "], talent_name2);
		--end

		--GameTooltip:Show();

		----clear tbl
		--wipe(Icetip_InspectTalent);
	    end
        end

	if (GameTooltip:IsShown()) then
	    --update GameTooltip, and flash
	    GameTooltip:Show()
	end
    end
end

function mod:GetOptions()
    local options = {
	tot = {
	    type = "toggle",
	    order = 2,
	    name = L["Toggle show target of target"],
	    desc = L["Enable/Disable display target of target"],
	    width = "full",
	    get = function() return db.showTarget end,
	    set = function(_, v)
		db.showTarget = v
	    end
	},
	showtalent = {
	    type = "toggle",
	    order = 3,
	    name = L["Toggle show talent"],
	    width = "full",
	    desc = L["Enable/Disable display the target's talent"],
	    get = function() return db.showTalent end,
	    set = function(_, v)
		db.showTalent = v
	    end
	},
	showItemLevel = {
	    type = "toggle",
	    order = 4,
	    name = L["Toggle show item level"],
	    width = "full",
	    desc = L["Enable/Disable display the target's equipped item level"],
	    get = function() return db.showItemLevel end,
	    set = function(_, v)
		db.showItemLevel = v
	    end
	},
	showfaction = {
	    type = "toggle",
	    width = "full",
	    order = 5,
	    name = L["Toggle show npc faction"],
	    desc = L["Enable/Disable to show a npc's reputation information between you"],
	    get = function() return db.showFaction end,
	    set = function(_, v)
		db.showFaction = v
	    end
	}
    }

    return options
end
