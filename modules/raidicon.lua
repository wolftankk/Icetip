local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("raidicon", L["RaidTarget"]);
local db
local raidTargetIcon

local defaults = {
    profile = {
	position = "TOP",
	size = 20,
    }
}

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
    self:RegisterEvent("RAID_TARGET_UPDATE");
end

function mod:OnDisable()
    self:UnregisterAllEvents();
    if raidTargetIcon then
	raidTargetIcon:Hide()
    end
end

function mod:Update()
    if not raidTargetIcon then
        raidTargetIcon = GameTooltip:CreateTexture("Icetip_RaidTargetIcon_Icon", "ARTWORK");
        raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
        raidTargetIcon:Hide()
        raidTargetIcon:SetWidth(db.size)
        raidTargetIcon:SetHeight(db.size)
        self:Reposition()
    end

    if not GameTooltip:GetUnit() then
        raidTargetIcon:Hide()
        return
    end

    local _, unit = GameTooltip:GetUnit();
    if not UnitExists(unit) then
        return
    end
    

    local index = GetRaidTargetIndex(unit);

    if index then
        SetRaidTargetIconTexture(raidTargetIcon, index);
        raidTargetIcon:Show()
    else
        raidTargetIcon:Hide()
    end
end

function mod:OnTooltipShow()
    self:Update()
end

function mod:RAID_TARGET_UPDATE()
    self:Update()
end

function mod:Reposition()
    if not raidTargetIcon then return end
    raidTargetIcon:SetPoint("CENTER", GameTooltip, db.position)
end

function mod:SetPosition(value)
    db.position = value
    self:Reposition();
end

function mod:SetSize(value)
    db.size = value

    if raidTargetIcon then
        raidTargetIcon:SetWidth(value)
        raidTargetIcon:SetHeight(value)
    end
end

function mod:OnTooltipHide()
    if raidTargetIcon then
        raidTargetIcon:Hide()
    end
end

function mod:GetOptions()
    local options = {
	showPos = {
	    type = "select",
	    order = 1,
	    name = L["Position"],
	    desc = L["Position of the raid target icon."],
	    values = {
		    LEFT = L["Left"],
		    RIGHT = L["Right"],
		    TOP = L["Top"],
		    BOTTOM = L["Bottom"],
		    TOPLEFT = L["Top Left"],
		    TOPRIGHT = L["Top Right"],
		    BOTTOMLEFT = L["Bottom Left"],
		    BOTTOMRIGHT = L["Bottom Right"]
	    },
	    get = function() return db.position end,
	    set = function(_, v)
		self:SetPosition(v)
	    end
	},
	size = {
	    type = "range",
	    order = 2,
	    name = L["Size"],
	    desc = L["Size of the raid target icon."],
	    min = 5,
	    max = 50,
	    step = 1,
	    get = function() return db.size end,
	    set = function(_, v)
		self:SetSize(v)
	    end
	}
    }

    return options
end
