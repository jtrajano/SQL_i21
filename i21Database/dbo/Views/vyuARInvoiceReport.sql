CREATE VIEW [dbo].[vyuARInvoiceReport]
AS
SELECT intInvoiceId				= INV.intInvoiceId	 
	 , strCompanyName			= CASE WHEN LOCATION.strUseLocationAddress = 'Letterhead' THEN '' ELSE COMPANY.strCompanyName END
	 , strCompanyAddress		= CASE WHEN LOCATION.strUseLocationAddress IS NULL OR LOCATION.strUseLocationAddress = 'No' OR LOCATION.strUseLocationAddress = '' OR LOCATION.strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip, COMPANY.strCountry, NULL, COMPANY.ysnIncludeEntityName)
									   WHEN LOCATION.strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, LOCATION.strAddress, LOCATION.strCity, LOCATION.strStateProvince, LOCATION.strZipPostalCode, LOCATION.strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN LOCATION.strUseLocationAddress = 'Letterhead'
											THEN ''
								  END
	 , strType					= ISNULL(INV.strType, 'Standard')
     , strCustomerName			= CUSTOMER.strName
	 , strLocationName			= LOCATION.strLocationName
	 , dtmDate					= INV.dtmDate
	 , dtmPostDate				= INV.dtmPostDate
	 , strCurrency				= CURRENCY.strCurrency	 	 
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strBillToLocationName	= INV.strBillToLocationName
	 , strBillTo				= dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strShipTo				= dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strSalespersonName		= SALESPERSON.strName
	 , strPONumber				= INV.strPONumber
	 , strBOLNumber				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									(CASE WHEN INV.strBOLNumber IS NOT NULL AND LEN(RTRIM(LTRIM(ISNULL(INV.strBOLNumber,'')))) > 0
										  THEN INV.strBOLNumber
										ELSE INVOICEDETAIL.strBOLNumber									
								    END)
								  ELSE NULL END
	 , strShipVia				= SHIPVIA.strName
	 , strTerm					= TERM.strTerm
	 , dtmShipDate				= INV.dtmShipDate
	 , dtmDueDate				= INV.dtmDueDate
	 , strFreightTerm			= FREIGHT.strFreightTerm
	 , strDeliverPickup			= INV.strDeliverPickup	 
	 , strInvoiceHeaderComment	= INV.strComments
	 , strInvoiceFooterComment	= INV.strFooterComments
	 , dblInvoiceSubtotal		= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(INV.dblInvoiceSubtotal, 0) END
	 , dblShipping				= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblShipping, 0) * -1 ELSE ISNULL(INV.dblShipping, 0) END
	 , dblTax					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INVOICEDETAIL.dblTotalTax, 0) * -1 ELSE ISNULL(INVOICEDETAIL.dblTotalTax, 0) END
								  ELSE NULL END
	 , dblInvoiceTotal			= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblInvoiceTotal, 0) * -1 ELSE ISNULL(INV.dblInvoiceTotal, 0) END
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , strItemNo				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strItemNo ELSE NULL END
	 , intInvoiceDetailId		= INVOICEDETAIL.intInvoiceDetailId
	 , dblContractBalance		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INVOICEDETAIL.dblContractBalance = 0 THEN INVOICEDETAIL.dblBalance ELSE INVOICEDETAIL.dblContractBalance END
								  ELSE NULL END
	 , strContractNumber		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strContractNumber ELSE NULL END				
	 , strItem					= CASE WHEN ISNULL(INVOICEDETAIL.strItemNo, '') = '' THEN INVOICEDETAIL.strItemDescription ELSE LTRIM(RTRIM(INVOICEDETAIL.strItemNo)) + ' - ' + ISNULL(INVOICEDETAIL.strItemDescription, '') END
	 , strItemDescription		= INVOICEDETAIL.strItemDescription
	 , strUnitMeasure			= INVOICEDETAIL.strUnitMeasure
	 , dblQtyShipped			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INVOICEDETAIL.dblQtyShipped, 0) * -1 ELSE ISNULL(INVOICEDETAIL.dblQtyShipped, 0) END
								  ELSE NULL END
	 , dblQtyOrdered			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INVOICEDETAIL.dblQtyOrdered, 0) * -1 ELSE ISNULL(INVOICEDETAIL.dblQtyOrdered, 0) END
								  ELSE NULL END
	 , dblDiscount				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									ISNULL(INVOICEDETAIL.dblDiscount, 0) / 100
								  ELSE NULL END
	 , dblTotalTax				= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblTax, 0) * -1 ELSE ISNULL(INV.dblTax, 0) END
	 , dblPrice					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblPrice, 0) ELSE NULL END
	 , dblItemPrice				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INVOICEDETAIL.dblTotal, 0) * -1 ELSE ISNULL(INVOICEDETAIL.dblTotal, 0) END
								  ELSE NULL END
	 , strPaid					= CASE WHEN ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strPosted				= CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END
	 , intTaxCodeId				= INVOICEDETAIL.intTaxCodeId
	 , strTaxCode				= INVOICEDETAIL.strTaxCode
	 , dblTaxDetail				= INVOICEDETAIL.dblAdjustedTax
	 , strTransactionType		= INV.strTransactionType
	 , intDetailCount			= ISNULL(INVOICEITEMS.intInvoiceDetailCount, 0)
	 , intRecipeId				= INVOICEDETAIL.intRecipeId
	 , intOneLinePrintId		= ISNULL(INVOICEDETAIL.intOneLinePrintId, 1)
	 , strInvoiceComments		= INVOICEDETAIL.strInvoiceComments
	 , dblTotalWeight			= ISNULL(INV.dblTotalWeight, 0)
	 , strVFDDocumentNumber		= INVOICEDETAIL.strVFDDocumentNumber
	 , ysnHasEmailSetup			= CASE WHEN (ISNULL(EMAILSETUP.intEmailSetupCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasRecipeItem			= CASE WHEN (ISNULL(RECIPEITEM.intRecipeItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasVFDDrugItem        = CASE WHEN (ISNULL(VFDDRUGITEM.intVFDDrugItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasProvisional		= CASE WHEN (ISNULL(PROVISIONAL.strProvisionalDescription, '')) <> '' THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , strProvisional			= PROVISIONAL.strProvisionalDescription
	 , dblTotalProvisional		= PROVISIONAL.dblProvisionalTotal
FROM dbo.tblARInvoice INV WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
	     , strName
	     , ysnIncludeEntityName 
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON INV.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
		 , strUseLocationAddress
		 , strAddress
		 , strCity
		 , strStateProvince
		 , strZipPostalCode
		 , strCountry
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATION ON INV.intCompanyLocationId = LOCATION.intCompanyLocationId
INNER JOIN (
	SELECT intTermID
		 , strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) TERM ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT ID.intInvoiceId
	     , ID.intInvoiceDetailId
		 , ID.intCommentTypeId
		 , ID.dblTotalTax
		 , ID.dblContractBalance
		 , ID.dblQtyShipped
		 , ID.dblQtyOrdered
		 , ID.dblDiscount
		 , ID.dblPrice
		 , ID.dblTotal
		 , ID.strVFDDocumentNumber
		 , UOM.strUnitMeasure
		 , CONTRACTS.dblBalance
		 , CONTRACTS.strContractNumber
		 , TAX.intTaxCodeId
		 , TAX.dblAdjustedTax
		 , TAX.strTaxCode
		 , ITEM.strItemNo
		 , ITEM.strInvoiceComments
		 , ITEM.strDescription	AS strItemDescription
		 , SO.strBOLNumber
		 , RECIPE.intRecipeId
		 , RECIPE.intOneLinePrintId
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN (
		SELECT intItemId
			 , strItemNo
			 , strDescription
			 , strInvoiceComments
		FROM dbo.tblICItem WITH (NOLOCK)
	) ITEM ON ID.intItemId = ITEM.intItemId
	LEFT JOIN (
		SELECT intItemUOMId
			 , intItemId
			 , strUnitMeasure
		FROM dbo. vyuARItemUOM WITH (NOLOCK)
	) UOM ON ID.intItemUOMId = UOM.intItemUOMId
	     AND ID.intItemId = UOM.intItemId
	LEFT JOIN (
		SELECT intSalesOrderDetailId
			 , intSalesOrderId
		FROM dbo.tblSOSalesOrderDetail WITH (NOLOCK)
	) SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	LEFT JOIN (
		SELECT intSalesOrderId
			 , strBOLNumber
		FROM dbo.tblSOSalesOrder WITH (NOLOCK)
	) SO ON SOD.intSalesOrderId = SO.intSalesOrderId
	LEFT JOIN (
		SELECT IDT.intInvoiceDetailId
			 , IDT.intTaxCodeId
			 , IDT.dblAdjustedTax
			 , TAXCODE.strTaxCode
		FROM dbo.tblARInvoiceDetailTax IDT WITH (NOLOCK)
		LEFT JOIN (
			SELECT intTaxCodeId
				 , strTaxCode
			FROM dbo.tblSMTaxCode WITH (NOLOCK)
		) TAXCODE ON IDT.intTaxCodeId = TAXCODE.intTaxCodeId
		WHERE dblAdjustedTax <> 0
	) TAX ON ID.intInvoiceDetailId = TAX.intInvoiceDetailId
	     AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM dbo.tblTRCompanyPreference WITH (NOLOCK)), 0)
	LEFT JOIN (
		SELECT CH.intContractHeaderId
			 , CD.intContractDetailId
			 , CD.dblBalance
			 , strContractNumber
		FROM dbo.tblCTContractHeader CH WITH (NOLOCK)
		LEFT JOIN (
			SELECT intContractHeaderId
				 , intContractDetailId
				 , dblBalance
			FROM dbo.tblCTContractDetail WITH (NOLOCK)
		) CD ON CH.intContractHeaderId = CD.intContractHeaderId
	) CONTRACTS ON ID.intContractDetailId = CONTRACTS.intContractDetailId
	LEFT JOIN (
		SELECT intRecipeId
			 , intOneLinePrintId
		FROM dbo.tblMFRecipe WITH (NOLOCK)
	) RECIPE ON ID.intRecipeId = RECIPE.intRecipeId	
) INVOICEDETAIL ON INV.intInvoiceId = INVOICEDETAIL.intInvoiceId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency
	FROM dbo.tblSMCurrency
) CURRENCY ON INV.intCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity
) SALESPERSON ON INV.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity
) SHIPVIA ON INV.intShipViaId = SALESPERSON.intEntityId
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
	FROM dbo.tblSMFreightTerms WITH (NOLOCK)
) FREIGHT ON INV.intFreightTermId = FREIGHT.intFreightTermId
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strAddress
			   , strCity
			   , strState
			   , strZip
			   , strCountry
			   , ysnIncludeEntityName
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT COUNT(*) AS intInvoiceDetailCount
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE intInvoiceId = INV.intInvoiceId
) INVOICEITEMS
OUTER APPLY (
	SELECT COUNT(*) AS intEmailSetupCount
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE intCustomerEntityId = INV.intEntityCustomerId 
	  AND ISNULL(strEmail, '') <> '' 
	  AND strEmailDistributionOption LIKE '%' + INV.strTransactionType + '%'
) EMAILSETUP
OUTER APPLY (
	SELECT COUNT(*) AS intRecipeItemCount
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE intInvoiceId = INVOICEDETAIL.intInvoiceId 
	  AND intRecipeId IS NOT NULL
) RECIPEITEM
OUTER APPLY (
	SELECT COUNT(*) AS intVFDDrugItemCount
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE intInvoiceId = INVOICEDETAIL.intInvoiceId 
	  AND ISNULL(strVFDDocumentNumber, '') != ''
) VFDDRUGITEM
OUTER APPLY (
	SELECT TOP 1 strProvisionalDescription = 'Less Payment Received: Provisional Invoice No. ' + ISNULL(strInvoiceNumber, '') + ' dated ' + CONVERT(VARCHAR(10), dtmDate, 110)
			   , dblProvisionalTotal	   = dblInvoiceTotal	    
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE strType = 'Provisional'
	  AND ysnProcessed = 1
	  AND intInvoiceId = INV.intOriginalInvoiceId
) PROVISIONAL