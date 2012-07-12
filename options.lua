local addonName, Icetip = ...
local SM = LibStub("LibSharedMedia-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local icon = LibStub("LibDBIcon-1.0", true);
local _order = 0
local options;

local function order()
    _order = _order + 1;
    return _order
end

local modifierKeys = {
    --["NONE"] = NONE,
    ["ALT"] = ALT_KEY,
    ["SHIFT"] = SHIFT_KEY,
    ["CTRL"] = CTRL_KEY
}

local tipShown = {
    ["always"] = L["Always"],
    ["notcombat"] = L["Out of combat"],
    ["never"] = L["Never"],
}

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
		general = {
		    type = "group",
		    name = L["General"],
		    desc = L["General settings"],
		    order = order(),
		    args = {
			minimap = {
			    type = "toggle",
			    order = order(),
			    name = L["Show minimap icon"],
			    get = function()
				return (not db.minimap.hide)
			    end,
			    set = function(_, v)
				db.minimap.hide = not db.minimap.hide;
				icon:Refresh("Icetip", db.minimap)
			    end
			},
		    },
		},
		scene = {
		    type = "group",
		    name = L["Scene"],
		    order = order(),
		    args = {
		    },
		}
	    },
	}

	for i, u in pairs({"units", "objects", "unitFrames", "otherFrames"}) do
	    options.args["scene"].args["header"..i] = {
		type = "header",
		order = order(),
		name = L[u.."_header"],
	    }
	    options.args["scene"].args["description"..i] = {
		type = "description",
		order = order(),
		name = L[u.."_desc"],
	    }
	    options.args["scene"].args["show"..i] = {
	    	type = "select",
	    	order = order(),
	    	name = L["Show"],
	    	desc = L["Show the tooltip if..."],
	    	values = tipShown,
	    	get = function() return db.tipmodifier[u].show end,
	    	set = function(_, v)
	    	    db["tipmodifier"][u].show = v
	    	end,
	    }
	    options.args["scene"].args["modifier"..i] = {
	        type = "multiselect",
	        order = order(),
	        name = L["Only show with modifiekey"],
	        desc = L["Show the tooltip if the specified modifier is being held down"],
	        values = modifierKeys,
	        get = function(_, v) return db.tipmodifier[u].modifiers[v] end,
	        set = function(_, k, v)
	            db.tipmodifier[u].modifiers[k] = v
	        end
	    }
	end

	for name, mod in Icetip:GetModules() do
	    options.args["module_"..name] = {
		type = "group",
		name = mod.label or name;
		order = (mod.order or order()) + 9000,
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
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Icetip", 800, 600)
	LibStub("AceConfigDialog-3.0"):Open("Icetip")
    end
    SLASH_ICETIP1 = "/icetip";
end
