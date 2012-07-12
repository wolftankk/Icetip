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
    self.db = mod:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
    if db.displayMode == "icon" then
	if not self.icon then
	    self:createIcon();
	end
    end
end

function mod:OnDisable()

end

function mod:createIcon()
    if not self.icon then
	self.icon = CreateFrame("Frame", nil, GameTooltip);
	self.icon:SetSize(db.iconSize, db.iconSize);
	self.icon.icon = self.icon:CreateTexture();
	self.icon.icon:SetAllPoints();
	self.icon.icon:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]]);
	self.icon:ClearAllPoints();
	if db.iconPosition == "LEFT" then
	    self.icon:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", -5, 0);
	elseif db.iconPosition == "RIGHT" then
	    self.icon:SetPoint("TOPLEFT", tooltip, "TOPRIGHT", 5, 0);
	end
    end
end

--hook event, PreTooltipSetUnit
function mod:PreTooltipSetUnit(tooltip, ...)
    local _, unit = tooltip:GetUnit();
    local _, cls, classid = UnitClass(unit)
    local isPlayer = UnitIsPlayer(unit);
    if unit and cls and isPlayer then
	if db.displayMode == "icon" then
	    local coords = CLASS_ICON_TCOORDS[cls];
	    self.icon.icon:SetTexCoord(coords[1] , coords[2] , coords[3] , coords[4] );
	    self.icon:Show();
	elseif db.displayMode == "border" then
	    local color = RAID_CLASS_COLORS[cls];
	    tooltip:SetBackdropBorderColor(color.r, color.g, color.b)
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
	displayMode = {
	    type = "select",
	    width = "full",
	    order = 1,
	    name = L["Display Mode"],
	    desc = L["What kind of display class for target"],
	    values = {
		["icon"] = L["icon"],
		["border"] = L["border"]
	    },
	    get = function() return db.displayMode end,
	    set = function(_, v)
		db.displayMode = v;
		if db.displayMode == "icon" and not self.icon then
		    self:createIcon();
		end
	    end,
	},
	iconPosition = {
	    type = "select",
	    order = 2,
	    name = L["Position"],
	    desc = L["Icon position"],
	    values = {
		["LEFT"] = L["Left"],
		["RIGHT"] = L["Right"]
	    },
	    hidden = function() return db.displayMode ~= "icon" end,
	    get = function() return db.iconPosition end,
	    set = function(_, v)
		db.iconPosition = v;
		self.icon:ClearAllPoints();
		if db.iconPosition == "LEFT" then
		    self.icon:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", -5, 0);
		elseif db.iconPosition == "RIGHT" then
		    self.icon:SetPoint("TOPLEFT", tooltip, "TOPRIGHT", 5, 0);
		end
	    end,
	},
	iconSize = {
	    type = "range",
	    min = 16,
	    max = 64,
	    step = 2,
	    name = L["Size"],
	    desc = L["Icon size"],
	    hidden = function() return db.displayMode ~= "icon" end,
	    get = function() return db.iconSize end,
	    set = function(_, v)
		db.iconSize = v;
		self.icon:SetSize(db.iconSize, db.iconSize);
	    end,
	}
    }

    return options;
end
