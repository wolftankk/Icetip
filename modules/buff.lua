local addonName, Icetip = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("Buff", "Aura")
local db
local update
local buffFrame, debuffFrame;

local defaults = {
    profile = {
	['**'] = { --buff, debuff
	   enabled = true,
	   position = "TOP"
	},
	--debuff = {
	--    enabled = false
	--}
    }
}

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
end

--function mod:OnEnable()
--    if not buffFrame and db.buff.enabled then
--	buffFrame = self:createAuraFrame("buff")
--    end
--end
--
--function mod:OnDisable()
--
--end
--
--function mod:createAuraFrame(type)
--    local frame = CreateFrame("Frame", nil, GameTooltip);
--    --frame:SetBackdrop({
--    --    bgFile = [[Interface/Tooltips/UI-Tooltip-Background]],
--    --    edgetFile = [[Interface/Tooltips/UI-Tooltip-Border]],
--    --    tile = false,
--    --    tileSize = 8,
--    --    edgetSize = 16,
--    --    insets = {
--    --        left = 5,
--    --        right = 5,
--    --        top = 5,
--    --        bottom = 5
--    --    }
--    --});
--    --frame:SetBackdropBorderColor(0, 0, 0, 0.6);
--    --frame:SetBackdropColor(0, 0, 0, 0.5);
--    frame.buttons = {}
--
--    return frame
--end
--
--function mod:createAuraButton(parent, order)
--    local button = CreateFrame("Button", "icetip_buff_button_"..order, parent, "AuraButtonTemplate")
--    button:SetSize(32, 32);
--    button:SetID(order)
--    button.icon = _G[button:GetName() .. "Icon"]
--    button:Hide();
--
--    return button
--end
--
--function mod:PreTooltipSetUnit(tooltip, ...)
--    local _, unit = tooltip:GetUnit();
--    if not unit then return end
--    local count = 0;
--    for i = 1, 10 do
--	if not buffFrame.buttons[i] then
--	    buffFrame.buttons[i] = self:createAuraButton(buffFrame, i);
--	end
--	local button = buffFrame.buttons[i]
--	button:Hide();
--	local name, rank, texture, count, debuffType, duration, expirationTime, _, _, shouldConsolidate = UnitBuff(unit, i);
--	if texture then
--	    button.icon:SetTexture(texture)
--	    button:Show();
--	    if i == 1 then
--		button:SetPoint("BOTTOMLEFT", buffFrame, "BOTTOMLEFT", 6, 4)
--	    else
--		button:SetPoint("LEFT", buffFrame.buttons[i-1], "RIGHT", 5, 0)
--	    end
--	    count = count + 1
--	end
--    end
--end
--
--function mod:OnTooltipShow()
--    buffFrame:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 2, 0);
--    buffFrame:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 2, 0);
--    buffFrame:SetHeight(100)
--end
--
--function mod:OnTooltipHide()
--    for _, button in pairs(buffFrame.buttons) do
--	button:Hide()
--    end
--end
