local addonName, Icetip = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("itemref", L["Item"]);
mod.description = L["When you watch a item, colored tooltip by item's quality color"]
local db;
local colors = {}

function mod:OnEnable()
end

function mod:PreTooltipSetItem(tooltip, ...)
    if (tooltip["GetItem"]) then
        local item = select(2, tooltip:GetItem());
        if item then
            local quality = select(3, GetItemInfo(item));
            if quality then
                local r, g, b = GetItemQualityColor(quality);
                colors[tooltip] = {r, g, b}
            end
        end
    end
end

function mod:OnTooltipShow(tooltip)
    if colors[tooltip] then
        local r, g, b = unpack(colors[tooltip])
        tooltip:SetBackdropBorderColor(r, g, b);
    end
end

function mod:OnTooltipHide()
    wipe(colors)
end
