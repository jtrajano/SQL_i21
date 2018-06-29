CREATE PROCEDURE [dbo].[uspSTCheckoutItemMovementReport]
	@BeginDate Datetime,
	@EndDate Datetime
AS
BEGIN

DECLARE @tblItemMovement TABLE (intItemUOMId int, intVendorId int, dblQty decimal(18,6))

INSERT INTO @tblItemMovement
SELECT CIM.intItemUPCId, CIM.intVendorId, SUM(CIM.intQtySold)
FROM dbo.tblSTCheckoutItemMovements CIM
JOIN dbo.tblSTCheckoutHeader CH ON CH.intCheckoutId = CIM.intCheckoutId
WHERE CH.dtmCheckoutDate BETWEEN @BeginDate AND @EndDate
GROUP BY CIM.intItemUPCId, CIM.intVendorId

--SELECT * FROM @tblItemMovement

SELECT t1.*, ((t1.[dblGrossMarginDollar]/t1.[dblTotalSales])*100) [dblGrossMarginPercent] FROM
(
SELECT t.*
, (t.[dblCurrentPrice]*t.[dblQtySold]) [dblTotalSales] 
, ((t.[dblCurrentPrice]*t.[dblQtySold]) - (t.[dblItemCost]*t.[dblQtySold])) [dblGrossMarginDollar]
FROM
(
SELECT DISTINCT CASE WHEN UOM.strUpcCode is not null then UOM.strUpcCode else UOM.strLongUPCCode end [strUPCNumber]
, I.strDescription [strDescription]
, V.strVendorId [strVendor]
, ISNULL(CIM.dblItemStandardCost, 0) [dblItemCost]
, CASE WHEN (SP.dtmBeginDate < CH.dtmCheckoutDate AND SP.dtmEndDate > CH.dtmCheckoutDate) 
		THEN ISNULL(SP.dblUnit,0) 
		ELSE ISNULL(Pr.dblSalePrice,0) 
	END [dblCurrentPrice]
, IM.dblQty [dblQtySold]
FROM @tblItemMovement IM
JOIN dbo.tblSTCheckoutItemMovements CIM ON CIM.intItemUPCId = IM.intItemUOMId AND CIM.intVendorId = IM.intVendorId
JOIN dbo.tblSTCheckoutHeader CH ON CH.intCheckoutId = CIM.intCheckoutId
JOIN dbo.tblICItemUOM UOM ON UOM.intItemUOMId = CIM.intItemUPCId
JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
JOIN dbo.tblAPVendor V ON V.[intEntityId] = CIM.intVendorId
JOIN dbo.tblICItemSpecialPricing SP ON I.intItemId = SP.intItemId 
LEFT JOIN dbo.tblICItemPricing Pr ON Pr.intItemId = I.intItemId 
) t
)t1


END
