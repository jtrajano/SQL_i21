﻿CREATE VIEW [dbo].[vyuSTDepartmentSummaryReport]
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
, SUM(CDT.intItemsSold) intItemsSold
, SUM(CDT.intTotalSalesCount) intTotalSalesCount
, SUM(CDT.dblTotalSalesAmount) dblTotalSalesAmount
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
INNER JOIN tblSTCheckoutDepartmetTotals CDT ON CDT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblICItem IT ON IT.intItemId = CDT.intItemId 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CDT.dblTotalSalesAmount > 0	
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CAT.intCategoryId, CAT.strCategoryCode, CAT.strDescription, CH.dtmCheckoutDate, CH.ysnPosted