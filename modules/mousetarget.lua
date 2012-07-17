local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("mousetarget", L["TooltipInfo"]);
mod.order = 1
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
        hexcolor = format("%2x%2x%2x", color[1]*255, color[2]*255, color[3]*255)
    end
    return hexcolor
end

local function GetTarget(unit)
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
                tmpString = LEVEL..(format(" |cff%s%d|r", GetDiffLevelColor(unitLevel), unitLevel));
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
            tmpString = format("%s |cff%s%s|r", tmpString, CLASS_COLORS[enClass], class);
        elseif UnitPlayerControlled(unit) then
            tmpString = format("%s %s", tmpString, (UnitCreatureFamily(unit) or creatureType or ""));
        elseif creatureType then
            if db.showFaction and reaction and reaction>4 then--faction 
                reactionColor = UnitReactionColor[reaction];
                local factionLabel = _G["FACTION_STANDING_LABEL"..reaction]
                factionLabel = format("|cff%2x%2x%2x(%s)|r", reactionColor.r*255, reactionColor.g*255, reactionColor.b*255, factionLabel)
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
            end
        end
    end

    self:GetTargetLine(unit)

    if isPlayer and UnitIsConnected(unit) then
        if UnitLevel(unit) >= 10 then
            local guid = UnitGUID(unit);
            mod:RegisterEvent("INSPECT_READY");
            --save it
            if not Icetip_InspectTalent[guid] then
                Icetip_InspectTalent[guid] = {}
            end
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
            GameTooltip:Show()
            return round(sum/count, 0)
        else
            return nil
        end
    end

    function mod:INSPECT_READY(event, guid)
        self:UnregisterEvent("INSPECT_READY");
        local unit = Icetip:GetUnitByGUID(guid);
        local iLvl = GetUnitItemLevel(unit);

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
            GameTooltip:Show();
            --wipe(Icetip_InspectTalent);
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
