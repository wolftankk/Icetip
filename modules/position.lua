local addonName, Icetip = ...;
local mod = Icetip:NewModule("position", "Position", true);
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

function mod:OnEnable()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
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
