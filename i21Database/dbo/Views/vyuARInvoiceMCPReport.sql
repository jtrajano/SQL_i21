CREATE VIEW [dbo].[vyuARInvoiceMCPReport]
AS
SELECT strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , dtmDate					= INV.dtmDate
	 , dtmDueDate				= INV.dtmDueDate
	 , strBOLNumber				= INV.strBOLNumber
	 , strPONumber				= INV.strPONumber
	 , intTruckDriverId			= INV.intTruckDriverId
	 , strTruckDriver			= DRIVER.strName
	 , intBillToLocationId		= INV.intBillToLocationId
	 , intShipToLocationId		= INV.intShipToLocationId
	 , strBillToLocationName	= INV.strBillToLocationName
	 , strShipToLocationName	= INV.strShipToLocationName
	 , strBillToAddress			= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strShipToAddress			= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL 
	 									THEN CONSUMPTIONSITE.strSiteFullAddress
										ELSE dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
								  END
	 , strSource				= INV.strType
	 , intTermId				= INV.intTermId
	 , strTerm					= TERM.strTerm
	 , intShipViaId				= INV.intShipViaId
	 , strShipVia				= SHIPVIA.strShipVia
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , strCompanyLocation		= [LOCATION].strLocationName	 
	 , INVOICEDETAIL.*
	 , dblInvoiceTotal			= INV.dblInvoiceTotal
	 , dblAmountDue				= INV.dblAmountDue
	 , dblInvoiceTax			= ISNULL(INV.dblTax, 0)
	 , strComments				= dbo.fnEliminateHTMLTags(ISNULL(INV.strComments, ''), 0)
	 , strItemComments          = ITEMCOMMENTS.strItemComments
	 , strOrigin				= ''
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
		 , dblPriceWithTax		= ID.dblPrice + dbo.fnRoundBanker(ISNULL(CASE WHEN ID.dblTotalTax <> 0 AND ID.dblQtyShipped <> 0 THEN ID.dblTotalTax/ID.dblQtyShipped ELSE 0 END, 0), 2)
		 , dblTotalPriceWithTax = ID.dblTotal
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
									  END
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT strItemComments = LEFT(strInvoiceComments, LEN(strInvoiceComments) - 0)
	FROM (
		SELECT CAST(ISNULL(ICC.strInvoiceComments, '') AS VARCHAR(MAX)) + CHAR(10)
		FROM dbo.tblARInvoiceDetail IDD WITH (NOLOCK)
		INNER JOIN (
			SELECT intItemId
				 , strInvoiceComments 
			FROM dbo.tblICItem ICC WITH (NOLOCK)
			WHERE ISNULL(ICC.strInvoiceComments, '') <> ''
		) ICC ON IDD.intItemId = ICC.intItemId
		WHERE IDD.intInvoiceId = INV.intInvoiceId		
		GROUP BY IDD.intItemId, ICC.strInvoiceComments
		FOR XML PATH ('')
	) DETAILS (strInvoiceComments)
) ITEMCOMMENTS
OUTER APPLY (
	SELECT TOP 1 strSiteFullAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, S.strSiteAddress, S.strCity, S.strState, S.strZipCode, S.strCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
			   , intSiteId			= ID.intSiteId
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
	WHERE intInvoiceId = INVOICEDETAIL.intInvoiceId 
	  AND ISNULL(ID.intSiteId, 0) <> 0
) CONSUMPTIONSITE