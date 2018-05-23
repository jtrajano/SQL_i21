CREATE VIEW [dbo].[vyuSTDepartmentDetailReport]
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
, ISNULL(Inv.ysnPosted, 0) ysnPosted
, CDT.intItemsSold 
, CDT.intTotalSalesCount
, CDT.dblTotalSalesAmount
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId
INNER JOIN tblSTCheckoutDepartmetTotals CDT ON CDT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblICItem IT ON IT.intItemId = CDT.intItemId 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CDT.dblTotalSalesAmount > 0