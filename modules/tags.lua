local addonName, Icetip = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local Tags = {};
Icetip.Tags = Tags;
local tagEnviroment;


--有些需要OnUpdate 触发, 比如Target, 也有一些需要事件
local tagPool, functionPool, temp, regFontStrings, frequentUpdates, frequencyCache = {}, {}, {}, {}, {}, {};

--function Tags:RegisterEvents(parent, fontString, tags)
--    for tag in string.gmatch(tags, "%[(.-)%]") do
--        local tagKey = select(2, string.match(tag, "(%b())([%w%p]+)(%b())"))
--        if( not tagKey ) then tagKey = select(2, string.match(tag, "(%b())([%w%p]+)")) end
--        if( not tagKey ) then tagKey = string.match(tag, "([%w%p]+)(%b())") end
--        
--        tag = tagKey or tag
--        local currentStyle = Icetip.db.profile.currentMode;
--        local currentStyleDB = Icetip:GetCurrentStyleDB(currentStyle);
--        
--        local tagEvents;
--        if (Tags.defaultEvents[tag]) then
--            tagEvents = Tags.defaultEvents[tag];
--        elseif (currentStyleDB and currentStyleDB.tags[tag] and currentStyleDB.tags[tag].events) then
--            tagEvents = currentStyleDB.tags[tag].events;
--        elseif (Icetip.db.profile.tags[tag] and Icetip.db.profile.tags[tag].events) then
--            tagEvents = Icetip.db.profile.tags[tag].events;
--        end
--
--        if( tagEvents ) then
--            for event in string.gmatch(tagEvents, "%S+") do
--                if( self.customEvents[event] ) then
--                    self.customEvents[event]:EnableTag(parent, fontString)
--                    fontString[event] = true
--                elseif( Tags.eventType[event] ~= "unitless" or Icetip.Module.unitEvents[event] ) then
--                    parent:RegisterUnitEvent(event, fontString, "UpdateTags")
--                else
--                    parent:RegisterNormalEvent(event, fontString, "UpdateTags")
--                end
--                
--                fontString.fastPower = fontString.fastPower or Tags.eventType[event] == "power"
--                fontString.fastHealth = fontString.fastHealth or Tags.eventType[event] == "health"
--            end
--        end
--    end
--end
--
--function Tags:Reload()
--    wipe(tagPool);
--    wipe(functionPool);
--    wipe(Icetip.tagFunc);
--
--    for fontString, tags in pairs(regFontStrings) do
--        self:Register(fontString.parent, fontString, tags)
--        fontString.parent:RegisterUpdateFunc(fontString, "UpdateTags")
--        fontString:UpdateTags()
--    end
--end

--Frequent updates
local freqFrame = CreateFrame("Frame")
freqFrame:SetScript("OnUpdate", function(self, elapsed)
    -- OnUpdate,  ex: targetoftarget.  
--    for fontString, timeLeft in pairs(frequentUpdates) do
--        if( fontString.parent:IsVisible() ) then
--            frequentUpdates[fontString] = timeLeft - elapsed
--            if( frequentUpdates[fontString] <= 0 ) then
--                frequentUpdates[fontString] = fontString.frequentStart
--                fontString:UpdateTags()
--            end
--        end
--    end
end)
freqFrame:Hide();

--[[
-- Register
-- parent:  GameTooltip
-- fontString: GameTooltipTextLeft1
--]]
--[=[
function Tags:Register(parent, fontString, tags, resetCache)
    if( fontString.UpdateTags ) then
        self:Unregister(fontString)
    end

    ---- current Style 
    local currentStyle = Icetip.db.profile.currentMode;
    local currentStyleDB = Icetip:GetCurrentStyleDB(currentStyle);

    fontString.parent = parent
    regFontStrings[fontString] = tags

    -- Use the cached polling time if we already saved it
    -- as we won't be rececking everything next call
    local pollTime = frequencyCache[tags]
    if( pollTime ) then
        frequentUpdates[fontString] = pollTime
        fontString.frequentStart = pollTime
        freqFrame:Show()
    end

    local updateFunc = not resetCache and tagPool[tags]
    if( not updateFunc ) then
        -- Using .- prevents supporting tags such as [foo ([)]. Supporting that and having a single pattern
        local formattedText = string.gsub(string.gsub(tags, "%%", "%%%%"), "[[].-[]]", "%%s")
        local args = {}

        for tag in string.gmatch(tags, "%[(.-)%]") do
            -- Tags that use pre or appends "foo(|)" etc need special matching, which is what this will handle
            local cachedFunc = not resetCache and functionPool[tag] or Icetip.tagFunc[tag]
            if( not cachedFunc ) then
                local hasPre, hasAp = true, true
                local tagKey = select(2, string.match(tag, "(%b())([%w%p]+)(%b())"))
                if( not tagKey ) then hasPre, hasAp = true, false tagKey = select(2, string.match(tag, "(%b())([%w%p]+)")) end
                if( not tagKey ) then hasPre, hasAp = false, true tagKey = string.match(tag, "([%w%p]+)(%b())") end

                if (tagKey) then
                    if(self.defaultFrequents[tagKey]) then
                        frequencyCache[tag] = self.defaultFrequents[tagKey];
                    elseif (currentStyleDB and currentStyleDB.tags[tagKey] and currentStyleDB.tags[tagKey].frequency) then
                        frequencyCache[tag] = currentStyleDB.tags[tagKey].frequency;
                    elseif (Icetip.db.profile.tags[tagKey] and Icetip.db.profile.tags[tagKey].frequency) then
                        frequencyCache[tag] = Icetip.db.profile.tags[tagKey].frequency;
                    end

                    --frequencyCache[tag] = tagKey and (self.defaultFrequents[tagKey] or Icetip.db.profile.tags[tagKey] and Icetip.db.profile.tags[tagKey].frequency)
                    local tagFunc = tagKey and Icetip.tagFunc[tagKey]
                    if( tagFunc ) then
                        local startOff, endOff = string.find(tag, tagKey)
                        local pre = hasPre and string.sub(tag, 2, startOff - 2)
                        local ap = hasAp and string.sub(tag, endOff + 2, -2)

                        if( pre and ap ) then
                            cachedFunc = function(...)
                                local str = tagFunc(...)
                                if( str ) then return pre .. str .. ap end
                            end
                        elseif( pre ) then
                            cachedFunc = function(...)
                                local str = tagFunc(...)
                                if( str ) then return pre .. str end
                            end
                        elseif( ap ) then
                            cachedFunc = function(...)
                                local str = tagFunc(...)
                                if( str ) then return str .. ap end
                            end
                        end

                        functionPool[tag] = cachedFunc
                    end
                end
            end

            -- Figure out what the lowest update frequency for this font string and use it
            local pollTime = self.defaultFrequents[tag] or frequencyCache[tag]
            if( currentStyleDB and currentStyleDB.tags[tag] and currentStyleDB.tags[tag].frequency ) then
                pollTime = currentStyleDB.tags[tag].frequency
            elseif (Icetip.db.profile.tags[tag] and Icetip.db.profile.tags[tag].frequency) then
                pollTime = Icetip.db.profile.tags[tag].frequency
            end

            if( pollTime and ( not fontString.frequentStart or fontString.frequentStart > pollTime ) ) then
                frequencyCache[tags] = pollTime
                frequentUpdates[fontString] = pollTime
                fontString.frequentStart = pollTime
                freqFrame:Show()
            end

            -- It's an invalid tag, simply return the tag itself wrapped in brackets
            if( not cachedFunc ) then
                functionPool[tag] = functionPool[tag] or function() return string.format("[%s-error]", tag) end
                cachedFunc = functionPool[tag]
            end
            table.iIcetipert(args, cachedFunc)
        end

        -- Create our update function now
        updateFunc = function(fontString)
            for id, func in pairs(args) do
                temp[id] = func(fontString.parent.unit, fontString.parent.unitOwner, fontString) or ""
            end

            fontString:SetFormattedText(formattedText, unpack(temp))
        end

        tagPool[tags] = updateFunc
    end

    -- And give other frames an easy way to force an update
    fontString.UpdateTags = updateFunc

    -- Register any needed event
    self:RegisterEvents(parent, fontString, tags)
end

function Tags:Unregister(fontString)
    regFontStrings[fontString] = nil
    frequentUpdates[fontString] = nil
    
    -- Kill frequent updates if they aren't needed anymore
    local hasFrequent
    for k in pairs(frequentUpdates) do
        hasFrequent = true
        break
    end
    
    if( not hasFrequent ) then
        freqFrame:Hide()
    end
    
    -- Unregister it as using HC
    for key, module in pairs(self.customEvents) do
        if( fontString[key] ) then
            fontString[key] = nil
            module:DisableTag(fontString.parent, fontString)
        end
    end
        
    -- Kill any tag data
    fontString.parent:UnregisterAll(fontString)
    fontString.fastPower = nil
    fontString.fastHealth = nil
    fontString.frequentStart = nil
    fontString.UpdateTags = nil
    fontString:SetText("")
end

]=]

Tags.defaultTags = {
    ["hp:color"] = [[function(unit, unitOwner)
        return Icetip:Hex(Icetip:GetGradientColor(unit))
    end]],
    ["guild"] = [[function(unit, unitOwner)
        return GetGuildInfo(unitOwner)
    end]],
    ["unit:situation"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation(unit)
        if( state == 3 ) then
            return Icetip.L["Aggro"]
        elseif( state == 2 ) then
            return Icetip.L["High"]
        elseif( state == 1 ) then
            return Icetip.L["Medium"]
        end
    end]],
    ["unit:target"] = [[function(unit, unitOwner)
    
    end]],
    ["situation"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation("player", "target")
        if( state == 3 ) then
            return L["Aggro"]
        elseif( state == 2 ) then
            return L["High"]
        elseif( state == 1 ) then
            return L["Medium"]
        end
    end]],
    ["unit:color:sit"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation(unit)
        
        return state and state > 0 and Icetip:Hex(GetThreatStatusColor(state))
    end]],
    ["unit:color:aggro"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation(unit)
        
        return state and state >= 3 and Icetip:Hex(GetThreatStatusColor(state))
    end]],
    ["color:sit"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation("player", "target")
        
        return state and state > 0 and Icetip:Hex(GetThreatStatusColor(state))
    end]],
    ["color:aggro"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation("player", "target")
        
        return state and state >= 3 and Icetip:Hex(GetThreatStatusColor(state))
    end]],
    ["scaled:threat"] = [[function(unit, unitOwner)
        local scaled = select(3, UnitDetailedThreatSituation("player", "target"))
        return scaled and string.format("%d%%", scaled)
    end]],
    ["general:sit"] = [[function(unit, unitOwner)
        local state = UnitThreatSituation("player")
        if( state == 3 ) then
            return L["Aggro"]
        elseif( state == 2 ) then
            return L["High"]
        elseif( state == 1 ) then
            return L["Medium"]
        end
    end]],
    ["afk"] = [[function(unit, unitOwner, fontString)
        return UnitIsAFK(unitOwner) and L["AFK"] or UnitIsDND(unitOwner) and L["DND"]
    end]],
    ["close"] = [[function(unit, unitOwner) return "|r" end]],
    ["smartrace"] = [[function(unit, unitOwner)
        return UnitIsPlayer(unit) and Tags.tagFunc.race(unit) or Tags.tagFunc.creature(unit)
    end]],
    ["reactcolor"] = [[function(unit, unitOwner)
        local color;
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

        if( not UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) ) then
            if( UnitCanAttack("player", unit) ) then
                --color = Icetip.db.profile.healthColors.hostile
            else
                --color = Icetip.db.profile.healthColors.enemyUnattack
            end
        elseif( UnitReaction(unit, "player") ) then
            local reaction = UnitReaction(unit, "player")
            if( reaction > 4 ) then
                color = UnitReactionColor[reaction];
            elseif( reaction == 4 ) then
                color = UnitReactionColor[reaction];
            elseif( reaction < 4 ) then
                color = UnitReactionColor[1]; --read
            end
        end
        
        return color and Icetip:Hex(color)
    end]],
    ["class"] = [[function(unit, unitOwner)
        return UnitIsPlayer(unit) and UnitClass(unit)
    end]],
    ["classcolor"] = [[function(unit, unitOwner) return Icetip:GetClassColor(unit) end]],
    ["creature"] = [[function(unit, unitOwner) return UnitCreatureFamily(unit) or UnitCreatureType(unit) end]],
    ["curhp"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end

        return Icetip:FormatLargeNumber(UnitHealth(unit))
    end]],
    ["colorname"] = [[function(unit, unitOwner)
        local color = Icetip:GetClassColor(unitOwner)
        local name = UnitName(unitOwner) or UNKNOWN
        if( not color ) then
            return name
        end
        if string.find(unit,"party%d?target") then
            if string.len(name) >=8 then
                name = string.sub(name,1,8)
                name = name.."..."
            end
        end
        return string.format("%s%s|r", color, name)
    end]],
    ["curpp"] = [[function(unit, unitOwner) 
        if( UnitPowerMax(unit) <= 0 ) then
            return nil
        elseif( UnitIsDeadOrGhost(unit) ) then
            return 0
        end
        
        return Icetip:FormatLargeNumber(UnitPower(unit))
    end]],
    ["curmaxhp"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end
        
        return string.format("%s/%s", Icetip:FormatLargeNumber(UnitHealth(unit)), Icetip:FormatLargeNumber(UnitHealthMax(unit)))
    end]],
    ["smart:curmaxhp"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end
        
        return string.format("%s/%s", Icetip:SmartFormatNumber(UnitHealth(unit)), Icetip:SmartFormatNumber(UnitHealthMax(unit)))
    end]],
    ["absolutehp"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end
        
        return string.format("%s/%s", UnitHealth(unit), UnitHealthMax(unit))
    end]],
    ["abscurhp"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end
        
        return UnitHealth(unit)
    end]],
    ["absmaxhp"] = [[function(unit, unitOwner) return UnitHealthMax(unit) end]],
    ["abscurpp"] = [[function(unit, unitOwner)
        if( UnitPowerMax(unit) <= 0 ) then
            return nil
        elseif( UnitIsDeadOrGhost(unit) ) then
            return 0
        end    
    
        return UnitPower(unit)
    end]],
    ["absmaxpp"] = [[function(unit, unitOwner)
        local power = UnitPowerMax(unit)
        return power > 0 and power or nil
    end]],
    ["absolutepp"] = [[function(unit, unitOwner)
        local maxPower = UnitPowerMax(unit)
        local power = UnitPower(unit)
        if( UnitIsDeadOrGhost(unit) ) then
            return string.format("0/%s", maxPower)
        elseif( maxPower <= 0 ) then
            return nil
        end
        
        return string.format("%s/%s", power, maxPower)
    end]],
    ["curmaxpp"] = [[function(unit, unitOwner)
        local maxPower = UnitPowerMax(unit)
        local power = UnitPower(unit)
        if( UnitIsDeadOrGhost(unit) ) then
            return string.format("0/%s", Icetip:FormatLargeNumber(maxPower))
        elseif( maxPower <= 0 ) then
            return nil
        end
        
        return string.format("%s/%s", Icetip:FormatLargeNumber(power), Icetip:FormatLargeNumber(maxPower))
    end]],
    ["smart:curmaxpp"] = [[function(unit, unitOwner)
        local maxPower = UnitPowerMax(unit)
        local power = UnitPower(unit)
        if( UnitIsDeadOrGhost(unit) ) then
            return string.format("0/%s", maxPower)
        elseif( maxPower <= 0 ) then
            return nil
        end
        
        return string.format("%s/%s", Icetip:SmartFormatNumber(power), Icetip:SmartFormatNumber(maxPower))
    end]],
    ["levelcolor"] = [[function(unit, unitOwner)
        local level = UnitLevel(unit)
        --if( level < 0 and UnitClassification(unit) == "worldboss" ) then
        --    return nil
        --end
        
	--if (level > 0) then
	--    if( UnitCanAttack("player", unit) or UnitCanAttack(unit, "player")) then
	--	local color = GetDiffLevelColor(level > 0 and level or 99);
	--	return color .. (level > 0 and level or "??") .. "|r"
	--    else
	--	return "|cff3377CC"..level.."|r
	--    end
	--end
    end]],
    ["faction"] = [[function(unit, unitOwner) return UnitFactionGroup(unitOwner) end]],
    ["level"] = [[function(unit, unitOwner)
        local level = UnitLevel(unit)
        return level > 0 and level or UnitClassification(unit) ~= "worldboss" and "??" or nil
    end]],
    ["maxhp"] = [[function(unit, unitOwner) return Icetip:FormatLargeNumber(UnitHealthMax(unit)) end]],
    ["maxpp"] = [[function(unit, unitOwner)
        local power = UnitPowerMax(unit)
        if( power <= 0 ) then
            return nil
        elseif( UnitIsDeadOrGhost(unit) ) then
            return 0
        end
        
        return Icetip:FormatLargeNumber(power)
    end]],
    ["missinghp"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end

        local missing = UnitHealthMax(unit) - UnitHealth(unit)
        if( missing <= 0 ) then return nil end
        return "-" .. Icetip:FormatLargeNumber(missing) 
    end]],
    ["missingpp"] = [[function(unit, unitOwner)
        local power = UnitPowerMax(unit)
        if( power <= 0 ) then
            return nil
        end

        local missing = power - UnitPower(unit)
        if( missing <= 0 ) then return nil end
        return "-" .. Icetip:FormatLargeNumber(missing)
    end]],
    ["def:name"] = [[function(unit, unitOwner)
        local deficit = Tags.tagFunc.missinghp(unit, unitOwner)
        if( deficit ) then return deficit end
        
        return Tags.tagFunc.name(unit, unitOwner)
    end]],
    ["name"] = [[function(unit, unitOwner) return UnitName(unitOwner) or UNKNOWN end]],
    ["server"] = [[function(unit, unitOwner)
        local server = select(2, UnitName(unitOwner))
        return server ~= "" and server or nil
    end]],
    ["perhp"] = [[function(unit, unitOwner)
        local max = UnitHealthMax(unit)
        if( max <= 0 or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) ) then
            return "0%"
        end
        
        return math.floor(UnitHealth(unit) / max * 100 + 0.5) .. "%"
    end]],
    ["perpp"] = [[function(unit, unitOwner)
        local maxPower = UnitPowerMax(unit)
        if( maxPower <= 0 ) then
            return nil
        elseif( UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) ) then
            return "0%"
        end
        
        return string.format("%d%%", math.floor(UnitPower(unit) / maxPower * 100 + 0.5))
    end]],
    ["plus"] = [[function(unit, unitOwner) local classif = UnitClassification(unit) return (classif == "elite" or classif == "rareelite") and "+" end]],
    ["race"] = [[function(unit, unitOwner) return UnitRace(unit) end]],
    ["rare"] = [[function(unit, unitOwner) local classif = UnitClassification(unit) return (classif == "rare" or classif == "rareelite") and Icetip.L["Rare"] end]],
    ["sex"] = [[function(unit, unitOwner) local sex = UnitSex(unit) return sex == 2 and L["Male"] or sex == 3 and L["Female"] end]],
    ["smartclass"] = [[function(unit, unitOwner) return UnitIsPlayer(unit) and Tags.tagFunc.class(unit) or Tags.tagFunc.creature(unit) end]],
    ["status"] = [[function(unit, unitOwner)
        if( UnitIsDead(unit) ) then
            return L["Dead"]
        elseif( UnitIsGhost(unit) ) then
            return L["Ghost"]
        elseif( not UnitIsConnected(unit) ) then
            return L["Offline"]
        end
    end]],
    ["cpoints"] = [[function(unit, unitOwner)
        local points = GetComboPoints(unit)
        if( points == 0 ) then
            points = GetComboPoints(unit, unit)
        end
        
        return points > 0 and points
    end]],
    ["smartlevel"] = [[function(unit, unitOwner)
        local classif = UnitClassification(unit)
        if( classif == "worldboss" ) then
            return L["Boss"]
        else
            local plus = Tags.tagFunc.plus(unit)
            local level = Tags.tagFunc.level(unit)
            if( plus ) then
                return level .. plus
            else
                return level
            end
        end
    end]],
    ["dechp"] = [[function(unit, unitOwner) return string.format("%.1f%%", (UnitHealth(unit) / UnitHealthMax(unit)) * 100) end]],
    ["classification"] = [[function(unit, unitOwner)
        local classif = UnitClassification(unit)
        if( classif == "rare" ) then
            return L["Rare"]
        elseif( classif == "rareelite" ) then
            return L["Rare Elite"]
        elseif( classif == "elite" ) then
            return L["Elite"]
        elseif( classif == "worldboss" ) then
            return L["Boss"]
        end
        
        return nil
    end]],
    ["shortclassification"] = [[function(unit, unitOwner)
        local classif = UnitClassification(unit)
        return classif == "rare" and "R" or classif == "rareelite" and "R+" or classif == "elite" and "+" or classif == "worldboss" and "B"
    end]],
    ["group"] = [[function(unit, unitOwner)
        if( GetNumGroupMembers() == 0 ) then return nil end
        local name, server = UnitName(unitOwner)
        if( server and server ~= "" ) then
            name = string.format("%s-%s", name, server)
        end
        
        for i=1, GetNumGroupMembers() do
            local raidName, _, group = GetRaidRosterInfo(i)
            if( raidName == name ) then
                return group
            end
        end
        
        return nil
    end]],
    ["druid:curpp"] = [[function(unit, unitOwner)
        if( select(2, UnitClass(unit)) ~= "DRUID" ) then return nil end
        local powerType = UnitPowerType(unit)
        if( powerType ~= 1 and powerType ~= 3 ) then return nil end
        return Icetip:FormatLargeNumber(UnitPower(unit, 0))
    end]],
    ["druid:abscurpp"] = [[function(unit, unitOwner)
        if( select(2, UnitClass(unit)) ~= "DRUID" ) then return nil end
        local powerType = UnitPowerType(unit)
        if( powerType ~= 1 and powerType ~= 3 ) then return nil end
        return UnitPower(unit, 0)
    end]],
    ["druid:curmaxpp"] = [[function(unit, unitOwner)
        if( select(2, UnitClass(unit)) ~= "DRUID" ) then return nil end
        local powerType = UnitPowerType(unit)
        if( powerType ~= 1 and powerType ~= 3 ) then return nil end
        
        local maxPower = UnitPowerMax(unit, 0)
        local power = UnitPower(unit, 0)
        if( UnitIsDeadOrGhost(unit) ) then
            return string.format("0/%s", Icetip:FormatLargeNumber(maxPower))
        elseif( maxPower == 0 and power == 0 ) then
            return nil
        end
        
        return string.format("%s/%s", Icetip:FormatLargeNumber(power), Icetip:FormatLargeNumber(maxPower))
    end]],
    ["druid:absolutepp"] = [[function(unit, unitOwner)
        if( select(2, UnitClass(unit)) ~= "DRUID" ) then return nil end
        local powerType = UnitPowerType(unit)
        if( powerType ~= 1 and powerType ~= 3 ) then return nil end
        return UnitPower(unit, 0)
    end]]
}

--
--Tags.defaultEvents = {
--    ["hp:color"]            = "UNIT_HEALTH UNIT_MAXHEALTH",
--    ["guild"]                = "UNIT_NAME_UPDATE",
--    ["abs:incheal"]            = "UNIT_HEAL_PREDICTION",
--    ["incheal:name"]        = "UNIT_HEAL_PREDICTION",
--    ["incheal"]                = "UNIT_HEAL_PREDICTION",
--    ["afk"]                    = "PLAYER_FLAGS_CHANGED",
--    ["afk:time"]            = "PLAYER_FLAGS_CHANGED UNIT_CONNECTION",
--    ["status:time"]            = "UNIT_POWER UNIT_CONNECTION",
--    ["pvp:time"]            = "PLAYER_FLAGS_CHANGED",
--    ["curhp"]               = "UNIT_HEALTH UNIT_CONNECTION",
--    ["abscurhp"]            = "UNIT_HEALTH UNIT_CONNECTION",
--    ["curmaxhp"]            = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION",
--    ["absolutehp"]            = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION",
--    ["smart:curmaxhp"]        = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION",
--    ["curpp"]               = "UNIT_POWER UNIT_DISPLAYPOWER",
--    ["abscurpp"]            = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER",
--    ["curmaxpp"]            = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER",
--    ["absolutepp"]            = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER",
--    ["smart:curmaxpp"]        = "UNIT_POWER UNIT_DISPLAYPOWER UNIT_MAXPOWER",
--    ["druid:curpp"]          = "UNIT_POWER UNIT_DISPLAYPOWER",
--    ["druid:abscurpp"]      = "UNIT_POWER UNIT_DISPLAYPOWER",
--    ["druid:curmaxpp"]        = "UNIT_POWER UNIT_MAXPOWER UNIT_DISPLAYPOWER",
--    ["druid:absolutepp"]    = "UNIT_POWER UNIT_MAXPOWER UNIT_DISPLAYPOWER",
--    ["level"]               = "UNIT_LEVEL PLAYER_LEVEL_UP",
--    ["levelcolor"]            = "UNIT_LEVEL PLAYER_LEVEL_UP",
--    ["maxhp"]               = "UNIT_MAXHEALTH",
--    ["def:name"]            = "UNIT_NAME_UPDATE UNIT_MAXHEALTH UNIT_HEALTH",
--    ["absmaxhp"]            = "UNIT_MAXHEALTH",
--    ["maxpp"]               = "UNIT_MAXPOWER",
--    ["absmaxpp"]            = "UNIT_MAXPOWER",
--    ["missinghp"]           = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION",
--    ["missingpp"]           = "UNIT_POWER UNIT_MAXPOWER",
--    ["name"]                = "UNIT_NAME_UPDATE",
--    ["abbrev:name"]            = "UNIT_NAME_UPDATE",
--    ["server"]                = "UNIT_NAME_UPDATE",
--    ["colorname"]            = "UNIT_NAME_UPDATE",
--    ["perhp"]               = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION",
--    ["perpp"]               = "UNIT_POWER UNIT_MAXPOWER UNIT_CONNECTION",
--    ["status"]              = "UNIT_HEALTH PLAYER_UPDATE_RESTING UNIT_CONNECTION",
--    ["smartlevel"]          = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED",
--    ["cpoints"]             = "UNIT_COMBO_POINTS PLAYER_TARGET_CHANGED",
--    ["rare"]                = "UNIT_CLASSIFICATION_CHANGED",
--    ["classification"]      = "UNIT_CLASSIFICATION_CHANGED",
--    ["shortclassification"] = "UNIT_CLASSIFICATION_CHANGED",
--    ["dechp"]                = "UNIT_HEALTH UNIT_MAXHEALTH",
--    ["group"]                = "RAID_ROSTER_UPDATE",
--    ["unit:color:aggro"]    = "UNIT_THREAT_SITUATION_UPDATE",
--    ["color:aggro"]            = "UNIT_THREAT_SITUATION_UPDATE",
--    ["situation"]            = "UNIT_THREAT_SITUATION_UPDATE",
--    ["color:sit"]            = "UNIT_THREAT_SITUATION_UPDATE",
--    ["scaled:threat"]        = "UNIT_THREAT_SITUATION_UPDATE",
--    ["general:sit"]            = "UNIT_THREAT_SITUATION_UPDATE",
--    ["unit:scaled:threat"]    = "UNIT_THREAT_SITUATION_UPDATE",
--    ["unit:color:sit"]        = "UNIT_THREAT_SITUATION_UPDATE",
--    ["unit:situation"]        = "UNIT_THREAT_SITUATION_UPDATE",
--}

--Tags.defaultFrequents = {
--	["afk"] = 1,
--	["afk:time"] = 1,
--	["status:time"] = 1,
--	["pvp:time"] = 1,
--	["scaled:threat"] = 1,
--	["unit:scaled:threat"] = 1,
--	["unit:raid:targeting"] = 0.50,
--	["unit:raid:assist"] = 0.50,
--}

--Tags.defaultCategories = {
--    ["hp:color"]            = "health",
--    ["abs:incheal"]            = "health",
--    ["incheal"]                = "health",
--    ["incheal:name"]        = "health",
--    ["smart:curmaxhp"]        = "health",
--    ["smart:curmaxpp"]        = "health",
--    ["afk"]                    = "status",
--    ["afk:time"]            = "status",
--    ["status:time"]            = "status",
--    ["pvp:time"]            = "status",
--    ["cpoints"]                = "misc",
--    ["smartlevel"]            = "classification",
--    ["classification"]        = "classification",
--    ["shortclassification"]    = "classification",
--    ["rare"]                = "classification",
--    ["plus"]                = "classification",
--    ["sex"]                    = "misc",
--    ["smartclass"]            = "classification",
--    ["smartrace"]            = "classification",
--    ["status"]                = "status",
--    ["race"]                = "classification",
--    ["level"]                = "classification",
--    ["maxhp"]                = "health",
--    ["maxpp"]                = "power",
--    ["missinghp"]            = "health",
--    ["missingpp"]            = "power",
--    ["name"]                = "misc",
--    ["abbrev:name"]            = "misc",
--    ["server"]                = "misc",
--    ["perhp"]                = "health",
--    ["perpp"]                = "power",
--    ["class"]                = "classification",
--    ["classcolor"]            = "classification",
--    ["creature"]            = "classification",
--    ["curhp"]                = "health",
--    ["curpp"]                = "power",
--    ["curmaxhp"]            = "health",
--    ["curmaxpp"]            = "power",
--    ["levelcolor"]            = "classification",
--    ["def:name"]            = "health",
--    ["faction"]                = "classification",
--    ["colorname"]            = "misc",
--    ["guild"]                = "misc",
--    ["absolutepp"]            = "power",
--    ["absolutehp"]            = "health",
--    ["absmaxhp"]            = "health",
--    ["abscurhp"]            = "health",
--    ["absmaxpp"]            = "power",
--    ["abscurpp"]            = "power",
--    ["reactcolor"]            = "classification",
--    ["dechp"]                = "health",
--    ["group"]                = "misc",
--    ["close"]                = "misc",
--    ["druid:curpp"]         = "power",
--    ["druid:abscurpp"]      = "power",
--    ["druid:curmaxpp"]        = "power",
--    ["druid:absolutepp"]    = "power",
--    ["situation"]            = "playerthreat",
--    ["color:sit"]            = "playerthreat",
--    ["scaled:threat"]        = "playerthreat",
--    ["general:sit"]            = "playerthreat",
--    ["color:aggro"]            = "playerthreat",
--    ["unit:scaled:threat"]    = "threat",
--    ["unit:color:sit"]        = "threat",
--    ["unit:situation"]        = "threat",
--    ["unit:color:aggro"]    = "threat",
--}

--Tags.defaultNames = {
--    ["unit:scaled:threat"]    = L["Unit scaled threat"],
--    ["unit:color:sit"]        = L["Unit colored situation"],
--    ["unit:situation"]        = L["Unit situation name"],
--    ["hp:color"]            = L["Health color"],
--    ["guild"]                = L["Guild name"],
--    ["abs:incheal"]            = L["Incoming heal (Absolute)"],
--    ["incheal"]                = L["Incoming heal (Short)"],
--    ["abbrev:name"]            = L["Name (Abbreviated)"],
--    ["smart:curmaxhp"]        = L["Cur/Max HP (Smart)"],
--    ["smart:curmaxpp"]        = L["Cur/Max PP (Smart)"],
--    ["pvp:time"]            = L["PVP timer"],
--    ["afk:time"]            = L["AFK timer"],
--    ["status:time"]            = L["Offline timer"],
--    ["afk"]                    = L["AFK status"],
--    ["cpoints"]                = L["Combo points"],
--    ["smartlevel"]            = L["Smart level"],
--    ["classification"]        = L["Classificaiton"],
--    ["shortclassification"]    = L["Short classification"],
--    ["rare"]                = L["Rare indicator"],
--    ["plus"]                = L["Short elite indicator"],
--    ["sex"]                    = L["Sex"],
--    ["smartclass"]            = L["Class (Smart)"],
--    ["smartrace"]            = L["Race (Smart)"],
--    ["status"]                = L["Status"],
--    ["race"]                = L["Race"],
--    ["level"]                = L["Level"],
--    ["maxhp"]                = L["Max HP (Short)"],
--    ["maxpp"]                = L["Max power (Short)"],
--    ["missinghp"]            = L["Missing HP (Short)"],
--    ["missingpp"]            = L["Missing power (Short)"],
--    ["name"]                = L["Unit name"],
--    ["server"]                = L["Unit server"],
--    ["perhp"]                = L["Percent HP"],
--    ["perpp"]                = L["Percent power"],
--    ["class"]                = L["Class"],
--    ["classcolor"]            = L["Class color tag"],
--    ["creature"]            = L["Creature type"],
--    ["curhp"]                = L["Current HP (Short)"],
--    ["curpp"]                = L["Current Power (Short)"],
--    ["curmaxhp"]            = L["Cur/Max HP (Short)"],
--    ["curmaxpp"]            = L["Cur/Max Power (Short)"],
--    ["levelcolor"]            = L["Level (Colored)"],
--    ["def:name"]            = L["Deficit/Unit Name"],
--    ["faction"]                = L["Unit faction"],
--    ["colorname"]            = L["Unit name (Class colored)"],
--    ["absolutepp"]            = L["Cur/Max power (Absolute)"],
--    ["absolutehp"]            = L["Cur/Max HP (Absolute)"],
--    ["absmaxhp"]            = L["Max HP (Absolute)"],
--    ["abscurhp"]            = L["Current HP (Absolute)"],
--    ["absmaxpp"]            = L["Max power (Absolute)"],
--    ["abscurpp"]            = L["Current power (Absolute)"],
--    ["reactcolor"]            = L["Reaction color tag"],
--    ["dechp"]                = L["Decimal percent HP"],
--    ["group"]                = L["Group number"],
--    ["close"]                = L["Close color"],
--    ["druid:curpp"]         = L["Current power (Druid)"],
--    ["druid:abscurpp"]      = L["Current power (Druid/Absolute)"],
--    ["druid:curmaxpp"]        = L["Cur/Max power (Druid)"],
--    ["druid:absolutepp"]    = L["Current health (Druid/Absolute)"],
--    ["situation"]            = L["Threat situation"],
--    ["color:sit"]            = L["Color code for situation"],
--    ["scaled:threat"]        = L["Scaled threat percent"],
--    ["general:sit"]            = L["General threat situation"],
--    ["color:aggro"]            = L["Color code on aggro"],
--    ["unit:color:aggro"]    = L["Unit color code on aggro"],
--}

--Tags.unitBlacklist = {
--    ["threat"]    = "%w+target",
--}

--Tags.unitRestriction = {
--    ["pvp:time"] = "player",    
--}
--
--local function loadAPIEvents()
--    if( Tags.APIEvents ) then return end
--    Tags.APIEvents = {
--        ["InCombatLockdown"]        = "PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED",
--        ["UnitLevel"]                = "UNIT_LEVEL",
--        ["UnitName"]                = "UNIT_NAME_UPDATE",
--        ["UnitClassification"]        = "UNIT_CLASSIFICATION_CHANGED",
--        ["UnitFactionGroup"]        = "UNIT_FACTION PLAYER_FLAGS_CHANGED",
--        ["UnitHealth%("]            = "UNIT_HEALTH",
--        ["UnitHealthMax"]            = "UNIT_MAXHEALTH",
--        ["UnitPower%("]                = "UNIT_POWER",
--        ["UnitPowerMax"]            = "UNIT_MAXPOWER",
--        ["UnitPowerType"]            = "UNIT_DISPLAYPOWER",
--        ["UnitIsDead"]                = "UNIT_HEALTH",
--        ["UnitIsGhost"]                = "UNIT_HEALTH",
--        ["UnitIsConnected"]            = "UNIT_HEALTH UNIT_CONNECTION",
--        ["UnitIsAFK"]                = "PLAYER_FLAGS_CHANGED",
--        ["UnitIsDND"]                = "PLAYER_FLAGS_CHANGED",
--        ["UnitIsPVP"]                = "PLAYER_FLAGS_CHANGED UNIT_FACTION",
--        ["UnitIsPartyLeader"]        = "PARTY_LEADER_CHANGED PARTY_MEMBERS_CHANGED",
--        ["UnitIsPVPFreeForAll"]        = "PLAYER_FLAGS_CHANGED UNIT_FACTION",
--        ["UnitCastingInfo"]            = "UNIT_SPELLCAST_START UNIT_SPELLCAST_STOP UNIT_SPELLCAST_FAILED UNIT_SPELLCAST_INTERRUPTED UNIT_SPELLCAST_DELAYED",
--        ["UnitChannelInfo"]            = "UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_CHANNEL_STOP UNIT_SPELLCAST_CHANNEL_INTERRUPTED UNIT_SPELLCAST_CHANNEL_UPDATE",
--        ["UnitAura"]                = "UNIT_AURA",
--        ["UnitBuff"]                = "UNIT_AURA",
--        ["UnitDebuff"]                = "UNIT_AURA",
--        ["UnitXPMax"]                = "UNIT_PET_EXPERIENCE PLAYER_XP_UPDATE PLAYER_LEVEL_UP",
--        ["UnitXP%("]                = "UNIT_PET_EXPERIENCE PLAYER_XP_UPDATE PLAYER_LEVEL_UP",
--        ["GetTotemInfo"]            = "PLAYER_TOTEM_UPDATE",
--        ["GetXPExhaustion"]            = "UPDATE_EXHAUSTION",
--        ["GetWatchedFactionInfo"]    = "UPDATE_FACTION",
--        ["GetRuneCooldown"]            = "RUNE_POWER_UPDATE",
--        ["GetRuneType"]                = "RUNE_TYPE_UPDATE",
--        ["GetRaidTargetIndex"]        = "RAID_TARGET_UPDATE",
--        ["GetComboPoints"]            = "UNIT_COMBO_POINTS",
--        ["GetNumPartyMembers"]        = "PARTY_MEMBERS_CHANGED",
--        ["GetNumRaidMembers"]        = "RAID_ROSTER_UPDATE",
--        ["GetRaidRosterInfo"]        = "RAID_ROSTER_UPDATE",
--        ["GetReadyCheckStatus"]        = "READY_CHECK READY_CHECK_CONFIRM READY_CHECK_FINISHED",
--        ["GetLootMethod"]            = "PARTY_LOOT_METHOD_CHANGED",
--        ["GetThreatStatusColor"]    = "UNIT_THREAT_SITUATION_UPDATE",
--        ["UnitThreatSituation"]        = "UNIT_THREAT_SITUATION_UPDATE",
--        ["UnitDetailedThreatSituation"] = "UNIT_THREAT_SITUATION_UPDATE",
--    }
--end
--
--local alreadyScanned = {}
--function Tags:IdentifyEvents(code, parentTag)
--    if( parentTag and alreadyScanned[parentTag] ) then
--        return ""
--    elseif( parentTag ) then
--        alreadyScanned[parentTag] = true
--    else
--        for k in pairs(alreadyScanned) do alreadyScanned[k] = nil end
--        loadAPIEvents()
--    end
--            
--    local eventList = ""
--    for func, events in pairs(self.APIEvents) do
--        if( string.match(code, func) ) then
--            eventList = eventList .. events .. " " 
--        end
--    end
--    
--    local currentStyle = Icetip.db.profile.currentStyle;
--    local currentStyleDB = Icetip:GetCurrentStyleDB(currentStyle);
--
--    for tag in string.gmatch(code, "tagFunc\.(%w+)%(") do
--        local code
--        if (Icetip.Tags.defaultTags[tag]) then
--            code =Icetip.Tags.defaultTags[tag]
--        elseif (currentStyleDB and currentStyleDB.tags[tag] and currentStyleDB.tags[tag].func) then
--            code = Icetip.Tags.defaultTags[tag];
--        elseif (Icetip.db.profile.tags[tag] and Icetip.db.profile.tags[tag].func) then
--            code = Icetip.db.profile.tags[tag].func
--        end
--        eventList = eventList .. " " .. self:IdentifyEvents(code, tag)
--    end
--    
--    -- Remove any duplicate events
--    if( not parentTag ) then
--        local tagEvents = {}
--        for event in string.gmatch(string.trim(eventList), "%S+") do
--            tagEvents[event] = true
--        end
--        
--        eventList = ""
--        for event in pairs(tagEvents) do
--            eventList = eventList .. event .. " "
--        end
--    end
--        
--    return string.trim(eventList or "")
--end

do
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

    if (not tagEnviroment) then
	tagEnviroment=setmetatable({
	    --add local variable for TagFunc
	    Icetip = Icetip,
	    L = L,
	    Tags = Tags,
	    GetDiffLevelColor = GetDiffLevelColor
	}, {
	    __index = _G,
	    __newindex = function(t, k, v) 
		_G[k] = v
	    end
	})
    end

    --setup tag cache
    Tags.tagFunc = setmetatable({}, {
	__index = function(t, key) 
	    if (not Tags.defaultTags[key]) then
		t[key] = false;
		return false;
	    end

	    local func, msg = loadstring("return "..(Tags.defaultTags[key] or ""));

	    if (func) then
		func = setfenv(func, tagEnviroment)();
	    elseif (msg) then
		error(msg, 1);
	    end

	    t[key] = func;
	    return t[key]
	end
    });
end
