local _, Icetip = ...

local mod = Icetip:NewModule("RaidTarget");
local db
local raidTargetIcon

function mod:OnEnable()
	self.db = self.db["raidtarget"];

	self:RegisterEvent("RAID_TARGET_UPDATE");
end

function mod:OnDisable()
	if raidTargetIcon then
		raidTargetIcon:Hide()
	end
end

function mod:Update()
	if not raidTargetIcon then
		raidTargetIcon = GameTooltip:CreateTexture("Icetip_RaidTargetIcon_Icon", "ARTWORK");
		raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
		raidTargetIcon:Hide()
		raidTargetIcon:SetWidth(self.db.size)
		raidTargetIcon:SetHeight(self.db.size)
		self:Reposition()
	end

	if not GameTooltip:GetUnit() then
		raidTargetIcon:Hide()
		return
	end

	if not UnitExists("mouseover") then
		return
	end

	local index = GetRaidTargetIndex("mouseover");

	if not self.db.enable then
		self:OnDisable();
	else
		if index then
			SetRaidTargetIconTexture(raidTargetIcon, index);
			raidTargetIcon:Show()
		else
			raidTargetIcon:Hide()
		end
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
	raidTargetIcon:SetPoint("CENTER", GameTooltip, self.db.position)
end

function mod:SetPosition(value)
	self.db.position = value
	self:Reposition();
end

function mod:SetSize(value)
	self.db.size = value

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