CREATE VIEW [dbo].[vyuSTCheckoutCustomerChargesPreload]
AS
SELECT ST.intStoreId
	   , EM.intEntityId AS intCustomerId
       , EM.strName AS strName
	   , ARC.strCustomerNumber AS strCustomerNumber
	   , CAST(NULL AS INT) AS intInvoice
	   , 'N' AS strType
	   , CAST(NULL AS decimal(18,6)) AS dblAmount
	   , '' AS strComment
	   , UOM.intItemUOMId AS intProduct
	   , UOM.strUpcCode AS strUpcCode
	   , CAST(NULL AS decimal(18,6)) AS dblUnitPrice
	   , CAST(NULL AS decimal(18,6)) AS dblGallons
FROM tblSTStore ST
JOIN tblICItem I ON ST.intCustomerChargesItemId = I.intItemId
JOIN tblICItemUOM UOM ON ST.intCustomerChargesItemId = UOM.intItemId
JOIN tblEMEntity EM ON ST.intCheckoutCustomerId = EM.intEntityId
JOIN tblARCustomer ARC ON ST.intCheckoutCustomerId = ARC.intEntityId
WHERE UOM.ysnStockUnit = CAST(1 AS BIT)
