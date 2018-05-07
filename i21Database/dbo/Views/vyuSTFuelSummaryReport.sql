CREATE VIEW [dbo].[vyuSTFuelSummaryReport]
	AS 
SELECT ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CAT.strDescription strCategoryDescription
, IT.strItemNo
, IT.strDescription strItemDescription
, CPT.dblQuantity
, CPT.dblPrice
, CPT.dblAmount 
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTCheckoutPumpTotals CPT ON CPT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPT.intPumpCardCouponId 
INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CPT.dblAmount > 0
