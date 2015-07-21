CREATE VIEW [dbo].[vyuARSalesOrderReport]
AS
SELECT SO.intSalesOrderId
     , strCustomerName = E.strName
	 , L.strLocationName
	 , SO.dtmDate
	 , CUR.strCurrency
	 , SO.strBOLNumber
	 , SO.strOrderStatus
	 , SO.strSalesOrderNumber
	 , strBillTo = [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strBillToLocationName, SO.strBillToAddress, SO.strBillToCity, SO.strBillToState, SO.strBillToZipCode, SO.strBillToCountry)
	 , strShipTo = [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strShipToLocationName, SO.strShipToAddress, SO.strShipToCity, SO.strShipToState, SO.strShipToZipCode, SO.strShipToCountry)
	 , strSalespersonName = ESP.strName
	 , SO.strPONumber
	 , SV.strShipVia
	 , T.strTerm
	 , strOrderedByName = EOB.strName
	 , SO.dtmDueDate
	 , FT.strFreightTerm
	 , strSplitName = CS.strDescription
	 , SO.strComments
	 , dblSalesOrderSubtotal = ISNULL(SO.dblSalesOrderSubtotal, 0)
	 , dblShipping = ISNULL(SO.dblShipping, 0)
	 , dblTax = ISNULL(SO.dblTax, 0)
	 , dblSalesOrderTotal = ISNULL(SO.dblSalesOrderTotal, 0)
	 , I.strItemNo
	 , strItemDescription = I.strDescription
	 , UOM.strUnitMeasure
	 , dblQtyShipped = ISNULL(SD.dblQtyShipped, 0)
	 , dblQtyOrdered = ISNULL(SD.dblQtyOrdered, 0)
	 , dblDiscount = ISNULL(SD.dblDiscount, 0)
	 , dblTotalTax = ISNULL(SD.dblTotalTax, 0)
	 , dblPrice = ISNULL(SD.dblPrice, 0)
	 , dblItemPrice = ISNULL(SD.dblTotal, 0)
FROM tblSOSalesOrder SO
LEFT JOIN (tblSOSalesOrderDetail SD 
	INNER JOIN tblICItem I ON SD.intItemId = I.intItemId 
	LEFT JOIN vyuARItemUOM UOM ON SD.intItemUOMId = UOM.intItemUOMId AND SD.intItemId = UOM.intItemId) ON SO.intSalesOrderId = SD.intSalesOrderId
INNER JOIN (tblARCustomer C 
	INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON C.intEntityCustomerId = SO.intEntityCustomerId
INNER JOIN tblSMCompanyLocation L ON SO.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblSMCurrency CUR ON SO.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (tblARSalesperson SP 
	INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON SO.intEntitySalespersonId = SP.intEntitySalespersonId
LEFT JOIN tblSMShipVia SV ON SO.intShipViaId = SV.intEntityShipViaId
INNER JOIN tblSMTerm T ON SO.intTermId = T.intTermID
LEFT JOIN tblEntity EOB ON SO.intOrderedById = EOB.intEntityId
LEFT JOIN tblSMFreightTerms FT ON SO.intFreightTermId = FT.intFreightTermId
LEFT JOIN tblARCustomerSplit CS ON SO.intSplitId = CS.intSplitId