------------------------------------------------
--Icetip
--Description: wow tooltip
--Author: 月色狼影@cwdg
--$Rev$
--$Id: core.lua 3295 2010-07-12 03:16:20Z 月色狼影 $
------------------------------------------------
local addonName, Icetip = ...
Icetip = LibStub("AceAddon-3.0"):NewAddon(Icetip, addonName, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0");
Icetip.vesion = GetAddOnMetadata(addonName, "Version") 
Icetip.revision = tonumber(("$Revision$"):match("%d+"));
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
        --FriendsTooltip,
        --BNToastFrame.tooltip
}
local default = {
    profile = {
        scale = 1,
        minimap = {
            hide = false, 
        },
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
        --style
        tooltipStyle = {
            bgTexture = "Blank",
            borderTexture = "Blank",
            tile = false,
            tileSize = 8,
            EdgeSize = 2,
            customColor = true,
        },
        itemQBorder = true,
        setAnchor = {
            unitAnchor = "CURSOR_BOTTOM",
            unitOffsetX = 0,
            unitOffsetY = 0,
            frameAnchor = "BOTTOMRIGHT",
            frameOffsetX = -93,
            frameOffsetY = 110,
        },
        tooltipFade = {
            units = "hide",
            objects ="fade",
            unitFrames = "fade",
            otherFrames = "hide",
        },
        tipmodifier = {
            units = "always",
            objects = "always",
            unitFrames = "always",
            otherFrames = "always",
            modifier = "NONE",
        },
        healthbar = {
            texture = "Blizzard",
            size = 5,
            position = "BOTTOM",
            enable = true,
            showText = false,
            font = "Friz Quadrata TT",
            fontSize = 9,
            fontflag = "Outline",
            style = "number",
            short = true,
        },
        powerbar = {
            texture = "Blizzard",
            size = 5,
            position = "BOTTOM",
            enable = true,
            showText = false,
            font = "Friz Quadrata TT",
            fontSize = 9,
            fontflag = "Outline",
            style = "number",
            short = true,
        },
        mousetarget = {
            showTalent = true,
            showTarget = true,
            showFaction = true,
            showServer = true,
            colorBorderByClass = true,
            colorNameByClass = false,
            SGuildColor = {
                r = 0.9,
                g = 0.45,
                b = 0.7,
            },
            DGuildColor = {
                r = 0.8,
                g = 0.8,
                b = 0.8,
            }
        },
        raidtarget = {
            enable = false,
            position = "TOP",
            size = 20,
        },
        buff = {
            enable = false,
        }
    }
}

local function ItemQualityBorder()
    for i=1, #tooltips do
        if not tooltips[i]["GetItem"] then return end
        local item = select(2, tooltips[i]:GetItem());
        if item then
            local quality = select(3, GetItemInfo(item));
            if quality then
                local r, g, b = GetItemQualityColor(quality);
                tooltips[i]:SetBackdropBorderColor(r, g, b);
            end
        end
    end
end

--------------------------------------------------------------
--- icetip mod
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

function Icetip:NewModule(name, embedHook)
    --has module
    if modules[name] then
        return
    end
    local mod = {};
    mod.name = name;
    for k, v in pairs(modmethod) do
        mod[v] = modhandler[v];
    end
    modules[name] = mod;
    
    --need hooked lib?
    if embedHook then
        LibStub("AceHook-3.0"):Embed(mod);
    end
    return mod
end

function Icetip:GetModule(name)
    return modules[name]
end

function Icetip:GetModules()
    return pairs(modules);
end

function Icetip:OnTooltipMethod(name)
    for i = 1, 3 do
        local methodName;
        if i == 1 then
            methodName = "PreTooltip"..name;
        elseif i == 2 then
            methodName = "OnTooltip"..name
        else
            methodName = "PostTooltip"..name
        end
        self:CallMethodAllModules(methodName);
    end
end

function Icetip:CallMethodAllModules(methodName, ...)
    for name, module in self:GetModules() do
        if module[methodName] then
            local succ, ret = pcall(module[methodName], module, ...)
            if not succ then
                geterrorhandler()(ret)
            end
        end
    end
end

----------------------------------------------------------------
--- init addon  --------------------------------------------------------
----------------------------------------------------------------

function Icetip:OnInitialize()
    SM:Register("border", "Blank", [[Interface\AddOns\Icetip\media\blank.tga]]);
    SM:Register("background", "Blank", [[Interface\AddOns\Icetip\media\blank.tga]]);
    local db = LibStub("AceDB-3.0"):New("IcetipDB", default, "Default");
    db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged");
    db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged");
    db.RegisterCallback(self, "OnProfileReset", "ProfileChanged");
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
        mod.db = self.db;
        if mod["OnEnable"] and type(mod["OnEnable"]) then
            mod["OnEnable"](mod);
        end
    end
    --hook
    self:RawHook(GameTooltip, "FadeOut", "GameTooltip_FadeOut", true);
    self:RawHook(GameTooltip, "Hide", "GameTooltip_Hide", true);
    for _, tooltip in pairs(tooltips) do
        self:HookScript(tooltip, "OnShow", "GameTooltip_OnShow");
        self:HookScript(tooltip, "OnHide", "GameTooltip_OnHide");
    end
    self:HookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_SetUnit");
    self:HookScript(GameTooltip, "OnTooltipSetItem", "GameTooltip_SetItem")

    local previousDead = false
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
    self:RegisterEvent("CURSOR_UPDATE");
    self:RegisterEvent("MODIFIER_STATE_CHANGED");
end

function Icetip:ShortValue(value)

end

local forgetNextOnTooltipMethod = false

--update db
function Icetip:ProfileChanged(db)
	
end

function Icetip:GameTooltip_FadeOut(tooltip, ...)
    self.hooks[tooltip].FadeOut(tooltip, ...)
    local kind
    local db = self.db["tooltipFade"];
    
    if GameTooltip:GetUnit() then
        if GameTooltip:IsOwned(UIParent) then
            kind = db.units
        else
            kind = db.unitFrames
        end
    else
        if GameTooltip:IsOwned(UIParent) then
            kind = db.objects
        else
            kind = db.otherFrames
        end
    end
    
    if kind == "fade" then
        self.hooks[tooltip].FadeOut(tooltip, ...)
    else
        GameTooltip:Hide()
    end
end

function Icetip:GameTooltip_Hide(tooltip, ...)
    local db = self.db["tooltipFade"]
    if tooltip.justHide then
        return self.hooks[tooltip].Hide(tooltip, ...)
    end
    local kind
    if GameTooltip:GetUnit() then
        if GameTooltip:IsOwned(UIParent) then
            kind = db.units
        else
            kind = db.unitFrames
        end
    else
        if GameTooltip:IsOwned(UIParent) then
            kind = db.objects
        else
            kind = db.otherFrames
        end
    end
    
    if kind == "fade" then
        return GameTooltip:FadeOut()
    else
        return self.hooks[tooltip].Hide(tooltip, ...)
    end
end

function Icetip:GameTooltip_OnShow(tooltip, ...)
    modules["Appstyle"]:Tooltip_OnShow(tooltip, ...);
    if self.db.itemQBorder and tooltip:GetItem() then
        ItemQualityBorder()
    else
        tooltip:SetBackdropBorderColor(self.db["border_color"].r, self.db["border_color"].g, self.db["border_color"].b, self.db["border_color"].a);
    end

    if tooltip:GetUnit() then
        self:PreTooltipSetUnit()
        forgetNextOnTooltipMethod = true
        --self:CallMethodAllModules("OnTooltipShow");
    elseif tooltip:GetItem() then
        forgetNextOnTooltipMethod = true
    elseif tooltip:GetSpell() then
        forgetNextOnTooltipMethod = true;
    end

    if self.db["tooltipStyle"].customColor then
        self:SetBackgroundColor(nil, nil, nil, nil, nil, tooltip)
    end
    self:SetTooltipScale(nil, self.db.scale)

    local show;
    if tooltip:IsOwned(UIParent) then
        if tooltip:GetUnit() then
            show = self.db.tipmodifier.units;
        else
            show = self.db.tipmodifier.objects
        end
    else
        if tooltip:GetUnit() then
            show = self.db.tipmodifier.unitFrames;
        else
            show = self.db.tipmodifier.otherFrames;
        end
    end

    local modifier = self.db.tipmodifier.modifier;

    if modifier == "ALT" then
        if not IsAltKeyDown() then
            tooltip:Hide()
            return;
        end
    elseif modifier == "SHIFT" then
        if not IsShiftKeyDown() then
            tooltip:Hide()
            return;
        end
    elseif modifier == "CTRL" then
        if not IsControlKeyDown() then
            tooltip:Hide()
            return;
        end
    end

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
    self.hooks[tooltip].OnShow(tooltip, ...)
    self:CallMethodAllModules("OnTooltipShow");
    self:OnTooltipShow();
end

function Icetip:GameTooltip_OnHide(tooltip, ...)
    self:OnTooltipHide()
    for name, mod in self:GetModules() do
        if mod["OnTooltipHide"] and type(mod["OnTooltipHide"]) == "function" then
            mod["OnTooltipHide"](mod);
        end
    end
    forgetNextOnTooltipMethod = false
    if self.hooks[tooltip] and self.hooks[tooltip].OnHide then
        --reset gametooltip style
        local ct = self.db.bgColor["other"];
        tooltip:SetBackdropColor(unpack(ct));
        tooltip:SetBackdropBorderColor(self.db.border_color["r"], self.db.border_color["g"], self.db.border_color["b"], self.db.border_color["a"]);
        self.hooks[tooltip].OnHide(tooltip, ...)
    end
end

function Icetip:GameTooltip_SetUnit(tooltip, ...)
    if forgetNextOnTooltipMethod then
        forgetNextOnTooltipMethod = false
    else
        for name, mod in self:GetModules() do
            if mod["SetUnit"] and type(mod["SetUnit"]) == "function" then
                mod["SetUnit"](mod)
            end
        end
        
        self:OnTooltipSetUnit()
    end
end

function Icetip:GameTooltip_SetItem(tooltip, ...)
    forgetNextOnTooltipMethod = true
    if forgetNextOnTooltipMethod then
        forgetNextOnTooltipMethod = false
    end
end

local currentSameFaction = false
function Icetip:PreTooltipSetUnit()
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

function Icetip:SetBackgroundColor(given_kind, r, g,b,a, tooltip)
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

function Icetip:SetTooltipScale(tooltip, value)
    if not tooltip then
        tooltip = GameTooltip
    end
    
    tooltip:SetScale(value)
end

function Icetip:GetMouseoverUnit()
    local _, tooltipUnit = GameTooltip:GetUnit()
    if not tooltipUnit or not UnitExists(tooltipUnit) or UnitIsUnit(tooltipUnit, "mouseover") then
        return "mouseover"
    else
        return tooltipUnit
    end
end

local lastMouseoverUnit
local function checkUnitExistance()
    local mouseover_unit = Icetip:GetMouseoverUnit()
    if not GameTooltip:GetUnit() or not UnitExists(mouseover_unit) or (lastMouseoverUnit == "mouseover" and mouseover_unit ~= "mouseover") then
        Icetip:CancelTimer(Icetip_Fade_checkUnitExistance, true)
        local kind
        local db = Icetip.db["tooltipFade"]
        if GameTooltip:IsOwned(UIParent) then
            kind = db.units
        else
            kind = db.unitFrames
        end
        if kind == "fade" then
            GameTooltip:FadeOut()
        else
            GameTooltip:Hide()
        end
    end
end

local function checkAlphaFrame()
    if GameTooltip:GetAlpha() < 1 then
        Icetip:CancelTimer(Icetip_Fade_checkUnitExistance, true)
        local kind
        local db = Icetip.db["tooltipFade"]
        if GameTooltip:IsOwned(UIParent) then
            kind = db.objects
        else
            kind = db.otherFrames
        end

        if kind == "fade" then
            GameTooltip:FadeOut()
        else
            GameTooltip:Hide()
        end
    end
end

local cursorChangedWithTooltip = false
function Icetip:OnTooltipShow()
    self:CancelTimer(Icetip_Fade_runHide, true)
    if GameTooltip:GetUnit() then
        if not Icetip_Fade_checkUnitExistance then
            Icetip_Fade_checkUnitExistance = self:ScheduleRepeatingTimer(checkUnitExistance, 0)
        end
    else
        if GameTooltip:IsOwned(UIParent) then
            cursorChangedWithTooltip = true
        end
        if not Icetip_Fade_checkUnitExistance then
            Icetip_Fade_checkUnitExistance = self:ScheduleRepeatingTimer(checkAlphaFrame, 0)
        end
    end
end

function Icetip:OnTooltipHide()
    cursorChangedWithTooltip = false
    self:CancelTimer(Icetip_Fade_checkUnitExistance, true)
    Icetip_Fade_checkUnitExistance = nil;
end

function Icetip:OnTooltipSetUnit()
    lastMouseoverUnit = self:GetMouseoverUnit()
end

local function runHide()
    local db = Icetip.db["tooltipFade"]
    if db.objects == "fade" then
        GameTooltip:FadeOut()
    else
        GameTooltip:Hide()
    end
end

local function donothing() end

function Icetip:CURSOR_UPDATE(...)
    --reset
    self:CancelTimer(Icetip_Fade_runHide, true);
    self:CancelTimer(Icetip_Fade_doNothing, true);
    if cursorChangedWithTooltip then
        Icetip_Fade_runHide = self:ScheduleTimer(runHide, 0)
    else
        Icetip_Fade_doNothing = self:ScheduleTimer(donothing, 0)
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
