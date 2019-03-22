CREATE VIEW [dbo].[vyuSTCustomerChargeReport]
	AS 
SELECT ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CH.dtmCheckoutDate
, ISNULL(Inv.ysnPosted, 0) ysnPosted
, CC.intCustomerId
, Cust.strCustomerNumber
, Entity.strName
, SUM(CC.dblAmount) dblAmount
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId 
INNER JOIN tblSTCheckoutCustomerCharges CC ON CC.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblARCustomer Cust ON Cust.intEntityId = CC.intCustomerId
INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Cust.intEntityId
INNER JOIN tblICItem IT ON IT.intItemId = CC.intProduct 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CC.dblAmount > 0	
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CH.dtmCheckoutDate, ISNULL(Inv.ysnPosted, 0), CC.intCustomerId, Cust.strCustomerNumber, Entity.strName

