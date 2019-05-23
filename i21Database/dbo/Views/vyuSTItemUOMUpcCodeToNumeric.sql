CREATE VIEW vyuSTItemUOMUpcCodeToNumeric
AS
SELECT 
       Item.strStatus
     , Item.strItemNo
	 , UOM.intItemUOMId
	 , UOM.intItemId
	 , UOM.strLongUPCCode
	 , UOM.ysnStockUnit
	 , CASE 
		 WHEN UOM.strLongUPCCode NOT LIKE '%[^0-9]%' 
			 THEN CONVERT(NUMERIC(32, 0),CAST(UOM.strLongUPCCode AS FLOAT))
		 ELSE NULL
	 END AS intLongUpcCode 
	 , ItemLoc.intLocationId
FROM dbo.tblICItemUOM UOM
INNER JOIN dbo.tblICItem Item
	ON UOM.intItemId = Item.intItemId
INNER JOIN dbo.tblICItemLocation ItemLoc
	ON Item.intItemId = ItemLoc.intItemId