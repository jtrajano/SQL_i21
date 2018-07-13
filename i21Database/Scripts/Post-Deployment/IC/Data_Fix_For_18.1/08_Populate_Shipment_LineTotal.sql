PRINT N'BEGIN - IC Data Fix for 18.1. #8'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 

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
END 

PRINT N'END - IC Data Fix for 18.1. #8'
GO
