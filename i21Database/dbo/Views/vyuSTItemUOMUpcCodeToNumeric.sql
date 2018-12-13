CREATE VIEW vyuSTItemUOMUpcCodeToNumeric
AS
SELECT Item.strItemNo
	 , UOM.intItemUOMId
	 , UOM.intItemId
	 , UOM.strUpcCode
	 , UOM.strLongUPCCode
	 , CASE 
		 WHEN UOM.strUpcCode NOT LIKE '%[^0-9]%' 
			 THEN CONVERT(NUMERIC(32, 0),CAST(UOM.strUpcCode AS FLOAT))
		 ELSE NULL
	 END AS intUpcCode
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