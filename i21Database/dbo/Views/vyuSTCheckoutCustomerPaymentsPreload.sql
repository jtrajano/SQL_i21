CREATE VIEW [dbo].[vyuSTCheckoutCustomerPaymentsPreload]
AS
SELECT ST.intStoreId
	   , EM.intEntityId AS intCustomerId
       , EM.strName AS strName
	   , ARC.strCustomerNumber AS strCustomerNumber
	   , CAST(NULL AS INT) AS intInvoice
	   , 'P' AS strType
	   , CAST(NULL AS decimal(18,6)) AS dblAmount
	   , '' AS strComment
	   , I.intItemId AS intItemId
	   , I.strItemNo AS strItemNo
	   , I.strDescription AS strItemDescription
	   , '' AS strCheckNo
FROM tblSTStore ST
LEFT JOIN tblICItem I ON ST.intCustomerPaymentItemId = I.intItemId
LEFT JOIN tblEMEntity EM ON ST.intCheckoutCustomerId = EM.intEntityId
LEFT JOIN tblARCustomer ARC ON ST.intCheckoutCustomerId = ARC.intEntityId