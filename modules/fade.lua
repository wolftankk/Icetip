local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("fade", L["Fadeout"],true);
local db
local defaults = {
    profile = {
        units = "hide",
        objects ="fade",
        unitFrames = "fade",
        otherFrames = "hide",
    },
}

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile;
end

function mod:OnEnable()
    self:RawHook(GameTooltip, "FadeOut", "GameTooltip_FadeOut", true);
    self:RawHook(GameTooltip, "Hide", "GameTooltip_Hide", true);
    self:RegisterEvent("CURSOR_UPDATE");
end

function mod:OnDisable()
    self:UnregisterAllEvents()
    self:UnhookAll();
end

function mod:GameTooltip_Hide(tooltip, ...)
    if tooltip.justHide then
        return self.hooks[tooltip].Hide(tooltip, ...)
    end
    local kind
    if GameTooltip:GetUnit() then
        if GameTooltip:IsOwned(UIParent) then
            kind = db.units
        else
            kind = db.unitFrames
        end
    else
        if GameTooltip:IsOwned(UIParent) then
            kind = db.objects
        else
            kind = db.otherFrames
        end
    end

    if kind == "fade" then
        return GameTooltip:FadeOut()
    else
        return self.hooks[tooltip].Hide(tooltip, ...)
    end
end

function mod:GameTooltip_FadeOut(tooltip, ...)
    self.hooks[tooltip].FadeOut(tooltip, ...)
    local kind

    if GameTooltip:GetUnit() then
        if GameTooltip:IsOwned(UIParent) then
            kind = db.units
        else
            kind = db.unitFrames
        end
    else
        if GameTooltip:IsOwned(UIParent) then
            kind = db.objects
        else
            kind = db.otherFrames
        end
    end

    if kind == "fade" then
        self.hooks[tooltip].FadeOut(tooltip, ...)
    else
        GameTooltip:Hide()
    end
end

local lastMouseoverUnit
local function checkUnitExistance()
    local mouseover_unit = Icetip:GetMouseoverUnit()
    if not GameTooltip:GetUnit() or not UnitExists(mouseover_unit) or (lastMouseoverUnit == "mouseover" and mouseover_unit ~= "mouseover") then
        Icetip:CancelTimer(Icetip_Fade_checkUnitExistance, true)
        local kind
        if GameTooltip:IsOwned(UIParent) then
            kind = db.units
        else
            kind = db.unitFrames
        end
        if kind == "fade" then
            GameTooltip:FadeOut()
        else
            GameTooltip:Hide()
        end
    end
end

local function checkAlphaFrame()
    if GameTooltip:GetAlpha() < 1 then
        Icetip:CancelTimer(Icetip_Fade_checkUnitExistance, true)
        local kind
        if GameTooltip:IsOwned(UIParent) then
            kind = db.objects
        else
            kind = db.otherFrames
        end

        if kind == "fade" then
            GameTooltip:FadeOut()
        else
            GameTooltip:Hide()
        end
    end
end

local cursorChangedWithTooltip = false
function mod:OnTooltipShow()
    Icetip:CancelTimer(Icetip_Fade_runHide, true)
    if GameTooltip:GetUnit() then
        if not Icetip_Fade_checkUnitExistance then
            Icetip_Fade_checkUnitExistance = Icetip:ScheduleRepeatingTimer(checkUnitExistance, 0)
        end
    else
        if GameTooltip:IsOwned(UIParent) then
            cursorChangedWithTooltip = true
        end
        if not Icetip_Fade_checkUnitExistance then
            Icetip_Fade_checkUnitExistance = Icetip:ScheduleRepeatingTimer(checkAlphaFrame, 0)
        end
    end
end

function mod:OnTooltipHide()
    cursorChangedWithTooltip = false
    Icetip:CancelTimer(Icetip_Fade_checkUnitExistance, true)
    Icetip_Fade_checkUnitExistance = nil;
end

function mod:OnTooltipSetUnit()
    lastMouseoverUnit = Icetip:GetMouseoverUnit()
end

local function runHide()
    if db.objects == "fade" then
        GameTooltip:FadeOut()
    else
        GameTooltip:Hide()
    end
end

local function donothing() end
function mod:CURSOR_UPDATE(...)
    --reset
    Icetip:CancelTimer(Icetip_Fade_runHide, true);
    Icetip:CancelTimer(Icetip_Fade_doNothing, true);
    if cursorChangedWithTooltip then
        Icetip_Fade_runHide = Icetip:ScheduleTimer(runHide, 0)
    else
        Icetip_Fade_doNothing = Icetip:ScheduleTimer(donothing, 0)
    end
end


local hidetype = {
    ["hide"] = L["Hide"],
    ["fade"] = L["Fadeout"],
}
function mod:GetOptions()
    local options = {
	unit = {
	    type = "select",
	    order = 1,
	    name = L["World units"],
	    desc = L["What kind of fade to use for world units (other players, NPC in the world, etc.)"],
	    values = hidetype,
	    get = function() return db.units end,
	    set = function(_, v)
		db.units = v
	    end,
	},
	objframe = {
	    type = "select",
	    order = 2,
	    name = L["World objects"],
	    desc = L["What kind of fade to use for world objects (mailbox, corpse, etc.)"],
	    values = hidetype,
	    get = function() return db.objects end,
	    set = function(_, v)
		db.objects = v
	    end,
	},
	unitframe = {
	    type = "select",
	    order = 3,
	    name = L["Unit frames"],
	    desc = L["What kind of fade to use for unit frames (myself, target, party member, etc.)"],
	    values = hidetype,
	    get = function() return db.unitFrames end,
	    set = function(_, v)
		db.unitFrames = v
	    end,
	},
	otherframe = {
	    type = "select",
	    order = 4,
	    name = L["Non-unit frames"],
	    desc = L["What kind of fade to use for non-unit frames (spells, items, etc.)"],
	    values = hidetype,
	    get = function() return db.otherFrames end,
	    set = function(_, v)
		db.otherFrames = v
	    end,
	}
    }

    return options
end
