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

SELECT * FROM @tblItemMovement

SELECT t1.*, ((t1.[Gross Margin $]/t1.[Total Sales])*100) [Gross Margin %] FROM
(
SELECT t.*
, (t.[Current Price]*t.[Qty Sold]) [Total Sales] 
, ((t.[Current Price]*t.[Qty Sold]) - (t.[Item Cost]*t.[Qty Sold])) [Gross Margin $]
FROM
(
SELECT DISTINCT CASE WHEN UOM.strUpcCode is not null then UOM.strUpcCode else UOM.strLongUPCCode end [UPC Number]
, I.strDescription [Description]
, V.strVendorId [Vendor]
, ISNULL(CIM.dblItemStandardCost, 0) [Item Cost]
, CASE WHEN (SP.dtmBeginDate < CH.dtmCheckoutDate AND SP.dtmEndDate > CH.dtmCheckoutDate) 
		THEN SP.dblUnit 
		ELSE Pr.dblSalePrice 
	END [Current Price]
, IM.dblQty [Qty Sold]
FROM @tblItemMovement IM
JOIN dbo.tblSTCheckoutItemMovements CIM ON CIM.intItemUPCId = IM.intItemUOMId AND CIM.intVendorId = IM.intVendorId
JOIN dbo.tblSTCheckoutHeader CH ON CH.intCheckoutId = CIM.intCheckoutId
JOIN dbo.tblICItemUOM UOM ON UOM.intItemUOMId = CIM.intItemUPCId
JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
JOIN dbo.tblAPVendor V ON V.intEntityVendorId = CIM.intVendorId
JOIN dbo.tblICItemSpecialPricing SP ON I.intItemId = SP.intItemId 
JOIN dbo.tblICItemPricing Pr ON Pr.intItemId = I.intItemId 
) t
)t1


END
