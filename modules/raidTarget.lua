local _, Icetip = ...
local mod = Icetip:NewModule("raidtarget");
local db
local raidTargetIcon

local defaults = {
    profile = {
	position = "TOP",
	size = 20,
    }
}

function mod:OnEnable()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
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
