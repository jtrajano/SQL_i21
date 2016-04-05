﻿CREATE VIEW [dbo].[vyuARSalesOrderReport]
AS
SELECT SO.intSalesOrderId	 
	 , strCompanyName = CASE WHEN L.strUseLocationAddress = 'Letterhead'
								THEN ''
							 ELSE
								(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
						END
	 , strCompanyAddress = CASE WHEN L.strUseLocationAddress IS NULL OR L.strUseLocationAddress = 'No' OR L.strUseLocationAddress = '' OR L.strUseLocationAddress = 'Always'
									THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup)
								WHEN L.strUseLocationAddress = 'Yes'
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, L.strZipPostalCode, L.strCountry, NULL)
								WHEN L.strUseLocationAddress = 'Letterhead'
									THEN ''
						   END 
	 , strOrderType				= ISNULL(SO.strType, 'Standard')
     , strCustomerName			= E.strName
	 , L.strLocationName
	 , SO.dtmDate
	 , CUR.strCurrency
	 , SO.strBOLNumber
	 , SO.strOrderStatus
	 , SO.strSalesOrderNumber
	 , SO.strPONumber
	 , SV.strShipVia
	 , T.strTerm
	 , SO.dtmDueDate
	 , FT.strFreightTerm
	 , I.strItemNo
	 , SD.intSalesOrderDetailId
	 , CH.strContractNumber
	 , SD.strItemDescription
	 , UOM.strUnitMeasure
	 , SDT.intTaxCodeId
	 , SO.strTransactionType
	 , QT.strTemplateName
	 , QT.intQuoteTemplateId
	 , strBillTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strBillToLocationName, SO.strBillToAddress, SO.strBillToCity, SO.strBillToState, SO.strBillToZipCode, SO.strBillToCountry, E.strName)
	 , strShipTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strShipToLocationName, SO.strShipToAddress, SO.strShipToCity, SO.strShipToState, SO.strShipToZipCode, SO.strShipToCountry, NULL)
	 , strSalespersonName		= ESP.strName
	 , strOrderedByName			= EOB.strName
	 , strSplitName				= CASE WHEN ISNULL(ES.strDescription, '') <> '' THEN ES.strDescription ELSE ES.strSplitNumber END
	 , strSOHeaderComment		= SO.strComments
	 , strSOFooterComment		= SO.strFooterComments
	 , dblSalesOrderSubtotal	= ISNULL(SO.dblSalesOrderSubtotal, 0)
	 , dblShipping				= ISNULL(SO.dblShipping, 0)
	 , dblTax					= ISNULL(SD.dblTotalTax, 0)
	 , dblSalesOrderTotal		= ISNULL(SO.dblSalesOrderTotal, 0)
	 , dblQtyShipped			= ISNULL(SD.dblQtyShipped, 0)
	 , dblQtyOrdered			= ISNULL(SD.dblQtyOrdered, 0)
	 , dblDiscount				= ISNULL(SD.dblDiscount, 0) / 100
	 , dblTotalTax				= ISNULL(SO.dblTax, 0)
	 , dblPrice					= ISNULL(SD.dblPrice, 0)
	 , dblItemPrice				= ISNULL(SD.dblTotal, 0)
	 , strTaxCode				= SMT.strTaxCode
	 , dblTaxDetail				= SDT.dblAdjustedTax
	 , intDetailCount			= (SELECT COUNT(*) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = SO.intSalesOrderId)
	 , ysnHasEmailSetup			= CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = SO.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + CASE WHEN SO.ysnQuote = 1 THEN 'Quote Order' ELSE 'Sales Order' END + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , blbLogo					= dbo.fnSMGetCompanyLogo('Header')	 
FROM tblSOSalesOrder SO
LEFT JOIN (tblSOSalesOrderDetail SD 
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId 
	LEFT JOIN tblSOSalesOrderDetailTax SDT ON SD.intSalesOrderDetailId = SDT.intSalesOrderDetailId
	LEFT JOIN tblSMTaxCode SMT ON SDT.intTaxCodeId = SMT.intTaxCodeId
	LEFT JOIN vyuARItemUOM UOM ON SD.intItemUOMId = UOM.intItemUOMId AND SD.intItemId = UOM.intItemId
	LEFT JOIN tblCTContractHeader CH ON SD.intContractHeaderId = CH.intContractHeaderId) ON SO.intSalesOrderId = SD.intSalesOrderId
LEFT JOIN (tblARCustomer C 
	INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON C.intEntityCustomerId = SO.intEntityCustomerId
LEFT JOIN tblSMCompanyLocation L ON SO.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblSMCurrency CUR ON SO.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (tblARSalesperson SP 
	INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON SO.intEntitySalespersonId = SP.intEntitySalespersonId
LEFT JOIN tblSMShipVia SV ON SO.intShipViaId = SV.intEntityShipViaId
INNER JOIN tblSMTerm T ON SO.intTermId = T.intTermID
LEFT JOIN tblEntity EOB ON SO.intOrderedById = EOB.intEntityId
LEFT JOIN tblSMFreightTerms FT ON SO.intFreightTermId = FT.intFreightTermId
LEFT JOIN tblEntitySplit ES ON SO.intSplitId = ES.intSplitId
LEFT JOIN tblARQuoteTemplate QT ON SO.intQuoteTemplateId = QT.intQuoteTemplateId AND SO.ysnQuote = 1