local _, Icetip = ...
local SM = LibStub("LibSharedMedia-3.0");
local mod = Icetip:NewModule("Appstyle");

--local Icetip_Appstyle = {};
--Icetip.Appstyle = Icetip_Appstyle;

function mod:OnEnable()
    
end

local backdrop = {insets = {}};
local hooked = {}
function mod:UpdateBackdrop(tooltip, ...)
    if not tooltip then tooltip = GameTooltip end

    local db = self.db.tooltipStyle
    backdrop.bgFile = SM:Fetch("background", db.bgTexture);
    backdrop.edgeFile = SM:Fetch("border", db.borderTexture)
    backdrop.tile = db.tile
    backdrop.tileSize = db.tileSize
    backdrop.edgeSize = db.EdgeSize
    local inset = floor(db.EdgeSize/3);
    backdrop.insets.left = inset
    backdrop.insets.right = inset
    backdrop.insets.top = inset
    backdrop.insets.bottom = inset
    tooltip:SetBackdrop(backdrop);
end

--Onshow
function mod:Tooltip_OnShow(tooltip, ...)
    if hooked[tooltip] then
        return
    end
    hooked[tooltip] = true
    self:UpdateBackdrop(tooltip, ...)
end

function mod:OnTooltipShow(tooltip)
    if self.db["tooltipStyle"].customColor then
        self:SetBackgroundColor(nil, nil, nil, nil, nil, tooltip)
    end
    self:SetTooltipScale(nil, self.db.scale)
end

local currentSameFaction = false
function mod:PreTooltipSetUnit()
    local myWatchedFaction = GetWatchedFactionInfo();
    currentSameFaction = false
    if myWatchedFaction then
        for i = 1, 10 do
            local left = _G["GameTooltipTextLeft"..i]
            if left then
                if left:GetText() == myWatchedFaction then
                      currentSameFaction = true
                      break
                end
            end
        end
    end
end

function mod:SetBackgroundColor(given_kind, r, g,b,a, tooltip)
    if not tooltip then
        tooltip = GameTooltip
    end
    local kind = given_kind
    if not kind then
        kind = "other"
        local unit
        if (type(tooltip.GetUnit) == "function") then
                _, unit = tooltip:GetUnit()
        end

        if unit and UnitExists(unit) then
            if UnitIsDeadOrGhost(unit) then
                kind = "dead"
            elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
                kind = "tapped"
            elseif tooltip == GameTooltip and currentSameFaction then--声望
                kind = "faction"
            elseif UnitIsPlayer(unit) then
                if UnitIsFriend("player", unit) then
                    local playerGuild = GetGuildInfo("player");
                    if playerGuild and playerGuild == GetGuildInfo(unit) or UnitIsUnit("player", unit) then
                        kind = "guild"
                    else
                        local friend = false
                        local name = UnitName(unit);
                        for i =1, GetNumFriends() do
                            if GetFriendInfo(i) == name then
                                friend = true
                                break
                            end
                        end
                        if friend then
                            kind = "guild"
                        else
                            kind = "friendlyPC"
                        end
                    end
                else
                    kind = "hostilePC"
                end
            else
                if (UnitIsFriend("player", unit)) then
                    kind = "friendlyNPC"
                else
                    local reaction = UnitReaction(unit, "player")
                    if not reaction or reaction <=2 then
                        kind = "hostileNPC"
                    else
                        kind = "neutralNPC"
                    end
                end
            end
        end
    end

    local bgColor = self.db.bgColor[kind]
    if r then
        bgColor[1] = r
        bgColor[2] = g
        bgColor[3] = b
        bgColor[4] = a
    else
        r, g, b, a = unpack(bgColor);
    end

    if given_kind then
        self:SetBackgroundColor(nil, nil, nil, nil, nil, tooltip)
        return
    end
    tooltip:SetBackdropColor(r, g, b, a)
end

function mod:SetTooltipScale(tooltip, value)
    if not tooltip then
        tooltip = GameTooltip
    end
    
    tooltip:SetScale(value)
end
