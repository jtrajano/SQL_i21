﻿CREATE VIEW [dbo].[vyuARInvoiceReport]
AS
SELECT INV.intInvoiceId
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
	 , strType = ISNULL(INV.strType, 'Standard')
     , strCustomerName = E.strName
	 , L.strLocationName
	 , INV.dtmDate
	 , INV.dtmPostDate
	 , CUR.strCurrency	 	 
	 , INV.strInvoiceNumber
	 , strBillTo = [dbo].fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry)
	 , strShipTo = [dbo].fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry)
	 , strSalespersonName = ESP.strName
	 , INV.strPONumber
	 , SO.strBOLNumber
	 , SV.strShipVia
	 , T.strTerm
	 , INV.dtmShipDate
	 , INV.dtmDueDate
	 , FT.strFreightTerm
	 , INV.strDeliverPickup
	 , INV.strComments
	 , dblInvoiceSubtotal = ISNULL(INV.dblInvoiceSubtotal, 0)
	 , dblShipping = ISNULL(INV.dblShipping, 0)
	 , dblTax = ISNULL(INV.dblTax, 0)
	 , dblInvoiceTotal = ISNULL(INV.dblInvoiceTotal, 0)
	 , dblAmountDue = ISNULL(INV.dblAmountDue, 0)
	 , I.strItemNo
	 , ID.intInvoiceDetailId
	 , strItemDescription = ID.strItemDescription
	 , UOM.strUnitMeasure
	 , dblQtyShipped = ISNULL(ID.dblQtyShipped, 0)
	 , dblQtyOrdered = ISNULL(ID.dblQtyOrdered, 0)
	 , dblDiscount = ISNULL(ID.dblDiscount, 0) / 100
	 , dblTotalTax = ISNULL(ID.dblTotalTax, 0)
	 , dblPrice = ISNULL(ID.dblPrice, 0)
	 , dblItemPrice = ISNULL(ID.dblTotal, 0)	 
	 , strPaid = CASE WHEN ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strPosted = CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END
	 , IDT.intTaxCodeId
	 , strTaxCode = SMT.strTaxCode
	 , dblTaxDetail = IDT.dblTax
	 , intDetailCount = (SELECT COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = INV.intInvoiceId)
FROM tblARInvoice INV
LEFT JOIN (tblARInvoiceDetail ID 
	LEFT JOIN tblICItem I ON ID.intItemId = I.intItemId 
	LEFT JOIN vyuARItemUOM UOM ON ID.intItemUOMId = UOM.intItemUOMId AND ID.intItemId = UOM.intItemId
	LEFT JOIN tblSOSalesOrderDetail SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SOD.intSalesOrderId
	LEFT JOIN tblARInvoiceDetailTax IDT ON ID.intInvoiceDetailId = IDT.intInvoiceDetailId
	LEFT JOIN tblSMTaxCode SMT ON IDT.intTaxCodeId = SMT.intTaxCodeId) ON INV.intInvoiceId = ID.intInvoiceId
INNER JOIN (tblARCustomer C 
	INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON C.intEntityCustomerId = INV.intEntityCustomerId
INNER JOIN tblSMCompanyLocation L ON INV.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblSMCurrency CUR ON INV.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (tblARSalesperson SP 
	INNER JOIN tblEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON INV.intEntitySalespersonId = SP.intEntitySalespersonId
LEFT JOIN tblSMShipVia SV ON INV.intShipViaId = SV.intEntityShipViaId
INNER JOIN tblSMTerm T ON INV.intTermId = T.intTermID
LEFT JOIN tblSMFreightTerms FT ON INV.intFreightTermId = FT.intFreightTermId