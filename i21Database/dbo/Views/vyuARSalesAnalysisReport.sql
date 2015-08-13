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
	 , A.strType
	 , A.dblPrice
	 , A.dblTotal
	 , C.strCustomerNumber
	 , GA.strDescription			  AS strAccountName
	 , L.strLocationName
	 , IC.strItemNo					  AS strItemName
	 , ICM.strManufacturer
	 , ICB.strBrandName
	 , ICC.strCommodityCode			  AS strCommodityName
	 , CAT.strCategoryCode			  AS strCategoryName
     , E.strName					  AS strCustomerName
	 , ESP.strName					  AS strSalespersonName	 
	 , RTRIM(A.strBillToLocationName) AS strBillTo
	 , RTRIM(A.strShipToLocationName) AS strShipTo
FROM
(SELECT I.strInvoiceNumber			  AS strRecordNumber
	  , I.intInvoiceId				  AS intTransactionId
	  , I.intEntityCustomerId
	  , I.intAccountId
	  , ID.intItemId
	  , I.dtmDate
	  , I.intCompanyLocationId	 
	  , I.intEntitySalespersonId	 
	  , I.strTransactionType
	  , I.strType
	  , ID.dblPrice
	  , I.dblInvoiceTotal			  AS dblTotal
	  , I.strBillToLocationName
	  , I.strShipToLocationName
FROM tblARInvoice I INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
WHERE I.ysnPosted = 1

UNION ALL

SELECT SO.strSalesOrderNumber		  AS strRecordNumber
	 , SO.intSalesOrderId			  AS intTransactionId
	 , SO.intEntityCustomerId
	 , SO.intAccountId
	 , SOD.intItemId	 
	 , SO.dtmDate
	 , SO.intCompanyLocationId
	 , SO.intEntitySalespersonId	 
	 , SO.strTransactionType
	 , SO.strType
	 , SOD.dblPrice
	 , SO.dblSalesOrderTotal		  AS dblTotal 
	 , SO.strBillToLocationName
	 , SO.strShipToLocationName
FROM tblSOSalesOrder SO INNER JOIN tblSOSalesOrderDetail SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
WHERE SO.ysnProcessed = 1) AS A
	INNER JOIN tblGLAccount GA ON A.intAccountId = GA.intAccountId
	INNER JOIN tblSMCompanyLocation L ON A.intCompanyLocationId = L.intCompanyLocationId
	INNER JOIN (tblARCustomer C 
		INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON A.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN (tblARSalesperson SP 
		INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON A.intEntitySalespersonId = SP.intEntitySalespersonId	
	LEFT JOIN (tblICItem IC 
		LEFT JOIN tblICManufacturer ICM ON IC.intManufacturerId = ICM.intManufacturerId
		LEFT JOIN tblICCommodity ICC ON IC.intCommodityId = ICC.intCommodityId
		LEFT JOIN tblICCategory CAT ON IC.intCategoryId = CAT.intCategoryId
		LEFT JOIN tblICBrand ICB ON IC.intBrandId = ICB.intBrandId) ON A.intItemId = IC.intItemId