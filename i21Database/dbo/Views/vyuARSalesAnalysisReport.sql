CREATE VIEW [dbo].[vyuARSalesAnalysisReport]
AS
SELECT strRecordNumber
	 , intTransactionId
	 , A.intAccountId	 
	 , dtmDate
	 , A.intCompanyLocationId
	 , A.intEntityCustomerId	 
	 , IC.intItemId
	 , IC.intManufacturerId
	 , IC.intBrandId
	 , IC.intCommodityId
	 , IC.intCategoryId
	 , A.intEntitySalespersonId	 
	 , A.strTransactionType
	 , A.dblPrice
	 , A.dblTotal
	 , C.strCustomerNumber
	 , GA.strDescription AS strAccountName
	 , L.strLocationName
	 , IC.strDescription AS strItemName
	 , ICM.strManufacturer
	 , ICB.strBrandName
	 , ICC.strDescription AS strCommodityName
	 , CAT.strDescription AS strCategoryName
     , E.strName AS strCustomerName
	 , ESP.strName AS strSalespersonName	 
	 , strBillTo =  ISNULL(RTRIM(E.strPhone) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(E.strEmail) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(A.strBillToLocationName) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(A.strBillToAddress) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(A.strBillToCity), '')
				  + ISNULL(', ' + RTRIM(A.strBillToState), '')
				  + ISNULL(', ' + RTRIM(A.strBillToZipCode), '')
				  + ISNULL(', ' + RTRIM(A.strBillToCountry), '')
	 , strShipTo =  ISNULL(RTRIM(E.strPhone) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(E.strEmail) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(A.strShipToLocationName) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(A.strShipToAddress) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(A.strShipToCity), '')
				  + ISNULL(', ' + RTRIM(A.strShipToState), '')
				  + ISNULL(', ' + RTRIM(A.strShipToZipCode), '')
				  + ISNULL(', ' + RTRIM(A.strShipToCountry), '')
FROM
(SELECT I.strInvoiceNumber AS strRecordNumber
	  , I.intInvoiceId AS intTransactionId
	  , I.intEntityCustomerId
	  , I.intAccountId
	  , ID.intItemId
	  , I.dtmDate
	  , I.intCompanyLocationId	 
	  , I.intEntitySalespersonId	 
	  , I.strTransactionType
	  , ID.dblPrice
	  , I.dblInvoiceTotal AS dblTotal
	  , I.strBillToLocationName
	  , I.strBillToAddress
	  , I.strBillToCity
	  , I.strBillToState
	  , I.strBillToZipCode
	  , I.strBillToCountry
	  , I.strShipToLocationName
	  , I.strShipToAddress
	  , I.strShipToCity
	  , I.strShipToState
	  , I.strShipToZipCode
	  , I.strShipToCountry
FROM tblARInvoice I INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
WHERE I.ysnPosted = 1

UNION ALL

SELECT SO.strSalesOrderNumber AS strRecordNumber
	 , SO.intSalesOrderId AS intTransactionId
	 , SO.intEntityCustomerId
	 , SO.intAccountId
	 , SOD.intItemId
	 , SO.dtmDate
	 , SO.intCompanyLocationId
	 , SO.intEntitySalespersonId	 
	 , SO.strTransactionType
	 , SOD.dblPrice
	 , SO.dblSalesOrderTotal AS dblTotal 
	 , SO.strBillToLocationName
	 , SO.strBillToAddress
	 , SO.strBillToCity
	 , SO.strBillToState
	 , SO.strBillToZipCode
	 , SO.strBillToCountry
	 , SO.strShipToLocationName
	 , SO.strShipToAddress
	 , SO.strShipToCity
	 , SO.strShipToState
	 , SO.strShipToZipCode
	 , SO.strShipToCountry
FROM tblSOSalesOrder SO INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
WHERE SO.ysnProcessed = 1) AS A
	INNER JOIN tblGLAccount GA ON A.intAccountId = GA.intAccountId
	INNER JOIN tblSMCompanyLocation L ON A.intCompanyLocationId = L.intCompanyLocationId
	INNER JOIN (tblARCustomer C 
		INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON A.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN (tblARSalesperson SP 
		INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON A.intEntitySalespersonId = SP.intEntitySalespersonId	
	INNER JOIN (tblICItem IC 
		LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
		LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
		LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId
		LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId) ON A.intItemId = IC.intItemId