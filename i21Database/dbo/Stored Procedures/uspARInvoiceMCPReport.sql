CREATE PROCEDURE [dbo].[uspARInvoiceMCPReport]
	  @tblInvoiceReport		AS InvoiceReportTable READONLY
	, @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS 

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @blbLogo 			VARBINARY (MAX) = NULL
      , @blbStretchedLogo 	VARBINARY (MAX) = NULL

SELECT TOP 1 @blbLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Header'

SELECT TOP 1 @blbStretchedLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Stretched Header'

SET @blbStretchedLogo = ISNULL(@blbStretchedLogo, @blbLogo)

DELETE FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat IN ('Format 1 - MCP', 'Format 5 - Honstein')
INSERT INTO tblARInvoiceReportStagingTable (
	   strCompanyName
	 , strCompanyAddress
	 , intInvoiceId
	 , intEntityCustomerId
	 , strInvoiceNumber
	 , strTransactionType
	 , dtmDate
	 , dtmDueDate
	 , strBOLNumber
	 , strPONumber
	 , intTruckDriverId
	 , strTruckDriver
	 , intBillToLocationId
	 , intShipToLocationId
	 , strBillToLocationName
	 , strShipToLocationName
	 , strBillTo		
	 , strShipTo
	 , strSource
	 , intTermId
	 , strTerm
	 , intShipViaId
	 , strShipVia
	 , intCompanyLocationId
	 , strCompanyLocation
	 , intInvoiceDetailId
	 , intSiteId
	 , dblQtyShipped
	 , intItemId
	 , strItemNo
	 , strItemDescription
	 , strContractNo
	 , strUnitMeasure
	 , dblPrice
	 , dblItemPrice
	 , dblPriceWithTax
	 , dblTotalPriceWithTax
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblInvoiceTax
	 , dblTotalTax
	 , strComments
	 , strItemComments
	 , strOrigin
	 , blbLogo
	 , intEntityUserId
	 , strRequestId
	 , strInvoiceFormat
	 , intTicketId
	 , strTicketNumbers
	 , dtmLoadedDate
	 , dtmScaleDate
	 , strCommodity
	 , ysnStretchLogo
	 , blbSignature
	 , strTicketType
	 , strLocationNumber
	 , strSalesOrderNumber
	 , strPaymentInfo
)
SELECT strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , intInvoiceId				= INV.intInvoiceId
	 , intEntityCustomerId		= INV.intEntityCustomerId
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strTransactionType		= INV.strTransactionType
	 , dtmDate					= CAST(INV.dtmDate AS DATE)
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
	 , strBillToAddress			= dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strShipToAddress			= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL 
	 									THEN CONSUMPTIONSITE.strSiteFullAddress
										ELSE dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
								  END
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
	 , intInvoiceDetailId		= INVOICEDETAIL.intInvoiceDetailId
	 , intSiteId				= INVOICEDETAIL.intSiteId
	 , dblQtyShipped			= INVOICEDETAIL.dblQtyShipped
	 , intItemId				= CASE WHEN SELECTEDINV.strInvoiceFormat = 'Format 5 - Honstein' THEN ISNULL(INVOICEDETAIL.intItemId, 99999999) ELSE INVOICEDETAIL.intItemId END
	 , strItemNo				= INVOICEDETAIL.strItemNo
	 , strItemDescription		= INVOICEDETAIL.strItemDescription
	 , strContractNo			= INVOICEDETAIL.strContractNo
	 , strUnitMeasure			= INVOICEDETAIL.strUnitMeasure
	 , dblPrice					= INVOICEDETAIL.dblPrice
	 , dblItemPrice				= INVOICEDETAIL.dblTotal
	 , dblPriceWithTax			= INVOICEDETAIL.dblPriceWithTax
	 , dblTotalPriceWithTax		= INVOICEDETAIL.dblTotalPriceWithTax
	 , dblInvoiceTotal			= ISNULL(INV.dblInvoiceTotal, 0)
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , dblInvoiceTax			= ISNULL(INV.dblTax, 0)
	 , dblTotalTax				= INVOICEDETAIL.dblTotalTax
	 , strComments				= CASE WHEN INV.strType = 'Tank Delivery'
	 									THEN dbo.fnEliminateHTMLTags(ISNULL(INV.strComments, ''), 0)
	   								  	ELSE dbo.fnEliminateHTMLTags(ISNULL(INV.strFooterComments, ''), 0)
								  END
	 , strItemComments          = HAZMAT.strMessage
	 , strOrigin				= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL
	 									THEN CONSUMPTIONSITE.strLocationName
	   								  	ELSE REPLACE(dbo.fnEliminateHTMLTags(ISNULL(INV.strComments, ''), 0), 'Origin:', '')
								  END
	 , blbLogo					= CASE WHEN ISNULL(SELECTEDINV.ysnStretchLogo, 0) = 1 THEN @blbStretchedLogo ELSE @blbLogo END
	 , intEntityUserId			= @intEntityUserId
	 , strRequestId				= @strRequestId
	 , strInvoiceFormat			= SELECTEDINV.strInvoiceFormat
	 , intTicketId				= ISNULL(TICKETDETAILS.intTicketId, 0)
	 , strTicketNumbers			= TICKETDETAILS.strTicketNumbers
	 , dtmLoadedDate			= TICKETDETAILS.dtmLoadedDate
	 , dtmScaleDate				= TICKETDETAILS.dtmScaleDate
	 , strCommodity				= TICKETDETAILS.strCommodity
	 , ysnStretchLogo			= ISNULL(SELECTEDINV.ysnStretchLogo, 0)
	 , blbSignature				= INV.blbSignature
	 , strTicketType			= INV.strTransactionType
	 , strLocationNumber		= [LOCATION].strLocationNumber
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strPaymentInfo			= CASE WHEN INV.strTransactionType = 'Cash' THEN ISNULL(PAYMENTMETHOD.strPaymentMethod, '') + ' - ' + ISNULL(INV.strPaymentInfo, '') ELSE NULL END
FROM dbo.tblARInvoice INV WITH (NOLOCK)
INNER JOIN @tblInvoiceReport SELECTEDINV ON INV.intInvoiceId = SELECTEDINV.intInvoiceId
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
		 , dblTotal				= ID.dblTotal
		 , dblPriceWithTax		= ID.dblPrice + ISNULL(CASE WHEN ID.dblTotalTax <> 0 AND ID.dblQtyShipped <> 0 THEN ID.dblTotalTax/ID.dblQtyShipped ELSE 0 END, 0)
		 , dblTotalPriceWithTax = ID.dblTotal + ID.dblTotalTax
		 , dblTotalTax			= ID.dblTotalTax
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
		 , strLocationNumber
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
LEFT JOIN (
	SELECT intPaymentMethodID
		 , strPaymentMethod
	FROM tblSMPaymentMethod
) PAYMENTMETHOD ON INV.intPaymentMethodId = PAYMENTMETHOD.intPaymentMethodID
LEFT JOIN tblSOSalesOrder SO ON INV.intSalesOrderId = SO.intSalesOrderId
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
	SELECT TOP 1 intTicketId		= TICKET.intTicketId
		       , strTicketNumbers	= TICKET.strTicketNumber
		       , dtmLoadedDate		= TICKET.dtmTransactionDateTime
		       , dtmScaleDate		= TICKET.dtmTicketDateTime
		       , strCommodity		= COM.strDescription
	FROM dbo.tblARInvoiceDetail DETAIL
	INNER JOIN dbo.tblSCTicket TICKET ON DETAIL.intTicketId = TICKET.intTicketId
	LEFT JOIN dbo.tblICCommodity COM ON TICKET.intCommodityId = COM.intCommodityId
	WHERE DETAIL.intInvoiceId = INV.intInvoiceId
		AND DETAIL.intTicketId IS NOT NULL
) TICKETDETAILS

UPDATE STAGING
SET strComments = ISNULL(MESSAGES.strMessage, '')
FROM tblARInvoiceReportStagingTable STAGING
OUTER APPLY (
	SELECT TOP 1 strMessage
	FROM tblEMEntityMessage EM
	WHERE EM.strMessageType = 'Invoice'
	  AND EM.intEntityId = STAGING.intEntityCustomerId
) MESSAGES
WHERE STAGING.intEntityUserId = @intEntityUserId
  AND STAGING.strRequestId = @strRequestId
  AND STAGING.strInvoiceFormat = 'Format 5 - Honstein'

--HONSTEIN TAX DETAILS
IF EXISTS (SELECT TOP 1 NULL FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat = 'Format 5 - Honstein')
	BEGIN
		DECLARE @strRemitToAddress	NVARCHAR(MAX)	= NULL

		SELECT TOP 1 @strRemitToAddress	= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, NULL, NULL, 0)
		FROM dbo.tblSMCompanySetup WITH (NOLOCK)

		INSERT INTO tblARInvoiceReportStagingTable (
			  intEntityUserId
			, strRequestId
			, strInvoiceFormat
			, strItemComments
			, dblInvoiceTotal
			, dblAmountDue
			, blbSignature
			, strComments
			, intInvoiceId
			, intInvoiceDetailId
			, strUnitMeasure
			, strItemNo
			, strItemDescription
			, dblQtyShipped
			, dblPrice
			, dblItemPrice
		)
		SELECT intEntityUserId		= @intEntityUserId
			, strRequestId			= @strRequestId
			, strInvoiceFormat		= 'Format 5 - Honstein'
			, strItemComments		= STAGING.strItemComments
			, dblInvoiceTotal		= STAGING.dblInvoiceTotal
			, dblAmountDue			= STAGING.dblAmountDue
			, blbSignature			= STAGING.blbSignature
			, strComments			= STAGING.strComments
			, intInvoiceId			= STAGING.intInvoiceId
			, intInvoiceDetailId	= STAGING.intInvoiceDetailId
			, strUnitMeasure		= STAGING.strUnitMeasure
			, strItemNo				= 'Tax' 
			, strItemDescription	= TAXES.strTaxCode
			, dblQtyShipped			= STAGING.dblQtyShipped
			, dblPrice				= TAXES.dblRate
			, dblItemPrice			= TAXES.dblAdjustedTax 
		FROM tblARInvoiceReportStagingTable STAGING
		INNER JOIN tblARInvoiceDetail ID ON STAGING.intInvoiceDetailId = ID.intInvoiceDetailId
		INNER JOIN (
			SELECT intInvoiceDetailId	= IDT.intInvoiceDetailId
				 , strTaxCode			= TCODE.strTaxCode
				 , strTaxDescription	= TCODE.strDescription
				 , dblRate				= SUM(IDT.dblRate)
				 , dblAdjustedTax		= SUM(IDT.dblAdjustedTax)
			FROM tblARInvoiceDetailTax IDT
			INNER JOIN tblSMTaxCode TCODE ON IDT.intTaxCodeId = TCODE.intTaxCodeId
			INNER JOIN tblSMTaxClass TCLASS ON TCODE.intTaxClassId = TCLASS.intTaxClassId
			LEFT JOIN tblSMTaxReportType TREPORT ON TCLASS.intTaxReportTypeId = TREPORT.intTaxReportTypeId
			WHERE ISNULL(TREPORT.strType, '') <> 'State Sales Tax'
			AND IDT.dblAdjustedTax <> 0
			GROUP BY IDT.intInvoiceDetailId
				   , IDT.intTaxCodeId
				   , TCODE.strTaxCode
				   , TCODE.strDescription
		) TAXES ON ID.intInvoiceDetailId = TAXES.intInvoiceDetailId
		WHERE STAGING.intEntityUserId = @intEntityUserId
		  AND STAGING.strRequestId = @strRequestId
		  AND STAGING.strInvoiceFormat = 'Format 5 - Honstein'
		  AND ID.dblTotalTax <> 0

		UNION ALL

		SELECT intEntityUserId		= @intEntityUserId
			, strRequestId			= @strRequestId
			, strInvoiceFormat		= 'Format 5 - Honstein'
			, strItemComments		= STAGING.strItemComments
			, dblInvoiceTotal		= STAGING.dblInvoiceTotal
			, dblAmountDue			= STAGING.dblAmountDue
			, blbSignature			= STAGING.blbSignature
			, strComments			= STAGING.strComments
			, intInvoiceId			= STAGING.intInvoiceId
			, intInvoiceDetailId	= 9999999 + TAXES.intTaxCodeId
			, strUnitMeasure		= NULL
			, strItemNo				= 'State Sales Tax' 
			, strItemDescription	= TAXES.strTaxCode
			, dblQtyShipped			= TAXES.dblQtyShipped
			, dblPrice				= TAXES.dblRate
			, dblItemPrice			= TAXES.dblAdjustedTax 
		FROM (
			SELECT DISTINCT intInvoiceId
						  , strItemComments
						  , dblInvoiceTotal
						  , dblAmountDue
						  , blbSignature
						  , strComments
			FROM tblARInvoiceReportStagingTable
			WHERE intEntityUserId = @intEntityUserId
		      AND strRequestId = @strRequestId
		      AND strInvoiceFormat = 'Format 5 - Honstein'
		) STAGING 
		INNER JOIN (
			SELECT intInvoiceId			= ID.intInvoiceId
			     , dblQtyShipped		= SUM(ID.dblQtyShipped)
				 , strTaxCode			= TCODE.strTaxCode
				 , strTaxDescription	= TCODE.strDescription
				 , dblRate				= SUM(IDT.dblRate)
				 , dblAdjustedTax		= SUM(IDT.dblAdjustedTax)
				 , intTaxCodeId			= TCODE.intTaxCodeId
			FROM tblARInvoiceDetail ID 
			INNER JOIN tblARInvoiceDetailTax IDT ON ID.intInvoiceDetailId = IDT.intInvoiceDetailId
			INNER JOIN tblSMTaxCode TCODE ON IDT.intTaxCodeId = TCODE.intTaxCodeId
			INNER JOIN tblSMTaxClass TCLASS ON TCODE.intTaxClassId = TCLASS.intTaxClassId
			INNER JOIN tblSMTaxReportType TREPORT ON TCLASS.intTaxReportTypeId = TREPORT.intTaxReportTypeId
			WHERE ISNULL(TREPORT.strType, '') = 'State Sales Tax'
			  AND IDT.dblAdjustedTax <> 0
			  AND ID.dblTotalTax <> 0
			GROUP BY ID.intInvoiceId				   
				   , TCODE.strTaxCode
				   , TCODE.strDescription
				   , TCODE.intTaxCodeId
		) TAXES ON STAGING.intInvoiceId = TAXES.intInvoiceId

		UPDATE STAGING		
		SET intCompanyLocationId 	= ORIG.intCompanyLocationId
		  , intEntityCustomerId		= ORIG.intEntityCustomerId
		  , intTruckDriverId		= ORIG.intTruckDriverId
		  , intBillToLocationId		= ORIG.intBillToLocationId
		  , intShipToLocationId		= ORIG.intShipToLocationId
		  , intTermId				= ORIG.intTermId
		  , intItemId				= NULL
		  , intShipViaId			= ORIG.intShipViaId
		  , intTicketId				= ORIG.intTicketId
		  , strCompanyName			= ORIG.strCompanyName
		  , strCompanyAddress		= ORIG.strCompanyAddress
		  , strCompanyLocation		= ORIG.strCompanyLocation
		  , strTicketType			= ORIG.strTicketType
		  , strLocationNumber		= ORIG.strLocationNumber
		  , strInvoiceNumber		= ORIG.strInvoiceNumber
		  , strBillToLocationName	= ORIG.strBillToLocationName
		  , strShipToLocationName	= ORIG.strShipToLocationName
		  , strBillTo				= ORIG.strBillTo
		  , strShipTo				= ORIG.strShipTo
		  , strShipVia				= ORIG.strShipVia
		  , strPONumber				= ORIG.strPONumber
		  , strBOLNumber			= ORIG.strBOLNumber
		  , strPaymentInfo			= ORIG.strPaymentInfo
		  , strTerm					= ORIG.strTerm
		  , strTransactionType		= ORIG.strTransactionType
		  , strSource				= ORIG.strSource
		  , strOrigin				= ORIG.strOrigin
		  , dblInvoiceTax			= ORIG.dblInvoiceTax
		  , dblPriceWithTax			= ORIG.dblPriceWithTax
		  , dblTotalPriceWithTax	= ORIG.dblTotalPriceWithTax
		  , ysnStretchLogo			= ORIG.ysnStretchLogo
		  , dtmDate					= ORIG.dtmDate
		  , dtmDueDate				= ORIG.dtmDueDate
		  , blbLogo					= ORIG.blbLogo
		  , strUnitMeasure			= ORIG.strUnitMeasure
		FROM tblARInvoiceReportStagingTable STAGING
		INNER JOIN (
			SELECT *
			FROM tblARInvoiceReportStagingTable
			WHERE intEntityUserId = @intEntityUserId
		  	  AND strRequestId = @strRequestId
		      AND strInvoiceFormat = 'Format 5 - Honstein'
			  AND blbLogo IS NOT NULL
		) ORIG ON STAGING.intInvoiceId = ORIG.intInvoiceId AND (STAGING.intInvoiceDetailId = ORIG.intInvoiceDetailId OR STAGING.strItemNo = 'State Sales Tax')
		WHERE STAGING.intEntityUserId = @intEntityUserId
		  AND STAGING.strRequestId = @strRequestId
		  AND STAGING.strInvoiceFormat = 'Format 5 - Honstein'
		  AND STAGING.strItemNo IN ('Tax', 'State Sales Tax')

		UPDATE tblARInvoiceReportStagingTable
		SET strRemitToAddress 	= @strRemitToAddress
		  , strOrigin			= CASE WHEN strSource = 'Transport Delivery' THEN NULL ELSE strOrigin END
		  , dblInvoiceTotal		= CASE WHEN strTransactionType = 'Credit Memo' THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
		  , dblAmountDue		= CASE WHEN strTransactionType = 'Credit Memo' THEN dblAmountDue * -1 ELSE dblAmountDue END
		WHERE intEntityUserId = @intEntityUserId
		  AND strRequestId = @strRequestId
		  AND strInvoiceFormat = 'Format 5 - Honstein'
	END