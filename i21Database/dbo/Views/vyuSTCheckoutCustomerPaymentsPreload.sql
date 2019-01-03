CREATE VIEW [dbo].[vyuSTCheckoutCustomerPaymentsPreload]
AS
SELECT ST.intStoreId
	   , EM.intEntityId AS intCustomerId
       , EM.strName AS strName
	   , ARC.strCustomerNumber AS strCustomerNumber
	   , CAST(NULL AS INT) AS intInvoice
	   , 'P' COLLATE Latin1_General_CI_AS AS strType
	   , CAST(NULL AS decimal(18,6)) AS dblAmount
	   , '' COLLATE Latin1_General_CI_AS AS strComment
	   --, I.intItemId AS intItemId
	   --, I.strItemNo AS strItemNo
	   --, I.strDescription AS strItemDescription
	   , '' COLLATE Latin1_General_CI_AS AS strCheckNo
	   , CH.intCheckoutId
FROM tblSTCheckoutCustomerPayments CCP
JOIN tblSTCheckoutHeader CH
	ON CCP.intCheckoutId = CH.intCheckoutId
JOIN tblSTStore ST
	ON CH.intStoreId = ST.intStoreId
--LEFT JOIN tblICItem I 
--	ON CCP.intItemId = I.intItemId
--JOIN tblICItemLocation IL
--	ON I.intItemId = IL.intItemId
--	AND ST.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblEMEntity EM 
	ON CCP.intCustomerId = EM.intEntityId
LEFT JOIN tblARCustomer ARC 
	ON CCP.intCustomerId = ARC.intEntityId