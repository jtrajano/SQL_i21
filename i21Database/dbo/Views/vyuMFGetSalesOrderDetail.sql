CREATE VIEW dbo.vyuMFGetSalesOrderDetail
AS
SELECT sh.intSalesOrderId
	,sh.strSalesOrderNumber
	,sh.dtmDate
	,sh.dtmDueDate
	,T.strTerm
	,c.strName AS strCustomerName
	,sh.strShipToLocationName
	,sh.strShipToAddress
	,sh.strShipToCity
	,sh.strShipToState
	,sh.strShipToZipCode
	,sh.strShipToCountry
	,sh.strBillToLocationName
	,sh.strBillToAddress
	,sh.strBillToCity
	,sh.strBillToState
	,sh.strBillToZipCode
	,sh.strBillToCountry
	,US.strUserName
	,sh.strPONumber
	,sh.strBOLNumber
	,sh.strOrderStatus
	,FT.strFreightTerm
	,E.strName AS strContact
	,cl.strLocationName
	,sh.strComments
	,i.strItemNo
	,i.strDescription
	,sd.dblQtyOrdered AS dblOrderedQty
	,sd.dblQtyShipped
	,um.strUnitMeasure AS strUOM
	,sd.dblPrice
	,sd.dblTotal
	,C1.strCurrency
FROM tblSOSalesOrder sh
JOIN tblSOSalesOrderDetail sd ON sh.intSalesOrderId = sd.intSalesOrderId
JOIN tblICItem i ON sd.intItemId = i.intItemId
JOIN tblICItemUOM iu ON sd.intItemUOMId = iu.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
JOIN tblSMCompanyLocation cl ON sh.intCompanyLocationId = cl.intCompanyLocationId
LEFT JOIN vyuARCustomer c ON sh.intEntityCustomerId = c.[intEntityId]
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = sh.intFreightTermId
LEFT JOIN tblEMEntity E ON E.intEntityId = sh.intEntityContactId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = sh.intOrderedById
JOIN tblSMTerm T ON T.intTermID = sh.intTermId
JOIN tblSMCurrency C1 ON C1.intCurrencyID = sh.intCurrencyId

