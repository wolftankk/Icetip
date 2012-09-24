local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("powerbar", L["PowerBar"]);
local SM = LibStub("LibSharedMedia-3.0")
local format = string.format
local powerbar, pbtext;
local update;
local db

local HBModule = Icetip:GetModule("healthbar", true);
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

function mod:OnInitialize()
    self.db = mod:RegisterDB(default)
    db = self.db.profile
end

function mod:OnEnable()
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

    if HBModule then
	healthbar = HBModule:GetBar();
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
            powerbar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, -2);
            powerbar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, -2);
        end
        powerbar:SetHeight(db.size);
        powerbar:SetOrientation("HORIZONTAL");
    elseif position == "TOP" then
        powerbar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 2, 0);
        powerbar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -2, 0);
        powerbar:SetHeight(db.size);
        powerbar:SetOrientation("HORIZONTAL");
    elseif position == "INNER" and powerbar.hasPower then
        if healthbar and healthbar.side == "INNER" then
            powerbar:ClearAllPoints();
            powerbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -4);
            powerbar:SetPoint("TOPRIGHT", healthbar, "BOTTOMRIGHT",0, -4);
	    powerbar:Hide();
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
    powerbar.hasPower = nil
end

function mod:PostTooltipShow(tooltip, ...)
    if tooltip == GameTooltip and db.position == "INNER" and tooltip:GetUnit() then
	if HBModule then
	    healthbar = HBModule:GetBar();
	end

	if not powerbar.hasPower and healthbar and healthbar.side == "INNER" then 
	    if (tooltip._offset) then
		tooltip._offset = tooltip._origin_offset + healthbar:GetHeight() + 5
	    end
	    return 
	end

	if (tooltip._offset == tooltip:GetHeight()) then
	    return
	end

	if healthbar and healthbar.side == "INNER" then
	    if tooltip._offset then
	        tooltip._offset = tooltip._origin_offset + db.size + healthbar:GetHeight() + 5
	    end
	    healthbar:SetPoint("BOTTOMLEFT", 8 , 8 + db.size )
	    healthbar:SetPoint("BOTTOMRIGHT", -8, 8 + db.size )
	else
	    powerbar:ClearAllPoints();
	    powerbar:SetParent(GameTooltip);
	    powerbar:SetPoint("BOTTOMLEFT", 8 , 8);
	    powerbar:SetPoint("BOTTOMRIGHT", -8, 8);
	    powerbar:SetWidth(GameTooltip:GetWidth())
	    powerbar:SetHeight(db.size)
	    powerbar:SetOrientation("HORIZONTAL");
	    if not tooltip._offset then
		tooltip._offset = db.size + tooltip:GetHeight()
	    else
		if tooltip._offset < tooltip:GetHeight() then
		    tooltip._offset = tooltip:GetHeight() + db.size
		end
	    end
	end
	powerbar:SetHeight(db.size)
	powerbar:SetOrientation("HORIZONTAL");
	powerbar:Show();
    end
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
    
    --rage / runic power
    powerbar.hasPower = false
    if (powerType == 1 or powerType == 6) and power <= 0 then
	powerbar.hasPower = false
    else
	powerbar.hasPower = true
    end

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
	elseif db.style == "short" then
	    pbtextformat = format("%s / %s", Icetip:FormatLargeNumber(power), Icetip:FormatLargeNumber(maxpower));
	elseif db.style == "pershort" then
	    pbtextformat = format("%s / %s (%d%%)", Icetip:FormatLargeNumber(power), Icetip:FormatLargeNumber(maxpower), value * 100);
        end
        pbtext:SetText(pbtextformat)
        pbtext:Show();
    else
        pbtext:Hide()
    end

    self:PostTooltipShow(GameTooltip)
    powerbar:Show()
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
	    desc = L["The texture which the power bar uses."],
	    dialogControl = "LSM30_Statusbar",
	    values = AceGUIWidgetLSMlists.statusbar,
	    get = function() return db.texture end,
	    set = function(_, v)
		db.texture = v
		powerbar:SetStatusBarTexture(SM:Fetch("statusbar", v));
	    end
	},
	size = {
	    type = "range",
	    order = 2,
	    name = L["Size"],
	    desc = L["The size of the power bar."],
	    min = 1,
	    max = 20,
	    step = 1,
	    get = function() return db.size end,
	    set = function(_, v)
		db.size = v
		powerbar:SetHeight(tonumber(v));
	    end,
	},
	position = {
	    type = "select",
	    order = 3,
	    name = L["Position"],
	    desc = L["The position of the power bar relative to the tooltip."],
	    values = barPosition,
	    get = function() return db.position end,
	    set = function(_, v) 
		db.position = v
		self:SetBarPoint()
	    end,
	},
	showpbtext = {
	    type = "toggle",
	    order = 4,
	    width = "full",
	    name = L["Power bar text"],
	    desc = L["Show the status text on the power bar."],
	    get = function() return db.showText end,
	    set = function(_, v)
		db.showText = v
	    end
	},
	pbfont = {
	    type = "select",
	    order = 5,
	    name = L["Font"],
	    desc = L["What font face to use."],
	    hidden = function() return not db.showText end,
	    dialogControl = "LSM30_Font",
	    values = AceGUIWidgetLSMlists.font,
	    get = function() return db.font end,
	    set = function(_, v)
		db.font = v
		pbtext:SetFont(SM:Fetch("font", v), db.fontSize, "Outline");
	    end
	},
	pbfontsize = {
	    type = "range",
	    order = 6,
	    name = L["Font size"],
	    desc = L["Change what size is the font."],
	    hidden = function() return not db.showText end,
	    min = 8,
	    max = 16,
	    step = 1,
	    get = function() return db.fontSize end,
	    set = function(_, v)
		db.fontSize = v
		pbtext:SetFont(SM:Fetch("font", v), db.fontSize, "Outline");
	    end,
	},
	pbtextstyle = {
	    type = "select",
	    order = 7,
	    name = L["Text format"],
	    desc = L["Format power value"],
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
