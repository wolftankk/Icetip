local addonName, Icetip = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local SM = LibStub("LibSharedMedia-3.0");
local mod = Icetip:NewModule("style", L["Style"]);
mod.order = 2
local backdrop = {insets = {}};
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
	    font = "Friz Quadrata TT",
	    tile = false,
	    tileSize = 8,
	    EdgeSize = 2,
	    customColor = true,
	},
    }
}


function mod:OnInitialize()
    self.db = mod:RegisterDB(defaults)
    db = self.db.profile

    self:InitializeTooltips();
end

local origin_GetBackdropColor = GameTooltip.GetBackdropColor
local origin_GetBackdropBorderColor = GameTooltip.GetBackdropBorderColor
local origin_backdrop = GameTooltip:GetBackdrop();

local hookOnShow;
do
    local hooked = {}
    function hookOnShow(tooltip)
	if hooked[tooltip] then
	    return
	end

	hooked[tooltip] = true;
	local onShow = tooltip:GetScript("OnShow");
	tooltip:SetScript("OnShow", function(frame, ...)
	    if onShow then
		onShow(frame, ...);
	    end
	    --update scale
	    mod:SetTooltipScale(nil, frame);
	    --update font
	    mod:SetTooltipFont(nil, frame);
	end)

	local Show = tooltip.Show;
	function tooltip.Show(frame, ...)
	    if Show then
		Show(frame, ...)
	    end
	    --update scale
	    mod:SetTooltipScale(nil, frame);
	    --update font
	    mod:SetTooltipFont(nil, frame);
	end

	if tooltip:IsShown() then
	    tooltip:GetScript("OnShow")(tooltip)
	end
    end
end

function mod:OnEnable()
    GameTooltip.GetBackdropColor = function()
	return unpack(db.bgColor["other"])
    end
    GameTooltip.GetBackdropBorderColor = function()
	return db.border_color["r"], db.border_color["g"], db.border_color["b"], db.border_color["a"]
    end

    mod:SetTooltipScale(nil);
    mod:SetTooltipFont(nil)
    mod:UpdateBackdrop(nil);
end

function mod:OnDisable()
    GameTooltip.GetBackdropColor = origin_GetBackdropColor
    GameTooltip.GetBackdropBorderColor = origin_GetBackdropBorderColor
    GameTooltip:SetBackdrop(origin_backdrop)
end

function mod:InitializeTooltips()
    local function run()
	local f
	while true do
	    f = EnumerateFrames(f);
	    if not f then break end;

	    if f:GetObjectType() == "GameTooltip" and f ~= GameTooltip then
		hookOnShow(f);
	    end
	end
    end
    run();
end

function mod:PreOnTooltipShow(tooltip, ...)
    hookOnShow(tooltip)
    self:UpdateBackdrop(tooltip, ...)
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
    self:SetTooltipScale(nil)
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

function mod:SetTooltipScale(value, tooltip)
    if value then
	db.scale = value
    else
	value = db.scale
    end

    if not tooltip then
        tooltip = GameTooltip
    end

    tooltip:SetScale(value)
end

function mod:SetTooltipFont(value, tooltip)
    if value then
	db.tooltipStyle.font = value
    else
	value = db.tooltipStyle.font
    end

    local font = SM:Fetch('font', value);
    
    if not tooltip then
	local text = _G["GameTooltipTextLeft1"];
	if text:GetFont() == font then
	    return
	end
	for i = 1, 50 do
	    local left = _G["GameTooltipTextLeft"..i];
	    local right = _G["GameTooltipTextRight"..i];
	    if not left then return end
	    local _, size, style = left:GetFont();
	    left:SetFont(font, size, style);

	    local _, size, style = right:GetFont();
	    right:SetFont(font, size, style);
	end
    else
	for i = 1, select('#', tooltip:GetRegions()) do
	    local v = select(i, tooltip:GetRegions());
	    if (v:GetObjectType() == "FontString") then
		local _, size, style = v:GetFont();
		v:SetFont(font, size, style);
	    end
	end
    end
end


function mod:GetOptions()
    local options = {
	tooltipBG = {
	    type = "group",
	    order = 1,
	    name = L["Style"],
	    inline = true,
	    args = {
		tooltipfont = {
		    type = "select",
		    dialogControl = "LSM30_Font",
		    order = 1,
		    name = L["Font"],
		    values = AceGUIWidgetLSMlists.font,
		    get = function() return db.tooltipStyle.font end,
		    set = function(_, v)
			self:SetTooltipFont(v);
		    end
		},
		bgtexture = {
		    type = "select",
		    dialogControl = "LSM30_Background",
		    order = 1,
		    name = L["Background style"],
		    desc = L["Change the background texture.\n\n\Note:You may need to change the Background color to white to see some of the backgrounds properly."],
		    values = AceGUIWidgetLSMlists.background,
		    get = function() return db["tooltipStyle"].bgTexture end,
		    set = function(_, v)
			db["tooltipStyle"].bgTexture = v
			self:UpdateBackdrop()
		    end,
		},
		bordertexture = {
		    type = "select",
		    dialogControl = "LSM30_Border",
		    order = 2,
		    name = L["Border style"],
		    desc = L["Change the border texture.\n\nNote: You may need to change the Background color to white to see some of the backgrounds properly."],
		    values = AceGUIWidgetLSMlists.border,
		    get = function() return db["tooltipStyle"].borderTexture end,
		    set = function(_, v)
			db["tooltipStyle"].borderTexture = v
			self:UpdateBackdrop()
		    end,
		},
		bgcolor = {
		    type = "toggle",
		    order = 3,
		    name = L["Toggle custom background color"],
		    desc = L["Enable/Disable custom background color"],
		    get = function() return db["tooltipStyle"].customColor end,
		    set = function(_, v)
			db["tooltipStyle"].customColor = v
		    end
		},
		bordercolor = {
		    type = "color",
		    order = 4,
		    name = L["Border color"],
		    desc = L["Sets what color the tooltip's border is."],
		    hasAlpha = true,
		    get = function() return db.border_color.r, db.border_color.g, db.border_color.b, db.border_color.a end,
		    set = function(_, r, g, b, a)
			db.border_color.r, db.border_color.g, db.border_color.b, db.border_color.a = r,g,b,a
		    end,
		},
		tile = {
		    type = "toggle",
		    order = 5,
		    name = L["Background tile"],
		    desc = L["Sets what texture tile the tooltip's background is."],
		    get = function() return db["tooltipStyle"].tile end,
		    set = function(_, v)
			db["tooltipStyle"].tile = v
			self:UpdateBackdrop()
		    end,
		},
		tilesize = {
		    type = "range",
		    order = 6,
		    name = L["Tile size"],
		    desc = L["Sets what size the tooltip's backgroud texture tile"],
		    min = 4,
		    max = 256,
		    step = 1,
		    disabled = function() return not db["tooltipStyle"].tile end,
		    get = function() return db["tooltipStyle"].tileSize end,
		    set = function(_, v)
			db["tooltipStyle"].tileSize = v
			self:UpdateBackdrop()
		    end
		},
		edgesize = {
		    type = "range",
		    order = 7,
		    name = L["Border size"],
		    desc = L["The size the border takes up."],
		    min = 2,
		    max = 32,
		    step = 1,
		    get = function() return db["tooltipStyle"].EdgeSize end,
		    set = function(_, v)
			db["tooltipStyle"].EdgeSize = v
			self:UpdateBackdrop()
		    end,
		},
		tooltipScale = {
		    type = "range",
		    order = 10,
		    name = L["Scale"],
		    desc = L["Set how large the tooltip is."],
		    min = 0,
		    max = 2,
		    isPercent = true,
		    step = 0.01,
		    get = function() return db.scale end,
		    set = function(_, v) 
			db.scale = v 
			self:SetTooltipScale(v)
		    end,
		},
	    }
	},
	color = {
	    type = "group",
	    order = 2,
	    name = L["Background color"],
	    desc = L["Sets what color the tooltip's background is."],
	    disabled = function() return not db["tooltipStyle"].customColor end,
	    inline = true,
	    args = {
		guild = {
		    type = "color",
		    name = L["Guild and friends"],
		    desc = L["Background color for your guildmates and friends."],
		    order = 1,
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.guild) end,
		    set = function(_, r, g, b, a)
			db.bgColor.guild[1], db.bgColor.guild[2], db.bgColor.guild[3], db.bgColor.guild[4] = r,g,b,a
		    end,
		},
		hostilePC = {
		    type = "color",
		    order = 2,
		    name = L["Hostile players"],
		    desc = L["Background color for hostile players."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.hostilePC) end,
		    set = function(_, r, g, b, a)
			db.bgColor.hostilePC[1], db.bgColor.hostilePC[2], db.bgColor.hostilePC[3], db.bgColor.hostilePC[4] = r,g,b,a
		    end,
		},
		hostileNPC = {
		    type = "color",
		    order = 3,
		    hasAlpha = true,
		    name = L["Hostile NPCs"],
		    desc = L["Background color for hostile NPCs."],
		    get = function() return unpack(db.bgColor.hostileNPC) end,
		    set = function(_, r, g, b, a)
			db.bgColor.hostileNPC[1], db.bgColor.hostileNPC[2], db.bgColor.hostileNPC[3], db.bgColor.hostileNPC[4] = r,g,b,a
		    end,
		},
		neutralNPC = {
		    type = "color",
		    order = 4,
		    hasAlpha = true,
		    name = L["Neutral NPCs"],
		    desc = L["Background color for neutral NPCs."],
		    get = function() return unpack(db.bgColor.neutralNPC) end,
		    set = function(_, r, g, b, a)
			db.bgColor.neutralNPC[1], db.bgColor.neutralNPC[2], db.bgColor.neutralNPC[3], db.bgColor.neutralNPC[4] = r,g,b,a
		    end,
		},
		faction = {
		    type = "color",
		    order = 5,
		    name = L["Currently watched faction"],
		    desc = L["Background color for the currently watched faction."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.faction) end,
		    set = function(_, r, g, b, a)
			db.bgColor.faction[1], db.bgColor.faction[2], db.bgColor.faction[3], db.bgColor.faction[4] = r,g,b,a
		    end,
		},
		friendPC = {
		    type = "color",
		    order = 6,
		    name = L["Friendly players"],
		    desc = L["Background color for the friendly players."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.friendlyPC) end,
		    set = function(_, r, g, b, a)
			db.bgColor.friendlyPC[1], db.bgColor.friendlyPC[2], db.bgColor.friendlyPC[3], db.bgColor.friendlyPC[4] = r,g,b,a
		    end,
		},
		friendlyNPC = {
		    type = "color",
		    order = 7,
		    name = L["Friendly NPCs"],
		    desc = L["Background color for the friendly NPCs."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.friendlyNPC) end,
		    set = function(_, r, g, b, a)
			db.bgColor.friendlyNPC[1], db.bgColor.friendlyNPC[2], db.bgColor.friendlyNPC[3], db.bgColor.friendlyNPC[4] = r,g,b,a
		    end,
		},
		other = {
		    type = "color",
		    order = 8,
		    name = L["Other"],
		    desc = L["Background color for non-units."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.other) end,
		    set = function(_, r, g, b, a)
			db.bgColor.other[1], db.bgColor.other[2], db.bgColor.other[3], db.bgColor.other[4] = r,g,b,a
		    end,
		},
		dead = {
		    type = "color",
		    order = 9,
		    name = L["Dead"],
		    desc = L["Background color for dead units."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.dead) end,
		    set = function(_, r, g, b, a)
			db.bgColor.dead[1], db.bgColor.dead[2], db.bgColor.dead[3], db.bgColor.dead[4] = r,g,b,a
		    end,
		},
		tapped = {
		    type = "color",
		    order = 10,
		    name = L["Tapped"],
		    desc = L["Background color for when a unit is tapped by another."],
		    hasAlpha = true,
		    get = function() return unpack(db.bgColor.tapped) end,
		    set = function(_, r, g, b, a)
			db.bgColor.tapped[1], db.bgColor.tapped[2], db.bgColor.tapped[3], db.bgColor.tapped[4] = r,g,b,a
		    end,
		},
	    },
	},
    }
    return options
end
