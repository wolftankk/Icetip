--[[
-- Icetip Module: class
-- Display Class button / color tooltip border by class
--]]

local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("Class", L["Class"]);

local defaults = {
    profile = {
	displayMode = "border", --options: border / icon
	iconPosition = "LEFT", -- options: where the icon display?   LEFT / RIGHT
	iconSize = 32
    }
}
local db;

function mod:OnInitialize()
    self.db = mod:RegisterDB(default)
    db = self.db.profile
end

function mod:OnEnable()
    if db.displayMode == "icon" then
	--create icon
    end
end

function mod:OnDisable()

end

--hook event, PreTooltipSetUnit
function mod:PreTooltipSetUnit(tooltip, ...)
    local unit = tooltip:GetUnit();
    if unit then
	if db.displayMode == "icon" then
	    --set position
	end
    end
end

--hook event, OnTooltipHide()
function mod:OnTooltipHide()
    if self.icon then
	self.icon:Hide();
    end
end

--add options to Icetip's options panel
function mod:GetOptions()
    local options = {

    }

    return options;
end
