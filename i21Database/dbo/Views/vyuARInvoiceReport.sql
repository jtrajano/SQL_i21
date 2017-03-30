CREATE VIEW [dbo].[vyuARInvoiceReport]
AS
SELECT INV.intInvoiceId	 
	 , strCompanyName			= (CASE WHEN L.strUseLocationAddress = 'Letterhead'
											THEN ''
										ELSE
											(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
									END)
	 , strCompanyAddress		= (CASE WHEN L.strUseLocationAddress IS NULL OR L.strUseLocationAddress = 'No' OR L.strUseLocationAddress = '' OR L.strUseLocationAddress = 'Always'
											THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, ysnIncludeEntityName) FROM tblSMCompanySetup)
									   WHEN L.strUseLocationAddress = 'Yes'
											THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, L.strZipPostalCode, L.strCountry, NULL, ysnIncludeEntityName)
									   WHEN L.strUseLocationAddress = 'Letterhead'
											THEN ''
									END)
	 , strType					= ISNULL(INV.strType, 'Standard')
     , strCustomerName			= E.strName
	 , L.strLocationName
	 , INV.dtmDate
	 , INV.dtmPostDate
	 , CUR.strCurrency	 	 
	 , INV.strInvoiceNumber
	 , INV.strBillToLocationName
	 , strBillTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, E.strName, ysnIncludeEntityName)
	 , strShipTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, E.strName, ysnIncludeEntityName)
	 , strSalespersonName		= ESP.strName
	 , INV.strPONumber
	 , strBOLNumber				= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									(CASE WHEN INV.strBOLNumber IS NOT NULL AND LEN(RTRIM(LTRIM(ISNULL(INV.strBOLNumber,'')))) > 0
										  THEN INV.strBOLNumber
										ELSE SO.strBOLNumber									
								    END)
									ELSE NULL END
	 , strShipVia				= ESV.strName
	 , T.strTerm
	 , INV.dtmShipDate
	 , INV.dtmDueDate
	 , FT.strFreightTerm
	 , INV.strDeliverPickup	 
	 , strInvoiceHeaderComment	= INV.strComments
	 , strInvoiceFooterComment	= INV.strFooterComments
	 , dblInvoiceSubtotal		= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(INV.dblInvoiceSubtotal, 0) END
	 , dblShipping				= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblShipping, 0) * -1 ELSE ISNULL(INV.dblShipping, 0) END
	 , dblTax					= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(ID.dblTotalTax, 0) * -1 ELSE ISNULL(ID.dblTotalTax, 0) END
								  ELSE NULL END
	 , dblInvoiceTotal			= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblInvoiceTotal, 0) * -1 ELSE ISNULL(INV.dblInvoiceTotal, 0) END								  
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , strItemNo				= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN I.strItemNo ELSE NULL END
	 , ID.intInvoiceDetailId
	 , dblContractBalance		= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN ID.dblContractBalance = 0 THEN CD.dblBalance ELSE ID.dblContractBalance END
								  ELSE NULL END
	 , strContractNumber		= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN CH.strContractNumber ELSE NULL END				
	 , strItem					= CASE WHEN ISNULL(I.strItemNo, '') = '' THEN ID.strItemDescription ELSE LTRIM(RTRIM(I.strItemNo)) + ' - ' + ISNULL(ID.strItemDescription, '') END
	 , strItemDescription		= ID.strItemDescription
	 , UOM.strUnitMeasure
	 , dblQtyShipped			= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(ID.dblQtyShipped, 0) * -1 ELSE ISNULL(ID.dblQtyShipped, 0) END
								  ELSE NULL END
	 , dblQtyOrdered			= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(ID.dblQtyOrdered, 0) * -1 ELSE ISNULL(ID.dblQtyOrdered, 0) END
								  ELSE NULL END
	 , dblDiscount				= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									ISNULL(ID.dblDiscount, 0) / 100
								  ELSE NULL END
	 , dblTotalTax				= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblTax, 0) * -1 ELSE ISNULL(INV.dblTax, 0) END
	 , dblPrice					= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN ISNULL(ID.dblPrice, 0) ELSE NULL END
	 , dblItemPrice				= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(ID.dblTotal, 0) * -1 ELSE ISNULL(ID.dblTotal, 0) END
								  ELSE NULL END
	 , strPaid					= CASE WHEN ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strPosted				= CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END
	 , IDT.intTaxCodeId
	 , strTaxCode				= SMT.strTaxCode
	 , dblTaxDetail				= IDT.dblAdjustedTax
	 , INV.strTransactionType
	 , intDetailCount			= (SELECT COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = INV.intInvoiceId)
	 , ysnHasEmailSetup			= CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = INV.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + INV.strTransactionType + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasRecipeItem			= CASE WHEN (SELECT COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = ID.intInvoiceId AND intRecipeId IS NOT NULL) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , intRecipeId				= ID.intRecipeId
	 , intOneLinePrintId		= ISNULL(MFR.intOneLinePrintId, 1)
	 , strInvoiceComments		= I.strInvoiceComments
	 , dblTotalWeight			= ISNULL(INV.dblTotalWeight, 0)
	 , ID.strVFDDocumentNumber
	 , ysnHasVFDDrugItem        = CASE WHEN (SELECT COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = ID.intInvoiceId AND ISNULL(strVFDDocumentNumber, '') != '') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM tblARInvoice INV
LEFT JOIN (tblARInvoiceDetail ID 
	LEFT JOIN tblICItem I ON ID.intItemId = I.intItemId 
	LEFT JOIN vyuARItemUOM UOM ON ID.intItemUOMId = UOM.intItemUOMId AND ID.intItemId = UOM.intItemId
	LEFT JOIN tblSOSalesOrderDetail SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SOD.intSalesOrderId
	LEFT JOIN tblARInvoiceDetailTax IDT ON ID.intInvoiceDetailId = IDT.intInvoiceDetailId 
									   AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)
									   AND IDT.dblAdjustedTax <> 0
	LEFT JOIN tblSMTaxCode SMT ON IDT.intTaxCodeId = SMT.intTaxCodeId
	LEFT JOIN tblCTContractHeader CH ON ID.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblMFRecipe MFR ON ID.intRecipeId = MFR.intRecipeId) ON INV.intInvoiceId = ID.intInvoiceId	
INNER JOIN (tblARCustomer C 
	INNER JOIN tblEMEntity E ON C.[intEntityId] = E.intEntityId) ON C.[intEntityId] = INV.intEntityCustomerId
INNER JOIN tblSMCompanyLocation L ON INV.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblSMCurrency CUR ON INV.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (tblARSalesperson SP 
	INNER JOIN tblEMEntity ESP ON SP.[intEntityId] = ESP.intEntityId) ON INV.intEntitySalespersonId = SP.[intEntityId]
LEFT JOIN (tblSMShipVia SV 
	INNER JOIN tblEMEntity ESV ON SV.[intEntityId] = ESV.intEntityId) ON INV.intShipViaId = SV.[intEntityId]
INNER JOIN tblSMTerm T ON INV.intTermId = T.intTermID
LEFT JOIN tblSMFreightTerms FT ON INV.intFreightTermId = FT.intFreightTermId

GO