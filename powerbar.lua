assert(Icetip, "can't find Icetip!");

local mod = Icetip:NewModule("PowerBar");
local db
local SM = LibStub("LibSharedMedia-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Icetip")
local format = string.format
local powerbar, pbtext;

function mod:OnEnable(event, unit)
	local db = self.db["powerbar"];
	self.db = db

	self:RegisterEvent("UNIT_MANA", "UNIT_MANA");
	self:RegisterEvent("UNIT_RAGE", "UNIT_MANA");
	self:RegisterEvent("UNIT_FOCUS", "UNIT_MANA");
	self:RegisterEvent("UNIT_ENERGY", "UNIT_MANA");
	self:RegisterEvent("UNIT_HAPPINESS", "UNIT_MANA");
	self:RegisterEvent("UNIT_RUNIC_POWER", "UNIT_MANA");
	self:RegisterEvent("UNIT_MAXMANA", "UNIT_MANA");
	self:RegisterEvent("UNIT_MAXRAGE", "UNIT_MANA");
	self:RegisterEvent("UNIT_MAXFOCUS", "UNIT_MANA");
	self:RegisterEvent("UNIT_MAXENERGY", "UNIT_MANA");
	self:RegisterEvent("UNIT_MAXHAPPINESS", "UNIT_MANA");
	self:RegisterEvent("UNIT_MAXRUNIC_POWER", "UNIT_MANA");
	self:RegisterEvent("UNIT_DISPLAYPOWER", "UNIT_MANA");

	self:SetBarPoint();

	self:TogglePowerbar(self.db.enable)
end

function mod:UNIT_MANA(unit)
	if not UnitIsUnit(unit, "mouseover") then
		return
	end
	self:Update()
end

function mod:SetUnit()
	self:TogglePowerbar(self.db.enable)
end

function mod:SetBarPoint()
	if not powerbar then return end
	
	local position = self.db.position
	powerbar:SetWidth(0)
	powerbar:SetHeight(0)
	powerbar:ClearAllPoints()
	powerbar.side = position
	local healthbar = _G.Icetip_Health_Bar
        if position == "BOTTOM" then
		if healthbar and healthbar.side == "BOTTOM" and self.db.showText then
			powerbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -(self.db.fontSize-5));
			powerbar:SetPoint("TOPRIGHT", healthbar, "BOTTOMRIGHT",0, -(self.db.fontSize-5));
		elseif healthbar and healthbar.side == "BOTTOM" then
			powerbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -2);
			powerbar:SetPoint("TOPRIGHT", healthbar, "BOTTOMRIGHT",0, -2);
		else
			powerbar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 4, 0);
			powerbar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -4, 0);
		end
		powerbar:SetHeight(self.db.size);
		powerbar:SetOrientation("HORIZONTAL");
	elseif position == "TOP" then
		powerbar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 4, 0);
		powerbar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -4, 0);
		powerbar:SetHeight(self.db.size);
		powerbar:SetOrientation("HORIZONTAL");
	end
end

function mod:OnTooltipShow()
	if not powerbar then
		powerbar = CreateFrame("StatusBar", "Icetip_Power_Bar", GameTooltip);
		powerbar:SetStatusBarTexture(SM:Fetch("statusbar", self.db.texture));
		powerbar:SetMinMaxValues(0, 1);

		pbtext = powerbar:CreateFontString("Icetip_Power_BarText", "ARTWORK");
		pbtext:SetFont(SM:Fetch("font", self.db.font), self.db.fontSize, "Outline");
		pbtext:SetJustifyH("CENTER");
		pbtext:SetAllPoints(powerbar);

		--self:SetBarPoint()
	end

        self:SetBarPoint();
        
	if not GameTooltip:GetUnit() then
		powerbar:Hide()
		return
	end

	self:TogglePowerbar(self.db.enable)
	self:Update()
end

function mod:OnTooltipHide()
	if not powerbar then return end
	powerbar:Hide()
end

function mod:Update()
	if not powerbar then return end

	local powerType = UnitPowerType("mouseover");
	local maxpower = UnitPowerMax("mouseover");
	local power = UnitPower("mouseover");

	local value;
	if maxpower == 0 then
		value = 0
	else
		value = power/maxpower
	end
	powerbar:SetValue(value)

	if powerType == 0 then
		--mana
		powerbar:SetStatusBarColor(48/255, 113/255, 191/255);
	elseif powerType == 1 then
		--rage
		powerbar:SetStatusBarColor(226/255, 45/255, 75/255);
	elseif powerType == 2 then
		--focus
		powerbar:SetStatusBarColor(255/255, 210/255, 0);
	elseif powerType == 3 then
		--energy
		powerbar:SetStatusBarColor(1, 220/255, 25/255);
	elseif powerType == 4 then
		--happniess
		powerbar:SetStatusBarColor(0, 1, 1);
	elseif powerType == 6 then
		--runic power
		powerbar:SetStatusBarColor(0, 0.82, 1)
	end

	if self.db.showText then
		local pbtextformat;
		if self.db.style == "number" and maxpower > 0 then
			pbtextformat = format("%d/%d", power, maxpower);
		elseif self.db.style == "percent" and value > 0 then
			pbtextformat = format("%d %%", value * 100);
		elseif self.db.style == "pernumber" and maxpower > 0 then
			pbtextformat = format("%d/%d (%d%%)", power, maxpower, value * 100);
		end
		pbtext:SetText(pbtextformat)
		pbtext:Show();
	else
		pbtext:Hide()
	end
end

function mod:TogglePowerbar(flag)
	if flag then
		self:Update()
		if powerbar then
			powerbar:Show()
		end
	else
		if powerbar then
			powerbar:Hide()
		end
	end
end
