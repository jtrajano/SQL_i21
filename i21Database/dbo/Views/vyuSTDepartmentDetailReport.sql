﻿CREATE VIEW [dbo].[vyuSTDepartmentDetailReport]
	AS 
SELECT ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CAT.intCategoryId
, CAT.strCategoryCode
, CAT.strDescription strCategoryDescription
, CH.dtmCheckoutDate
, CH.ysnPosted
, CDT.intItemsSold 
, CDT.intTotalSalesCount
, CDT.dblTotalSalesAmount
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTCheckoutDepartmetTotals CDT ON CDT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CDT.intItemId 
INNER JOIN tblICItem IT ON IT.intItemId = IU.intItemId 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CDT.dblTotalSalesAmount > 0