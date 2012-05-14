local addonName, Icetip = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("position", L["Position"], true);
local db;

local currentOffsetX, currentOffsetY = 0, 0
local currentCursorAnchor = "BOTTOM"
local currentAnchorType = "CURSOR"
local currentOwner = UIParent

local anchorOpposite = {
    BOTTOMLEFT = "TOPLEFT",
    BOTTOM = "TOP",
    BOTTOMRIGHT = "TOPRIGHT",
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    TOPLEFT = "BOTTOMLEFT",
    TOP = "BOTTOM",
    TOPRIGHT = "BOTTOMRIGHT",
}

local defaults = {
    profile = {
	unitAnchor = "CURSOR_BOTTOM",
	unitOffsetX = 0,
	unitOffsetY = 0,
	frameAnchor = "BOTTOMRIGHT",
	frameOffsetX = -93,
	frameOffsetY = 110,
    }
}

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
    self:SecureHook("GameTooltip_SetDefaultAnchor", "SetTooltipAnchor");
end

function mod:OnDisable()
    self:Unhook("GameTooltip_SetDefaultAnchor")
end

local function ReanchorTooltip()
    GameTooltip:ClearAllPoints();
    local scale = GameTooltip:GetEffectiveScale();
    if currentAnchorType == "PARENT" then
        GameTooltip:SetPoint(currentCursorAnchor, currentOwner, anchorOpposite[currentCursorAnchor], currentOffsetX, currentOffsetY)
    elseif currentAnchorType == "CURSOR" then
        local x, y = GetCursorPosition();
        x, y = x/scale + currentOffsetX, y/scale +currentOffsetY;
        GameTooltip:SetPoint(currentCursorAnchor, UIParent, "BOTTOMLEFT", x, y);
    end
end

function mod:SetTooltipAnchor(tooltip, parent, ...)
    local anchor, offsetX, offsetY
    currentOwner = parent
    if parent == UIParent then
        anchor = db.unitAnchor
        offsetX = db.unitOffsetX
        offsetY = db.unitOffsetY
    else --frame
        anchor = db.frameAnchor
        offsetX = db.frameOffsetX
        offsetY = db.frameOffsetY
    end
    if anchor:find("^CURSOR") or anchor:find("^PARENT") then
        if anchor == "CURSOR_TOP" and math.abs(offsetX) < 1 and math.abs(offsetY) < 0 then
            tooltip:SetOwner(parent, "ANCHOR_CURSOR");
        else
            currentOffsetX = offsetX
            currentOffsetY = offsetY
            currentCursorAnchor = anchor:sub(8);
            currentAnchorType = anchor:sub(1, 6);
            ReanchorTooltip()
        end
    else
        tooltip:SetOwner(parent, "ANCHOR_NONE");
        tooltip:ClearAllPoints();
        tooltip:SetPoint(anchor, UIParent, anchor, offsetX, offsetY)
    end
end

function mod:editPosition()

end


local anchorType = {
    ["CURSOR_BOTTOM"] = L["Mouse Top"],
    ["CURSOR_TOP"] = L["Mouse Bottom"],
    ["CURSOR_RIGHT"] = L["Mouse Left"],
    ["CURSOR_LEFT"] = L["Mouse Right"],
    ["CURSOR_TOPLEFT"] = L["Mouse Bottom Right"],
    ["CURSOR_BOTTOMLEFT"] = L["Mouse Top Right"],
    ["CURSOR_TOPRIGHT"] = L["Mouse Bottom Left"],
    ["CURSOR_BOTTOMRIGHT"] = L["Mouse Top Left"],
    ["BOTTOM"] = L["Bottom"],
    ["TOP"] = L["Top"],
    ["RIGHT"] = L["Right"],
    ["LEFT"] = L["Left"],
    ["BOTTOMRIGHT"] = L["Bottom Right"],
    ["BOTTOMLEFT"] = L["Bottom Left"],
    ["TOPRIGHT"] = L["Top Right"],
    ["TOPLEFT"] = L["Top Left"],
    ["CENTER"] = L["Center"],
    ["PARENT_TOP"] = L["Parent Bottom"],
    ["PARENT_BOTTOM"] = L["Parent Top"],
    ["PARENT_RIGHT"] = L["Parent Left"],
    ["PARENT_LEFT"] = L["Parent Right"],
    ["PARENT_TOPLEFT"] = L["Parent Bottom Left"],
    ["PARENT_TOPRIGHT"] = L["Parent Bottom Right"],
    ["PARENT_BOTTOMLEFT"] = L["Parent Top Left"],
    ["PARENT_BOTTOMRIGHT"] = L["Parent Top Right"],
}
function mod:GetOptions()
    local options = {
	header1 = {
	    type = "header",
	    order = 1,
	    name = L["Unit"],
	},
	desc_1 = {
	    type = "description",
	    name = L["Options for unit mouseover tooltips(NPC, target, player, etc.)"],
	    order = 2,
	},
	unitAnchor = {
	    type = "select",
	    order = 3,
	    name = L["Anchor"],
	    desc = L["The anchor with which the tooltips are showed."],
	    values = anchorType,
	    get = function() return db.unitAnchor end,
	    set = function(_, v)
		db.unitAnchor = v
	    end
	},
	space_1 = {
	    type = "description",
	    name = L["Sets anchor offset"],
	    order = 4,
	},
	unitPosX = {
	    type = "range",
	    order = 5,
	    name = L["Horizontal offset"],
	    desc = L["Sets offset of the X"],
	    min = tonumber(-(floor(GetScreenWidth()/5 + 0.5) * 5)),
	    max = tonumber(floor(GetScreenWidth()/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.unitOffsetX end,
	    set = function(_, v)
		db.unitOffsetX = v
	    end
	},
	unitPoxY = {
	    type = "range",
	    order = 6,
	    name = L["Vertical offset"],
	    desc = L["Sets offset of the Y"],
	    min = tonumber(-(floor(GetScreenHeight()/5 + 0.5) * 5)),
	    max = tonumber(floor(GetScreenHeight()/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.unitOffsetY end,
	    set = function(_, v)
		db.unitOffsetY = v
	    end
	},
	header2 = {
	    type = "header",
	    order = 7,
	    name = L["Frame"],
	},
	desc_2 = {
	    type = "description",
	    name = L["Options for the frame mouseover tooltips(spells, items, etc.)"],
	    order = 8
	},
	frameAnchor = {
	    type = "select",
	    order = 9,
	    name = L["Anchor"],
	    desc = L["The anchor with which the tooltips are showed."],
	    values = anchorType,
	    get = function() return db.frameAnchor end,
	    set = function(_, v)
		db.frameAnchor = v
	    end
	},
	space_2 = {
	    type = "description",
	    name = L["Sets anchor offset"],
	    order = 10,
	},
	framePosX = {
	    type = "range",
	    order = 11,
	    name = L["Horizontal offset"],
	    desc = L["Sets offset of the X"],
	    min = tonumber(-(floor(GetScreenWidth()/5 + 0.5) * 5)),
	    max = tonumber(floor(GetScreenWidth()/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.frameOffsetX end,
	    set = function(_, v)
		db.frameOffsetX = v
	    end
	},
	framePoxY = {
	    type = "range",
	    order = 12,
	    name = L["Vertical offset"],
	    desc = L["Sets offset of the Y"],
	    min = tonumber(-(floor(GetScreenHeight()/5 + 0.5) * 5)),
	    max = tonumber(floor(GetScreenHeight()/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.frameOffsetY end,
	    set = function(_, v)
		db.frameOffsetY = v
	    end
	}
    }

    return options
end
