------------------------------------------------
--Icetip
--Description: The tooltip addon for wow
--Author: wolftankk@gmail.com
------------------------------------------------
local addonName, Icetip = ...
Icetip = LibStub("AceAddon-3.0"):NewAddon(Icetip, addonName, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0");
Icetip.vesion = GetAddOnMetadata(addonName, "Version") 
local modules = {};
Icetip.modules = modules;
local SM = LibStub("LibSharedMedia-3.0");
local LDB = LibStub("LibDataBroker-1.1", true);
local icon = LibStub("LibDBIcon-1.0", true);
local tooltips = {
    GameTooltip,
    ItemRefTooltip,
    ShoppingTooltip1,
    ShoppingTooltip2,
    ShoppingTooltip3,
    WorldMapTooltip,
}

local default = {
    profile = {
	minimap = {
	    hide = false
	},
	modules = {
	    ['*'] = {
		enabled = true
	    },
	    raidtarget = {
		enabled = false
	    }
	}
	--scale = 1,
	--minimap = {
	--    hide = false, 
	--},
	--bgColor = {
	--    guild = {0, 0.15, 0, 1},
	--    faction = {0.25, 0.25, 0, 1},
	--    hostilePC = {0.25, 0, 0, 1},
	--    hostileNPC = {0.15, 0, 0, 1},
	--    neutralNPC = {0.15, 0.15, 0, 1},
	--    friendlyPC = {0, 0, 0.25, 1},
	--    friendlyNPC = {0, 0, 0.15, 1},
	--    other = {0, 0, 0, 1},
	--    dead = {0.15, 0.15, 0.15, 1},
	--    tapped = {0.25, 0.25, 0.25, 1},
	--},
	--border_color = {
	--    r = 0,
	--    g = 0,
	--    b = 0,
	--    a = 0,
	--},
	--tooltipStyle = {
	--    bgTexture = "Blizzard Tooltip",
	--    borderTexture = "Blank",
	--    tile = false,
	--    tileSize = 8,
	--    EdgeSize = 2,
	--    customColor = true,
	--},
	--itemQBorder = true,
	--setAnchor = {
	--    unitAnchor = "CURSOR_BOTTOM",
	--    unitOffsetX = 0,
	--    unitOffsetY = 0,
	--    frameAnchor = "BOTTOMRIGHT",
	--    frameOffsetX = -93,
	--    frameOffsetY = 110,
	--},
	--tooltipFade = {
	--    units = "hide",
	--    objects ="fade",
	--    unitFrames = "fade",
	--    otherFrames = "hide",
	--},
	--tipmodifier = {
	--    units = "always",
	--    objects = "always",
	--    unitFrames = "always",
	--    otherFrames = "always",
	--    modifier = "NONE",
	--},
	--healthbar = {
	--    texture = "Smooth",
	--    size = 5,
	--    position = "BOTTOM",
	--    enable = true,
	--    showText = false,
	--    font = "Friz Quadrata TT",
	--    fontSize = 9,
	--    fontflag = "Outline",
	--    style = "number",
	--    short = true,
	--},
	--powerbar = {
	--    texture = "Smooth",
	--    size = 5,
	--    position = "BOTTOM",
	--    enable = true,
	--    showText = false,
	--    font = "Friz Quadrata TT",
	--    fontSize = 9,
	--    fontflag = "Outline",
	--    style = "number",
	--    short = true,
	--},
	--mousetarget = {
	--    showTalent = true,
	--    showTarget = true,
	--    showFaction = true,
	--    showServer = true,
	--    colorBorderByClass = true,
	--    colorNameByClass = false,
	--    SGuildColor = {
	--	r = 0.9,
	--	g = 0.45,
	--	b = 0.7,
	--    },
	--    DGuildColor = {
	--	r = 0.8,
	--	g = 0.8,
	--	b = 0.8,
	--    }
	--},
	--raidtarget = {
	--    enable = false,
	--    position = "TOP",
	--    size = 20,
	--},
	--buff = {
	--    enable = false,
	--}
    }
}

--------------------------------------------------------------
--- icetip modules
--------------------------------------------------------------
local modhandler = {};
local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0");
modhandler.frame = CreateFrame("Frame");
if not modhandler.events then
    modhandler.events = CallbackHandler:New(modhandler, "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents");
end

function modhandler.events:OnUsed(target, event)
    modhandler.frame:RegisterEvent(event)
end

function modhandler.events:OnUnused(target, event)
    modhandler.frame:UnregisterEvent(event)
end

local modmethod = {
    "RegisterEvent",
    "UnregisterEvent",
    "UnregisterAllEvents"
}

local events = modhandler.events;
modhandler.frame:SetScript("OnEvent", function(frame, event, ...)
    events:Fire(event, ...)
end)

local modPrototype = {};
function modPrototype:Enable()
    self._enabled = true
    self:OnEnable();
end

function modPrototype:Disable()
    self._enabled = false;
    self:OnDisable();
end

function modPrototype:IsEnabled()
    return self._enabled
end

function modPrototype:SetName(name)
    self.name = name
end

function modPrototype:GetName()
    return self.name
end

function modPrototype:RegisterDB(profile)
    local db = Icetip.acedb:RegisterNamespace(self.name, profile)
    return db
end

function modPrototype:RegisterOption()

end

function Icetip:NewModule(name, embedHook, slince)
    if modules[name] then
	if not slince then
	    error("Icetip has `" .. name .. "` module", 2)
	else
	    return
	end
    end
    local mod = setmetatable({}, {__index = modPrototype});
    mod:SetName(name)
    for k, v in pairs(modmethod) do
	mod[v] = modhandler[v];
    end
    modules[name] = mod;
    
    if embedHook then
	LibStub("AceHook-3.0"):Embed(mod);
    end
    return mod
end

function Icetip:GetModule(name, slince)
    if not slince then
	if not modules[name] then
	    error("Icetip Module "..name.." not found", 2);
	end
    end
    return modules[name]
end

function Icetip:GetModules()
    return pairs(modules);
end

function Icetip:HasModule(name)
    if modules[name] then
	return true
    end

    return false
end

function Icetip:OnTooltipMethod(name, ...)
    for i = 1, 3 do
	local methodName;
	if i == 1 then
	    methodName = "PreTooltip"..name;
	elseif i == 2 then
	    methodName = "OnTooltip"..name
	else
	    methodName = "PostTooltip"..name
	end
	self:CallMethodAllModules(methodName, ...);
    end
end

function Icetip:CallMethodAllModules(methodName, ...)
    for name, module in self:GetModules() do
	if module[methodName] and module._enabled then
	    local succ, ret = pcall(module[methodName], module, ...)
	    if not succ then
		geterrorhandler()(ret)
	    end
	end
    end
end

----------------------------------------------------------------
----------------------- init addon  ----------------------------
----------------------------------------------------------------
function Icetip:OnInitialize()
    --register sharedmedia
    SM:Register("border", "Blank", [[Interface\AddOns\Icetip\media\blank.tga]]);
    SM:Register("background", "Blank", [[Interface\AddOns\Icetip\media\blank.tga]]);
    SM:Register("statusbar", "Smooth", [[Interface\AddOns\Icetip\media\Smooth.tga]]);

    local db = LibStub("AceDB-3.0"):New("IcetipDB", default, "Default");
    --db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged");
    --db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged");
    --db.RegisterCallback(self, "OnProfileReset", "ProfileChanged");

    self.acedb = db;
    self.db = db.profile;

    local iceLDB;
    if LDB then
	iceLDB = LDB:NewDataObject("Icetip", {
	    type = "data source",
	    text = "Icetip",
	    icon = "Interface\\Icons\\achievement_worldevent_brewmaster",
	    OnClick = function()
		LibStub("AceConfigDialog-3.0"):SetDefaultSize("Icetip", 650, 580)
		LibStub("AceConfigDialog-3.0"):Open("Icetip")
	    end
	})
    end

    if icon and iceLDB then
	icon:Register("Icetip", iceLDB, self.db.minimap);
    end
end

function Icetip:OnEnable()
    for name, mod in self:GetModules() do
	if (self.db.modules[name].enabled) then
	    if mod["OnEnable"] and type(mod["OnEnable"]) then
	       mod:Enable();
	    end
	end
    end

    for _, tooltip in pairs(tooltips) do
        self:HookScript(tooltip, "OnShow", "Tooltip_OnShow");
        self:HookScript(tooltip, "OnHide", "Tooltip_OnHide");

        self:HookScript(tooltip, "OnUpdate", "Tooltip_OnUpdate");

        self:HookScript(tooltip, "OnTooltipCleared", "Tooltip_Cleared");
        self:HookScript(tooltip, "OnTooltipSetUnit", "Tooltip_SetUnit");
        self:HookScript(tooltip, "OnTooltipSetItem", "Tooltip_SetItem");
        self:HookScript(tooltip, "OnTooltipSetSpell", "Tooltip_SetSpell");
        self:HookScript(tooltip, "OnTooltipSetQuest", "Tooltip_SetQuest");
        self:HookScript(tooltip, "OnTooltipSetAchievement", "Tooltip_SetAchievement");
        --self:HookScript(tooltip, "OnTooltipSetDefaultAnchor", "Tooltip_SetDefaultAnchor");
    end

    GameTooltipStatusBar:Hide();
    GameTooltipStatusBar:ClearAllPoints();

    --GameTooltip.GetBackdropColor = function()
    --    return unpack(self.db.bgColor["other"])
    --end
    --GameTooltip.GetBackdropBorderColor = function()
    --    return self.db.border_color["r"], self.db.border_color["g"], self.db.border_color["b"], self.db.border_color["a"]
    --end

    --local previousDead = false
    --self:ScheduleRepeatingTimer(function() 
    --    local mouse_unit = Icetip:GetMouseoverUnit()
    --    if UnitExists(mouse_unit) then
    --        if UnitIsDeadOrGhost(mouse_unit) then
    --    	if previousDead == false then
    --    	    GameTooltip:Hide()
    --    	    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
    --    	    GameTooltip:SetUnit(mouse_unit)
    --    	    GameTooltip:Show()
    --    	end
    --    	previousDead = true
    --        else
    --    	previousDead = false
    --        end
    --    else
    --        previousDead = nil
    --    end
    --end, 0.05)

    --self:RegisterEvent("MODIFIER_STATE_CHANGED");
end

function Icetip:ShortValue(value)
    if value ~= nil then
	if value >= 1000000 then return format('%.1fm', value / 1000000)
	elseif value >= 1000 then return format('%.1fk', value / 1000)
	else return value end
    end
end

function Icetip:GetMouseoverUnit()
    local _, tooltipUnit = GameTooltip:GetUnit()
    if not tooltipUnit or not UnitExists(tooltipUnit) or UnitIsUnit(tooltipUnit, "mouseover") then
	return "mouseover"
    else
	return tooltipUnit
    end
end

function Icetip:MODIFIER_STATE_CHANGED(event, modifier, down)
    local m = self.db.tipmodifier.modifier;
    if modifier:match(m) == nil then
	return
    end
    local frame = GetMouseFocus();
    if frame == WorldFrame or frame == UIParent then
	local mouseover_unit = self:GetMouseoverUnit();
	if not UnitExists(mouseover_unit) then
	    GameTooltip:Hide()
	end
	GameTooltip:Hide();
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetUnit(mouseover_unit);
	GameTooltip:Show();
    else
	local onLeave, onEnter = frame:GetScript("OnLeave"), frame:GetScript("OnEnter");
	if onLeave then
	    self.modifierFrame = frame;
	    onLeave(frame);
	    self.modifierFrame = nil;
	end
	if onEnter then
	    self.modifierFrame = frame;
	    onEnter(frame);
	    self.modifierFrame = nil;
	end
    end
end

local forgetNextOnTooltipMethod = false
function Icetip:Tooltip_OnShow(tooltip, ...)
    self:CallMethodAllModules("PreOnTooltipShow", tooltip, ...);

    --if tooltip == GameTooltip then
    --    if not doneOnTooltipMethod then
    --        if tooltip:GetUnit() then
    --    	self:OnTooltipMethod("SetUnit", tooltip, ...);
    --    	forgetNextOnTooltipMethod = true
    --        elseif tooltip:GetItem() then
    --    	forgetNextOnTooltipMethod = true
    --        elseif tooltip:GetSpell() then
    --    	forgetNextOnTooltipMethod = true;
    --        end
    --    end

    --    local show;
    --    if tooltip:IsOwned(UIParent) then
    --        if tooltip:GetUnit() then
    --    	show = self.db.tipmodifier.units;
    --        else
    --    	show = self.db.tipmodifier.objects
    --        end
    --    else
    --        if tooltip:GetUnit() then
    --    	show = self.db.tipmodifier.unitFrames;
    --        else
    --    	show = self.db.tipmodifier.otherFrames;
    --        end
    --    end

    --    local modifier = self.db.tipmodifier.modifier;

    --    if modifier == "ALT" then
    --        if not IsAltKeyDown() then
    --    	tooltip:Hide()
    --    	return;
    --        end
    --    elseif modifier == "SHIFT" then
    --        if not IsShiftKeyDown() then
    --    	tooltip:Hide()
    --    	return;
    --        end
    --    elseif modifier == "CTRL" then
    --        if not IsControlKeyDown() then
    --    	tooltip:Hide()
    --    	return;
    --        end
    --    end

    --    if show == "notcombat" then
    --        if InCombatLockdown() then
    --    	tooltip.justHide = true;
    --    	tooltip:Hide()
    --    	tooltip.justHide = nil;
    --    	return;
    --        end
    --    elseif show == "never" then
    --        tooltip.justHide = true;
    --        tooltip:Hide();
    --        tooltip.justHide = nil
    --    end
    --end

    self.hooks[tooltip].OnShow(tooltip, ...)
    self:CallMethodAllModules("OnTooltipShow", tooltip);
end

function Icetip:Tooltip_OnHide(tooltip, ...)
    doneOnTooltipMethod = false;
    forgetNextOnTooltipMethod = false

    self:CallMethodAllModules("OnTooltipHide");
    if self.hooks[tooltip] and self.hooks[tooltip].OnHide then
	--reset gametooltip style
	--local ct = self.db.bgColor["other"];
	--tooltip:SetBackdropColor(unpack(ct));
	--tooltip:SetBackdropBorderColor(self.db.border_color["r"], self.db.border_color["g"], self.db.border_color["b"], self.db.border_color["a"]);
	self.hooks[tooltip].OnHide(tooltip, ...)
    end
end

local doneOnTooltipMethod;
function Icetip:Tooltip_SetUnit(tooltip, ...)
    GameTooltipStatusBar:Hide();
    GameTooltipStatusBar:ClearAllPoints();
    local doneOnTooltipMethod = true
    if forgetNextOnTooltipMethod then
	forgetNextOnTooltipMethod = false
    else
	self:OnTooltipMethod("SetUnit", tooltip, ...); 
    end
end

function Icetip:Tooltip_SetItem(tooltip, ...)
    --local doneOnTooltipMethod = true
    if forgetNextOnTooltipMethod then
	forgetNextOnTooltipMethod = false
    else
	self:OnTooltipMethod("SetItem", tooltip, ...);
    end
end

function Icetip:Tooltip_SetSpell(tooltip, ...)
    --local doneOnTooltipMethod = true
    if forgetNextOnTooltipMethod then
	forgetNextOnTooltipMethod = false
    else
	self:OnTooltipMethod("SetSpell", tooltip, ...);
    end
end

function Icetip:Tooltip_SetQuest(tooltip, ...)
    if forgetNextOnTooltipMethod then
	forgetNextOnTooltipMethod = false
    else
	self:OnTooltipMethod("SetQuest", tooltip, ...);
    end
end

function Icetip:Tooltip_SetAchievement(tooltip, ...)
    if forgetNextOnTooltipMethod then
	forgetNextOnTooltipMethod = false
    else
	self:OnTooltipMethod("SetAchievement", tooltip, ...);
    end
end

function Icetip:Tooltip_Cleared(tooltip, ...)

end

function Icetip:Tooltip_SetDefaultAnchor(tooltip, ...)

end

function Icetip:Tooltip_OnUpdate(tooltip, elapsed)

end
