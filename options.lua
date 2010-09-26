local _, Icetip = ...

local SM = LibStub("LibSharedMedia-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Icetip")
local optionFrame = Icetip:NewModule("OptionFrame") 
Icetip.OptionFrame = optionFrame
local config
local _order = 0
local options;

--load module
local Icetip_HealthBar = Icetip:GetModule("HealthBar");
local Icetip_PowerBar = Icetip:GetModule("PowerBar");
local Icetip_AppStyle = Icetip:GetModule("Appstyle")
local Icetip_MouseTarget = Icetip:GetModule("MouseTarget");
local Icetip_RaidTarget = Icetip:GetModule("RaidTarget");

local function order()
	_order = _order + 1;
	return _order
end

local hidetype = {
	["hide"] = L["Hide"],
	["fade"] = L["Fadeout"],
}

local anchorType = {
	["CURSOR_BOTTOM"] = L["Mouse Top"],
	["CURSOR_TOP"] = L["Mouse Bottom"],
	["CURSOR_RIGHT"] = L["Mouse Left"],
	["CURSOR_LEFT"] = L["Mouse Right"],
	["CURSOR_TOPLEFT"] = L["Mouse Bottom Right"],
	["CURSOR_BOTTOMLEFT"] = L["Mouse Top Right"],
	["CURSOR_TOPRIGHT"] = L["Mouse Bottom Left"],
	["CURSOR_BOTTOMRIGHT"] = L["Mouse Top Left"],
	["BOTTOM"] = L["Bottom"],
	["TOP"] = L["Top"],
	["RIGHT"] = L["Right"],
	["LEFT"] = L["Left"],
	["BOTTOMRIGHT"] = L["Bottom Right"],
	["BOTTOMLEFT"] = L["Bottom Left"],
	["TOPRIGHT"] = L["Top Right"],
	["TOPLEFT"] = L["Top Left"],
	["CENTER"] = L["Center"],
	["PARENT_TOP"] = L["Parent Bottom"],
	["PARENT_BOTTOM"] = L["Parent Top"],
	["PARENT_RIGHT"] = L["Parent Left"],
	["PARENT_LEFT"] = L["Parent Right"],
	["PARENT_TOPLEFT"] = L["Parent Bottom Left"],
	["PARENT_TOPRIGHT"] = L["Parent Bottom Right"],
	["PARENT_BOTTOMLEFT"] = L["Parent Top Left"],
	["PARENT_BOTTOMRIGHT"] = L["Parent Top Right"],
}

local barPosition = {
	["TOP"] = L["Tooltip Top"],
	["BOTTOM"] = L["Tooltip Bottom"],
	--["LEFT"] = L["Tooltip Left"],
	--["RIGHT"] = L["Tooltip Right"],
}

local bartextStyle = {
	["number"] = L["Num"],
	["percent"] = L["Percent"],
	["pernumber"] = L["Num(precent)"],
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
					name = L["Icetip"]..L["|cffffd200Version: "]..Icetip.vesion.."|r",
				},
				general = {
					type = "group",
					name = L["General"],
					desc = L["Change how the tooltip appearance in grneral."],
					order = order(),
					args = {
						tot = {
							type = "toggle",
							order = order(),
							name = L["Toggle show target of target"],
							desc = L["Enable/Disable show target of target"],
							width = "full",
							get = function() return db["mousetarget"].showTarget end,
							set = function(_, v)
								db["mousetarget"].showTarget = v
							end
						},
						showtalent = {
							type = "toggle",
							order = order(),
							name = L["Toggle show target's talent"],
							width = "full",
							desc = L["Enable/Disable show target's talent"],
							get = function() return db["mousetarget"].showTalent end,
							set = function(_, v)
								db["mousetarget"].showTalent = v
							end
						},
						itemborder = {
							type = "toggle",
							order = order(),
							name = L["Colored tooltip border"],
							desc = L["When you watch a item, colored tooltip by item's quality color"],
							get = function() return db.itemQBorder end,
							set = function(_, v) db.itemQBorder = v end,
						},
						showfaction = {
							type = "toggle",
							order = order(),
							name = L["Toggle show npc faction"],
							desc = L["Enable/Disable to show a npc's reputation information between you"],
							get = function() return db["mousetarget"].showFaction end,
							set = function(_, v)
								db["mousetarget"].showFaction = v
							end,
						},
						tooltipBG = {
							type = "group",
							order = order(),
							name = L["Tooltip's style configure"],
							desc = L["Sets the tooltip's style"],
							inline = true,
							args = {
								bgtexture = {
									type = "select",
									dialogControl = "LSM30_Background",
									order = order(),
									name = L["Background style"],
									desc = L["Change the background texture.\n\n\Note:You may need to change the Background color to white to see some of the backgrounds properly."],
									values = AceGUIWidgetLSMlists.background,
									get = function() return db["tooltipStyle"].bgTexture end,
									set = function(_, v)
										db["tooltipStyle"].bgTexture = v
										Icetip_AppStyle:UpdateBackdrop()
									end,
								},
								bordertexture = {
									type = "select",
									dialogControl = "LSM30_Border",
									order = order(),
									name = L["Border style"],
									desc = L["Change the border texture.\n\nNote: You may need to change the Background color to white to see some of the backgrounds properly."],
									values = AceGUIWidgetLSMlists.border,
									get = function() return db["tooltipStyle"].borderTexture end,
									set = function(_, v)
										db["tooltipStyle"].borderTexture = v
										Icetip_AppStyle:UpdateBackdrop()
									end,
								},
								bgcolor = {
									type = "toggle",
									order = order(),
									name = L["Toggle custom background color"],
									desc = L["Enable/Disable custom background color"],
									get = function() return db["tooltipStyle"].customColor end,
									set = function(_, v)
										db["tooltipStyle"].customColor = v
									end
								},
								bordercolor = {
									type = "color",
									order = order(),
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
									order = order(),
									name = L["Background tile"],
									desc = L["Sets what texture tile the tooltip's background is."],
									get = function() return db["tooltipStyle"].tile end,
									set = function(_, v)
										db["tooltipStyle"].tile = v
										Icetip_Appstyle:UpdateBackdrop()
									end,
								},
								tilesize = {
									type = "range",
									order = order(),
									name = L["Tile size"],
									desc = L["Sets what size the tooltip's backgroud texture tile"],
									min = 4,
									max = 256,
									step = 1,
									disabled = function() return not db["tooltipStyle"].tile end,
									get = function() return db["tooltipStyle"].tileSize end,
									set = function(_, v)
										db["tooltipStyle"].tileSize = v
										Icetip_Appstyle:UpdateBackdrop()
									end
								},
								edgesize = {
									type = "range",
									order = order(),
									name = L["Border size"],
									desc = L["The size the border takes up."],
									min = 8,
									max = 32,
									step = 1,
									get = function() return db["tooltipStyle"].EdgeSize end,
									set = function(_, v)
										db["tooltipStyle"].EdgeSize = v
										Icetip_Appstyle:UpdateBackdrop()
									end,
								},
								tooltipScale = {
									type = "range",
									order = order(),
									name = L["Scale"],
									desc = L["Set how large the tooltip is."],
									min = 0,
									max = 2,
									isPercent = true,
									step = 0.01,
									get = function() return db.scale end,
									set = function(_, v) db.scale = v end,
								},
							},
						},
						fadeout = {
							type = "group",
							inline = true,
							name = L["Fadeout configure"],
							desc = L["Change how the tooltip fades."],
							order = order(),
							args = {
								unit = {
									type = "select",
									order = order(),
									name = L["World units"],
									desc = L["What kind of fade to use for world units (other players, NPC in the world, etc.)"],
									values = hidetype,
									get = function() return db["tooltipFade"].units end,
									set = function(_, v)
										db["tooltipFade"].units = v
									end,
								},
								objframe = {
									type = "select",
									order = order(),
									name = L["World objects"],
									desc = L["What kind of fade to use for world objects (mailbox, corpse, etc.)"],
									values = hidetype,
									get = function() return db["tooltipFade"].objects end,
									set = function(_, v)
										db["tooltipFade"].objects = v
									end,
								},
								unitframe = {
									type = "select",
									order = order(),
									name = L["Unit frames"],
									desc = L["What kind of fade to use for unit frames (myself, target, party member, etc.)"],
									values = hidetype,
									get = function() return db["tooltipFade"].unitFrames end,
									set = function(_, v)
										db["tooltipFade"].unitFrames = v
									end,
								},
								otherframe = {
									type = "select",
									order = order(),
									name = L["Non-unit frames"],
									desc = L["What kind of fade to use for non-unit frames (spells, items, etc.)"],
									values = hidetype,
									get = function() return db["tooltipFade"].otherFrames end,
									set = function(_, v)
										db["tooltipFade"].otherFrames = v
									end,
								},
							},
						},
					},
				},
				position = {
					type = "group",
					name = L["Position"],
					desc = L["Change where is the tooltip is showed."],
					order = order(),
					args = {
						header1 = {
							type = "header",
							order = order(),
							name = L["Unit"],
						},
						desc_1 = {
							type = "description",
							name = L["Options for unit mouseover tooltips(NPC, target, player, etc.)"],
							order = order(),
						},
						unitAnchor = {
							type = "select",
							order = order(),
							name = L["Anchor"],
							desc = L["The anchor with which the tooltips are showed."],
							values = anchorType,
							get = function() return db["setAnchor"].unitAnchor end,
							set = function(_, v)
								db["setAnchor"].unitAnchor = v
							end
						},
						space_1 = {
							type = "description",
							name = L["Sets anchor offset"],
							order = order(),
						},
						unitPosX = {
							type = "range",
							order = order(),
							name = L["Horizontal offset"],
							desc = L["Sets offset of the X"],
							min = tonumber(-(floor(GetScreenWidth()/5 + 0.5) * 5)),
							max = tonumber(floor(GetScreenWidth()/5 + 0.5) * 5),
							step = 1,
							get = function() return db["setAnchor"].unitOffsetX end,
							set = function(_, v)
								db["setAnchor"].unitOffsetX = v
							end
						},
						unitPoxY = {
							type = "range",
							order = order(),
							name = L["Vertical offset"],
							desc = L["Sets offset of the Y"],
							min = tonumber(-(floor(GetScreenHeight()/5 + 0.5) * 5)),
							max = tonumber(floor(GetScreenHeight()/5 + 0.5) * 5),
							step = 1,
							get = function() return db["setAnchor"].unitOffsetY end,
							set = function(_, v)
								db["setAnchor"].unitOffsetY = v
							end
						},
						--[[qEditPos = {
							type = "execute",
							order = order(),
							name = "quick edit",
						},]]
						--
						header2 = {
							type = "header",
							order = order(),
							name = L["Frame"],
						},
						desc_2 = {
							type = "description",
							name = L["Options for the frame mouseover tooltips(spells, items, etc.)"],
							order = order(),
						},
						frameAnchor = {
							type = "select",
							order = order(),
							name = L["Anchor"],
							desc = L["The anchor with which the tooltips are showed."],
							values = anchorType,
							get = function() return db["setAnchor"].frameAnchor end,
							set = function(_, v)
								db["setAnchor"].frameAnchor = v
							end
						},
						space_2 = {
							type = "description",
							name = L["Sets anchor offset"],
							order = order(),
						},
						framePosX = {
							type = "range",
							order = order(),
							name = L["Horizontal offset"],
							desc = L["Sets offset of the X"],
							min = tonumber(-(floor(GetScreenWidth()/5 + 0.5) * 5)),
							max = tonumber(floor(GetScreenWidth()/5 + 0.5) * 5),
							step = 1,
							get = function() return db["setAnchor"].frameOffsetX end,
							set = function(_, v)
								db["setAnchor"].frameOffsetX = v
							end
						},
						framePoxY = {
							type = "range",
							order = order(),
							name = L["Vertical offset"],
							desc = L["Sets offset of the Y"],
							min = tonumber(-(floor(GetScreenHeight()/5 + 0.5) * 5)),
							max = tonumber(floor(GetScreenHeight()/5 + 0.5) * 5),
							step = 1,
							get = function() return db["setAnchor"].frameOffsetY end,
							set = function(_, v)
								db["setAnchor"].frameOffsetY = v
							end
						},
						--[[qEditPos2 = {
							type = "execute",
							order = order(),
							name = "quick edit",
						},]]
					},
				},
				color = {
					type = "group",
					order = order(),
					name = L["Background color"],
					desc = L["Sets what color the tooltip's background is."],
					disabled = function() return not db["tooltipStyle"].customColor end,
					args = {
						guild = {
							type = "color",
							name = L["Guild and friends"],
							desc = L["Background color for your guildmates and friends."],
							order = order(),
							hasAlpha = true,
							get = function() return unpack(db.bgColor.guild) end,
							set = function(_, r, g, b, a)
								db.bgColor.guild[1], db.bgColor.guild[2], db.bgColor.guild[3], db.bgColor.guild[4] = r,g,b,a
							end,
						},
						hostilePC = {
							type = "color",
							order = order(),
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
							order = order(),
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
							order = order(),
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
							order = order(),
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
							order = order(),
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
							order = order(),
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
							order = order(),
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
							order = order(),
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
							order = order(),
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
				raidIcon = {
					type = "group",
					name = L["Raid target icon"],
					desc = L["Change how the raid target icon shows."],
					order = order(),
					args = {
						enable = {
							type = "toggle",
							name = L["Enable"],
							desc = L["Toggle show the raid target icon on the tooltip."],
							order = order(),
							width = "full",
							get = function() return db["raidtarget"].enable end,
							set = function(_, v) db["raidtarget"].enable = v end,
						},
						showPos = {
							type = "select",
							order = order(),
							name = L["Position"],
							desc = L["Position of the raid target icon."],
							values = {LEFT = L["Left"],
									RIGHT = L["Right"],
									TOP = L["Top"],
									BOTTOM = L["Bottom"],
									TOPLEFT = L["Top-left"],
									TOPRIGHT = L["Top-right"],
									BOTTOMLEFT = L["Bottom-left"],
									BOTTOMRIGHT = L["Bottom-right"]},
							disabled = function() return not db["raidtarget"].enable end,
							get = function() return db["raidtarget"].position end,
							set = function(_, v)
								Icetip_RaidTarget:SetPosition(v)
							end
						},
						size = {
							type = "range",
							order = order(),
							name = L["Size"],
							desc = L["Size of the raid target icon."],
							min = 5,
							max = 50,
							step = 1,
							disabled = function() return not db["raidtarget"].enable end,
							get = function() return db["raidtarget"].size end,
							set = function(_, v)
								Icetip_RaidTarget:SetSize(v)
							end
						},
					},
				},
				statusbar = {
					type = "group",
					order =order(),
					name = L["Status bar"],
					desc = L["Options for the tooltip's status bar."],
					args = {
						--healbar
						healbarHeader = {
							type = "group",
							order = order(),
							name = L["Health bar"],
							inline = true,
							args = {
								healbar = {
									type = "toggle",
									order = order(),
									name = L["Enable"],
									desc = L["Toggle the health bar on the tooltip."],
									get = function() return db["healthbar"].enable end,
									set = function(_, v)
										db["healthbar"].enable = v
										Icetip_HealthBar:ToggleHealthbar(v)
										Icetip_HealthBar:SetBarPoint()
									end
								},
								texture = {
									type = "select",
									order = order(),
									name = L["Texture"],
									desc = L["The texture which the health bar uses."],
									disabled = function() return not db["healthbar"].enable end,
									dialogControl = "LSM30_Statusbar",
									values = AceGUIWidgetLSMlists.statusbar,
									get = function() return db["healthbar"].texture end,
									set = function(_, v)
										db["healthbar"].texture = v
										Icetip_Health_Bar:SetStatusBarTexture(SM:Fetch("statusbar", v));
									end
								},
								size = {
									type = "range",
									order = order(),
									name = L["Size"],
									desc = L["The size of the health bar"],
									disabled = function() return not db["healthbar"].enable end,
									min = 1,
									max = 20,
									step = 1,
									get = function() return db["healthbar"].size end,
									set = function(_, v)
										db["healthbar"].size = v
										Icetip_Health_Bar:SetHeight(tonumber(v));
									end,
								},
								position = {
									type = "select",
									order = order(),
									name = L["Position"],
									desc = L["The position of the health bar relative to the tooltip."],
									disabled = function() return not db["healthbar"].enable end,
									values = barPosition,
									get = function() return db["healthbar"].position end,
									set = function(_, v) 
										db["healthbar"].position = v
										Icetip_HealthBar:SetBarPoint()
									end,
								},

								showhbtext = {
									type = "toggle",
									order = order(),
									name = L["Health bar text"],
									desc = L["Toggle show the status text on the health bar."],
									disabled = function() return not db["healthbar"].enable end,
									get = function() return db["healthbar"].showText end,
									set = function(_, v)
										db["healthbar"].showText = v
									end
								},
								hbfont = {
									type = "select",
									order = order(),
									name = L["Font"],
									desc = L["What font face to use."],
									disabled = function() return not db["healthbar"].enable end,
									hidden = function() return not db["healthbar"].showText end,
									dialogControl = "LSM30_Font",
									values = AceGUIWidgetLSMlists.font,
									get = function() return db["healthbar"].font end,
									set = function(_, v)
										db["healthbar"].font = v
										Icetip_Health_BarText:SetFont(SM:Fetch("font", v), db["healthbar"].fontSize, "Outline");
									end
								},
								hbfontsize = {
									type = "range",
									order = order(),
									name = L["Font size"],
									desc = L["Change what size is the font."],
									disabled = function() return not db["healthbar"].enable end,
									hidden = function() return not db["healthbar"].showText end,
									min = 8,
									max = 16,
									step = 1,
									get = function() return db["healthbar"].fontSize end,
									set = function(_, v)
										db["healthbar"].fontSize = v
										Icetip_Health_BarText:SetFont(SM:Fetch("font", v), db["healthbar"].fontSize, "Outline");
									end,
								},
								hbtextstyle = {
									type = "select",
									order = order(),
									name = L["Text style"],
									desc = L["Sets the text style."],
									disabled = function() return not db["healthbar"].enable end,
									hidden = function() return not db["healthbar"].showText end,
									values = bartextStyle,
									get = function() return db["healthbar"].style end,
									set = function(_, v)
										db["healthbar"].style = v
									end
								},
							},
						},
						manabarHeader = {
							type = "group",
							order = order(),
							name = L["Power bar"],
							inline = true,
							args = {
								powerbar = {
									type = "toggle",
									order = order(),
									name = L["Enable"],
									desc = L["Toggle the power bar on the tooltip."],
									get = function() return db["powerbar"].enable end,
									set = function(_, v)
										db["powerbar"].enable = v
										Icetip_PowerBar:TogglePowerbar(v)
										Icetip_PowerBar:SetBarPoint()
									end
								},
								texture = {
									type = "select",
									order = order(),
									name = L["Texture"],
									desc = L["The texture which the power bar uses."],
									disabled = function() return not db["powerbar"].enable end,
									dialogControl = "LSM30_Statusbar",
									values = AceGUIWidgetLSMlists.statusbar,
									get = function() return db["powerbar"].texture end,
									set = function(_, v)
										db["powerbar"].texture = v
										Icetip_Power_Bar:SetStatusBarTexture(SM:Fetch("statusbar", v));
									end
								},
								size = {
									type = "range",
									order = order(),
									name = L["Size"],
									desc = L["The size of the power bar."],
									disabled = function() return not db["powerbar"].enable end,
									min = 1,
									max = 20,
									step = 1,
									get = function() return db["powerbar"].size end,
									set = function(_, v)
										db["powerbar"].size = v
										Icetip_Power_Bar:SetHeight(tonumber(v));
									end,
								},
								position = {
									type = "select",
									order = order(),
									name = L["Position"],
									desc = L["The position of the power bar relative to the tooltip."],
									disabled = function() return not db["powerbar"].enable end,
									values = barPosition,
									get = function() return db["powerbar"].position end,
									set = function(_, v) 
										db["powerbar"].position = v
										Icetip_PowerBar:SetBarPoint()
									end,
								},
								showpbtext = {
									type = "toggle",
									order = order(),
									name = L["Power bar text"],
									desc = L["Show the status text on the power bar."],
									disabled = function() return not db["powerbar"].enable end,
									get = function() return db["powerbar"].showText end,
									set = function(_, v)
										db["powerbar"].showText = v
									end
								},
								pbfont = {
									type = "select",
									order = order(),
									name = L["Font"],
									desc = L["What font face to use."],
									disabled = function() return not db["powerbar"].enable end,
									hidden = function() return not db["powerbar"].showText end,
									dialogControl = "LSM30_Font",
									values = AceGUIWidgetLSMlists.font,
									get = function() return db["powerbar"].font end,
									set = function(_, v)
										db["powerbar"].font = v
										Icetip_Power_BarText:SetFont(SM:Fetch("font", v), db["powerbar"].fontSize, "Outline");
									end
								},
								pbfontsize = {
									type = "range",
									order = order(),
									name = L["Font size"],
									desc = L["Change what size is the font."],
									disabled = function() return not db["powerbar"].enable end,
									hidden = function() return not db["powerbar"].showText end,
									min = 8,
									max = 16,
									step = 1,
									get = function() return db["powerbar"].fontSize end,
									set = function(_, v)
										db["powerbar"].fontSize = v
										Icetip_Power_BarText:SetFont(SM:Fetch("font", v), db["powerbar"].fontSize, "Outline");
									end,
								},
								pbtextstyle = {
									type = "select",
									order = order(),
									name = L["Text style"],
									desc = L["Sets the text style."],
									disabled = function() return not db["powerbar"].enable end,
									hidden = function() return not db["powerbar"].showText end,
									values = bartextStyle,
									get = function() return db["powerbar"].style end,
									set = function(_, v)
										db["powerbar"].style = v
									end
								},
							},
						},
					},
				},
			},
		}

                options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db);
                options.args.profile.order = 9999;
	end

	return options
end

function optionFrame:OnEnable()
	local db = Icetip.db
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Icetip", CreateOption);
	SlashCmdList["ICETIP"] = function()
		LibStub("AceConfigDialog-3.0"):SetDefaultSize("Icetip", 650, 580)
		LibStub("AceConfigDialog-3.0"):Open("Icetip")
	end
	SLASH_ICETIP1 = "/icetip";

	--register wowshell
        --[[
	if wsRegisterOption then
		wsRegisterOption(
			"Others",
			"Icetip",
			L["鼠标提示"],
			L["鼠标提示增强"],
			"Interface\\Icons\\Spell_Frost_Iceclaw",
			{
				type = "group",
				args = {
					tot = {
						type = "toggle",
						order = order(),
						name = L["启用显示目标的目标"],
						desc = L["显示鼠标目标的目标"],
						width = "full",
						get = function() return db["mousetarget"].showTarget end,
						set = function(_, v)
							db["mousetarget"].showTarget = v
						end
					},
					showtalent = {
						type = "toggle",
						order = order(),
						name = L["启用显示目标的天赋"],
						width = "full",
						desc = L["显示目标的天赋"],
						get = function() return db["mousetarget"].showTalent end,
						set = function(_, v)
							db["mousetarget"].showTalent = v
						end
					},
					itemborder = {
						type = "toggle",
						order = order(),
						name = L["物品提示边框着色"],
						desc = L["当查看一件物品时, 提示边框会以当前物品的材质着色"],
						get = function() return db.itemQBorder end,
						set = function(_, v) db.itemQBorder = v end,
					},
					showfaction = {
						type = "toggle",
						order = order(),
						name = L["显示目标声望信息"],
						desc = L["显示目标NPC与你之间的声望信息"],
						get = function() return db["mousetarget"].showFaction end,
						set = function(_, v)
							db["mousetarget"].showFaction = v
						end,
					},
					enableraidicon = {
						type = "toggle",
						name = L["启用团队标记"],
						desc = L["在鼠标提示上显示目标的团队标记"],
						order = order(),
						width = "full",
						get = function() return db["raidtarget"].enable end,
						set = function(_, v) db["raidtarget"].enable = v end,
					},
					healbar = {
						type = "toggle",
						order = order(),
						name = L["启用血量条"],
						desc = L["在鼠标提示框上显示鼠标目标的血量条"],
						get = function() return db["healthbar"].enable end,
						set = function(_, v)
							db["healthbar"].enable = v
							Icetip_HealthBar:ToggleHealthbar(v)
							Icetip_HealthBar:SetBarPoint()
						end
					},
					powerbar = {
						type = "toggle",
						order = order(),
						name = L["启用能量条"],
						desc = L["在鼠标提示框上显示鼠标目标的能量条(法力, 能力, 快乐度, 符文之力, 怒气等)"],
						get = function() return db["powerbar"].enable end,
						set = function(_, v)
							db["powerbar"].enable = v
							Icetip_PowerBar:TogglePowerbar(v)
							Icetip_PowerBar:SetBarPoint()
						end
					},
					advance = {
						type = "execute",
						name = L["高级设定"],
						func = function()
							LibStub("AceConfigDialog-3.0"):SetDefaultSize("Icetip", 650, 580)
							if not (LibStub("AceConfigDialog-3.0"):Close("Icetip")) then
								LibStub("AceConfigDialog-3.0"):Open("Icetip")
							end
							WS_GUI:ToggleFrame(false)
						end
					}
				}
			},
			10
		);
	end
        ]]
end
