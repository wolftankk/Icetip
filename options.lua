local addonName, Icetip = ...

local SM = LibStub("LibSharedMedia-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local icon = LibStub("LibDBIcon-1.0", true);
local _order = 0
local options;

----load module
--local HealthBar = Icetip:GetModule("HealthBar");
--local PowerBar = Icetip:GetModule("PowerBar");
--local Icetip_AppStyle = Icetip:GetModule("Appstyle")
--local Icetip_MouseTarget = Icetip:GetModule("MouseTarget");
--local Icetip_RaidTarget = Icetip:GetModule("RaidTarget");

local function order()
    _order = _order + 1;
    return _order
end

--
--
--local barPosition = {
--    ["TOP"] = L["Tooltip Top"],
--    ["BOTTOM"] = L["Tooltip Bottom"],
--    --["INNER"] = L["Tooltip inner"]
--    --["LEFT"] = L["Tooltip Left"],
--    --["RIGHT"] = L["Tooltip Right"],
--}
--
--local bartextStyle = {
--    ["number"] = L["Num"],
--    ["percent"] = L["Percent"],
--    ["pernumber"] = L["Num(precent)"],
--}
--
--local modifierKeys = {
--    ["NONE"] = NONE,
--    ["ALT"] = ALT_KEY,
--    ["SHIFT"] = SHIFT_KEY,
--    ["CTRL"] = CTRL_KEY
--}
--
--local tipShown = {
--    ["always"] = L["Always"],
--    ["notcombat"] = L["Out of combat"],
--    ["never"] = L["Never"],
--}

local function CreateOption()
    local db = Icetip.db
    if not options then
	options = {
	    type = "group",
	    name = "Icetip",
	    order = order(),
	    args = {
		version = {
		    type = "description",
		    order = order(),
		    name = L["|cffffd200Version: "]..Icetip.vesion.."|r",
		},
		minimap = {
		    type = "toggle",
		    order = order(),
		    name = L["Show minimap icon"],
		    desc = L["Show the icon on the minimap"],
		    get = function()
			return (not db.minimap.hide)
		    end,
		    set = function(_, v)
			db.minimap.hide = not db.minimap.hide;
			icon:Refresh("Icetip", db.minimap)
		    end
		}
--		general = {
--		    type = "group",
--		    name = L["General"],
--		    desc = L["Change how the tooltip appearance in grneral."],
--		    order = order(),
--		    args = {
	--itemborder = {
	--    type = "toggle",
	--    order = order(),
	--    name = L["Colored tooltip border"],
	--    get = function() return db.itemQBorder end,
	--    set = function(_, v) db.itemQBorder = v end,
	--},
--			    },
--			},
--			fadeout = {
--			    type = "group",
--			    inline = true,
--			    name = L["Fadeout configure"],
--			    desc = L["Change how the tooltip fades."],
--			    order = order(),
--			    args = {
--			    },
--			},
--			tipshow = {
--			    type = "group",
--			    inline = true,
--			    name = L["Show tooltips"],
--			    order = order(),
--			    args = {
--				unit = {
--				    type = "select",
--				    order = order(),
--				    name = L["World units"],
--				    desc = L["Show the tooltip for world units if..."],
--				    values = tipShown,
--				    get = function() return db.tipmodifier.units end,
--				    set = function(_, v)
--					db["tipmodifier"].units = v
--				    end,
--				},
--				objframe = {
--				    type = "select",
--				    order = order(),
--				    name = L["World objects"],
--				    desc = L["Show the tooltip for world objects if..."],
--				    values = tipShown,
--				    get = function() return db.tipmodifier.objects end,
--				    set = function(_, v)
--					db["tipmodifier"].objects = v
--				    end,
--				},
--				unitframe = {
--				    type = "select",
--				    order = order(),
--				    name = L["Unit frames"],
--				    desc = L["Show the tooltip for unit frames if..."],
--				    values = tipShown,
--				    get = function() return db["tipmodifier"].unitFrames end,
--				    set = function(_, v)
--					db["tipmodifier"].unitFrames = v
--				    end,
--				},
--				otherframe = {
--				    type = "select",
--				    order = order(),
--				    name = L["Non-unit frames"],
--				    desc = L["Show the tooltip for non-unit framers if..."],
--				    values = tipShown,
--				    get = function() return db["tipmodifier"].otherFrames end,
--				    set = function(_, v)
--					db["tipmodifier"].otherFrames = v
--				    end,
--				},
--				modifiekey = {
--				    type = "select",
--				    order = order(),
--				    name = L["Only show with modifiekey"],
--				    desc = L["Show the tooltip if the specified modifier is being held down"],
--				    values = modifierKeys,
--				    get = function() return db["tipmodifier"].modifier end,
--				    set = function(_, v)
--					db["tipmodifier"].modifier = v;
--				    end
--				}
--			    },
--			},
--		    },
--		},
--		position = {
--		    type = "group",
--		    name = L["Position"],
--		    desc = L["Change where is the tooltip is showed."],
--		    order = order(),
--		    args = {
--		    },
--		},
--		raidIcon = {
--		    type = "group",
--		    name = L["Raid target icon"],
--		    desc = L["Change how the raid target icon shows."],
--		    order = order(),
--		    args = {
--			enable = {
--			    type = "toggle",
--			    name = L["Enable"],
--			    desc = L["Toggle show the raid target icon on the tooltip."],
--			    order = order(),
--			    width = "full",
--			    get = function() return db["raidtarget"].enable end,
--			    set = function(_, v) 
--				db["raidtarget"].enable = v 
--				if db["raidtarget"].enable then
--				    Icetip_RaidTarget:Enable();
--				else
--				    Icetip_RaidTarget:Disable();
--				end
--			    end,
--			},
--		},
--		statusbar = {
--		    type = "group",
--		    order =order(),
--		    name = L["Status bar"],
--		    desc = L["Options for the tooltip's status bar."],
--		    args = {
--			--healbar
--			manabarHeader = {
--			    type = "group",
--			    order = order(),
--			    name = L["Power bar"],
--			    inline = true,
--			    args = {
--				powerbar = {
--				    type = "toggle",
--				    order = order(),
--				    name = L["Enable"],
--				    desc = L["Toggle the power bar on the tooltip."],
--				    get = function() return db["powerbar"].enable end,
--				    set = function(_, v)
--					db["powerbar"].enable = v
--					if v then
--					    PowerBar:Enable()
--					else
--					    PowerBar:Disable()
--					end
--					PowerBar:SetBarPoint()
--				    end
--				},
--				texture = {
--				    type = "select",
--				    order = order(),
--				    name = L["Texture"],
--				    desc = L["The texture which the power bar uses."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    dialogControl = "LSM30_Statusbar",
--				    values = AceGUIWidgetLSMlists.statusbar,
--				    get = function() return db["powerbar"].texture end,
--				    set = function(_, v)
--					db["powerbar"].texture = v
--					PowerBar.powerbar:SetStatusBarTexture(SM:Fetch("statusbar", v));
--				    end
--				},
--				size = {
--				    type = "range",
--				    order = order(),
--				    name = L["Size"],
--				    desc = L["The size of the power bar."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    min = 1,
--				    max = 20,
--				    step = 1,
--				    get = function() return db["powerbar"].size end,
--				    set = function(_, v)
--					db["powerbar"].size = v
--					PowerBar.powerbar:SetHeight(tonumber(v));
--				    end,
--				},
--				position = {
--				    type = "select",
--				    order = order(),
--				    name = L["Position"],
--				    desc = L["The position of the power bar relative to the tooltip."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    values = barPosition,
--				    get = function() return db["powerbar"].position end,
--				    set = function(_, v) 
--					db["powerbar"].position = v
--					PowerBar:SetBarPoint()
--				    end,
--				},
--				showpbtext = {
--				    type = "toggle",
--				    order = order(),
--				    name = L["Power bar text"],
--				    desc = L["Show the status text on the power bar."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    get = function() return db["powerbar"].showText end,
--				    set = function(_, v)
--					db["powerbar"].showText = v
--				    end
--				},
--				pbfont = {
--				    type = "select",
--				    order = order(),
--				    name = L["Font"],
--				    desc = L["What font face to use."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    hidden = function() return not db["powerbar"].showText end,
--				    dialogControl = "LSM30_Font",
--				    values = AceGUIWidgetLSMlists.font,
--				    get = function() return db["powerbar"].font end,
--				    set = function(_, v)
--					db["powerbar"].font = v
--					PowerBar.powerbar.pbtext:SetFont(SM:Fetch("font", v), db["powerbar"].fontSize, "Outline");
--				    end
--				},
--				pbfontsize = {
--				    type = "range",
--				    order = order(),
--				    name = L["Font size"],
--				    desc = L["Change what size is the font."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    hidden = function() return not db["powerbar"].showText end,
--				    min = 8,
--				    max = 16,
--				    step = 1,
--				    get = function() return db["powerbar"].fontSize end,
--				    set = function(_, v)
--					db["powerbar"].fontSize = v
--					PowerBar.powerbar.pbtext:SetFont(SM:Fetch("font", v), db["powerbar"].fontSize, "Outline");
--				    end,
--				},
--				pbtextstyle = {
--				    type = "select",
--				    order = order(),
--				    name = L["Text style"],
--				    desc = L["Sets the text style."],
--				    disabled = function() return not db["powerbar"].enable end,
--				    hidden = function() return not db["powerbar"].showText end,
--				    values = bartextStyle,
--				    get = function() return db["powerbar"].style end,
--				    set = function(_, v)
--					db["powerbar"].style = v
--				    end
--				},
--			    },
--			},
--		    },
--		},
	    },
	}

	for name, mod in Icetip:GetModules() do
	    options.args["module_"..name] = {
		type = "group",
		name = mod.label or name;
		order = mod.order or order(),
		args = {
		    enable = {
			type = "toggle",
			name = L["Enable"],
			desc = (mod.description or L["Toggle %s module."]:format(mod.label or name)),
			order = 0,
			width = "full",
			get = function() return db.modules[name].enabled end,
			set = function(_, v) 
			    db.modules[name].enabled = v
			    if (v) then
				mod:Enable()
			    else
				mod:Disable()
			    end
			end,
		    }
		}
	    }

	    if mod.GetOptions then
		local modOptions = mod:GetOptions();
	        if modOptions and type(modOptions) == "table" then
	            for key, value in pairs(modOptions) do
	        	options.args["module_"..name].args[key] = value
	        	options.args["module_"..name].args[key].disabled = function() return not mod:IsEnabled() end;
	            end
	        end
	    end
	end

	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Icetip.acedb);
	options.args.profile.order = 9999;
    end

    return options
end

function Icetip:RegisterOptions()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Icetip", CreateOption);
    SlashCmdList["ICETIP"] = function()
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Icetip", 650, 580)
	LibStub("AceConfigDialog-3.0"):Open("Icetip")
    end
    SLASH_ICETIP1 = "/icetip";
end
