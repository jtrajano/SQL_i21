CREATE VIEW [dbo].[vyuSTCustomerPaymentReport]
	AS 
SELECT ST.intStoreId
, ST.intStoreNo
, ST.strRegion
, ST.strDistrict
, ST.strDescription strStoreDescription
, CH.dtmCheckoutDate
, ISNULL(Inv.ysnPosted, 0) ysnPosted
, CT.intCustomerId
, Cust.strCustomerNumber
, Entity.strName
, SUM(CT.dblAmount) dblAmount
FROM tblSTCheckoutHeader CH INNER JOIN tblSTStore ST ON ST.intStoreId = CH.intStoreId 
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId = CH.intInvoiceId
INNER JOIN tblSTCheckoutCustomerPayments CT ON CT.intCheckoutId = CH.intCheckoutId 
INNER JOIN tblARCustomer Cust ON Cust.intEntityId = CT.intCustomerId
INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Cust.intEntityId
INNER JOIN tblICItem IT ON IT.intItemId = CT.intItemId 
INNER JOIN tblICCategory CAT ON CAT.intCategoryId = IT.intCategoryId
WHERE CT.dblAmount > 0	
GROUP BY ST.intStoreId, ST.intStoreNo, ST.strRegion, ST.strDistrict, ST.strDescription, CH.dtmCheckoutDate, ISNULL(Inv.ysnPosted, 0), CT.intCustomerId, Cust.strCustomerNumber, Entity.strName
