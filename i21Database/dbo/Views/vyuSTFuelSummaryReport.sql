﻿CREATE VIEW [dbo].[vyuSTFuelSummaryReport]
	AS 
SELECT ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CAT.intCategoryId
, CAT.strDescription strCategoryDescription
, IT.intItemId
, IT.strItemNo
, IT.strDescription strItemDescription
, CH.dtmCheckoutDate
, SUM(CPT.dblQuantity) dblQuantity
, SUM(CPT.dblAmount) dblAmount
, SUM(CPT.dblAmount) / SUM(CPT.dblQuantity) dblPrice
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTCheckoutPumpTotals CPT ON CPT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CPT.intPumpCardCouponId 
INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CPT.dblAmount > 0	
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CAT.intCategoryId, CAT.strDescription, IT.intItemId, IT.strItemNo, IT.strDescription, CH.dtmCheckoutDate
