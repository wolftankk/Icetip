assert(Icetip, "Icetip没有找到")
local Icetip = _G.Icetip
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
	["hide"] = L["立刻隐藏"],
	["fade"] = L["渐隐"],
}

local anchorType = {
	["CURSOR_BOTTOM"] = L["鼠标上边"],
	["CURSOR_TOP"] = L["鼠标下边"],
	["CURSOR_RIGHT"] = L["鼠标左边"],
	["CURSOR_LEFT"] = L["鼠标右边"],
	["CURSOR_TOPLEFT"] = L["鼠标右下"],
	["CURSOR_BOTTOMLEFT"] = L["鼠标右上"],
	["CURSOR_TOPRIGHT"] = L["鼠标左下"],
	["CURSOR_BOTTOMRIGHT"] = L["鼠标左上"],
	["BOTTOM"] = L["下部"],
	["TOP"] = L["上部"],
	["RIGHT"] = L["右边"],
	["LEFT"] = L["左边"],
	["BOTTOMRIGHT"] = L["右下"],
	["BOTTOMLEFT"] = L["左下"],
	["TOPRIGHT"] = L["右上"],
	["TOPLEFT"] = L["左上"],
	["CENTER"] = L["居中"],
	["PARENT_TOP"] = L["主框体下部"],
	["PARENT_BOTTOM"] = L["主框体上部"],
	["PARENT_RIGHT"] = L["主框体左边"],
	["PARENT_LEFT"] = L["主框体右边"],
	["PARENT_TOPLEFT"] = L["主框体左下"],
	["PARENT_TOPRIGHT"] = L["主框体右下"],
	["PARENT_BOTTOMLEFT"] = L["主框体左上"],
	["PARENT_BOTTOMRIGHT"] = L["主框体右上"],
}

local barPosition = {
	["TOP"] = L["鼠标上边"],
	["BOTTOM"] = L["鼠标下边"],
	--["LEFT"] = L["鼠标左边"],
	--["RIGHT"] = L["鼠标右边"],
}

local bartextStyle = {
	["number"] = L["数值"],
	["percent"] = L["百分比"],
	["pernumber"] = L["数值(百分比)"],
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
					name = L["鼠标提示增强"]..L["|cffffd200版本: "]..Icetip.vesion.."|r",
				},
				general = {
					type = "group",
					name = L["样式设定"],
					desc = L["鼠标提示样式设定"],
					order = order(),
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
						tooltipBG = {
							type = "group",
							order = order(),
							name = "鼠标提示样式",
							desc = "设定鼠标提示样式",
							inline = true,
							args = {
								bgtexture = {
									type = "select",
									dialogControl = "LSM30_Background",
									order = order(),
									name = L["鼠标提示背景材质"],
									desc = L["设定鼠标提示背景材质.\n\n注意：你可能要更改背景颜色为白色才可以使得部分背景看起来正常。"],
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
									name = L["鼠标提示边框材质"],
									desc = L["设定鼠标提示边框材质.\n\n注意：你可能要更改背景颜色为白色才可以使边框着色正常功能。"],
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
									name = L["自定义背景颜色"],
									desc = L["启用/禁用自定义背景颜色"],
									get = function() return db["tooltipStyle"].customColor end,
									set = function(_, v)
										db["tooltipStyle"].customColor = v
									end
								},
								bordercolor = {
									type = "color",
									order = order(),
									name = L["边框颜色"],
									desc = L["鼠标提示框边框颜色"],
									hasAlpha = true,
									get = function() return db.border_color.r, db.border_color.g, db.border_color.b, db.border_color.a end,
									set = function(_, r, g, b, a)
										db.border_color.r, db.border_color.g, db.border_color.b, db.border_color.a = r,g,b,a
									end,
								},
								tile = {
									type = "toggle",
									order = order(),
									name = L["背景拼贴"],
									desc = L["背景材质拼贴"],
									get = function() return db["tooltipStyle"].tile end,
									set = function(_, v)
										db["tooltipStyle"].tile = v
										Icetip_Appstyle:UpdateBackdrop()
									end,
								},
								tilesize = {
									type = "range",
									order = order(),
									name = L["背景材质拼贴尺寸"],
									desc = L["设定背景材质拼贴尺寸"],
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
									name = L["边框厚度"],
									desc = L["设定鼠标提示边框厚度"],
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
									name = L["显示比例"],
									desc = L["鼠标提示框显示比例"],
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
							name = L["提示框消失设定"],
							desc = L["设定提示信息框消失的形式"],
							order = order(),
							args = {
								unit = {
									type = "select",
									order = order(),
									name = L["世界单位"],
									desc = L["世界中其他玩家或者NPC的提示信息消失的形式"],
									values = hidetype,
									get = function() return db["tooltipFade"].units end,
									set = function(_, v)
										db["tooltipFade"].units = v
									end,
								},
								objframe = {
									type = "select",
									order = order(),
									name = L["世界物品"],
									desc = L["世界中各种物体, 例如邮箱, 尸体等的提示信息消失的形式"],
									values = hidetype,
									get = function() return db["tooltipFade"].objects end,
									set = function(_, v)
										db["tooltipFade"].objects = v
									end,
								},
								unitframe = {
									type = "select",
									order = order(),
									name = L["对象框架"],
									desc = L["自己或者队友等的提示信息消失的形式"],
									values = hidetype,
									get = function() return db["tooltipFade"].unitFrames end,
									set = function(_, v)
										db["tooltipFade"].unitFrames = v
									end,
								},
								otherframe = {
									type = "select",
									order = order(),
									name = L["非对象框架"],
									desc = L["法术或者背包内物品等的提示信息消失的形式"],
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
					name = L["显示位置设定"],
					desc = L["设置鼠标提示显示位置."],
					order = order(),
					args = {
						header1 = {
							type = "header",
							order = order(),
							name = L["单位鼠标提示位置"],
						},
						desc_1 = {
							type = "description",
							name = L["鼠标悬停在某对象(例如: Npc, 目标以及玩家)上时的提示信息框的设置"],
							order = order(),
						},
						unitAnchor = {
							type = "select",
							order = order(),
							name = L["对象鼠标锚点位置"],
							desc = L["选择对象鼠标锚点显示位置"],
							values = anchorType,
							get = function() return db["setAnchor"].unitAnchor end,
							set = function(_, v)
								db["setAnchor"].unitAnchor = v
							end
						},
						space_1 = {
							type = "description",
							name = L["微调显示位置"],
							order = order(),
						},
						unitPosX = {
							type = "range",
							order = order(),
							name = L["调整水平方向位置"],
							desc = L["调整水平方向显示位置"],
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
							name = L["调整垂直方向位置"],
							desc = L["调整垂直方向显示位置"],
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
							name = L["框体鼠标提示位置"],
						},
						desc_2 = {
							type = "description",
							name = L["鼠标悬停在某框体(例如: 技能, 玩家头像)上时的提示信息框的设置"],
							order = order(),
						},
						frameAnchor = {
							type = "select",
							order = order(),
							name = L["框体鼠标锚点位置"],
							desc = L["选择框体鼠标锚点显示位置"],
							values = anchorType,
							get = function() return db["setAnchor"].frameAnchor end,
							set = function(_, v)
								db["setAnchor"].frameAnchor = v
							end
						},
						space_2 = {
							type = "description",
							name = L["微调显示位置"],
							order = order(),
						},
						framePosX = {
							type = "range",
							order = order(),
							name = L["调整水平方向位置"],
							desc = L["调整水平方向显示位置"],
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
							name = L["调整垂直方向位置"],
							desc = L["调整垂直方向显示位置"],
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
					name = L["颜色设定"],
					desc = L["鼠标提示框背景颜色设定"],
					disabled = function() return not db["tooltipStyle"].customColor end,
					args = {
						guild = {
							type = "color",
							name = L["公会和好友"],
							desc = L["设置同一公会或好友时鼠标提示背景颜色"],
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
							name = L["敌对玩家背景颜色"],
							desc = L["设置敌对玩家鼠标提示背景颜色"],
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
							name = L["敌对NPC背景颜色"],
							desc = L["敌对NPC背景颜色"],
							get = function() return unpack(db.bgColor.hostileNPC) end,
							set = function(_, r, g, b, a)
								db.bgColor.hostileNPC[1], db.bgColor.hostileNPC[2], db.bgColor.hostileNPC[3], db.bgColor.hostileNPC[4] = r,g,b,a
							end,
						},
						neutralNPC = {
							type = "color",
							order = order(),
							hasAlpha = true,
							name = L["中立NPC背景颜色"],
							desc = L["设置中立NPC鼠标提示背景颜色"],
							get = function() return unpack(db.bgColor.neutralNPC) end,
							set = function(_, r, g, b, a)
								db.bgColor.neutralNPC[1], db.bgColor.neutralNPC[2], db.bgColor.neutralNPC[3], db.bgColor.neutralNPC[4] = r,g,b,a
							end,
						},
						faction = {
							type = "color",
							order = order(),
							name = L["当前正跟踪的阵营"],
							desc = L["目标如果属于你当前正跟踪的阵营时的背景颜色"],
							hasAlpha = true,
							get = function() return unpack(db.bgColor.faction) end,
							set = function(_, r, g, b, a)
								db.bgColor.faction[1], db.bgColor.faction[2], db.bgColor.faction[3], db.bgColor.faction[4] = r,g,b,a
							end,
						},
						friendPC = {
							type = "color",
							order = order(),
							name = L["同阵营背景颜色"],
							desc = L["目标是同阵营鼠标提示背景颜色"],
							hasAlpha = true,
							get = function() return unpack(db.bgColor.friendlyPC) end,
							set = function(_, r, g, b, a)
								db.bgColor.friendlyPC[1], db.bgColor.friendlyPC[2], db.bgColor.friendlyPC[3], db.bgColor.friendlyPC[4] = r,g,b,a
							end,
						},
						friendlyNPC = {
							type = "color",
							order = order(),
							name = L["同阵营NPC背景颜色"],
							desc = L["目标是同阵营NPC鼠标提示背景颜色"],
							hasAlpha = true,
							get = function() return unpack(db.bgColor.friendlyNPC) end,
							set = function(_, r, g, b, a)
								db.bgColor.friendlyNPC[1], db.bgColor.friendlyNPC[2], db.bgColor.friendlyNPC[3], db.bgColor.friendlyNPC[4] = r,g,b,a
							end,
						},
						other = {
							type = "color",
							order = order(),
							name = L["其他背景颜色"],
							desc = L["目标属于静态物件时的背景颜色"],
							hasAlpha = true,
							get = function() return unpack(db.bgColor.other) end,
							set = function(_, r, g, b, a)
								db.bgColor.other[1], db.bgColor.other[2], db.bgColor.other[3], db.bgColor.other[4] = r,g,b,a
							end,
						},
						dead = {
							type = "color",
							order = order(),
							name = L["目标死亡背景颜色"],
							desc = L["设置目标死亡鼠标提示背景颜色"],
							hasAlpha = true,
							get = function() return unpack(db.bgColor.dead) end,
							set = function(_, r, g, b, a)
								db.bgColor.dead[1], db.bgColor.dead[2], db.bgColor.dead[3], db.bgColor.dead[4] = r,g,b,a
							end,
						},
						tapped = {
							type = "color",
							order = order(),
							name = L["目标被攻击背景颜色"],
							desc = L["设置目标被攻击鼠标提示背景颜色"],
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
					name = L["团队标记"],
					desc = L["在鼠标提示上显示团队标记"],
					order = order(),
					args = {
						enable = {
							type = "toggle",
							name = L["启用团队标记"],
							desc = L["在鼠标提示上显示目标的团队标记"],
							order = order(),
							width = "full",
							get = function() return db["raidtarget"].enable end,
							set = function(_, v) db["raidtarget"].enable = v end,
						},
						showPos = {
							type = "select",
							order = order(),
							name = L["设置团队标记显示位置"],
							desc = L["设定团队标记在鼠标提示上的显示位置"],
							values = {LEFT = L["鼠标左边"],
									RIGHT = L["鼠标右边"],
									TOP = L["鼠标上边"],
									BOTTOM = L["鼠标下边"],
									TOPLEFT = L["鼠标左上"],
									TOPRIGHT = L["鼠标右上"],
									BOTTOMLEFT = L["鼠标左下"],
									BOTTOMRIGHT = L["鼠标右下"]},
							disabled = function() return not db["raidtarget"].enable end,
							get = function() return db["raidtarget"].position end,
							set = function(_, v)
								Icetip_RaidTarget:SetPosition(v)
							end
						},
						size = {
							type = "range",
							order = order(),
							name = L["团队标记尺寸"],
							desc = L["设置团队标记显示的大小"],
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
					name = L["状态条"],
					desc = L["设定鼠标提示上的状态条样式"],
					args = {
						--healbar
						healbarHeader = {
							type = "group",
							order = order(),
							name = L["血量条设定"],
							inline = true,
							args = {
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
								texture = {
									type = "select",
									order = order(),
									name = L["材质"],
									desc = L["设定血量条材质"],
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
									name = L["尺寸"],
									desc = L["设定血量条宽度"],
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
									name = L["显示位置"],
									desc = L["设置血量条显示位置"],
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
									name = L["显示状态条文字"],
									desc = L["在状态条显示具体生命值信息"],
									disabled = function() return not db["healthbar"].enable end,
									get = function() return db["healthbar"].showText end,
									set = function(_, v)
										db["healthbar"].showText = v
									end
								},
								hbfont = {
									type = "select",
									order = order(),
									name = L["设定字体样式"],
									desc = L["设置生命条字体样式"],
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
									name = L["字体尺寸"],
									desc = L["设定生命条字体的尺寸"],
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
									name = L["显示样式"],
									desc = L["设定文字信息显示的样式"],
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
							name = L["能量条设定"],
							inline = true,
							args = {
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
								texture = {
									type = "select",
									order = order(),
									name = L["材质"],
									desc = L["设定能量条材质"],
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
									name = L["尺寸"],
									desc = L["设定能量条宽度"],
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
									name = L["显示位置"],
									desc = L["设置能量条显示位置"],
									disabled = function() return not db["powerbar"].enable end,
									values = barPosition,
									get = function() return db["powerbar"].position end,
									set = function(_, v) 
										db["powerbar"].position = v
										Icetip_PowerBar:SetBarPoint()
									end,
								},

								showhbtext = {
									type = "toggle",
									order = order(),
									name = L["显示状态条文字"],
									desc = L["在状态条显示具体生命值信息"],
									disabled = function() return not db["powerbar"].enable end,
									get = function() return db["powerbar"].showText end,
									set = function(_, v)
										db["powerbar"].showText = v
									end
								},
								pbfont = {
									type = "select",
									order = order(),
									name = L["设定字体样式"],
									desc = L["设置能量条字体样式"],
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
									name = L["字体尺寸"],
									desc = L["设定能量条字体的尺寸"],
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
									name = L["显示样式"],
									desc = L["设定文字信息显示的样式"],
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
				profile = {
					type = "group",
					order = order(),
					name = L["配置文件"],
					desc = L["管理配置文件, 你可以重置, 复制等工作"],
					args = {
						desc = {
							type = "description",
							order = order(),
							name = L[""],
						},
						resetButton = {
							type = "execute",
							order = order(),
							name = L["重置"],
							desc = L["点击重置Icetip鼠标提示配置\n\n需要重载界面"],
							func = function()
								local db = Icetip:GetDefaultConfig()
								IcetipDB = nil
								IcetipDB = {}
								IcetipDB = db
								ReloadUI()
							end
						},
					},
				},
			},
		}
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
end
