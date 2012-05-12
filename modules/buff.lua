local addonName, Icetip = ...;
local mod = Icetip:NewModule("Buff", "Buff");
local db
--update function
local update

local buffFrame, debuffFrame;

function mod:OnEnable()
    local db = self.db["auras"];
    self.db = db;

    --create buffFrame and debuffFrame if the mode enable
end

function mod:OnDisable()

end

function mod:CreateAuraFrame()
end

function mod:OnTooltipShow()
    --if buffFrame then return end
    --buffFrame = CreateFrame("Frame", nil, GameTooltip);
    ----buff frame grow dir
    --buffFrame.growBy = "up";
    --buffFrame:SetBackdrop({
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
    --buffFrame:SetBackdropBorderColor(0, 0, 0, 0.6);
    --buffFrame:SetBackdropColor(0, 0, 0, 0.5);
    --

    ----position
    --buffFrame:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 2, 0);
    --buffFrame:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 2, 0);
    --buffFrame:SetHeight(100)
end

function mod:OnTooltipHide()

end
