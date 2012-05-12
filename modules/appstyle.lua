local _, Icetip = ...
local SM = LibStub("LibSharedMedia-3.0");
local mod = Icetip:NewModule("style");
local backdrop = {insets = {}};
local hooked = {}
local db

local defaults = {
    profile = {
	scale = 1,
	bgColor = {
	    guild = {0, 0.15, 0, 1},
	    faction = {0.25, 0.25, 0, 1},
	    hostilePC = {0.25, 0, 0, 1},
	    hostileNPC = {0.15, 0, 0, 1},
	    neutralNPC = {0.15, 0.15, 0, 1},
	    friendlyPC = {0, 0, 0.25, 1},
	    friendlyNPC = {0, 0, 0.15, 1},
	    other = {0, 0, 0, 1},
	    dead = {0.15, 0.15, 0.15, 1},
	    tapped = {0.25, 0.25, 0.25, 1},
	},
	border_color = {
	    r = 0,
	    g = 0,
	    b = 0,
	    a = 0,
	},
	tooltipStyle = {
	    bgTexture = "Blizzard Tooltip",
	    borderTexture = "Blank",
	    tile = false,
	    tileSize = 8,
	    EdgeSize = 2,
	    customColor = true,
	},
    }
}

function mod:OnEnable()
    self.db = mod:RegisterDB(defaults)
    db = self.db.profile
    GameTooltip.GetBackdropColor = function()
	return unpack(db.bgColor["other"])
    end
    GameTooltip.GetBackdropBorderColor = function()
	return db.border_color["r"], db.border_color["g"], db.border_color["b"], db.border_color["a"]
    end
end

function mod:PreOnTooltipShow(tooltip, ...)
    if hooked[tooltip] then
    else
        hooked[tooltip] = true
        self:UpdateBackdrop(tooltip, ...)
    end
    tooltip:SetBackdropBorderColor(db["border_color"].r, db["border_color"].g, db["border_color"].b, db["border_color"].a);
end

function mod:PostOnTooltipHide(tooltip, ...)
    --reset gametooltip style
    local ct = db.bgColor["other"];
    tooltip:SetBackdropColor(unpack(ct));
    tooltip:SetBackdropBorderColor(db.border_color["r"], db.border_color["g"], db.border_color["b"], db.border_color["a"]);
end

function mod:UpdateBackdrop(tooltip, ...)
    if not tooltip then tooltip = GameTooltip end

    local _db = db.tooltipStyle
    backdrop.bgFile = SM:Fetch("background", _db.bgTexture);
    backdrop.edgeFile = SM:Fetch("border", _db.borderTexture)
    backdrop.tile = _db.tile
    backdrop.tileSize = _db.tileSize
    backdrop.edgeSize = _db.EdgeSize
    local inset = floor(_db.EdgeSize/3);
    backdrop.insets.left = inset
    backdrop.insets.right = inset
    backdrop.insets.top = inset
    backdrop.insets.bottom = inset
    tooltip:SetBackdrop(backdrop);
end


function mod:OnTooltipShow(tooltip)
    if db["tooltipStyle"].customColor then
        self:SetBackgroundColor(nil, nil, nil, nil, nil, tooltip)
    end
    self:SetTooltipScale(nil, db.scale)
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

    local bgColor = db.bgColor[kind]
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
