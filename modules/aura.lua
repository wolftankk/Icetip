local addonName, Icetip = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("aura", L["Aura"])
local db
local update
local auraFrame, auras = nil, {};

local defaults = {
    profile = {
	size = 32,
	auraMaxRows = 2,
	position = "TOP",
	['**'] = {
	    enabled = true,
	    cooldown = true
	},
	buff = {
	}
    }
}

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
    if not auraFrame then
	self:createAuraFrame()
    end
end

function mod:OnDisable()
    if auraFrame then
	wipe(auras);
	auraFrame:ClearAllPoints();
	auraFrame = nil;
    end
end

function mod:createAuraFrame(type)
    local frame = CreateFrame("Frame", nil, GameTooltip);
    --frame:SetBackdrop({
    --    bgFile = [[Interface/Tooltips/UI-Tooltip-Background]],
    --    edgetFile = [[Interface/Tooltips/UI-Tooltip-Border]],
    --    tile = false,
    --    tileSize = 8,
    --    edgetSize = 16,
    --    insets = {
    --        left = 5,
    --        right = 5,
    --        top = 5,
    --        bottom = 5
    --    }
    --});
    --frame:SetBackdropBorderColor(0, 0, 0, 0.6);
    --frame:SetBackdropColor(0, 0, 0, 0.5);
    auraFrame = frame;
end

function mod:createAura(parent)
    local button = CreateFrame("Button", nil, parent);
    button:SetSize(db.size, db.size);

    button.count = button:CreateFontString(nil, "ARTWORK")
    button.count:SetPoint("BOTTOMRIGHT", 1, 0)
    button.count:SetFont(GameFontNormal:GetFont(), db.size /2, "OUTLINE");

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints(button)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    button.cooldown = CreateFrame("Cooldown", nil, parent ,"CooldownFrameTemplate");
    button.cooldown:SetReverse(1)
    button.cooldown:SetAllPoints(button)
    button.cooldown:SetFrameLevel(button:GetFrameLevel())
    button.cooldown.noCooldownCount = true
    button.border = button:CreateTexture(nil, "OVERLAY");
    button.border:SetPoint("TOPLEFT", -1, 1);
    button.border:SetPoint("BOTTOMRIGHT", 1, -1);
    button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays");
    button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625);
    auras[#auras+1] = button
    return button
end

function mod:PreTooltipSetUnit(tooltip, ...)
    local _, unit = tooltip:GetUnit();
    if not unit then return end
    local pos = 1
    local aurasPerRow = floor((tooltip:GetWidth() - 4) / (db.size + 1))
    
    if db.buff.enabled then
	local index = 1
	while (true) do
	    local name, rank, texture, count, debuffType, duration, expirationTime, casterUnit = UnitBuff(unit, index);

	    if (not texture) or ((pos / aurasPerRow) > db.auraMaxRows) then break end
	    if (casterUnit == "player" or casterUnit == "pet" or casterUnit == "vehicle") then
		local button = auras[pos] or self:createAura(auraFrame);
		button:ClearAllPoints();
		if ((pos - 1) % aurasPerRow == 0) or (pos == 1) then
		    local x, y = 5, (db.size + 1) * floor((pos - 1) / aurasPerRow) + 5;
		    if db.position == "TOP" then
			button:SetPoint("BOTTOMLEFT", auraFrame, "BOTTOMLEFT", x, y)
		    else
			button:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", x, -y);
		    end
		else
		    button:SetPoint("LEFT", auras[pos - 1], "RIGHT",  2, 0);
		end

		if db.buff.cooldown and (duration and duration > 0 and expirationTime and expirationTime > 0) then
		    button.cooldown:SetCooldown(expirationTime - duration , duration)
		else
		    button.cooldown:Hide();
		end

		button.icon:SetTexture(texture)
		if count and count > 1 then
		    button.count:SetText(count)
		else
		    button.count:SetText("")
		end
		button.border:Hide()

		button:Show();

		pos = pos + 1
	    end
	    index = index + 1
	end
    end

    if (db.debuff.enabled) and (pos / aurasPerRow <= db.auraMaxRows) then
        local index = 1
        local buffCount = pos - 1
        while (true) do
            local name, rank, texture, count, debuffType, duration, expirationTime, casterUnit = UnitDebuff(unit, index);
            if (not texture) or (pos / aurasPerRow > db.auraMaxRows) then break end
            if (casterUnit == "player" or casterUnit == "pet" or casterUnit == "vehicle") then
        	local button = auras[pos] or self:createAura(auraFrame);
        	button:ClearAllPoints();
        	if ((pos - 1) % aurasPerRow == 0) or (pos == buffCount +1 ) then
        	    local x, y = -5, (db.size + 1) * floor((pos - 1) / aurasPerRow) + 5;
        	    if db.position == "TOP" then
        		button:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", x, y)
        	    else
        		button:SetPoint("TOPRIGHT", auraFrame, "TOPRIGHT", x, -y);
        	    end
        	else
        	    button:SetPoint("RIGHT", auras[pos - 1], "LEFT", -1, 0)
        	end

        	if db.debuff.cooldown and (duration and duration > 0 and expirationTime and expirationTime > 0) then
        	    button.cooldown:SetCooldown(expirationTime , duration)
        	    button.cooldown:Show();
        	else
        	    button.cooldown:Hide();
        	end

        	button.icon:SetTexture(texture)
        	if count and count > 1 then
        	    button.count:SetText(count)
        	else
        	    button.count:SetText("")
        	end
        	local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
        	button.border:SetVertexColor(color.r, color.g, color.b)
        	button.border:Show();
        	button:Show();

        	pos = pos + 1
            end
            index = index + 1
        end
    end
    for i = pos, #auras do
	if auras[i] then
	    auras[i].cooldown:Hide();
	    auras[i]:Hide()
	end
    end
    auraFrame:Show();
end

function mod:OnTooltipShow(tooltip, ...)
    local _, unit = tooltip:GetUnit();
    if not unit then return end
    if db.position == "TOP" then
	auraFrame:SetPoint("BOTTOMLEFT", tooltip, "TOPLEFT", 2, 0);
	auraFrame:SetPoint("BOTTOMRIGHT", tooltip, "TOPRIGHT", 2, 0);
    end
    auraFrame:SetHeight(2 * db.size + 20)
end

function mod:OnTooltipHide()
    auraFrame:Hide();
end

function mod:GetOptions()
    local options = {
	size = {
	    type = "range",
	    order = 1,
	    name = L["Size"],
	    desc = L["Sets aura button size"],
	    min = 16,
	    max = 64,
	    step = 2,
	    get = function() return db.size end,
	    set = function(_, v)
		db.size = tonumber(v)
		for i =1, #auras do
		    if auras[i] then
			auras[i]:SetSize(db.size, db.size)
		    end
		end
	    end
	},
	auraMaxRows = {
	    type = "range",
	    order = 2,
	    name = L["Max rows"],
	    desc = L["Sets max rows"],
	    min = 1,
	    max = 5,
	    step = 1,
	    get = function() return db.auraMaxRows end,
	    set = function(_, v)
		db.auraMaxRows = tonumber(v)
	    end
	}
    }

    for _, t in pairs({"buff", "debuff"}) do
	options[t] = {
	    type = "group",
	    order = 3,
	    name = t,
	    inline = true,
	    args = {
		enabled = {
		    type = "toggle",
		    name = L["Enable"],
		    order = 1,
		    get = function() return db[t].enabled end,
		    set = function(_, v)
			db[t].enabled = v
		    end
		},
		cooldown = {
		    type = "toggle",
		    name = L["Toggle Cooldown"],
		    order = 2,
		    get = function() return db[t].cooldown end,
		    set = function(_, v)
			db[t].cooldown = v
		    end
		}
	    }
	}
    end

    return options
end
