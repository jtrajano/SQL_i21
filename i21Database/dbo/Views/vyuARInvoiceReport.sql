CREATE VIEW [dbo].[vyuARInvoiceReport]
AS
SELECT intInvoiceId				= INV.intInvoiceId
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , strCompanyName			= CASE WHEN [LOCATION].strUseLocationAddress = 'Letterhead' THEN '' ELSE COMPANY.strCompanyName END
	 , strCompanyAddress		= CASE WHEN [LOCATION].strUseLocationAddress IS NULL OR [LOCATION].strUseLocationAddress = 'No' OR [LOCATION].strUseLocationAddress = '' OR [LOCATION].strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip, COMPANY.strCountry, NULL, COMPANY.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, [LOCATION].strAddress, [LOCATION].strCity, [LOCATION].strStateProvince, [LOCATION].strZipPostalCode, [LOCATION].strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Letterhead'
											THEN ''
								  END COLLATE Latin1_General_CI_AS
	 , strCompanyInfo			= CASE WHEN [LOCATION].strUseLocationAddress IS NULL OR [LOCATION].strUseLocationAddress = 'No' OR [LOCATION].strUseLocationAddress = '' OR [LOCATION].strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip, COMPANY.strCountry, NULL, COMPANY.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, [LOCATION].strAddress, [LOCATION].strCity, [LOCATION].strStateProvince, [LOCATION].strZipPostalCode, [LOCATION].strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Letterhead'
											THEN ''
								  END  + CHAR(10) + ISNULL(COMPANY.strEmail,'')   + CHAR(10) + ISNULL(COMPANY.strPhone,'') COLLATE Latin1_General_CI_AS
	 , strCompanyPhoneNumber	= COMPANY.strPhone
	 , strCompanyEmail			= COMPANY.strEmail
	 , strType					= ISNULL(INV.strType, 'Standard')
     , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber        = CUSTOMER.strCustomerNumber
	 , strLocationName			= [LOCATION].strLocationName
	 , dtmDate					= CAST(INV.dtmDate AS DATE)
	 , dtmPostDate				= INV.dtmPostDate
	 , strCurrency				= CURRENCY.strCurrency	 	 
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strBillToLocationName	= INV.strBillToLocationName
	 , strBillTo				= dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName) COLLATE Latin1_General_CI_AS
	 , strShipTo				= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL 
	 									THEN CONSUMPTIONSITE.strSiteFullAddress
										ELSE dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
								  END COLLATE Latin1_General_CI_AS
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
	 , strDeliverPickup			= FREIGHT.strFobPoint--INV.strDeliverPickup	 
	 , strInvoiceHeaderComment	= INV.strComments
	 , strInvoiceFooterComment	= INV.strFooterComments
	 , dblInvoiceSubtotal		= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblInvoiceSubtotal, 0) * -1 ELSE ISNULL(INV.dblInvoiceSubtotal, 0) END
	 , dblShipping				= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblShipping, 0) * -1 ELSE ISNULL(INV.dblShipping, 0) END
	 , dblTax					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INVOICEDETAIL.dblTotalTax, 0) * -1 ELSE ISNULL(INVOICEDETAIL.dblTotalTax, 0) END
								  ELSE NULL END
	 , dblInvoiceTotal			= CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(INV.dblInvoiceTotal, 0) * -1 ELSE ISNULL(INV.dblInvoiceTotal, 0) - ISNULL(INV.dblProvisionalAmount, 0)  END
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , strItemNo				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strItemNo ELSE NULL END
	 , intInvoiceDetailId		= INVOICEDETAIL.intInvoiceDetailId
	 , dblContractBalance		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.dblBalance ELSE NULL END
	 , strContractNumber		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strContractNumber ELSE NULL END				
	 , strItem					= CASE WHEN ISNULL(INVOICEDETAIL.strItemNo, '') = '' THEN ISNULL(INVOICEDETAIL.strItemDescription, INVOICEDETAIL.strSCInvoiceNumber) ELSE LTRIM(RTRIM(INVOICEDETAIL.strItemNo)) + '-' + ISNULL(INVOICEDETAIL.strItemDescription, '') END
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
	 , strPaid					= CASE WHEN ysnPaid = 1 THEN 'Yes' ELSE 'No' END COLLATE Latin1_General_CI_AS
	 , strPosted				= CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END COLLATE Latin1_General_CI_AS
	 , intTaxCodeId				= INVOICEDETAIL.intTaxCodeId
	 , strTaxCode				= INVOICEDETAIL.strTaxCode
	 , dblTaxDetail				= INVOICEDETAIL.dblAdjustedTax
	 , strTransactionType		= INV.strTransactionType
	 , intDetailCount			= ISNULL(INVOICEITEMS.intInvoiceDetailCount, 0)
	 , intRecipeId				= INVOICEDETAIL.intRecipeId
	 , intOneLinePrintId		= ISNULL(INVOICEDETAIL.intOneLinePrintId, 1)
	 , strInvoiceComments		= INVOICEDETAIL.strInvoiceComments
	 , strItemType				= INVOICEDETAIL.strItemType
	 , dblTotalWeight			= ISNULL(INV.dblTotalWeight, 0)
	 , strVFDDocumentNumber		= INVOICEDETAIL.strVFDDocumentNumber
	 , strBOLNumberDetail		= INVOICEDETAIL.strBOLNumberDetail
	 , ysnHasEmailSetup			= CASE WHEN (ISNULL(EMAILSETUP.intEmailSetupCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasRecipeItem			= CASE WHEN (ISNULL(RECIPEITEM.intRecipeItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasVFDDrugItem        = CASE WHEN (ISNULL(VFDDRUGITEM.intVFDDrugItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasProvisional		= CASE WHEN (ISNULL(PROVISIONAL.strProvisionalDescription, '')) <> '' THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , strProvisional			= PROVISIONAL.strProvisionalDescription
	 , dblTotalProvisional		= PROVISIONAL.dblProvisionalTotal
	 , strCustomerComments		= CUSTOMERCOMMENTS.strCustomerComments
	 , ysnPrintInvoicePaymentDetail = ARPREFERENCE.ysnPrintInvoicePaymentDetail
	 , ysnStretchLogo			= ISNULL(ARPREFERENCE.ysnStretchLogo, 0)
	 , ysnListBundleSeparately	= ISNULL(INVOICEDETAIL.ysnListBundleSeparately, CONVERT(BIT, 0))
	 , strTicketNumbers			= SCALETICKETS.strTicketNumbers
	 , strSiteNumber			= INVOICEDETAIL.strSiteNumber
	 , dblEstimatedPercentLeft	= INVOICEDETAIL.dblEstimatedPercentLeft
	 , dblPercentFull			= INVOICEDETAIL.dblPercentFull
	 , blbLogo					= CASE WHEN ISNULL(ARPREFERENCE.ysnStretchLogo, 0) = 1 THEN ISNULL(STRETCHEDLOGO.blbLogo, LOGO.blbLogo) ELSE LOGO.blbLogo END
	 , strAddonDetailKey		= INVOICEDETAIL.strAddonDetailKey
	 , ysnHasAddOnItem			= CASE WHEN (ADDON.strAddonDetailKey) IS NOT NULL THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM dbo.tblARInvoice INV WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
	     , strName
		 , strCustomerNumber
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
) LOCATION ON INV.intCompanyLocationId = [LOCATION].intCompanyLocationId
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
		 , ID.dblQtyShipped
		 , ID.dblQtyOrdered
		 , ID.dblDiscount
		 , ID.dblPrice
		 , ID.dblTotal
		 , ID.strVFDDocumentNumber
		 , ID.strBOLNumberDetail
		 , ID.strSCInvoiceNumber
		 , UOM.strUnitMeasure
		 , CONTRACTS.dblBalance
		 , CONTRACTS.strContractNumber
		 , TAX.intTaxCodeId
		 , TAX.dblAdjustedTax
		 , TAX.strTaxCode
		 , ITEM.strItemNo
		 , ITEM.strInvoiceComments
		 , strItemType			= ITEM.strType
		 , strItemDescription	= CASE WHEN ISNULL(ID.strItemDescription, '') <> '' THEN ID.strItemDescription ELSE ITEM.strDescription END
		 , SO.strBOLNumber
		 , ITEM.ysnListBundleSeparately
		 , RECIPE.intRecipeId
		 , RECIPE.intOneLinePrintId
		 , SITE.intSiteID
		 , SITE.strSiteNumber
		 , SITE.dblEstimatedPercentLeft
		 , ID.dblPercentFull
		 , ID.strAddonDetailKey
		 , ID.ysnAddonParent
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN (
		SELECT intItemId
			 , strItemNo
			 , strDescription
			 , strInvoiceComments
			 , strType
			 , ysnListBundleSeparately
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
	LEFT JOIN (
		SELECT intSiteID,(CASE WHEN intSiteNumber < 9 THEN '00' + CONVERT(VARCHAR,intSiteNumber) ELSE '0' + CONVERT(VARCHAR,intSiteNumber) END ) + ' - ' + strDescription strSiteNumber,dblEstimatedPercentLeft 
		FROM tblTMSite
	) SITE
		ON SITE.intSiteID = ID.intSiteId
	--WHERE ID.ysnAddonParent IS NULL OR ID.ysnAddonParent = 1
) INVOICEDETAIL ON INV.intInvoiceId = INVOICEDETAIL.intInvoiceId
	 AND (INVOICEDETAIL.ysnAddonParent IS NULL OR INVOICEDETAIL.ysnAddonParent = 1 OR INV.strTransactionType='Credit Memo') 
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
) SHIPVIA ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
		 , strFobPoint
	FROM dbo.tblSMFreightTerms WITH (NOLOCK)
) FREIGHT ON INV.intFreightTermId = FREIGHT.intFreightTermId
LEFT JOIN (
	SELECT strCode
		 , strMessage
	FROM vyuARDocumentMaintenanceMessage
) Comments ON INV.strComments = Comments.strCode
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strAddress
			   , strCity
			   , strState
			   , strZip
			   , strCountry
			   , ysnIncludeEntityName
			   , strPhone
			   , strEmail
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT TOP 1 ysnPrintInvoicePaymentDetail
			   , ysnStretchLogo
	FROM dbo.tblARCompanyPreference WITH (NOLOCK)
) ARPREFERENCE
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
	  AND ISNULL(strVFDDocumentNumber, '') <> ''
) VFDDRUGITEM
OUTER APPLY (
	SELECT TOP 1 strSiteFullAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, S.strSiteAddress, S.strCity, S.strState, S.strZipCode, S.strCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
			   , intSiteId			= ID.intSiteId
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
	WHERE intInvoiceId = INVOICEDETAIL.intInvoiceId 
	  AND ISNULL(ID.intSiteId, 0) <> 0
) CONSUMPTIONSITE
OUTER APPLY (
	SELECT TOP 1 strProvisionalDescription = 'Less Payment Received: Provisional Invoice No. ' + ISNULL(strInvoiceNumber, '') + ' dated ' + CONVERT(VARCHAR(10), dtmDate, 110)
			   , dblProvisionalTotal	   = dblPayment	    
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE strType = 'Provisional'
	  AND ysnProcessed = 1
	  AND intInvoiceId = INV.intOriginalInvoiceId
) PROVISIONAL
OUTER APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
		INNER JOIN (
			SELECT intTicketId
				 , strTicketNumber 
			FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intInvoiceId = INV.intInvoiceId
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS
LEFT JOIN(
	SELECT intInvoiceId, strAddonDetailKey 
	FROM dbo.tblARInvoiceDetail WITH(NOLOCK)
	WHERE  ysnAddonParent = 0
) ADDON ON INV.intInvoiceId = ADDON.intInvoiceId AND ADDON.strAddonDetailKey =  INVOICEDETAIL.strAddonDetailKey
OUTER APPLY (
	SELECT TOP 1 blbLogo = blbFile 
	FROM tblSMUpload U
	INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
	WHERE A.strScreen = 'SystemManager.CompanyPreference' 
	  AND A.strComment = 'Header'
) LOGO
OUTER APPLY (
	SELECT TOP 1 blbLogo = blbFile 
	FROM tblSMUpload U
	INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
	WHERE A.strScreen = 'SystemManager.CompanyPreference' 
	  AND A.strComment = 'Stretched Header'
) STRETCHEDLOGO
OUTER APPLY (
	SELECT strCustomerComments = LEFT(strMessage, LEN(strMessage) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(A.strMessage AS VARCHAR(MAX))  + ', '
		FROM dbo.tblEMEntityMessage A WITH(NOLOCK)
		WHERE A.intEntityId = INV.intEntityCustomerId
		  AND A.strMessageType = 'Invoice'
		FOR XML PATH ('')
	) CC (strMessage)
) CUSTOMERCOMMENTS