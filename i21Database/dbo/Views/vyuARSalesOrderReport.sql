CREATE VIEW [dbo].[vyuARSalesOrderReport]
AS
SELECT SO.intSalesOrderId
	 , strCompanyName = CASE WHEN L.strUseLocationAddress = 'Letterhead'
								THEN ''
							 ELSE
								(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
						END
	 , strCompanyAddress = CASE WHEN L.strUseLocationAddress IS NULL OR L.strUseLocationAddress = 'No' OR L.strUseLocationAddress = '' OR L.strUseLocationAddress = 'Always'
									THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry) FROM tblSMCompanySetup)
								WHEN L.strUseLocationAddress = 'Yes'
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, L.strZipPostalCode, L.strCountry)
								WHEN L.strUseLocationAddress = 'Letterhead'
									THEN ''
						   END 
	 , strOrderType = ISNULL(SO.strType, 'Standard')
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
	 , strSplitName = ES.strDescription
	 , SO.strComments
	 , dblSalesOrderSubtotal = ISNULL(SO.dblSalesOrderSubtotal, 0)
	 , dblShipping = ISNULL(SO.dblShipping, 0)
	 , dblTax = ISNULL(SO.dblTax, 0)
	 , dblSalesOrderTotal = ISNULL(SO.dblSalesOrderTotal, 0)
	 , I.strItemNo
	 , SD.intSalesOrderDetailId
	 , CH.strContractNumber
	 , SD.strItemDescription
	 , UOM.strUnitMeasure
	 , dblQtyShipped = ISNULL(SD.dblQtyShipped, 0)
	 , dblQtyOrdered = ISNULL(SD.dblQtyOrdered, 0)
	 , dblDiscount = ISNULL(SD.dblDiscount, 0) / 100
	 , dblTotalTax = ISNULL(SD.dblTotalTax, 0)
	 , dblPrice = ISNULL(SD.dblPrice, 0)
	 , dblItemPrice = ISNULL(SD.dblTotal, 0)
	 , SDT.intTaxCodeId
	 , strTaxCode = SMT.strTaxCode
	 , dblTaxDetail = SDT.dblTax
	 , intDetailCount = (SELECT COUNT(*) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = SO.intSalesOrderId)
FROM tblSOSalesOrder SO
LEFT JOIN (tblSOSalesOrderDetail SD 
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId 
	LEFT JOIN tblSOSalesOrderDetailTax SDT ON SD.intSalesOrderDetailId = SDT.intSalesOrderDetailId
	LEFT JOIN tblSMTaxCode SMT ON SDT.intTaxCodeId = SMT.intTaxCodeId
	LEFT JOIN vyuARItemUOM UOM ON SD.intItemUOMId = UOM.intItemUOMId AND SD.intItemId = UOM.intItemId
	LEFT JOIN tblCTContractHeader CH ON SD.intContractHeaderId = CH.intContractHeaderId) ON SO.intSalesOrderId = SD.intSalesOrderId
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
LEFT JOIN tblEntitySplit ES ON SO.intSplitId = ES.intSplitId