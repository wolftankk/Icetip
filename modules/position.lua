local addonName, Icetip = ...;
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local mod = Icetip:NewModule("position", L["Position"], true);
local db;

local currentOffsetX, currentOffsetY = 0, 0
local currentCursorAnchor = "BOTTOM"
local currentAnchorType = "CURSOR"
local currentOwner = UIParent
local screenHeight = GetScreenHeight();
local screenWidth  = GetScreenWidth();

local anchorOpposite = {
    BOTTOMLEFT = "TOPLEFT",
    BOTTOM = "TOP",
    BOTTOMRIGHT = "TOPRIGHT",
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    TOPLEFT = "BOTTOMLEFT",
    TOP = "BOTTOM",
    TOPRIGHT = "BOTTOMRIGHT",
}
local defaults = {
    profile = {
	unitAnchor = "BOTTOMRIGHT",
	unitOffsetX = -93,
	unitOffsetY = 110,
	frameAnchor = "BOTTOMRIGHT",
	frameOffsetX = -93,
	frameOffsetY = 110,
    }
}

function mod:OnInitialize()
    self.db = self:RegisterDB(defaults)
    db = self.db.profile
end

function mod:OnEnable()
    self:SecureHook("GameTooltip_SetDefaultAnchor", "SetTooltipAnchor");
end

function mod:OnDisable()
    self:Unhook("GameTooltip_SetDefaultAnchor")
end

local function ReanchorTooltip()
    GameTooltip:ClearAllPoints();
    local scale = GameTooltip:GetEffectiveScale();
    if currentAnchorType == "PARENT" then
        GameTooltip:SetPoint(currentCursorAnchor, currentOwner, anchorOpposite[currentCursorAnchor], currentOffsetX, currentOffsetY)
    elseif currentAnchorType == "CURSOR" then
        local x, y = GetCursorPosition();
        x, y = x/scale + currentOffsetX, y/scale +currentOffsetY;
        GameTooltip:SetPoint(currentCursorAnchor, UIParent, "BOTTOMLEFT", x, y);
    end
end

function mod:SetTooltipAnchor(tooltip, parent, ...)
    local anchor, offsetX, offsetY
    currentOwner = parent
    if parent == UIParent then
        anchor = db.unitAnchor
        offsetX = db.unitOffsetX
        offsetY = db.unitOffsetY
    else --frame
        anchor = db.frameAnchor
        offsetX = db.frameOffsetX
        offsetY = db.frameOffsetY
    end
    if anchor:find("^CURSOR") or anchor:find("^PARENT") then
        if anchor == "CURSOR_TOP" and math.abs(offsetX) < 1 and math.abs(offsetY) < 0 then
            tooltip:SetOwner(parent, "ANCHOR_CURSOR");
        else
            currentOffsetX = offsetX
            currentOffsetY = offsetY
            currentCursorAnchor = anchor:sub(8);
            currentAnchorType = anchor:sub(1, 6);
            ReanchorTooltip()
        end
    else
        tooltip:SetOwner(parent, "ANCHOR_NONE");
        tooltip:ClearAllPoints();
        tooltip:SetPoint(anchor, UIParent, anchor, offsetX, offsetY)
    end
end

local anchorTypeList = {
    ["CURSOR_BOTTOM"] = L["Mouse Top"],
    ["CURSOR_TOP"] = L["Mouse Bottom"],
    ["CURSOR_RIGHT"] = L["Mouse Left"],
    ["CURSOR_LEFT"] = L["Mouse Right"],
    ["CURSOR_TOPLEFT"] = L["Mouse Bottom Right"],
    ["CURSOR_BOTTOMLEFT"] = L["Mouse Top Right"],
    ["CURSOR_TOPRIGHT"] = L["Mouse Bottom Left"],
    ["CURSOR_BOTTOMRIGHT"] = L["Mouse Top Left"],
    ["BOTTOM"] = L["Screen"].." "..L["Bottom"],
    ["TOP"] = L["Screen"].." "..L["Top"],
    ["RIGHT"] = L["Screen"].." "..L["Right"],
    ["LEFT"] = L["Screen"].." "..L["Left"],
    ["BOTTOMRIGHT"] = L["Screen"].." "..L["Bottom Right"],
    ["BOTTOMLEFT"] = L["Screen"].." "..L["Bottom Left"],
    ["TOPRIGHT"] = L["Screen"].." "..L["Top Right"],
    ["TOPLEFT"] = L["Screen"].." "..L["Top Left"],
    ["CENTER"] = L["Screen"].." "..L["Center"],
    ["PARENT_TOP"] = L["Parent Bottom"],
    ["PARENT_BOTTOM"] = L["Parent Top"],
    ["PARENT_RIGHT"] = L["Parent Left"],
    ["PARENT_LEFT"] = L["Parent Right"],
    ["PARENT_TOPLEFT"] = L["Parent Bottom Left"],
    ["PARENT_TOPRIGHT"] = L["Parent Bottom Right"],
    ["PARENT_BOTTOMLEFT"] = L["Parent Top Left"],
    ["PARENT_BOTTOMRIGHT"] = L["Parent Top Right"],
}


do
    local editorbox;
    local updatePoisition, onUpdate;

    --init editorbox
    local function createEditorBox()
	--Create a editor window
	editorbox = CreateFrame("Frame", nil, UIParent);
	editorbox:SetSize(screenWidth / 2, screenHeight / 2);
	editorbox:SetFrameStrata("TOOLTIP");
	editorbox:SetPoint("CENTER", UIParent, "CENTER");
	--set editorbox background;
	local bg = editorbox:CreateTexture(nil, "BACKGROUND");
	bg:SetTexture(0, 0, 0, 0.9);
	bg:SetAllPoints(editorbox);

	--create a editorbox's header
	local header = CreateFrame("Frame", nil, editorbox);
	header:SetSize(editorbox:GetWidth(), 32);
	header:SetPoint("BOTTOM", editorbox, "TOP", 0, 5);
	local headerbg = header:CreateTexture(nil, "BACKGROUND");
	headerbg:SetTexture(0, 0, 0, 0.8);
	headerbg:SetAllPoints(header);

	--create a close button on the header
	local close = CreateFrame("Button", nil, header);
	close:SetSize(16, 16);
	close:SetPoint("TOPRIGHT", header, "TOPRIGHT", -2, -2);
	close:SetNormalTexture("Interface\\AddOns\\Icetip\\media\\close.tga");
	close:SetHighlightTexture("Interface\\AddOns\\Icetip\\media\\close.tga", "ADD");
	close:SetScript("OnClick", function()
	    editorbox.kind = nil;
	    editorbox:Hide();
	end);
	close:SetScript("OnEnter", function(self)
	    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	    GameTooltip:SetText("Icetip Visual Editor");
	    GameTooltip:AddLine("Close the editor window");
	    GameTooltip:Show();
	end);
	close:SetScript("OnLeave", function()
	    GameTooltip:Hide();
	end);

	local line = editorbox:CreateTexture(nil, "BORDER");
	line:SetTexture("Interface\\BUTTONS\\WHITE8X8");
	line:SetSize(editorbox:GetWidth(), 1);
	line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0);
	line:SetVertexColor(1, 1, 1, 0.7);

	local anchorText = header:CreateFontString(nil, "OVERLAY");
	anchorText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
	anchorText:SetHeight(15);
	anchorText:SetTextColor(1, .82, 0);
	anchorText:SetText("Anchor");
	anchorText:SetPoint("LEFT", header, "LEFT", 10, 0);
	
	--add dropdown list
	local dropdown = LibStub("AceGUI-3.0"):Create("Dropdown");
	dropdown:SetWidth(150);
	dropdown:ClearAllPoints();
	dropdown.frame:SetParent(header);
	dropdown:SetPoint("LEFT", anchorText, "RIGHT", 3, 0);
	dropdown:SetList(anchorTypeList);
	dropdown:SetCallback("OnValueChanged", function(widget, event, key)
	    local kind = editorbox.kind;
	    if (kind) then
		local db_anchorKey = kind.."Anchor";
		db[db_anchorKey] = key;

		LibStub("AceConfigRegistry-3.0"):NotifyChange("Icetip");

		updatePoisition(kind);
	    end
	end);
	editorbox.dropdown = dropdown;

	local offset = header:CreateFontString(nil, "OVERLAY");
	offset:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
	offset:SetHeight(15);
	offset:SetTextColor(1, .82, 0);
	offset:SetText("Coord: ");
	offset:SetPoint("LEFT", dropdown.frame, "RIGHT", 10, 0);

	local coord = header:CreateFontString(nil, "OVERLAY");
	coord:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
	coord:SetHeight(15);
	coord:SetTextColor(1, 1, 1);
	coord:SetText("");
	coord:SetPoint("LEFT", offset, "RIGHT", 10, 0);
	editorbox.coord = coord;

	--position button
	local tooltip = CreateFrame("Button", nil, editorbox);
	tooltip:SetSize(32, 32);
	tooltip:SetParent(editorbox);
	tooltip:SetClampedToScreen(true);
	tooltip:RegisterForDrag("LeftButton");
	tooltip:SetMovable(true);
	
	local cursor_tex = tooltip:CreateTexture(nil, "OVERLAY");
	cursor_tex:SetTexture(0.45, 0.6, 0, 0.5);
	cursor_tex:SetAllPoints(tooltip);
	editorbox.tooltip = tooltip;
	--------------------------------
	--create a mouse in the screen
	--------------------------------
	local mouse = editorbox:CreateTexture(nil, "DIALOG", editorbox);
	mouse:SetTexture("Interface\\CURSOR\\Point");
	mouse:SetSize(32, 32);
	mouse:SetPoint("CENTER", editorbox, "CENTER", 0, 0);
	mouse:Hide();
	editorbox.mouse = mouse;

	tooltip:SetScript("OnEnter", function(self)
	    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	    GameTooltip:AddLine("Hold and drag the green diamond for positioning");
	    GameTooltip:Show();
	end)
	tooltip:SetScript("OnLeave", function()
	    GameTooltip:Hide();
	end);


	--[=[
	tooltip:SetScript("OnDragStart", function()
	    --GameTooltip:Hide();
	    --cursor:StartMoving();
	    --cursor:SetScript("OnUpdate", onUpdate);
	    --local _, _, _, x, y = cursor:GetPoint();
	    --print(x, y)
	end)
	tooltip:SetScript("OnDragStop", function()
	    cursor:StopMovingOrSizing();
	    cursor:SetScript("OnUpdate", nil);
	end);
	]=]

	editorbox:SetScript("OnShow", function(self)
	    updatePoisition(editorbox.kind);
	end);

	editorbox:Hide();
    end
    
    --[[
    -- anchor: 
    -- offsetX:
    -- offsetY:
    -- type:
    --   simulator: from real world to the simulator
    --   figure   : from the simulator to real world
    --]]
    local function calculatePosition(anchor, offsetX, offsetY, kind, mode)
        if anchor:find("^CURSOR") or anchor:find("^PARENT") then
            if anchor == "CURSOR_TOP" and math.abs(offsetX) < 1 and math.abs(offsetY) < 0 then
                --tooltip:SetOwner(parent, "ANCHOR_CURSOR");
            else
                local cursorAnchor = anchor:sub(8);
                local anchorType = anchor:sub(1, 6);
		local currentOwner;
		if (kind == "unit") then
		    currentOwner = editorbox;--the unit's parent is UIParent
		else
		    --currentOwner = 
		end
                --if anchorType == "PARENT" then
                --    GameTooltip:SetPoint(currentCursorAnchor, currentOwner, anchorOpposite[currentCursorAnchor], currentOffsetX, currentOffsetY)
                --elseif anchorType == "CURSOR" then
                --    self.mouse:Show();
                --    local x, y = 0, 0
                --    self.cursor:SetPoint(cursorAnchor, self.mouse, "BOTTOMLEFT", x + (offsetX / 2), y + (offsetY / 2));
                --end
            end
        else
	    -- tooltip's screen mode. Only set tooltip's point at the screen.
	    -- So, in the simulator, the editorbox likes your screen
	    if (mode == "simulator") then
		editorbox.tooltip:ClearAllPoints();
		editorbox.tooltip:SetPoint(anchor, editorbox, anchor, offsetX / 2, offsetY / 2)

	    end
        end
    end

    --local function onUpdate()
    --    local parentLeft = editorbox:GetLeft();
    --    local parentRight = editorbox:GetRight();
    --    local parentTop = editorbox:GetTop();
    --    local parentBottom = editorbox:GetBottom();

    --    local cursorLeft = tooltip:GetLeft();
    --    local cursorRight = tooltip:GetRight();
    --    local cursorTop = tooltip:GetTop();
    --    local cursorBottom = tooltip:GetBottom();

    --    local _point, _relativeTo, _relativePoint, _x, _y = tooltip:GetPoint();

    --    --检测 X  是否超出边界
    --    if ((cursorLeft < parentLeft) or (cursorRight > parentRight)) then
    --        --左边超出边界, 重置位置
    --        if (cursorLeft < parentLeft) then
    --    	tooltip:SetPoint(_point, _relativeTo, _relativePoint, parentLeft, _y);
    --        end
    --        if (cursorRight > parentRight) then
    --    	tooltip:SetPoint(_point, _relativeTo, _relativePoint, parentRight - tooltip:GetWidth(), _y);
    --        end
    --    end

    --    --检查 Y 是否超出边界
    --    if ((cursorTop > parentTop) or (cursorBottom < parentBottom)) then
    --        if (cursorTop > parentTop) then
    --    	tooltip:SetPoint(_point, _relativeTo, _relativePoint, _x, -parentBottom);
    --        end
    --        if (cursorBottom < parentBottom) then
    --    	tooltip:SetPoint(_point, _relativeTo, _relativePoint, _x, -parentTop + tooltip:GetHeight());
    --        end
    --    end

    --    ---------------------------------------------------------------------------------------------------------------------

    --    local kind = editorbox.kind;
    --    local anchor = db[kind.."Anchor"];
    --    local realX, realY = 0, 0;
    --    local db_offsetX = kind.."OffsetX";
    --    local db_offsetY = kind.."OffsetY";

    --    if anchor:find("^CURSOR") or anchor:find("^PARENT") then
    --        --TODO
    --    else
    --        --print(_x, parentLeft, editorbox:GetWidth())
    --        local points = {
    --    	-- x, y  : 0, 0
    --    	TOPLEFT= { parentLeft, -parentBottom },
    --    	TOPRIGHT= { parentRight - tooltip:GetWidth(), -parentBottom },
    --    	--这里计算有误
    --    	TOP     = { parentLeft - tooltip:GetWidth() + editorbox:GetWidth() / 2 ,-parentBottom },
    --    	CENTER  = {  },
    --    	LEFT    = {  },
    --    	RIGHT   = {  },
    --    	BOTTOM  = {   },
    --    	BOTTOMRIGHT = { parentRight - tooltip:GetWidth(), -parentTop + tooltip:GetWidth() },
    --    	BOTTOMLEFT = { parentLeft,  -parentTop + tooltip:GetWidth() }
    --        }
    --        local relativeX, relativeY = unpack(points[anchor]);
    --        if (relativeX and relativeY) then
    --    	realX = math.ceil((_x - relativeX) * 2);
    --    	realY = math.ceil((_y - relativeY) * 2);
    --        end
    --    end

    --    --db[db_offsetX] = tonumber(realX);
    --    --db[db_offsetY] = tonumber(realY);
    --    editorbox.coord:SetText(realX..", "..realY);
    --    --LibStub("AceConfigRegistry-3.0"):NotifyChange("Icetip");
    --end

    function updatePoisition(kind)
        local db_anchorKey = kind.."Anchor";
        local db_offsetX = kind.."OffsetX";
        local db_offsetY = kind.."OffsetY";
        local anchor = db[db_anchorKey];
        local offsetX = db[db_offsetX];
        local offsetY = db[db_offsetY];

        editorbox.dropdown:SetValue(anchor);
        editorbox.coord:SetText(offsetX..", "..offsetY);
        editorbox.mouse:Hide();
	calculatePosition(anchor, offsetX, offsetY, kind, "simulator");
    end

    function mod:openPositionEditor(kind)
	if (not kind) then
	    return false;
	end
	if (not editorbox) then 
	    createEditorBox();
	end
	editorbox:Hide();
	editorbox.kind = kind
	editorbox:Show();
    end
end

function mod:GetOptions()
    local options = {
	header1 = {
	    type = "header",
	    order = 1,
	    name = L["Unit"],
	},
	desc_1 = {
	    type = "description",
	    name = L["Options for unit mouseover tooltips(NPC, target, player, etc.)"],
	    order = 2,
	},
	unitAnchor = {
	    type = "select",
	    order = 3,
	    name = L["Anchor"],
	    desc = L["The anchor with which the tooltips are showed."],
	    values = anchorTypeList,
	    get = function() return db.unitAnchor end,
	    set = function(_, v)
		db.unitAnchor = v
	    end
	},
	space_1 = {
	    type = "description",
	    name = L["Sets anchor offset"],
	    order = 4,
	},
	unitPosX = {
	    type = "range",
	    order = 5,
	    name = L["Horizontal offset"],
	    desc = L["Sets offset of the X"],
	    min = tonumber(-(floor(screenWidth/5 + 0.5) * 5)),
	    max = tonumber(floor(screenWidth/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.unitOffsetX end,
	    set = function(_, v)
		db.unitOffsetX = v
	    end
	},
	unitPoxY = {
	    type = "range",
	    order = 6,
	    name = L["Vertical offset"],
	    desc = L["Sets offset of the Y"],
	    min = tonumber(-(floor(screenHeight/5 + 0.5) * 5)),
	    max = tonumber(floor(screenHeight/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.unitOffsetY end,
	    set = function(_, v)
		db.unitOffsetY = v
	    end
	},
	unitGUI = {
	    type = "execute",
	    width = "full",
	    order = 7,
	    name = "Visual editor (Alpha)",
	    desc = "Edit tooltip's position", --TODO
	    func = function()
		mod:openPositionEditor("unit");
	    end
	},


	header2 = {
	    type = "header",
	    order = 8,
	    name = L["Frame"],
	},
	desc_2 = {
	    type = "description",
	    name = L["Options for the frame mouseover tooltips(spells, items, etc.)"],
	    order = 9
	},
	frameAnchor = {
	    type = "select",
	    order = 10,
	    name = L["Anchor"],
	    desc = L["The anchor with which the tooltips are showed."],
	    values = anchorTypeList,
	    get = function() return db.frameAnchor end,
	    set = function(_, v)
		db.frameAnchor = v
	    end
	},
	space_2 = {
	    type = "description",
	    name = L["Sets anchor offset"],
	    order = 11,
	},
	framePosX = {
	    type = "range",
	    order = 12,
	    name = L["Horizontal offset"],
	    desc = L["Sets offset of the X"],
	    min = tonumber(-(floor(screenWidth/5 + 0.5) * 5)),
	    max = tonumber(floor(screenWidth/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.frameOffsetX end,
	    set = function(_, v)
		db.frameOffsetX = v
	    end
	},
	framePoxY = {
	    type = "range",
	    order = 13,
	    name = L["Vertical offset"],
	    desc = L["Sets offset of the Y"],
	    min = tonumber(-(floor(screenHeight/5 + 0.5) * 5)),
	    max = tonumber(floor(screenHeight/5 + 0.5) * 5),
	    step = 1,
	    get = function() return db.frameOffsetY end,
	    set = function(_, v)
		db.frameOffsetY = v
	    end
	},
	frameGUI = {
	    type = "execute",
	    width = "full",
	    order = 14,
	    name = "Visual editor (Alpha)",
	    desc = "Edit tooltip's position", --TODO
	    func = function()
		mod:openPositionEditor("frame");
	    end
	},
    }

    return options
end
