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
    WorldMapTooltip
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
	    },
	    aura = {
		enabled = false
	    }
	},
	tipmodifier = {
	    ['**'] = {
		show = "always", --options  always, notcombat, never
		modifiers = {
		    ALT = false,
		    SHIFT = false,
		    CTRL = false
		}
	    },
	}
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
    if self["OnEnable"] then
	self:OnEnable()
    end
end

function modPrototype:Disable()
    self._enabled = false;
    if self["OnDisable"] then
	self:OnDisable() 
    end
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
    local db
    if not Icetip.acedb:GetNamespace(self.name, true) then
	db = Icetip.acedb:RegisterNamespace(self.name, profile)
    else
	db = Icetip.acedb:GetNamespace(self.name, true)
    end
    return db
end

function Icetip:NewModule(name, label, embedHook, slince)
    if modules[name] then
	if not slince then
	    error("Icetip has `" .. name .. "` module", 2)
	else
	    return
	end
    end
    local mod = setmetatable({}, {__index = modPrototype});
    mod:SetName(name);
    mod.label = label;
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
    SM:Register("font", "Myriad Condensed Web", [[Interface\AddOns\Icetip\media\Myriad Condensed Web.ttf]])

    local db = LibStub("AceDB-3.0"):New("IcetipDB", default, "Default");
    self.acedb = db;
    self.db = db.profile;

    self:checkAndUpgrade();

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

    for name, mod in self:GetModules() do
	if mod["OnInitialize"] and type(mod["OnInitialize"]) then
	    mod:OnInitialize();
	end
    end

    Icetip:RegisterOptions();
end

function Icetip:OnEnable()
    for name, mod in self:GetModules() do
	if (self.db.modules[name].enabled) then
	    if mod["OnEnable"] and type(mod["OnEnable"]) then
	       mod:Enable();
	    end
	end
    end

    --HOOK tooltip
    for _, tooltip in pairs(tooltips) do
	--OnShow 
        self:HookScript(tooltip, "OnShow", "Tooltip_OnShow");
	--OnHide
        self:HookScript(tooltip, "OnHide", "Tooltip_OnHide");
	--OnUpdate
        self:HookScript(tooltip, "OnUpdate", "Tooltip_OnUpdate");

	--fire when tooltip has cleared
        self:HookScript(tooltip, "OnTooltipCleared", "Tooltip_Cleared");
	--fire when tooltip has SetUnit
        self:HookScript(tooltip, "OnTooltipSetUnit", "Tooltip_SetUnit");
	--SetItem
        self:HookScript(tooltip, "OnTooltipSetItem", "Tooltip_SetItem");
	--Set Spell
        self:HookScript(tooltip, "OnTooltipSetSpell", "Tooltip_SetSpell");
	--SetQuest
        self:HookScript(tooltip, "OnTooltipSetQuest", "Tooltip_SetQuest");
	--SetAchievement
        self:HookScript(tooltip, "OnTooltipSetAchievement", "Tooltip_SetAchievement");

	--tooltip position hook
        self:HookScript(tooltip, "OnTooltipSetDefaultAnchor", "Tooltip_SetDefaultAnchor");

	self:RawHook(tooltip, "Show", "Tooltip_Show", true);
    end
    
    --handler Statusbar, always hidden
    GameTooltipStatusBar:Hide();
    GameTooltipStatusBar:ClearAllPoints();

    local previousDead = false;
    self:ScheduleRepeatingTimer(function() 
        local mouse_unit = Icetip:GetMouseoverUnit()
        if UnitExists(mouse_unit) then
            if UnitIsDeadOrGhost(mouse_unit) then
        	if previousDead == false then
        	    GameTooltip:Hide()
        	    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
        	    GameTooltip:SetUnit(mouse_unit)
        	    GameTooltip:Show()
        	end
        	previousDead = true
            else
        	previousDead = false
            end
        else
            previousDead = nil
        end
    end, 0.05)

    --handler modifier
    self:RegisterEvent("MODIFIER_STATE_CHANGED");
end

--Check and upgrade IcetipDB
function Icetip:checkAndUpgrade()
    --Icetip 2.0, check tipmodifier
    local _;
    if (not self.db.tipmodifier) or (self.db.tipmodifier and not self.db.tipmodifier["units"].modifiers) then
	--update
	self.db.tipmodifier = {};
	for _, unit in pairs({"units", "objects", "unitFrames", "otherFrames"}) do
	    self.db.tipmodifier[unit] = {
		show = "always",
		modifiers = {
		    ALT = false,
		    SHIFT = false,
		    CTRL = false
		}
	    }
	end
    end
end

-------------------------------
--imporvide modifier
--See http://wow.curseforge.com/addons/icetip/tickets/4-show-hide-logic-update-mouse-position/
-------------------------------
-- need rewrite!
-- update key status
function Icetip:MODIFIER_STATE_CHANGED(event, modifier, down)
    --if not set
    if not GameTooltip._config then return end
    if (not GameTooltip._config.checkFunc) then return end
    local checkFunc = GameTooltip._config.checkFunc;

    local mayIShow = true;--yep, You can show it!
    --if it has key modifier
    if #checkFunc then
	for _, modifier in pairs(checkFunc) do
	    --must all true
	    mayIShow = mayIShow and modifierFuncs[modifier]()
	end

	--Oops, you need hide.
	if not mayIShow then
	    return nil
	end
    else
	--it's not include checkFunc, it will return ;
	return nil;
    end


    --Ohahah, I can show!
    if mayIShow then
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
end

-------------------------------------------------------------------------------------------------
-- Tooltip handler
-------------------------------------------------------------------------------------------------
local forgetNextOnTooltipMethod = false
local doneOnTooltipMethod = false;

function Icetip:Tooltip_Show(tooltip, ...)
    --self:CallMethodAllModules("PreTooltipShow", tooltip, ...)
    tooltip:SetHeight(0)
    self.hooks[tooltip].Show(tooltip, ...)
    tooltip._origin_offset = tooltip:GetHeight()
    self:CallMethodAllModules("PostTooltipShow", tooltip, ...)
end

local modifierFuncs = {
    ALT = function() return IsAltKeyDown() end,
    SHIFT = function() return IsShiftKeyDown() end,
    CTRL = function() return IsControlKeyDown() end
}
function Icetip:Tooltip_OnShow(tooltip, ...)
    tooltip._offset = nil
    self:CallMethodAllModules("PreOnTooltipShow", tooltip, ...);

    --Only handler GameTooltip OnShow
    if tooltip == GameTooltip then
        if doneOnTooltipMethod then
            if tooltip:GetUnit() then
        	self:OnTooltipMethod("SetUnit", tooltip, ...);
        	forgetNextOnTooltipMethod = true
            elseif tooltip:GetItem() then
        	forgetNextOnTooltipMethod = true
            elseif tooltip:GetSpell() then
        	forgetNextOnTooltipMethod = true;
            end
        end


	--get tooltip type, and get config
        local config;
        if tooltip:IsOwned(UIParent) then
            if tooltip:GetUnit() then
        	config = self.db.tipmodifier.units;
            else
        	config = self.db.tipmodifier.objects
            end
        else
            if tooltip:GetUnit() then
        	config = self.db.tipmodifier.unitFrames;
            else
        	config = self.db.tipmodifier.otherFrames;
            end
	end
	--tooltip._config = config;

        local modifiers = config.modifiers;
	local checkFunc = {}
	--get checkfunc when you seted key modifier
	for modifier, mvalue in pairs(modifiers) do
	    if mvalue then
		tinsert(checkFunc, modifier);
	    end
	end
	
	--temp config
	tooltip._config = {
	    config = config,
	    checkFunc = checkFunc
	}

	--TODO: NEED OPTIMIZING!!
	local mayIShow = true;--yep, You can show it!
	--if it has key modifier
	if #checkFunc then
	    for _, modifier in pairs(checkFunc) do
		--must all true
		mayIShow = mayIShow and modifierFuncs[modifier]()
	    end

	    --Oops, you need hide.
	    if not mayIShow then
		tooltip.justHide = true
		tooltip:Hide();
		tooltip.justHide = nil
		return
	    end
	end
    
	--now, check show type, incombat?
	local show = config.show;
        if show == "notcombat" then
            if InCombatLockdown() then
        	tooltip.justHide = true;
        	tooltip:Hide()
        	tooltip.justHide = nil;
        	return;
            end
        elseif show == "never" then
            tooltip.justHide = true;
            tooltip:Hide();
            tooltip.justHide = nil
        end
    end

    self.hooks[tooltip].OnShow(tooltip, ...)
    self:CallMethodAllModules("OnTooltipShow", tooltip);
end

function Icetip:Tooltip_OnHide(tooltip, ...)
    --reset
    doneOnTooltipMethod = false;
    forgetNextOnTooltipMethod = false
    tooltip._offset = nil
    tooltip._config = nil

    self:CallMethodAllModules("OnTooltipHide");
    if self.hooks[tooltip] and self.hooks[tooltip].OnHide then
	self:CallMethodAllModules("PostOnTooltipHide", tooltip, ...);

	self.hooks[tooltip].OnHide(tooltip, ...)
    end
end

function Icetip:Tooltip_SetUnit(tooltip, ...)
    GameTooltipStatusBar:Hide();
    GameTooltipStatusBar:ClearAllPoints();
    doneOnTooltipMethod = true
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
    if tooltip._offset and tooltip._offset > 0 then
	if tooltip:GetHeight() <= tooltip._offset then
	    tooltip:SetHeight(tooltip._offset)
	end
    end
end

---------------------------------------------
-- Common function
---------------------------------------------
function Icetip:GetMouseoverUnit()
    local _, tooltipUnit = GameTooltip:GetUnit()
    if not tooltipUnit or not UnitExists(tooltipUnit) or UnitIsUnit(tooltipUnit, "mouseover") then
	return "mouseover"
    else
	return tooltipUnit
    end
end

function Icetip:GetUnitByGUID(unitGUID)
    local unitID
    for i = 1, 4, 1 do
	if UnitGUID("party"..i) == unitGUID then unitID = "party"..i end
    end
    for i = 1, 40, 1 do
	if UnitGUID("raid"..i) == unitGUID then unitID = "raid"..i end
    end
    if UnitGUID("player") == unitGUID then
	unitID = "player"
    elseif UnitGUID("mouseover") == unitGUID then
	unitID = "mouseover"
    elseif UnitGUID("target") == unitGUID then
	unitID = "target"
    elseif UnitGUID("focus") == unitGUID then
	unitID = "focus"
    end
    return unitID
end

function Icetip:Hex(r, g, b)
    if (type(r) == "table") then
        if (r.r) then
            r,g,b = r.r, r.g, r.b
        else
            r, g, b = unpack(r);
        end
    end
    
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255);
end

function Icetip:FormatLargeNumber(number)
    if( number < 9999 ) then
        return number
    elseif( number < 999999 ) then
        return string.format("%.1fk", number / 1000)
    elseif( number < 99999999 ) then
        return string.format("%.2fm", number / 1000000)
    end
    
    return string.format("%dm", number / 1000000)
end

function Icetip:SmartFormatNumber(number)
    if( number < 999999 ) then
        return number
    elseif( number < 99999999 ) then
        return string.format("%.2fm", number / 1000000)
    end
    
    return string.format("%dm", number / 1000000)
end

function Icetip:GetClassColor(unit)
    if (not UnitIsPlayer(unit)) then
        return nil
    end

    local class = select(2, UnitClass(unit));

    return class and Icetip:Hex(RAID_CLASS_COLORS[class]);
end

function Icetip:FormatShortTime(seconds)
    if( seconds >= 3600 ) then
        return string.format("%dh", seconds / 3600)
    elseif( seconds >= 60 ) then
        return string.format("%dm", seconds / 60)
    end

    return string.format("%ds", seconds)
end

function Icetip:GetGradientColor(unit)
    local hpmax = UnitHealthMax(unit)
    local hp = UnitHealth(unit);
    local r1, g1, b1
    local r2, g2, b2

    local value;
    if hpmax == 0 then
        value = 0
    else
        value = hp/hpmax
    end

    if value <= 0.5 then
        value = value * 2
        r1, g1, b1 = 1, 0, 0
        r2, g2, b2 = 1, 1, 0
    else
        value = value * 2 - 1
        r1, g1, b1 = 1, 1, 0
        r2, g2, b2 = 0, 1, 0
    end

    return r1 +(r2-r1)*value, g1 + (g2-g1)*value,  b1 +(b2-b1)*value
end


