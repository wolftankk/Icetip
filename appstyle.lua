local _, Icetip = ...
local SM = LibStub("LibSharedMedia-3.0");
local Appstyle = Icetip:NewModule("Appstyle");

--local Icetip_Appstyle = {};
--Icetip.Appstyle = Icetip_Appstyle;

local backdrop = {insets = {}};

local hooked = {}
function Appstyle:UpdateBackdrop(tooltip, ...)
	if not tooltip then tooltip = GameTooltip end

        local db = self.db.tooltipStyle
	backdrop.bgFile = SM:Fetch("background", db.bgTexture);
	backdrop.edgeFile = SM:Fetch("border", db.borderTexture)
	backdrop.tile = db.tile
	backdrop.tileSize = db.tileSize
	backdrop.edgeSize = db.EdgeSize
	local inset = floor(db.EdgeSize/3);
	backdrop.insets.left = inset
	backdrop.insets.right = inset
	backdrop.insets.top = inset
	backdrop.insets.bottom = inset
	tooltip:SetBackdrop(backdrop);
end

--Onshow
function Appstyle:Tooltip_OnShow(tooltip, ...)
	if hooked[tooltip] then
		return
	end
	hooked[tooltip] = true
	self:UpdateBackdrop(tooltip, ...)
end

