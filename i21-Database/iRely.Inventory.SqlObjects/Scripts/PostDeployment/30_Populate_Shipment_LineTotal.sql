UPDATE si
SET		dblLineTotal = ROUND(
			si.dblQuantity 
			* si.dblUnitPrice
			* (itemUOM.dblUnitQty / isnull(priceUOM.dblUnitQty, itemUOM.dblUnitQty)) 
			, 2
		)
		, si.intPriceUOMId = itemUOM.intItemUOMId
FROM	tblICInventoryShipmentItem si LEFT JOIN tblICItemUOM itemUOM
			ON si.intItemUOMId = itemUOM.intItemUOMId
		LEFT JOIN tblICItemUOM priceUOM
			ON priceUOM.intItemUOMId = si.intPriceUOMId
WHERE	priceUOM.intItemUOMId IS NULL 
		and itemUOM.dblUnitQty <> 0 