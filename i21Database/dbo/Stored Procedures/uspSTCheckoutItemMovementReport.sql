CREATE PROCEDURE [dbo].[uspSTCheckoutItemMovementReport]
	@strStoreIdList AS NVARCHAR(MAX) = '',
	@strCategoryIdList AS NVARCHAR(MAX) = '',
	@strFamilyIdList AS NVARCHAR(MAX) = '', 
	@strClassIdList AS NVARCHAR(MAX) = '', 
	@dtmCheckoutDateFrom AS DATETIME,
	@dtmCheckoutDateTo AS DATETIME 
AS
BEGIN

SELECT 
	 IL.intItemLocationId AS intRowCount
	 , ST.intStoreId
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
	 --, tblIMQty.dblItemCostAvgSum AS dblItemCost

	 , (tblIMQty.dblGrossSalesSum - tblIMQty.dblDiscountAmountSum) AS dblTotalSales
	 --, (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) AS dblTotalSales

	 -- ADDED
	 , ((tblIMQty.dblGrossSalesSum - tblIMQty.dblDiscountAmountSum) / tblIMQty.intQtySoldSum) AS dblAveragePrice
	 , (tblIMQty.dblItemCostSum * tblIMQty.intQtySoldSum) AS dblTotalCost
	 , (tblIMQty.dblItemCostSum / tblIMQty.intQtySoldSum) AS dblAverageCost
	 , ItemPricing.dblLastCost AS dblCurrentCost

	 -- Formula: Gross Margin $ = Totals Sales - (Qty * Item Movement Item Cost)
	 , (tblIMQty.dblGrossSalesSum - tblIMQty.dblDiscountAmountSum) - (tblIMQty.dblItemCostSum * tblIMQty.intQtySoldSum) AS dblGrossMarginDollar
	 --, (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) - (tblIMQty.intQtySoldSum * tblIMQty.dblItemCostAvgSum) AS dblGrossMarginDollar

	 -- Formula: Gross Margin % = Total Sales - (Qty * Item Movement Item Cost) / Total Sales
	 , CASE 
		WHEN (tblIMQty.dblGrossSalesSum - tblIMQty.dblDiscountAmountSum) <> 0
			THEN ( (tblIMQty.dblGrossSalesSum - tblIMQty.dblDiscountAmountSum) - (tblIMQty.dblItemCostSum * tblIMQty.intQtySoldSum) )   / (tblIMQty.dblGrossSalesSum - tblIMQty.dblDiscountAmountSum) 
		ELSE 0
	 END AS dblGrossMarginPercent
	 --, CASE 
		--WHEN (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) <> 0
		--	THEN ( (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum) - (tblIMQty.intQtySoldSum * tblIMQty.dblItemCostAvgSum) ) / (ItemPricing.dblSalePrice * tblIMQty.intQtySoldSum)
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
		, SUM(ISNULL(IM.dblDiscountAmount, 0)) AS dblDiscountAmountSum
		, SUM(ISNULL(IM.dblGrossSales, 0)) AS dblGrossSalesSum
		, SUM(ISNULL(IM.intQtySold, 0)) AS intQtySoldSum
		, SUM(ISNULL(IM.dblItemStandardCost, 0)) AS dblItemCostSum
		-- , AVG(ISNULL(IM.dblItemStandardCost, 0)) AS dblItemCostAvgSum
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
	INNER JOIN tblICItemLocation IL
		ON Item.intItemId = IL.intItemId
		AND CL.intCompanyLocationId = IL.intLocationId
	LEFT JOIN tblSTSubcategory Family
		ON IL.intFamilyId = Family.intSubcategoryId
		AND Family.strSubcategoryType = 'F'
	LEFT JOIN tblSTSubcategory Class
		ON IL.intFamilyId = Class.intSubcategoryId
		AND Class.strSubcategoryType = 'C'
	WHERE UOM.strLongUPCCode IS NOT NULL 
		AND (
				ST.intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))
				OR 1 = CASE 
							WHEN @strStoreIdList = ''
								THEN 1
							ELSE 0
					   END
			)
		AND (
				Item.intCategoryId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryIdList))
				OR 1 = CASE 
							WHEN @strCategoryIdList = ''
								THEN 1
							ELSE 0
					   END
			)
		AND (
				Item.intCategoryId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryIdList))
				OR 1 = CASE 
							WHEN @strCategoryIdList = ''
								THEN 1
							ELSE 0
					   END
			)
		AND (
				IL.intFamilyId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strFamilyIdList))
				OR 1 = CASE 
							WHEN @strFamilyIdList = ''
								THEN 1
							ELSE 0
					   END
			)
		AND (
				IL.intClassId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strClassIdList))
				OR 1 = CASE 
							WHEN @strClassIdList = ''
								THEN 1
							ELSE 0
					   END
			)
		AND (
				CH.dtmCheckoutDate BETWEEN @dtmCheckoutDateFrom AND @dtmCheckoutDateTo
				OR 1 = CASE 
							WHEN @dtmCheckoutDateFrom IS NULL AND @dtmCheckoutDateTo IS NULL
								THEN 1
							ELSE 0
					   END
			)
	GROUP BY  ST.intStoreId
			, UOM.intItemUOMId
			, UOM.strLongUPCCode
			, Item.intItemId
			, Item.strDescription
			, Item.strItemNo
			, Item.intCategoryId
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
ORDER BY Cat.intCategoryId
       , tblIMQty.strLongUPCCode ASC





--DECLARE @tblItemMovement TABLE (intItemUOMId int, intVendorId int, dblQty decimal(18,6))

--INSERT INTO @tblItemMovement
--SELECT CIM.intItemUPCId, CIM.intVendorId, SUM(CIM.intQtySold)
--FROM dbo.tblSTCheckoutItemMovements CIM
--JOIN dbo.tblSTCheckoutHeader CH ON CH.intCheckoutId = CIM.intCheckoutId
--WHERE CH.dtmCheckoutDate BETWEEN @BeginDate AND @EndDate
--GROUP BY CIM.intItemUPCId, CIM.intVendorId

----SELECT * FROM @tblItemMovement

--SELECT t1.*, ((t1.[dblGrossMarginDollar]/t1.[dblTotalSales])*100) [dblGrossMarginPercent] FROM
--(
--SELECT t.*
--, (t.[dblCurrentPrice]*t.[dblQtySold]) [dblTotalSales] 
--, ((t.[dblCurrentPrice]*t.[dblQtySold]) - (t.[dblItemCost]*t.[dblQtySold])) [dblGrossMarginDollar]
--FROM
--(
--SELECT DISTINCT CASE WHEN UOM.strUpcCode is not null then UOM.strUpcCode else UOM.strLongUPCCode end [strUPCNumber]
--, I.strDescription [strDescription]
--, V.strVendorId [strVendor]
--, ISNULL(CIM.dblItemStandardCost, 0) [dblItemCost]
--, CASE WHEN (SP.dtmBeginDate < CH.dtmCheckoutDate AND SP.dtmEndDate > CH.dtmCheckoutDate) 
--		THEN ISNULL(SP.dblUnit,0) 
--		ELSE ISNULL(Pr.dblSalePrice,0) 
--	END [dblCurrentPrice]
--, IM.dblQty [dblQtySold]
--FROM @tblItemMovement IM
--JOIN dbo.tblSTCheckoutItemMovements CIM ON CIM.intItemUPCId = IM.intItemUOMId AND CIM.intVendorId = IM.intVendorId
--JOIN dbo.tblSTCheckoutHeader CH ON CH.intCheckoutId = CIM.intCheckoutId
--JOIN dbo.tblICItemUOM UOM ON UOM.intItemUOMId = CIM.intItemUPCId
--JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
--JOIN dbo.tblAPVendor V ON V.[intEntityId] = CIM.intVendorId
--JOIN dbo.tblICItemSpecialPricing SP ON I.intItemId = SP.intItemId 
--LEFT JOIN dbo.tblICItemPricing Pr ON Pr.intItemId = I.intItemId 
--) t
--)t1


END