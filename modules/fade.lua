local addonName, Icetip = ...
local mod = Icetip:NewModule("Fade", true);

function mod:OnEnable()
    self:RawHook(GameTooltip, "FadeOut", "GameTooltip_FadeOut", true);
    self:RawHook(GameTooltip, "Hide", "GameTooltip_Hide", true);
    self:RegisterEvent("CURSOR_UPDATE");
end

function mod:GameTooltip_Hide(tooltip, ...)
    local db = self.db["tooltipFade"]
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
    local db = self.db["tooltipFade"];

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
        local db = mod.db["tooltipFade"]
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
        local db = mod.db["tooltipFade"]
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
    local db = mod.db["tooltipFade"]
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
