CREATE VIEW [dbo].[vyuARInvoiceMCPReport]
AS
SELECT strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , dtmDate					= INV.dtmDate
	 , dtmDueDate				= INV.dtmDueDate
	 , strBOLNumber				= INV.strBOLNumber
	 , strPONumber				= INV.strPONumber
	 , intTruckDriverId			= ISNULL(INV.intTruckDriverId, INV.intEntitySalespersonId)
	 , strTruckDriver			= CASE WHEN INV.strType = 'Tank Delivery'
	 									THEN ISNULL(NULLIF(DRIVER.strName, ''), SALESPERSON.strName)
	   								  	ELSE NULL
								  END
	 , intBillToLocationId		= INV.intBillToLocationId
	 , intShipToLocationId		= INV.intShipToLocationId
	 , strBillToLocationName	= BILLTO.strEntityNo
	 , strShipToLocationName	= SHIPTO.strEntityNo
	 , strBillToAddress			= dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName) COLLATE Latin1_General_CI_AS
	 , strShipToAddress			= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL 
	 									THEN CONSUMPTIONSITE.strSiteFullAddress
										ELSE dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
								  END COLLATE Latin1_General_CI_AS
	 , strSource				= INV.strType
	 , intTermId				= INV.intTermId
	 , strTerm					= TERM.strTerm
	 , intShipViaId				= INV.intShipViaId
	 , strShipVia				= SHIPVIA.strShipVia
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , strCompanyLocation		= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL
	 									THEN CONSUMPTIONSITE.strSiteNumber
	   								  	ELSE [LOCATION].strLocationName
								  END
	 , INVOICEDETAIL.*
	 , dblInvoiceTotal			= ISNULL(INV.dblInvoiceTotal, 0)
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , dblInvoiceTax			= ISNULL(INV.dblTax, 0)
	 , strComments				= CASE WHEN INV.strType = 'Tank Delivery'
	 									THEN dbo.fnEliminateHTMLTags(ISNULL(INV.strComments, ''), 0)
	   								  	ELSE dbo.fnEliminateHTMLTags(ISNULL(INV.strFooterComments, ''), 0)
								  END COLLATE Latin1_General_CI_AS
	 , strItemComments          = HAZMAT.strMessage COLLATE Latin1_General_CI_AS
	 , strOrigin				= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL
	 									THEN CONSUMPTIONSITE.strLocationName
	   								  	ELSE REPLACE(dbo.fnEliminateHTMLTags(ISNULL(INV.strComments, ''), 0), 'Origin:', '')
								  END
	 , blbLogo					= LOGO.blbLogo
FROM dbo.tblARInvoice INV WITH (NOLOCK)
LEFT JOIN (
	SELECT intInvoiceId			= ID.intInvoiceId
		 , intInvoiceDetailId   = ID.intInvoiceDetailId
		 , intSiteId			= ID.intSiteId
		 , dblQtyShipped		= ID.dblQtyShipped
		 , intItemId			= ID.intItemId
		 , strItemNo			= ITEM.strItemNo
		 , strItemDescription	= ID.strItemDescription
		 , strContractNo		= CT.strContractNumber
		 , strUnitMeasure		= UOM.strUnitMeasure
		 , dblPrice				= ID.dblPrice
		 , dblPriceWithTax		= ID.dblPrice + ISNULL(CASE WHEN ID.dblTotalTax <> 0 AND ID.dblQtyShipped <> 0 THEN ID.dblTotalTax/ID.dblQtyShipped ELSE 0 END, 0)
		 , dblTotalPriceWithTax = ID.dblTotal + ID.dblTotalTax
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN (
		SELECT intItemId
			 , strItemNo
		FROM dbo.tblICItem WITH (NOLOCK)
	) ITEM ON ID.intItemId = ITEM.intItemId
	LEFT JOIN (
		SELECT intContractHeaderId
			 , strContractNumber
		FROM dbo.tblCTContractHeader WITH (NOLOCK)
	) CT ON ID.intContractHeaderId = CT.intContractHeaderId
	LEFT JOIN (
		SELECT intItemUOMId
			 , intItemId
			 , strUnitMeasure
		FROM dbo.vyuARItemUOM WITH (NOLOCK)
	) UOM ON ID.intItemUOMId = UOM.intItemUOMId
	     AND ID.intItemId = UOM.intItemId
) INVOICEDETAIL ON INV.intInvoiceId = INVOICEDETAIL.intInvoiceId
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
) [LOCATION] ON INV.intCompanyLocationId = [LOCATION].intCompanyLocationId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK) 
) DRIVER ON INV.intTruckDriverId = DRIVER.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK) 
) SALESPERSON ON INV.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN (
	SELECT intEntityLocationId	= EL.intEntityLocationId
		 , strEntityNo			= EM.strEntityNo
	FROM tblEMEntityLocation EL WITH (NOLOCK)
	INNER JOIN dbo.tblEMEntity EM ON EL.intEntityId = EM.intEntityId
) BILLTO ON INV.intBillToLocationId = BILLTO.intEntityLocationId
LEFT JOIN (
	SELECT intEntityLocationId	= EL.intEntityLocationId
		 , strEntityNo			= EM.strEntityNo
	FROM tblEMEntityLocation EL WITH (NOLOCK)
	INNER JOIN dbo.tblEMEntity EM ON EL.intEntityId = EM.intEntityId
) SHIPTO ON INV.intShipToLocationId = SHIPTO.intEntityLocationId
LEFT JOIN (
	SELECT intTermID
		 , strTerm
	FROM tblSMTerm WITH (NOLOCK) 
) TERM ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT intEntityId
		 , strShipVia
	FROM tblSMShipVia WITH (NOLOCK)
) SHIPVIA ON INV.intShipViaId = SHIPVIA.intEntityId
OUTER APPLY (
	SELECT TOP 1 strCompanyName		= CASE WHEN [LOCATION].strUseLocationAddress = 'Letterhead' THEN '' ELSE strCompanyName END
			   , strCompanyAddress	= CASE WHEN [LOCATION].strUseLocationAddress IS NULL OR [LOCATION].strUseLocationAddress = 'No' OR [LOCATION].strUseLocationAddress = '' OR [LOCATION].strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, NULL, NULL, ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, [LOCATION].strAddress, [LOCATION].strCity, [LOCATION].strStateProvince, [LOCATION].strZipPostalCode, [LOCATION].strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Letterhead'
											THEN ''
									  END COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT strMessage = LEFT(strMessage, LEN(strMessage) - 0)
	FROM (
		SELECT CAST(ISNULL(ICC.strMessage, '') AS VARCHAR(MAX)) + CHAR(10)
		FROM dbo.tblARInvoiceDetail IDD WITH (NOLOCK)
		INNER JOIN (
			SELECT intItemId
				 , ICT.strMessage 
			FROM dbo.tblICItem ICC WITH (NOLOCK)
			INNER JOIN dbo.tblICTag ICT ON ICC.intHazmatTag = ICT.intTagId AND ICT.strType = 'Hazmat Message'
			WHERE ISNULL(ICC.intHazmatTag, 0) <> 0
		) ICC ON IDD.intItemId = ICC.intItemId
		WHERE IDD.intInvoiceId = INV.intInvoiceId		
		GROUP BY IDD.intItemId, ICC.strMessage
		FOR XML PATH ('')
	) DETAILS (strMessage)
) HAZMAT
OUTER APPLY (
	SELECT TOP 1 strSiteFullAddress 	= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, S.strSiteAddress, S.strCity, S.strState, S.strZipCode, S.strCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
			   , intSiteId				= ID.intSiteId
			   , intCompanyLocationId	= CLS.intCompanyLocationId
			   , strLocationName		= CLS.strLocationName
			   , strSiteNumber			= RIGHT('000'+ CAST(S.intSiteNumber AS NVARCHAR(4)),4) + ' - ' + ISNULL(S.strDescription, '')
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
	INNER JOIN tblSMCompanyLocation CLS ON S.intLocationId = CLS.intCompanyLocationId
	WHERE intInvoiceId = INVOICEDETAIL.intInvoiceId 
	  AND ISNULL(ID.intSiteId, 0) <> 0
) CONSUMPTIONSITE
OUTER APPLY (
	SELECT blbLogo = blbFile 
	FROM tblSMUpload 
	WHERE intAttachmentId = (SELECT TOP 1 intAttachmentId FROM tblSMAttachment WHERE strScreen = 'SystemManager.CompanyPreference' AND strComment = 'Header' ORDER BY intAttachmentId DESC)
) LOGO