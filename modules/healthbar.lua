local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("healthbar", L["HealthBar"]);
local SM = LibStub("LibSharedMedia-3.0")
local format = string.format
local hbtext, healthbar
local update
local db

local PBModule = Icetip:GetModule("Powerbar", true);
local powerbar

local defaults = {
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

function mod:OnInitialize()
    self.db = mod:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
    self:CreateBar();
    self:SetBarPoint();
end

function mod:OnDisable()
    self:UnregisterAllEvents();
    if healthbar then
        healthbar:Hide()
        healthbar.side = nil;
    end
end

function mod:CreateBar()
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
end

function mod:SetBarPoint()
    if not healthbar then return end

    local position = db.position
    healthbar:SetWidth(0);
    healthbar:SetHeight(0);
    healthbar:ClearAllPoints();
    healthbar.side = position
    
    if PBModule then
	powerbar = PBModule:GetBar()
    end

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
        healthbar:ClearAllPoints();
        healthbar:SetParent(GameTooltip);
        healthbar:SetPoint("BOTTOMLEFT", 8 , 8);
        healthbar:SetPoint("BOTTOMRIGHT", -8, 8);
        healthbar:SetWidth(GameTooltip:GetWidth())
        healthbar:SetHeight(db.size)
        healthbar:SetOrientation("HORIZONTAL");
    end
end

function mod:GetBar()
    return self.healthbar
end


function mod:OnTooltipSetUnit()
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
    healthbar:SetStatusBarColor(Icetip:GetGradientColor(Icetip:GetMouseoverUnit()))

    if db.showText then
        local hbtextformat;
        if db.style == "number" then
            hbtextformat = format("%d / %d", hp, hpmax);
        elseif db.style == "percent" then
            hbtextformat = format("%d %%", value * 100);
        elseif db.style == "pernumber" then
            hbtextformat = format("%d / %d (%d%%)", hp, hpmax, value * 100);
	elseif db.style == "short" then
	    hbtextformat = format("%s / %s", Icetip:FormatLargeNumber(hp), Icetip:FormatLargeNumber(hpmax));
	elseif db.style == "pershort" then
	    hbtextformat = format("%s / %s (%d%%)", Icetip:FormatLargeNumber(hp), Icetip:FormatLargeNumber(hpmax), value * 100);
        end
        hbtext:SetText(hbtextformat)
        hbtext:Show();
    else
        hbtext:Hide()
    end
end

function mod:OnTooltipShow()
    local min, max = GameTooltipStatusBar:GetMinMaxValues();
    local value = GameTooltipStatusBar:GetValue();
    if not self.healthbar then return end

    if min == 0 and max == 1 and value <= 1 and GameTooltipStatusBar:IsShown() then
	healthbar:SetMinMaxValues(min, max)
	healthbar:SetValue(value)

	healthbar:SetStatusBarColor(Icetip:GetGradientColor(value));

	healthbar:Show();
	if db.showText then
	    hbtext:Hide()
	end
    end
end

function mod:PostTooltipShow(tooltip, ...)
    if tooltip == GameTooltip and db.position == "INNER" and tooltip:GetUnit() then
        healthbar:ClearAllPoints();
        healthbar:SetParent(GameTooltip);
        healthbar:SetPoint("BOTTOMLEFT", 8 , 8);
        healthbar:SetPoint("BOTTOMRIGHT", -8, 8);
        healthbar:SetWidth(GameTooltip:GetWidth())
        healthbar:SetHeight(db.size)
        healthbar:SetOrientation("HORIZONTAL");
	if not tooltip._offset then
	    tooltip._offset = db.size + tooltip:GetHeight()
	else
	    if tooltip._offset < tooltip:GetHeight() then
		tooltip._offset = tooltip:GetHeight() + db.size
	    end
	end
    end

    return true
end

local barPosition = {
    ["TOP"] = L["Tooltip top"],
    ["BOTTOM"] = L["Tooltip bottom"],
    ["INNER"] = L["Tooltip inner"]
    --["LEFT"] = L["Tooltip Left"],
    --["RIGHT"] = L["Tooltip Right"],
}

local bartextStyle = {
    ["number"] = L["Number"],
    ["short"]  = L["Smarty"],
    ["percent"] = L["Percent"],
    ["pernumber"] = L["Number(precent)"],
    ["pershort"] = L["Smarty(precent)"]
}
function mod:GetOptions()
    local options = {
	texture = {
	    type = "select",
	    order = 1,
	    name = L["Texture"],
	    desc = L["The texture which the health bar uses."],
	    disabled = function() return not mod:IsEnabled() end,
	    dialogControl = "LSM30_Statusbar",
	    values = AceGUIWidgetLSMlists.statusbar,
	    get = function() return db.texture end,
	    set = function(_, v)
	        db.texture = v
	        healthbar:SetStatusBarTexture(SM:Fetch("statusbar", v));
	    end
	},
	size = {
	    type = "range",
	    order = 2,
	    name = L["Size"],
	    desc = L["The size of the health bar"],
	    disabled = function() return not mod:IsEnabled() end,
	    min = 1,
	    max = 20,
	    step = 1,
	    get = function() return db.size end,
	    set = function(_, v)
	        db.size = v
	        healthbar:SetHeight(tonumber(v));
	    end,
	},
	position = {
	    type = "select",
	    order = 3,
	    name = L["Position"],
	    desc = L["The position of the health bar relative to the tooltip."],
	    disabled = function() return not mod:IsEnabled() end,
	    values = barPosition,
	    get = function() return db.position end,
	    set = function(_, v) 
	        db.position = v
	        self:SetBarPoint()
	    end,
	},
	showhbtext = {
	    type = "toggle",
	    order = 4,
	    width = "full",
	    name = L["Health bar text"],
	    desc = L["Toggle show the status text on the health bar."],
	    disabled = function() return not mod:IsEnabled() end,
	    get = function() return db.showText end,
	    set = function(_, v)
	        db.showText = v
	    end
	},
	hbfont = {
	    type = "select",
	    order = 5,
	    name = L["Font"],
	    desc = L["What font face to use."],
	    disabled = function() return not mod:IsEnabled() end,
	    hidden = function() return not db.showText end,
	    dialogControl = "LSM30_Font",
	    values = AceGUIWidgetLSMlists.font,
	    get = function() return db.font end,
	    set = function(_, v)
	        db.font = v
	        hbtext:SetFont(SM:Fetch("font", v), db.fontSize, "Outline");
	    end
	},
	hbfontsize = {
	    type = "range",
	    order = 6,
	    name = L["Font size"],
	    desc = L["Change what size is the font."],
	    disabled = function() return not mod:IsEnabled() end,
	    hidden = function() return not db.showText end,
	    min = 8,
	    max = 16,
	    step = 1,
	    get = function() return db.fontSize end,
	    set = function(_, v)
	        db.fontSize = v
	        hbtext:SetFont(SM:Fetch("font", v), db.fontSize, "Outline");
	    end,
	},
	hbtextstyle = {
	    type = "select",
	    order = 7,
	    name = L["Text format"],
	    desc = L["Format health value"],
	    disabled = function() return not mod:IsEnabled() end,
	    hidden = function() return not db.showText end,
	    values = bartextStyle,
	    get = function() return db.style end,
	    set = function(_, v)
	        db.style = v
	    end
	}
    }
    return options
end
