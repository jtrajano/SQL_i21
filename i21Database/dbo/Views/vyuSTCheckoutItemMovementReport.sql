CREATE VIEW [dbo].[vyuSTCheckoutItemMovementReport]
	AS
SELECT
	   ST.intStoreId
	 , ST.intStoreNo
	 , IL.intFamilyId
	 , Family.strSubcategoryId AS strFamily
	 , IL.intClassId
	 , Class.strSubcategoryId  AS strClass
	 , Cat.intCategoryId
	 , Cat.strCategoryCode
	 , EM.strName AS strVendorName
	 , tblIMQty.dtmCheckoutDateMin
	 , tblIMQty.dtmCheckoutDateMax
	 , tblIMQty.strLongUPCCode
	 , tblIMQty.strItemNo
	 , tblIMQty.strItemDescription
	 , tblIMQty.intQtySoldSum AS intQtySold
	 , ItemPricing.dblSalePrice AS dblCurrentPrice
	 , tblIMQty.dblItemCostSum AS dblItemCost
	 , (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) AS dblTotalSales

	 -- Formula: Gross Margin $ = Totals Sales - (Qty * Item Movement Item Cost)
	 , (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) - (tblIMQty.intQtySoldSum * tblIMQty.dblItemCostSum) AS dblGrossMarginDollar

	 -- Formula: Gross Margin % = Total Sales - (Qty * Item Movement Item Cost) / Total Sales
	 , CASE 
		WHEN (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) <> 0
			THEN ( (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) - (tblIMQty.intQtySoldSum * tblIMQty.dblItemCostSum) ) / (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum)
		ELSE 0
	 END AS dblGrossMarginPercent
	 --, ((ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) - (tblIMQty.dblItemCostSum * tblIMQty.intQtySoldSum)) AS dblGrossMarginDollar
	 --, CASE 
		--WHEN (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) <> 0
		--	THEN (( ((ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) - (tblIMQty.dblItemCostSum * tblIMQty.intQtySoldSum)) / (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) )*100)
		--ELSE 0
	 --END AS dblGrossMarginPercent
FROM
(
	SELECT 
	      ST.intStoreId
		, UOM.intItemUOMId
		, UOM.strLongUPCCode
		, Item.intItemId
		, Item.strItemNo
		, Item.strDescription AS strItemDescription
		, Item.intCategoryId
		, SUM(ISNULL(IM.intQtySold, 0)) AS intQtySoldSum
		, AVG(ISNULL(IM.dblItemStandardCost, 0)) AS dblItemCostSum
		, MIN(CH.dtmCheckoutDate) AS dtmCheckoutDateMin
		, MAX(CH.dtmCheckoutDate) AS dtmCheckoutDateMax
	FROM tblSTCheckoutItemMovements IM
	INNER JOIN tblSTCheckoutHeader CH
		ON IM.intCheckoutId = CH.intCheckoutId
	INNER JOIN tblSTStore ST
		ON CH.intStoreId = ST.intStoreId
	INNER JOIN tblSMCompanyLocation CL	
		ON ST.intCompanyLocationId = CL.intCompanyLocationId
	INNER JOIN dbo.tblICItemUOM UOM 
		ON UOM.intItemUOMId = IM.intItemUPCId
	INNER JOIN tblICItem Item
		ON UOM.intItemId = Item.intItemId
	WHERE UOM.strLongUPCCode IS NOT NULL
	GROUP BY  ST.intStoreId
			, UOM.intItemUOMId
			, UOM.strLongUPCCode
			, Item.intItemId
			, Item.strDescription
			, Item.strItemNo
			, Item.intCategoryId
	
	-- ORDER BY ST.intStoreId, UOM.strLongUPCCode
) tblIMQty
INNER JOIN tblICCategory Cat
	ON tblIMQty.intCategoryId = Cat.intCategoryId
INNER JOIN tblSTStore ST
	ON tblIMQty.intStoreId = ST.intStoreId
INNER JOIN tblSMCompanyLocation CL	
	ON ST.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN tblICItemLocation IL
	ON tblIMQty.intItemId = IL.intItemId
	AND CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSTSubcategory Family
	ON IL.intFamilyId = Family.intSubcategoryId
	AND Family.strSubcategoryType = 'F'
LEFT JOIN tblSTSubcategory Class
	ON IL.intFamilyId = Class.intSubcategoryId
	AND Class.strSubcategoryType = 'C'
LEFT JOIN dbo.tblAPVendor Vendor 
	ON Vendor.intEntityId = IL.intVendorId
LEFT JOIN dbo.tblEMEntity EM
	ON Vendor.intEntityId = EM.intEntityId
LEFT JOIN dbo.tblICItemSpecialPricing ItemSpecial 
	ON tblIMQty.intItemId = ItemSpecial.intItemId 
	AND IL.intItemLocationId = ItemSpecial.intItemLocationId 
LEFT JOIN dbo.tblICItemPricing ItemPricing 
	ON tblIMQty.intItemId = ItemPricing.intItemId
	AND IL.intItemLocationId = ItemPricing.intItemLocationId 
--ORDER BY ST.intStoreId, tblIMQty.strLongUPCCode

