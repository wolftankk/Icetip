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


