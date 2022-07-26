CREATE VIEW [dbo].[vyuSTCheckoutAggregateMeterReadingsByFuelGrade]
AS
SELECT		a.intPumpTotalsId as intFuelTotalSoldId,
			a.intCheckoutId,
			IL.strPassportFuelId1 as intProductNumber,
			a.strDescription,
			a.dblAmount as dblDollarsSold,
			a.dblQuantity as dblGallonsSold
FROM		tblSTCheckoutPumpTotals  a
INNER JOIN	tblSTCheckoutHeader CH
ON			a.intCheckoutId = CH.intCheckoutId
INNER JOIN tblSTStore ST
ON			CH.intStoreId = ST.intStoreId
INNER JOIN tblICItemUOM UOM
ON			a.intPumpCardCouponId = UOM.intItemUOMId
INNER JOIN tblICItem Item
ON			UOM.intItemId = Item.intItemId
INNER JOIN dbo.tblICItemLocation IL 
ON			Item.intItemId = IL.intItemId AND 
			ST.intCompanyLocationId = IL.intLocationId