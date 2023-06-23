﻿CREATE PROCEDURE [dbo].[uspARInvoiceMCPReport]
	  @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS 

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICES
END
IF(OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL)
BEGIN
    DROP TABLE #LOCATIONS
END

DECLARE @ysnPrintInvoicePaymentDetail	BIT = 0
	  , @strEmail				NVARCHAR(100) = NULL
	  , @strPhone				NVARCHAR(100) = NULL
	  , @strCompanyName			NVARCHAR(200) = NULL
	  , @strCompanyFullAddress	NVARCHAR(500) = NULL
	  , @strBerryOilAddress		NVARCHAR(500) = NULL
	  , @dtmDateNow				DATETIME = NULL
	  ,	@strInvoiceFormat		NVARCHAR(200)

SET @dtmDateNow = GETDATE()

--AR PREFERENCE
SELECT TOP 1 @ysnPrintInvoicePaymentDetail	= ysnPrintInvoicePaymentDetail
FROM dbo.tblARCompanyPreference WITH (NOLOCK)
ORDER BY intCompanyPreferenceId DESC

--COMPANY INFO
SELECT TOP 1 @strCompanyFullAddress	= ISNULL(LTRIM(RTRIM(strAddress)), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
		   , @strBerryOilAddress	= ISNULL(LTRIM(RTRIM(strAddress)), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(' ' + NULLIF(strZip, ''), '') + ISNULL(' ' + NULLIF(strCountry, ''), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strPhone, ''), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strEmail, ''), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strWebSite, ''), '')
		   , @strCompanyName		= strCompanyName
		   , @strPhone				= strPhone
		   , @strEmail				= strEmail
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--LOCATIONS
SELECT intCompanyLocationId		= L.intCompanyLocationId
	 , strLocationName			= L.strLocationName
	 , strUseLocationAddress	= ISNULL(L.strUseLocationAddress, 'No')
	 , strInvoiceComments		= L.strInvoiceComments
	 , strLocationNumber		= L.strLocationNumber
	 , strFullAddress			= ISNULL(LTRIM(RTRIM(L.strAddress)), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(L.strCity, ''), '') + ISNULL(', ' + NULLIF(L.strStateProvince, ''), '') + ISNULL(', ' + NULLIF(L.strZipPostalCode, ''), '') + ISNULL(', ' + NULLIF(L.strCountry, ''), '')
INTO #LOCATIONS
FROM tblSMCompanyLocation L

DELETE FROM tblARInvoiceReportStagingTable 
WHERE intEntityUserId = @intEntityUserId 
  AND strRequestId = @strRequestId 
  AND strInvoiceFormat IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 2', 'Format 9 - Berry Oil', 'Format 2 - With Laid in Cost','Format 10 - Berry Trucking')

--MAIN QUERY
SELECT strCompanyName			= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE @strCompanyName END
	 , strCompanyAddress		= CASE WHEN (SELECTEDINV.strInvoiceFormat <> 'Format 9 - Berry Oil' AND SELECTEDINV.strInvoiceFormat <> 'Format 10 - Berry Trucking')
	 								   THEN 
	 										CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
									   			 WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
									   			 WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
											END
									   ELSE @strBerryOilAddress
								  END
	 , intInvoiceId				= INV.intInvoiceId
	 , intEntityCustomerId		= INV.intEntityCustomerId
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strTransactionType		= INV.strTransactionType
	 , dtmDate					= CAST(INV.dtmDate AS DATE)
	 , dtmDueDate				= INV.dtmDueDate
	 , strBOLNumber				= INV.strBOLNumber
	 , strPONumber				= INV.strPONumber
	 , intTruckDriverId			= ISNULL(INV.intTruckDriverId, INV.intEntitySalespersonId)
	 , strTruckDriver			= CASE WHEN INV.strType = 'Tank Delivery' THEN ISNULL(NULLIF(DRIVER.strName, ''), SALESPERSON.strName) ELSE NULL END
	 , intBillToLocationId		= INV.intBillToLocationId
	 , intShipToLocationId		= INV.intShipToLocationId
	 , strBillToLocationName	= EMBT.strEntityNo
	 , strShipToLocationName	= EMST.strEntityNo
	 , strBillToAddress			= CASE WHEN (SELECTEDINV.strInvoiceFormat = 'Format 9 - Berry Oil' OR SELECTEDINV.strInvoiceFormat = 'Format 10 - Berry Trucking')
									   THEN ISNULL(RTRIM(INV.strBillToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToAddress) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToCity), '') + ISNULL(RTRIM(', ' + INV.strBillToState), '') + ISNULL(RTRIM(' ' + INV.strBillToZipCode), '') + ISNULL(RTRIM(' ' + INV.strBillToCountry), '')
	 							  	   ELSE ISNULL(RTRIM(INV.strBillToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToAddress) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToCity), '') + ISNULL(RTRIM(', ' + INV.strBillToState), '') + ISNULL(RTRIM(', ' + INV.strBillToZipCode), '') + ISNULL(RTRIM(', ' + INV.strBillToCountry), '')
								  END
	 , strShipToAddress			= CASE WHEN (SELECTEDINV.strInvoiceFormat = 'Format 9 - Berry Oil' OR SELECTEDINV.strInvoiceFormat = 'Format 10 - Berry Trucking')
	 								   THEN CAST(ISNULL(RTRIM(INV.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToAddress) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToCity), '') + ISNULL(RTRIM(', ' + INV.strShipToState), '') + ISNULL(RTRIM(' ' + INV.strShipToZipCode), '') + ISNULL(RTRIM(' ' + INV.strShipToCountry), '') AS NVARCHAR(MAX))
									   ELSE CAST(ISNULL(RTRIM(INV.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToAddress) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToCity), '') + ISNULL(RTRIM(', ' + INV.strShipToState), '') + ISNULL(RTRIM(', ' + INV.strShipToZipCode), '') + ISNULL(RTRIM(', ' + INV.strShipToCountry), '') AS NVARCHAR(MAX))
								  END
	 , strSource				= INV.strType
	 , intTermId				= INV.intTermId
	 , strTerm					= TERM.strTerm
	 , intShipViaId				= INV.intShipViaId
	 , strShipVia				= SHIPVIA.strShipVia
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , strCompanyLocation		= CAST(L.strLocationName AS NVARCHAR(100))
	 , intInvoiceDetailId		= ISNULL(INVOICEDETAIL.intInvoiceDetailId,0)
	 , intSiteId				= INVOICEDETAIL.intSiteId
	 , dblQtyShipped			= INVOICEDETAIL.dblQtyShipped
	 , intItemId				= CASE WHEN SELECTEDINV.strInvoiceFormat IN ('Format 5 - Honstein', 'Format 9 - Berry Oil','Format 10 - Berry Trucking') THEN ISNULL(INVOICEDETAIL.intItemId, 99999999) ELSE INVOICEDETAIL.intItemId END
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
	 , dblInvoiceSubtotal		= ISNULL(INV.dblInvoiceSubtotal, 0)
	 , dblTotalTax				= INVOICEDETAIL.dblTotalTax
	 , strComments				= CASE WHEN INV.strType = 'Tank Delivery' THEN ISNULL(INV.strComments, '') ELSE ISNULL(INV.strFooterComments, '') END
	 , strItemComments          = CAST('' AS NVARCHAR(500))
	 , strOrigin				= CAST(REPLACE(INV.strComments, 'Origin:', '') AS NVARCHAR(MAX))
	 , intEntityUserId			= @intEntityUserId
	 , strRequestId				= @strRequestId
	 , strInvoiceFormat			= SELECTEDINV.strInvoiceFormat
	 , intTicketId				= CAST(0 AS INT)
	 , strTicketNumbers			= CAST('' AS NVARCHAR(MAX))
	 , dtmLoadedDate			= INV.dtmShipDate
	 , dtmScaleDate				= INV.dtmPostDate
	 , strCommodity				= CAST('' AS NVARCHAR(100))
	 , blbSignature				= INV.blbSignature
	 , strTicketType			= INV.strTransactionType
	 , strLocationNumber		= L.strLocationNumber
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strPaymentInfo			= CASE WHEN INV.strTransactionType = 'Cash' THEN ISNULL(PAYMENTMETHOD.strPaymentMethod, '') + ' - ' + ISNULL(INV.strPaymentInfo, '') ELSE NULL END
	 , dtmCreated				= @dtmDateNow
	 , strType					= INV.strType
	 , ysnPrintInvoicePaymentDetail = @ysnPrintInvoicePaymentDetail
	 , strFooterComment  		= ISNULL(INV.strFooterComments,'')
INTO #INVOICES
FROM dbo.tblARInvoice INV WITH (NOLOCK)
INNER JOIN #MCPINVOICES SELECTEDINV ON INV.intInvoiceId = SELECTEDINV.intInvoiceId
INNER JOIN #LOCATIONS L ON INV.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN tblSMTerm TERM WITH (NOLOCK) ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT intInvoiceId			= ID.intInvoiceId
		 , intInvoiceDetailId   = ID.intInvoiceDetailId
		 , intSiteId			= ID.intSiteId
		 , dblQtyShipped		= ID.dblQtyShipped
		 , intItemId			= ID.intItemId
		 , strItemNo			= ITEM.strItemNo
		 , strItemDescription	= ID.strItemDescription
		 , strContractNo		= CT.strContractNumber
		 , strUnitMeasure		= UM.strUnitMeasure
		 , dblPrice				= ID.dblPrice
		 , dblTotal				= ID.dblTotal
		 , dblPriceWithTax		= ID.dblPrice + ISNULL(CASE WHEN ID.dblTotalTax <> 0 AND ID.dblQtyShipped <> 0 THEN ID.dblTotalTax/ID.dblQtyShipped ELSE 0 END, 0)
		 , dblTotalPriceWithTax = ID.dblTotal + ID.dblTotalTax
		 , dblTotalTax			= ID.dblTotalTax
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN tblICItem ITEM WITH (NOLOCK) ON ID.intItemId = ITEM.intItemId
	LEFT JOIN tblCTContractHeader CT WITH (NOLOCK) ON ID.intContractHeaderId = CT.intContractHeaderId
	LEFT JOIN tblICItemUOM IUOM ON ID.intItemUOMId = IUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId
) INVOICEDETAIL ON INV.intInvoiceId = INVOICEDETAIL.intInvoiceId
LEFT JOIN tblEMEntity DRIVER WITH (NOLOCK) ON INV.intTruckDriverId = DRIVER.intEntityId
LEFT JOIN tblEMEntity SALESPERSON WITH (NOLOCK) ON INV.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN tblEMEntityLocation BILLTO WITH (NOLOCK) ON INV.intBillToLocationId = BILLTO.intEntityLocationId
LEFT JOIN tblEMEntity EMBT ON BILLTO.intEntityId = EMBT.intEntityId
LEFT JOIN tblEMEntityLocation SHIPTO WITH (NOLOCK) ON INV.intShipToLocationId = SHIPTO.intEntityLocationId
LEFT JOIN tblEMEntity EMST ON SHIPTO.intEntityId = EMST.intEntityId
LEFT JOIN tblSMShipVia SHIPVIA WITH (NOLOCK) ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN tblSMPaymentMethod PAYMENTMETHOD ON INV.intPaymentMethodId = PAYMENTMETHOD.intPaymentMethodID
LEFT JOIN tblSOSalesOrder SO ON INV.intSalesOrderId = SO.intSalesOrderId

--CUSTOMERS
SELECT intEntityCustomerId	= C.intEntityId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnIncludeEntityName	= C.ysnIncludeEntityName
INTO #CUSTOMERS
FROM tblARCustomer C
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM #INVOICES
) STAGING ON C.intEntityId = STAGING.intEntityCustomerId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId

--SHIP TO FOR TM SITE
UPDATE I
SET strShipToAddress	= CONSUMPTIONSITE.strSiteFullAddress
  , strCompanyLocation	= CONSUMPTIONSITE.strSiteNumber
  , strOrigin			= CONSUMPTIONSITE.strLocationName
FROM #INVOICES I 
CROSS APPLY (
	SELECT TOP 1 intSiteId				= ID.intSiteId
				
			   , strSiteFullAddress		= (CASE WHEN I.strInvoiceFormat = 'Format 10 - Berry Trucking'
											THEN
												ISNULL(RTRIM(S.strSiteAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(S.strCity), '') + ISNULL(RTRIM(', ' + S.strState), '') + ISNULL(RTRIM(' ' + S.strZipCode), '') + ISNULL(RTRIM(', ' + S.strCountry), '')
											ELSE
												ISNULL(RTRIM(S.strSiteAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(S.strCity), '') + ISNULL(RTRIM(', ' + S.strState), '') + ISNULL(RTRIM(', ' + S.strZipCode), '') + ISNULL(RTRIM(', ' + S.strCountry), '')
											END)
			   , strSiteNumber			= RIGHT('000'+ CAST(S.intSiteNumber AS NVARCHAR(4)),4) + ' - ' + ISNULL(S.strDescription, '')
			   , strLocationName		= CLS.strLocationName
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
	INNER JOIN tblSMCompanyLocation CLS ON S.intLocationId = CLS.intCompanyLocationId
	WHERE ID.intInvoiceId = I.intInvoiceId 
	  AND ISNULL(ID.intSiteId, 0) <> 0
	ORDER BY ID.intInvoiceDetailId
) CONSUMPTIONSITE
WHERE I.strType = 'Tank Delivery'

--UPDATE CUSTOMER
UPDATE I
SET strBillToAddress		= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + I.strBillToAddress ELSE I.strBillToAddress END
  , strShipToAddress		= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + I.strShipToAddress ELSE I.strShipToAddress END
FROM #INVOICES I
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId

--UPDATE NEGATIVE AMOUNTS
UPDATE I
SET dblPrice				= dblPrice * -1
  , dblPriceWithTax			= dblPriceWithTax * -1
  , dblTotalPriceWithTax	= dblTotalPriceWithTax * -1
  , dblInvoiceTotal			= dblInvoiceTotal * -1
  , dblQtyShipped			= dblQtyShipped * -1
  , dblInvoiceSubtotal		= dblInvoiceSubtotal * -1
FROM #INVOICES I
WHERE I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')

--UPDATE TICKET DETAILS
UPDATE I
SET intTicketId			= TICKETDETAILS.intTicketId
  , strTicketNumbers	= TICKETDETAILS.strTicketNumbers
  , strCommodity		= TICKETDETAILS.strCommodity
FROM #INVOICES I
CROSS APPLY (
	SELECT TOP 1 intTicketId		= TICKET.intTicketId
		       , strTicketNumbers	= TICKET.strTicketNumber
		       , strCommodity		= COM.strDescription
	FROM dbo.tblARInvoiceDetail DETAIL
	INNER JOIN dbo.tblSCTicket TICKET ON DETAIL.intTicketId = TICKET.intTicketId
	LEFT JOIN dbo.tblICCommodity COM ON TICKET.intCommodityId = COM.intCommodityId
	WHERE DETAIL.intInvoiceId = I.intInvoiceId
	  AND DETAIL.intTicketId IS NOT NULL
	ORDER BY DETAIL.intInvoiceDetailId
) TICKETDETAILS

--HAZMAT ITEMS
UPDATE I
SET strItemComments = HAZMAT.strMessage
FROM #INVOICES I
CROSS APPLY (
	SELECT strMessage = LEFT(strMessage, LEN(strMessage) - 0)
	FROM (
		SELECT CAST(ISNULL(ICC.strMessage, '') AS VARCHAR(MAX)) + CHAR(10)
		FROM dbo.tblARInvoiceDetail IDD WITH (NOLOCK)
		INNER JOIN (
			SELECT intItemId
				 , ICT.strMessage 
			FROM dbo.tblICItem ICC WITH (NOLOCK)
			INNER JOIN dbo.tblICTag ICT ON ICC.intHazmatTag = ICT.intTagId AND ICT.strType = 'Hazmat Message'
			WHERE ICC.intHazmatTag > 0
			  AND ICC.intHazmatTag IS NOT NULL
		) ICC ON IDD.intItemId = ICC.intItemId
		WHERE IDD.intInvoiceId = I.intInvoiceId		
		GROUP BY IDD.intItemId, ICC.strMessage
		FOR XML PATH ('')
	) DETAILS (strMessage)
) HAZMAT

--COMMENTS
UPDATE I
SET strComments	= dbo.fnEliminateHTMLTags(I.strComments, 0)
  , strOrigin	= dbo.fnEliminateHTMLTags(I.strOrigin, 0)
FROM #INVOICES I
WHERE strComments <> '' 
   OR strOrigin <> ''

INSERT INTO tblARInvoiceReportStagingTable WITH (TABLOCK) (
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
	 , dblInvoiceSubtotal
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblInvoiceTax
	 , dblTotalTax
	 , strComments
	 , strItemComments
	 , strOrigin
	 , intEntityUserId
	 , strRequestId
	 , strInvoiceFormat
	 , intTicketId
	 , strTicketNumbers
	 , dtmLoadedDate
	 , dtmScaleDate
	 , strCommodity
	 , blbSignature
	 , strTicketType
	 , strLocationNumber
	 , strSalesOrderNumber
	 , strPaymentInfo
	 , dtmCreated
	 , ysnPrintInvoicePaymentDetail
	 , strInvoiceFooterComment
)
SELECT strCompanyName
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
	 , strBillToAddress
	 , strShipToAddress
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
	 , dblInvoiceSubtotal
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblInvoiceTax
	 , dblTotalTax
	 , strComments
	 , strItemComments
	 , strOrigin
	 , intEntityUserId
	 , strRequestId
	 , strInvoiceFormat
	 , intTicketId
	 , strTicketNumbers
	 , dtmLoadedDate
	 , dtmScaleDate
	 , strCommodity
	 , blbSignature
	 , strTicketType
	 , strLocationNumber
	 , strSalesOrderNumber
	 , strPaymentInfo
	 , dtmCreated
	 , ysnPrintInvoicePaymentDetail
	 , strInvoiceFooterComment = strFooterComment
FROM #INVOICES

UPDATE STAGING
SET strComments = ISNULL([MESSAGES].strMessage, '')
FROM tblARInvoiceReportStagingTable STAGING
OUTER APPLY (
	SELECT TOP 1 strMessage
	FROM tblEMEntityMessage EM
	WHERE EM.strMessageType = 'Invoice'
	  AND EM.intEntityId = STAGING.intEntityCustomerId
	ORDER BY EM.intMessageId
) [MESSAGES]
WHERE STAGING.intEntityUserId = @intEntityUserId
  AND STAGING.strRequestId = @strRequestId
  AND STAGING.strInvoiceFormat IN ('Format 5 - Honstein', 'Format 9 - Berry Oil','Format 10 - Berry Trucking')

--HONSTEIN TAX DETAILS
IF EXISTS (SELECT TOP 1 NULL FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking'))
BEGIN
	SELECT TOP 1 @strInvoiceFormat = strInvoiceFormat FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId 
	DECLARE @strRemitToAddress	NVARCHAR(MAX)	= NULL

	SELECT TOP 1 @strRemitToAddress	= 	(CASE WHEN @strInvoiceFormat = 'Format 10 - Berry Trucking' 
										THEN ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(strCity), '') + ISNULL(RTRIM(', ' + strState), '') + ISNULL(RTRIM(' ' + strZip), '')
										ELSE ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(strCity), '') + ISNULL(RTRIM(', ' + strState), '') + ISNULL(RTRIM(', ' + strZip), '')
										END)
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
	ORDER BY intCompanySetupID

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
		, strInvoiceFormat		= STAGING.strInvoiceFormat
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
		WHERE TREPORT.strType <> 'State Sales Tax'
			AND IDT.dblAdjustedTax <> 0
		GROUP BY IDT.intInvoiceDetailId
				, IDT.intTaxCodeId
				, TCODE.strTaxCode
				, TCODE.strDescription
	) TAXES ON ID.intInvoiceDetailId = TAXES.intInvoiceDetailId
	WHERE STAGING.intEntityUserId = @intEntityUserId
		AND STAGING.strRequestId = @strRequestId
		AND STAGING.strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking')
		AND ID.dblTotalTax <> 0

	UNION ALL

	SELECT intEntityUserId		= @intEntityUserId
		, strRequestId			= @strRequestId
		, strInvoiceFormat		= STAGING.strInvoiceFormat
		, strItemComments		= STAGING.strItemComments
		, dblInvoiceTotal		= STAGING.dblInvoiceTotal
		, dblAmountDue			= STAGING.dblAmountDue
		, blbSignature			= STAGING.blbSignature
		, strComments			= STAGING.strComments
		, intInvoiceId			= STAGING.intInvoiceId
		, intInvoiceDetailId	= 99999999 + TAXES.intTaxCodeId
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
						, strInvoiceFormat
		FROM tblARInvoiceReportStagingTable
		WHERE intEntityUserId = @intEntityUserId
		    AND strRequestId = @strRequestId
		    AND strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking')
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
		WHERE TREPORT.strType = 'State Sales Tax'
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
		, intItemId				= CASE WHEN STAGING.strItemNo = 'State Sales Tax' THEN NULL ELSE ORIG.intItemId END
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
		, dtmDate					= ORIG.dtmDate
		, dtmDueDate				= ORIG.dtmDueDate
		, strUnitMeasure			= ORIG.strUnitMeasure
		, strSalesOrderNumber		= ORIG.strSalesOrderNumber
	FROM tblARInvoiceReportStagingTable STAGING
	INNER JOIN (
		SELECT *
		FROM tblARInvoiceReportStagingTable
		WHERE intEntityUserId = @intEntityUserId
		  	AND strRequestId = @strRequestId
		    AND strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking')
	) ORIG ON STAGING.intInvoiceId = ORIG.intInvoiceId AND (STAGING.intInvoiceDetailId = ORIG.intInvoiceDetailId OR STAGING.strItemNo = 'State Sales Tax')
	WHERE STAGING.intEntityUserId = @intEntityUserId
		AND STAGING.strRequestId = @strRequestId
		AND STAGING.strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking')
		AND STAGING.strItemNo IN ('Tax', 'State Sales Tax')

	UPDATE tblARInvoiceReportStagingTable
	SET strRemitToAddress 	= @strRemitToAddress
		, strOrigin			= CASE WHEN strSource = 'Transport Delivery' THEN NULL ELSE strOrigin END
		, dblInvoiceTotal		= CASE WHEN strTransactionType = 'Credit Memo' THEN dblInvoiceTotal * -1 ELSE dblInvoiceTotal END
		, dblAmountDue		= CASE WHEN strTransactionType = 'Credit Memo' THEN dblAmountDue * -1 ELSE dblAmountDue END
		, intSortId			= CASE WHEN strItemNo IN ('Tax') THEN 99999999 ELSE intInvoiceDetailId END
	WHERE intEntityUserId = @intEntityUserId
		AND strRequestId = @strRequestId
		AND strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking')

	UPDATE STAGING
	SET dblTotalTax = STAGING.dblTotalTax - SST.dblTotalSST
	FROM tblARInvoiceReportStagingTable STAGING
	INNER JOIN (
		SELECT IDT.intInvoiceDetailId
				, dblTotalSST = SUM(dblAdjustedTax) 
		FROM tblARInvoiceDetailTax IDT
		INNER JOIN tblSMTaxClass TCLASS ON IDT.intTaxClassId = TCLASS.intTaxClassId
		INNER JOIN tblSMTaxReportType TREPORT ON TCLASS.intTaxReportTypeId = TREPORT.intTaxReportTypeId
		WHERE TREPORT.strType = 'State Sales Tax'
			AND IDT.dblAdjustedTax <> 0			  
		GROUP BY IDT.intInvoiceDetailId
	) SST ON STAGING.intInvoiceDetailId = SST.intInvoiceDetailId
	WHERE STAGING.intEntityUserId = @intEntityUserId
		AND STAGING.strRequestId = @strRequestId
		AND STAGING.strInvoiceFormat IN ('Format 5 - Honstein','Format 10 - Berry Trucking')
		AND STAGING.strItemNo <> 'State Sales Tax'
END
ELSE IF EXISTS (SELECT TOP 1 1 FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat IN ('Format 9 - Berry Oil'))
BEGIN
	DELETE FROM tblARInvoiceTaxReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat  IN ('Format 9 - Berry Oil')
	INSERT INTO tblARInvoiceTaxReportStagingTable (
		  [intTransactionId]
		, [intTransactionDetailId]
		, [intTransactionDetailTaxId]
		, [intTaxCodeId]
		, [intEntityUserId]
		, [strRequestId]
		, [strTaxTransactionType]
		, [strCalculationMethod]
		, [strTaxCode]
		, [strDescription]
		, [strTaxClass]
		, [strInvoiceFormat]
		, [dblAdjustedTax]
		, [dblRate]
	)
	SELECT [intTransactionId]			= I.intInvoiceId
		, [intTransactionDetailId]		= ID.intInvoiceDetailId
		, [intTransactionDetailTaxId]	= IDT.intInvoiceDetailTaxId
		, [intTaxCodeId]				= IDT.intTaxCodeId
		, [intEntityUserId]				= @intEntityUserId
		, [strRequestId]				= @strRequestId
		, [strTaxTransactionType]		= 'Invoice'
		, [strCalculationMethod]		= IDT.strCalculationMethod
		, [strTaxCode]					= NULL
		, [strDescription]				= SMT.strDescription
		, [strTaxClass]					= TC.strTaxClass
		, [strInvoiceFormat]			= I.strInvoiceFormat
		, [dblAdjustedTax]				= IDT.dblAdjustedTax
		, [dblRate]						= IDT.dblRate		
	FROM (
		SELECT DISTINCT intInvoiceId
					  , strInvoiceFormat
		FROM #INVOICES
	) I
	INNER JOIN tblARInvoiceDetail ID WITH (NOLOCK) ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblARInvoiceDetailTax IDT WITH (NOLOCK) ON ID.intInvoiceDetailId = IDT.intInvoiceDetailId
	INNER JOIN tblSMTaxCode SMT ON IDT.intTaxCodeId = SMT.intTaxCodeId
	INNER JOIN tblSMTaxClass TC ON SMT.intTaxClassId = TC.intTaxClassId
	LEFT JOIN tblSMTaxReportType TREPORT ON TC.intTaxReportTypeId = TREPORT.intTaxReportTypeId		 
	WHERE IDT.dblAdjustedTax <> 0
	  AND (TREPORT.strType IS NULL OR TREPORT.strType <> 'State Sales Tax')

	UPDATE STAGING
	SET dblPriceTotal	= ISNULL(TOTALPRICE.dblPriceTotal, 0)
	  , dblLineTotal	= ISNULL(TOTALPRICE.dblLineTotal, 0)
	FROM tblARInvoiceReportStagingTable STAGING
	INNER JOIN (
		SELECT dblPriceTotal		= SUM(ISNULL(ITEMPRICE.dblPrice, 0) + ISNULL(TAXPRICE.dblRate, 0))
		     , dblLineTotal			= SUM(ISNULL(ITEMPRICE.dblItemPrice, 0) + ISNULL(TAXPRICE.dblAdjustedTax, 0))
			 , intInvoiceId			= ITEMPRICE.intInvoiceId
			 , intInvoiceDetailId	= ITEMPRICE.intInvoiceDetailId
		FROM tblARInvoiceReportStagingTable ITEMPRICE
		LEFT JOIN (
			SELECT intInvoiceId			= intTransactionId	
				 , intInvoiceDetailId	= intTransactionDetailId
				 , dblAdjustedTax 		= SUM(dblAdjustedTax)
				 , dblRate				= SUM(dblRate)
			FROM tblARInvoiceTaxReportStagingTable			
			WHERE strInvoiceFormat IN ('Format 9 - Berry Oil')
			  AND intEntityUserId = @intEntityUserId
			  AND strRequestId = @strRequestId
			GROUP BY intTransactionId, intTransactionDetailId
		) TAXPRICE ON ITEMPRICE.intInvoiceId = TAXPRICE.intInvoiceId
				  AND ITEMPRICE.intInvoiceDetailId = TAXPRICE.intInvoiceDetailId
		WHERE ITEMPRICE.intEntityUserId = @intEntityUserId
		  AND ITEMPRICE.strRequestId = @strRequestId
		  AND ITEMPRICE.strInvoiceFormat IN ('Format 9 - Berry Oil')
		GROUP BY ITEMPRICE.intInvoiceId, ITEMPRICE.intInvoiceDetailId
	) TOTALPRICE ON STAGING.intInvoiceId = TOTALPRICE.intInvoiceId
	            AND STAGING.intInvoiceDetailId = TOTALPRICE.intInvoiceDetailId
	WHERE STAGING.intEntityUserId = @intEntityUserId
	  AND STAGING.strRequestId = @strRequestId
	  AND STAGING.strInvoiceFormat  IN('Format 9 - Berry Oil')

	UPDATE STAGING
	SET dblInvoiceSubtotal = ISNULL(DETAIL.dblLineTotal, 0)
	FROM tblARInvoiceReportStagingTable STAGING
	INNER JOIN (
		SELECT intInvoiceId	= intInvoiceId
			 , dblLineTotal = SUM(dblLineTotal) 
		FROM tblARInvoiceReportStagingTable DETAIL		
		WHERE DETAIL.intEntityUserId = @intEntityUserId
		  AND DETAIL.strRequestId = @strRequestId
		  AND DETAIL.strInvoiceFormat  IN ('Format 9 - Berry Oil')
		GROUP BY DETAIL.intInvoiceId
	) DETAIL ON STAGING.intInvoiceId = DETAIL.intInvoiceId
	WHERE STAGING.intEntityUserId = @intEntityUserId
	  AND STAGING.strRequestId = @strRequestId
	  AND STAGING.strInvoiceFormat IN ('Format 9 - Berry Oil')
	  
	UPDATE STAGING
	SET dblInvoiceTax = ISNULL(SST.dblTotalSST, 0)
	FROM tblARInvoiceReportStagingTable STAGING
	LEFT JOIN (
		SELECT ID.intInvoiceId
			 , dblTotalSST = SUM(dblAdjustedTax) 
		FROM tblARInvoiceDetailTax IDT
		INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
		INNER JOIN tblSMTaxClass TCLASS ON IDT.intTaxClassId = TCLASS.intTaxClassId
		INNER JOIN tblSMTaxReportType TREPORT ON TCLASS.intTaxReportTypeId = TREPORT.intTaxReportTypeId
		WHERE TREPORT.strType = 'State Sales Tax'
		  AND IDT.dblAdjustedTax <> 0			  
		GROUP BY ID.intInvoiceId
	) SST ON STAGING.intInvoiceId = SST.intInvoiceId
	WHERE STAGING.intEntityUserId = @intEntityUserId
	  AND STAGING.strRequestId = @strRequestId
	  AND STAGING.strInvoiceFormat IN ('Format 9 - Berry Oil')
END

IF EXISTS (SELECT TOP 1 NULL FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat = 'Format 2 - With Laid in Cost')
BEGIN

	--UPDATE LAID IN COST
	UPDATE I
	SET dblLaidInCost = LIC.LaidInCost
	FROM tblARInvoiceReportStagingTable I
	LEFT JOIN (
		SELECT 
			  ID.intInvoiceDetailId
			, (ID.dblPrice
				+ (Freight.dblPrice * Freight.dblQtyShipped / ID.dblQtyShipped)
				+ ((Freight.dblPrice * Freight.dblQtyShipped / ID.dblQtyShipped) * Surgecharge.dblPrice)
				+ Taxes.taxRate
			) [LaidInCost]
		FROM tblARInvoiceDetail ID WITH (NOLOCK)
		INNER JOIN tblICItem I WITH (NOLOCK) ON ID.intItemId = I.intItemId
		LEFT JOIN (
			SELECT 
				intLoadDistributionDetailId
				, intInvoiceId
				, dblQtyShipped
				, dblPrice
			FROM tblARInvoiceDetail LD WITH (NOLOCK)
			INNER JOIN tblTRLoadHeader H WITH (NOLOCK) ON H.strTransaction = LD.strDocumentNumber AND LD.intItemId = H.intFreightItemId
		) Freight ON Freight.intLoadDistributionDetailId = ID.intLoadDistributionDetailId AND Freight.intInvoiceId = ID.intInvoiceId
		LEFT JOIN (
			SELECT 
				intLoadDistributionDetailId
				, intInvoiceId
				, dblQtyShipped
				, dblPrice
			FROM tblARInvoiceDetail LD WITH (NOLOCK)
			INNER JOIN tblTRLoadHeader H WITH (NOLOCK) ON H.strTransaction = LD.strDocumentNumber
			INNER JOIN vyuICGetOtherCharges GOC WITH (NOLOCK) ON GOC.intOnCostTypeId = H.intFreightItemId AND LD.intItemId = GOC.intItemId
		) Surgecharge ON Surgecharge.intLoadDistributionDetailId = ID.intLoadDistributionDetailId AND Surgecharge.intInvoiceId = ID.intInvoiceId
		LEFT JOIN (
			SELECT 
				   intInvoiceDetailId	= DETAIL.intInvoiceDetailId
				 , taxRate				= SUM(ISNULL(IDT.dblRate, 0))
			FROM dbo.tblARInvoiceDetail DETAIL WITH (NOLOCK)
			INNER JOIN (
				SELECT intInvoiceDetailId
					 , intTaxCodeId
					 , strCalculationMethod
					 , dblRate
					 , dblTax
					 , dblAdjustedTax
				FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
			) IDT ON DETAIL.intInvoiceDetailId = IDT.intInvoiceDetailId
			WHERE IDT.dblAdjustedTax <> 0
			GROUP BY DETAIL.intInvoiceId, DETAIL.intInvoiceDetailId
			HAVING SUM(ISNULL(IDT.dblAdjustedTax, 0)) <> 0
		) Taxes ON ID.intInvoiceDetailId = Taxes.intInvoiceDetailId
		WHERE I.strType IN ('Bundle','Inventory')
	) LIC ON I.intInvoiceDetailId = LIC.intInvoiceDetailId

END