local _, Icetip = ...
local mod = Icetip:NewModule("healthbar");
local SM = LibStub("LibSharedMedia-3.0")
local format = string.format
local hbtext, healthbar
local update
local db

local Powerbar = Icetip:GetModule("Powerbar", true);
local powerbar
if Powerbar then
    powerbar = Powerbar:GetBar()
end

local default = {
    profile = {
	texture = "Smooth",
	size = 5,
	position = "BOTTOM",
	enable = true,
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
    self:SetBarPoint();
end

function mod:OnDisable()
    self:UnregisterAllEvents();
    if healthbar then
        healthbar:Hide()
        healthbar.side = nil;
    end
end

local function HealthGradient(precent)
    local r1, g1, b1
    local r2, g2, b2
    if precent <= 0.5 then
        precent = precent * 2
        r1, g1, b1 = 1, 0, 0
        r2, g2, b2 = 1, 1, 0
    else
        precent = precent * 2 - 1
        r1, g1, b1 = 1, 1, 0
        r2, g2, b2 = 0, 1, 0
    end

    return r1 +(r2-r1)*precent, g1 + (g2-g1)*precent,  b1 +(b2-b1)*precent
end

function mod:SetBarPoint()
    if not healthbar then return end

    local position = db.position
    healthbar:SetWidth(0);
    healthbar:SetHeight(0);
    healthbar:ClearAllPoints();
    healthbar.side = position
    if position == "BOTTOM" then
        healthbar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, -2);
        healthbar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, -2);
        healthbar:SetHeight(db.size);
        healthbar:SetOrientation("HORIZONTAL");
    elseif position == "TOP" then
        if powerbar and powerbar.side == "TOP" and db.showText then
            healthbar:SetPoint("BOTTOMLEFT", powerbar, "TOPLEFT", 0, db.fontSize-5);
            healthbar:SetPoint("BOTTOMRIGHT", powerbar, "TOPRIGHT", 0, db.fontSize-5);
        elseif powerbar and powerbar.side == "TOP" then
            healthbar:SetPoint("BOTTOMLEFT", powerbar, "TOPLEFT", 0, 2);
            healthbar:SetPoint("BOTTOMRIGHT", powerbar, "TOPRIGHT", 0, 2);
        else
            healthbar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 2, 0);
            healthbar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 2, 0);
        end
        healthbar:SetHeight(db.size);
        healthbar:SetOrientation("HORIZONTAL");
    elseif position == "INNER" then
        --display into the GameTooltip
        --healthbar:ClearAllPoints();
        --healthbar:SetParent(GameTooltip);
        --healthbar:SetPoint("BOTTOMLEFT", 8 , 5);
        --healthbar:SetPoint("BOTTOMRIGHT", -8, 5);
        --healthbar:SetWidth(GameTooltip:GetWidth())
        --healthbar:SetHeight(db.size)
        --healthbar:SetOrientation("HORIZONTAL");
    end
end

function mod:GetBar()
    return self.healthbar
end

function mod:OnTooltipSetUnit()
    if not healthbar then
        healthbar = CreateFrame("StatusBar", nil, GameTooltip);
        healthbar:SetStatusBarTexture(SM:Fetch("statusbar", db.texture));
        healthbar:SetMinMaxValues(0, 1);
        hbtext = healthbar:CreateFontString(nil, "ARTWORK");
	healthbar.text = hbtext;

        hbtext:SetFont(SM:Fetch("font", db.font), db.fontSize, "Outline");
        hbtext:SetJustifyH("CENTER");
        hbtext:SetAllPoints(healthbar);

	self.healthbar = healthbar;
    end

    self:SetBarPoint();

    if not GameTooltip:GetUnit() then
        healthbar:Hide()
        return
    end

    healthbar:Show();
    healthbar.updateTooltip = TOOLTIP_UPDATE_TIME;
    update(healthbar, 0, true)
    healthbar:SetScript("OnUpdate", update);
end

function mod:OnTooltipHide()
    if not healthbar then return end
    healthbar:Hide();
    healthbar:SetScript("OnUpdate", nil);
end

function update(frame, elapsed, force)
    local self = mod;
    if not healthbar then return end
    
    if (not force) then
        frame.updateTooltip = frame.updateTooltip - elapsed;
        if (frame.updateTooltip  > 0) then
            return;
        end
        frame.updateTooltip = TOOLTIP_UPDATE_TIME;
    end

    local hpmax = UnitHealthMax(Icetip:GetMouseoverUnit());
    local hp = UnitHealth(Icetip:GetMouseoverUnit());

    if (hp == hpmax and not force) then
        return;
    end

    local value;
    if hpmax == 0 then
        value = 0
    else
        value = hp/hpmax
    end
    healthbar:SetValue(value);
    healthbar:SetStatusBarColor(HealthGradient(value))

    if db.showText then
        local hbtextformat;
        if db.style == "number" then
            hbtextformat = format("%d / %d", hp, hpmax);
        elseif db.style == "percent" then
            hbtextformat = format("%d %%", value * 100);
        elseif db.style == "pernumber" then
            hbtextformat = format("%d / %d (%d%%)", hp, hpmax, value * 100);
        end
        hbtext:SetText(hbtextformat)
        hbtext:Show();
    else
        hbtext:Hide()
    end
end
