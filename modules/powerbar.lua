local _, Icetip = ...
local mod = Icetip:NewModule("powerbar");
local SM = LibStub("LibSharedMedia-3.0")
local format = string.format
local powerbar, pbtext;
local update;
local db

local Healthbar = Icetip:GetModule("healthbar", true);
local healthbar

local default = {
    profile = {
	texture = "Smooth",
	size = 5,
	position = "BOTTOM",
	showText = false,
	font = "Friz Quadrata TT",
	fontSize = 9,
	fontflag = "Outline",
	style = "number",
	short = true,
    }
}

function mod:OnEnable()
    self.db = mod:RegisterDB(default)
    db = self.db.profile
    self:CreateBar()
    self:SetBarPoint();
end

function mod:OnDisable()
    self:UnregisterAllEvents();
    if powerbar then
        powerbar:Hide();
        powerbar.side = nil;
    end
end

function mod:CreateBar()
    if not powerbar then
        powerbar = CreateFrame("StatusBar", nil, GameTooltip);
        powerbar:SetStatusBarTexture(SM:Fetch("statusbar", db.texture));
        powerbar:SetMinMaxValues(0, 1);

        pbtext = powerbar:CreateFontString(nil, "ARTWORK");
        pbtext:SetFont(SM:Fetch("font", db.font), db.fontSize, "Outline");
        pbtext:SetJustifyH("CENTER");
        pbtext:SetAllPoints(powerbar);
	powerbar.pbtext = pbtext

	self.powerbar = powerbar
    end
end

function mod:SetBarPoint()
    if not powerbar then return end

    local position = db.position
    powerbar:SetWidth(0)
    powerbar:SetHeight(0)
    powerbar:ClearAllPoints()
    powerbar.side = position

    if Healthbar then
	healthbar = Healthbar:GetBar();
    end

    if position == "BOTTOM" then
        if healthbar and healthbar.side == "BOTTOM" and db.showText then
            powerbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -(db.fontSize-5));
            powerbar:SetPoint("TOPRIGHT", healthbar, "BOTTOMRIGHT",0, -(db.fontSize-5));
        elseif healthbar and healthbar.side == "BOTTOM" then
            powerbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -2);
            powerbar:SetPoint("TOPRIGHT", healthbar, "BOTTOMRIGHT",0, -2);
        elseif healthbar and healthbar.side == "INNER" then
            powerbar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, -2);
            powerbar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT",0, -2);
        else
            powerbar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, 2);
            powerbar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, 2);
        end
        powerbar:SetHeight(db.size);
        powerbar:SetOrientation("HORIZONTAL");
    elseif position == "TOP" then
        powerbar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 2, 0);
        powerbar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -2, 0);
        powerbar:SetHeight(db.size);
        powerbar:SetOrientation("HORIZONTAL");
    elseif position == "INNER" then
        if healthbar and healthbar.side == "INNER" then
            powerbar:ClearAllPoints();
            powerbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -4);
            powerbar:SetPoint("TOPRIGHT", healthbar, "BOTTOMRIGHT",0, -4);
        else
            powerbar:ClearAllPoints();
            powerbar:SetParent(GameTooltip);
            powerbar:SetPoint("BOTTOMLEFT", 8 , 5);
            powerbar:SetPoint("BOTTOMRIGHT", -8, 5);
            powerbar:SetWidth(GameTooltip:GetWidth())
        end
        powerbar:SetHeight(db.size)
        powerbar:SetOrientation("HORIZONTAL");
    end
end


function mod:OnTooltipSetUnit()

    self:SetBarPoint();

    if not GameTooltip:GetUnit() then
        powerbar:Hide()
        return
    end

    powerbar:Show();

    powerbar.updateTooltip = TOOLTIP_UPDATE_TIME;
    update(powerbar, 0, true);
    powerbar:SetScript("OnUpdate", update)
end

function mod:GetBar()
    return self.powerbar
end

function mod:OnTooltipHide()
    if not powerbar then return end
    powerbar:Hide()
    powerbar:SetScript("OnUpdate", nil);
end

function update(frame, elapsed, force)
    local self = mod;
    if not powerbar then return end

    if (not force) then
        frame.updateTooltip = frame.updateTooltip - elapsed;
        if (frame.updateTooltip  > 0) then
            return;
        end
        frame.updateTooltip = TOOLTIP_UPDATE_TIME;
    end

    local unit = Icetip:GetMouseoverUnit();
    local powerType = UnitPowerType(unit);
    local maxpower = UnitPowerMax(unit);
    local power = UnitPower(unit);

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

    if db.showText then
        local pbtextformat;
        if db.style == "number" and maxpower > 0 then
            pbtextformat = format("%d / %d", power, maxpower);
        elseif db.style == "percent" and value > 0 then
            pbtextformat = format("%d %%", value * 100);
        elseif db.style == "pernumber" and maxpower > 0 then
            pbtextformat = format("%d / %d (%d%%)", power, maxpower, value * 100);
        end
        pbtext:SetText(pbtextformat)
        pbtext:Show();
    else
        pbtext:Hide()
    end
end
