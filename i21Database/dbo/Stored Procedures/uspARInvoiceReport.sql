CREATE PROCEDURE [dbo].[uspARInvoiceReport]
	  @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

IF(OBJECT_ID('tempdb..#SELECTEDINVOICES') IS NOT NULL) DROP TABLE #SELECTEDINVOICES
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES
IF(OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL) DROP TABLE #LOCATIONS

CREATE TABLE #INVOICES (
	   intInvoiceId					INT				NOT NULL
	 , intCompanyLocationId			INT				NOT NULL
	 , intEntityCustomerId			INT				NOT NULL
	 , strCompanyName				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strCompanyAddress			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strCompanyInfo				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strCompanyPhoneNumber		NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strCompanyEmail				NVARCHAR(75)	COLLATE Latin1_General_CI_AS NULL
	 , strType						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL DEFAULT 'Standard'
     , strCustomerName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strCustomerNumber			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strLocationName				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dtmDate						DATETIME		NOT NULL
	 , dtmPostDate					DATETIME		NULL
	 , strCurrency					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strBillToLocationName		NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strBillTo					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strShipTo					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strSalespersonName			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strPONumber					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strBOLNumber					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strShipVia					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strTerm						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dtmShipDate					DATETIME		NULL
	 , dtmDueDate					DATETIME		NOT NULL
	 , strFreightTerm				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strDeliverPickup				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strComments					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceHeaderComment		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceFooterComment		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , dblInvoiceSubtotal			NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblShipping					NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblTax						NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblInvoiceTotal				NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblAmountDue					NUMERIC(18, 6)	NULL DEFAULT 0
	 , strItemNo					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , intInvoiceDetailId			INT				NULL
	 , dblContractBalance			NUMERIC(18, 6)	NULL DEFAULT 0
	 , strContractNumber			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strContractNoSeq				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strItem						NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strItemDescription			NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strUnitMeasure				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dblQtyShipped				NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblQtyOrdered				NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblDiscount					NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblTotalTax					NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblPrice						NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblItemPrice					NUMERIC(18, 6)	NULL DEFAULT 0
	 , strPaid						NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL
	 , strPosted					NVARCHAR(10)	COLLATE Latin1_General_CI_AS NULL
	 , strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NOT NULL
	 , intRecipeId					INT				NULL
	 , intOneLinePrintId			INT				NULL
	 , strInvoiceComments			NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strPaymentComments			NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strCustomerComments			NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strItemType					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dblTotalWeight				NUMERIC(18, 6)	NULL DEFAULT 0
	 , strVFDDocumentNumber			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , ysnHasEmailSetup				BIT				NULL
	 , ysnHasRecipeItem				BIT				NULL
	 , ysnHasVFDDrugItem			BIT				NULL
	 , ysnHasProvisional			BIT				NULL
	 , strProvisional				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dblTotalProvisional			NUMERIC(18, 6)	NULL DEFAULT 0
	 , ysnPrintInvoicePaymentDetail BIT				NULL
	 , ysnListBundleSeparately		BIT				NULL
	 , strTicketNumbers				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strSiteNumber				NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , dblEstimatedPercentLeft		NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblPercentFull				NUMERIC(18, 6)	NULL DEFAULT 0
	 , strCustomerContract			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strTicketNumber 				NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strTicketNumberDate			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strCustomerReference			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strSalesReference			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strPurchaseReference			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strLoadNumber				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strTruckDriver				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strTrailer					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strSeals						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strLotNumber					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , blbLogo						VARBINARY(MAX)	NULL
	 , strAddonDetailKey			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strBOLNumberDetail			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , ysnHasAddOnItem				BIT				NULL
	 , intEntityUserId				INT				NULL
	 , strRequestId					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceFormat				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , blbSignature					VARBINARY(MAX)	NULL
	 , ysnStretchLogo				BIT				NULL
	 , strSubFormula				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dtmCreated					DATETIME		NULL
	 , strServiceChargeItem			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , intDaysOld					INT				NULL
	 , strServiceChareInvoiceNumber NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dtmDateSC					DATETIME		NULL
	 , intSiteId					INT				NULL
	 , ysnIncludeEntityName			BIT				NULL
	 , strFooterComments			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , intOriginalInvoiceId			INT				NULL
	 , dblServiceChargeAPR			NUMERIC(18, 6)	NULL DEFAULT 0
	 , strLogoType					NVARCHAR(10)
	 , intItemId					INT 			NULL
)

DECLARE @blbLogo						VARBINARY (MAX) = NULL
      , @blbStretchedLogo				VARBINARY (MAX) = NULL
	  , @ysnPrintInvoicePaymentDetail	BIT = 0
	  , @strInvoiceReportName			NVARCHAR(100) = NULL
	  , @strEmail						NVARCHAR(100) = NULL
	  , @strPhone						NVARCHAR(100) = NULL
	  , @strCompanyName					NVARCHAR(200) = NULL
	  , @strCompanyFullAddress			NVARCHAR(500) = NULL
	  , @intItemForFreightId			INT = NULL
	  , @dtmCurrentDate					DATETIME = GETDATE()
	  , @ysnIncludeHazmatMessage		BIT = 0

SELECT TOP 1 @intItemForFreightId = intItemForFreightId 
FROM tblTRCompanyPreference
ORDER BY intCompanyPreferenceId DESC
	  
--LOGO
SELECT TOP 1 @blbLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen IN ('SystemManager.CompanyPreference', 'SystemManager.view.CompanyPreference') 
  AND A.strComment = 'Header'
ORDER BY A.intAttachmentId DESC

--STRETCHED LOGO
SELECT TOP 1 @blbStretchedLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen IN ('SystemManager.CompanyPreference', 'SystemManager.view.CompanyPreference') 
  AND A.strComment = 'Stretched Header'
ORDER BY A.intAttachmentId DESC

SET @blbStretchedLogo = ISNULL(@blbStretchedLogo, @blbLogo)

--AR PREFERENCE
SELECT TOP 1 @ysnPrintInvoicePaymentDetail	= ysnPrintInvoicePaymentDetail
		   , @strInvoiceReportName			= strInvoiceReportName
		   , @ysnIncludeHazmatMessage		= ysnIncludeHazmatMessage
FROM dbo.tblARCompanyPreference WITH (NOLOCK)
ORDER BY intCompanyPreferenceId DESC

--COMPANY INFO
SELECT TOP 1 @strCompanyFullAddress	= ISNULL(LTRIM(RTRIM(strAddress)), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
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
	 , strFullAddress			= ISNULL(LTRIM(RTRIM(L.strAddress)), '') + CHAR(13) + CHAR(10) + ISNULL(NULLIF(L.strCity, ''), '') + ISNULL(', ' + NULLIF(L.strStateProvince, ''), '') + ISNULL(', ' + NULLIF(L.strZipPostalCode, ''), '') + ISNULL(', ' + NULLIF(L.strCountry, ''), '')
	 , intCompanySegment		= L.intCompanySegment
	 , strCompanyName			= VCRH.strCompanyName
	 , strCompanyAddress		= VCRH.strAddress
INTO #LOCATIONS
FROM tblSMCompanyLocation L
LEFT JOIN vyuARCompanyReportHeader VCRH ON L.intCompanyLocationId = VCRH.intCompanyLocationId

DELETE FROM tblARInvoiceReportStagingTable 
WHERE	
(
   intEntityUserId = @intEntityUserId 
   AND strRequestId = @strRequestId 
   AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 9 - Berry Oil', 'Format 2 - With Laid in Cost')
)
OR		dtmCreated < DATEADD(DAY, DATEDIFF(DAY, 0, @dtmCurrentDate), 0) 
OR		dtmCreated IS NULL

--MAIN QUERY
INSERT INTO #INVOICES (
	  intInvoiceId
	, intCompanyLocationId
	, intEntityCustomerId
	, strCompanyName
	, strCompanyAddress
	, strCompanyInfo
	, strCompanyPhoneNumber
	, strCompanyEmail
	, strType
	, strCustomerName
	, strCustomerNumber
	, strLocationName
	, dtmDate
	, dtmPostDate
	, strCurrency
	, strInvoiceNumber
	, strBillToLocationName
	, strBillTo
	, strShipTo
	, strSalespersonName
	, strPONumber
	, strBOLNumber
	, strShipVia
	, strTerm
	, dtmShipDate
	, dtmDueDate
	, strFreightTerm
	, strDeliverPickup
	, strComments
	, strInvoiceHeaderComment
	, strInvoiceFooterComment
	, dblInvoiceSubtotal
	, dblShipping
	, dblTax
	, dblInvoiceTotal
	, dblAmountDue
	, strItemNo
	, intInvoiceDetailId
	, strItem
	, strItemDescription
	, strUnitMeasure
	, dblQtyShipped
	, dblQtyOrdered
	, dblDiscount
	, dblTotalTax
	, dblPrice
	, dblItemPrice
	, strPaid
	, strPosted
	, strTransactionType
	, strInvoiceComments
	, strPaymentComments
	, strCustomerComments
	, strItemType
	, dblTotalWeight
	, strVFDDocumentNumber
	, ysnHasEmailSetup
	, ysnHasRecipeItem
	, ysnHasVFDDrugItem
	, ysnHasProvisional
	, strProvisional
	, dblTotalProvisional
	, ysnPrintInvoicePaymentDetail
	, ysnListBundleSeparately
	, strLotNumber
	, blbLogo
	, strAddonDetailKey
	, strBOLNumberDetail
	, ysnHasAddOnItem
	, intEntityUserId
	, strRequestId
	, strInvoiceFormat
	, blbSignature
	, ysnStretchLogo
	, strSubFormula
	, dtmCreated
	, ysnIncludeEntityName
	, strFooterComments
	, intOriginalInvoiceId
	, dblServiceChargeAPR
	, strLogoType
	, intOneLinePrintId
	, strTicketNumbers
	, dblPercentFull
	, intItemId
)
SELECT 
	 intInvoiceId					= INV.intInvoiceId
	, intCompanyLocationId			= INV.intCompanyLocationId
	, intEntityCustomerId			= INV.intEntityCustomerId
	, strCompanyName				= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' 
										WHEN (ISNULL(L.strCompanyName, '') <> '') THEN L.strCompanyName
										ELSE @strCompanyName END
	, strCompanyAddress				= CASE WHEN (ISNULL(L.strCompanyAddress, '') <> '') THEN L.strCompanyAddress
										WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
										WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
										WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
									END
	, strCompanyInfo				= CASE WHEN (ISNULL(L.strCompanyAddress, '') <> '') THEN L.strCompanyAddress
										WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
										WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
										WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
									END  + CHAR(10) + ISNULL(@strEmail,'')   + CHAR(10) + ISNULL(@strPhone,'')
	, strCompanyPhoneNumber			= @strPhone
	, strCompanyEmail				= @strEmail
	, strType						= ISNULL(INV.strType, 'Standard')
	, strCustomerName				= CAST('' AS NVARCHAR(100))
	, strCustomerNumber        		= CAST('' AS NVARCHAR(100))
	, strLocationName				= L.strLocationName
	, dtmDate						= CAST(INV.dtmDate AS DATE)
	, dtmPostDate					= INV.dtmPostDate
	, strCurrency					= CURRENCY.strCurrency	 	 
	, strInvoiceNumber				= INV.strInvoiceNumber
	, strBillToLocationName			= INV.strBillToLocationName
	, strBillTo						= ISNULL(RTRIM(ENTITYLOCATION.strCheckPayeeName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToAddress) + CHAR(13) + CHAR(10), '')	+ ISNULL(NULLIF(INV.strBillToCity, ''), '') + ISNULL(', ' + NULLIF(INV.strBillToState, ''), '') + ISNULL(', ' + NULLIF(INV.strBillToZipCode, ''), '') + ISNULL(', ' + NULLIF(INV.strBillToCountry, ''), '')
	, strShipTo						= ISNULL(RTRIM(INV.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToAddress) + CHAR(13) + CHAR(10), '') + ISNULL(NULLIF(INV.strShipToCity, ''), '') + ISNULL(', ' + NULLIF(INV.strShipToState, ''), '') + ISNULL(', ' + NULLIF(INV.strShipToZipCode, ''), '') + ISNULL(', ' + NULLIF(INV.strShipToCountry, ''), '')	 
	, strSalespersonName			= SALESPERSON.strName
	, strPONumber					= INV.strPONumber
	, strBOLNumber					= INV.strBOLNumber
	, strShipVia					= SHIPVIA.strName
	, strTerm						= TERM.strTerm
	, dtmShipDate					= INV.dtmShipDate
	, dtmDueDate					= INV.dtmDueDate
	, strFreightTerm				= FREIGHT.strFreightTerm
	, strDeliverPickup				= FREIGHT.strFobPoint
	, strComments					= INV.strComments
	, strInvoiceHeaderComment		= CAST('' AS NVARCHAR(MAX))
	, strInvoiceFooterComment		= CAST('' AS NVARCHAR(MAX))
	, dblInvoiceSubtotal			= (ISNULL(INV.dblInvoiceSubtotal, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END)
	, dblShipping					= ISNULL(INV.dblShipping, 0)
	, dblTax						= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN (ISNULL(INVOICEDETAIL.dblTotalTax, 0) - CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) * INVOICEDETAIL.dblQtyShipped ELSE 0 END) ELSE NULL END
	, dblInvoiceTotal				= ISNULL(INV.dblInvoiceTotal, 0) - ISNULL(INV.dblProvisionalAmount, 0) - CASE WHEN ISNULL('', 'Standard') <> 'Format 2 - Mcintosh' THEN 0 ELSE ISNULL(TOTALTAX.dblNonSSTTax, 0) END 
	, dblAmountDue					= CASE WHEN SELECTEDINV.strInvoiceFormat IN ('By Customer Balance', 'By Invoice') 
										THEN INVOICEDETAIL.dblServiceChargeAmountDue
										ELSE ISNULL(INV.dblAmountDue, 0)
									  END
	, strItemNo						= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strItemNo ELSE NULL END
	, intInvoiceDetailId			= ISNULL(INVOICEDETAIL.intInvoiceDetailId, 0)	
	, strItem						= CASE WHEN ISNULL(INVOICEDETAIL.strItemNo, '') = '' THEN INVOICEDETAIL.strItemDescription ELSE LTRIM(RTRIM(INVOICEDETAIL.strItemNo)) + '-' + ISNULL(INVOICEDETAIL.strItemDescription, '') END
	, strItemDescription			= INVOICEDETAIL.strItemDescription
	, strUnitMeasure				= INVOICEDETAIL.strUnitMeasure
	, dblQtyShipped					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblQtyShipped, 0) END
	, dblQtyOrdered					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblQtyOrdered, 0) END
	, dblDiscount					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblDiscount, 0) / 100 ELSE NULL END
	, dblTotalTax					= CASE WHEN ISNULL(NULL, 'Standard') <> 'Format 2 - Mcintosh' THEN ISNULL(INV.dblTax, 0) - CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END ELSE ISNULL(TOTALTAX.dblSSTTax, 0) END
	, dblPrice						= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblPrice, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) ELSE 0 END ELSE NULL END
	, dblItemPrice					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN (ISNULL(INVOICEDETAIL.dblTotal, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END) ELSE NULL END
	, strPaid						= CASE WHEN INV.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	, strPosted						= CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END
	, strTransactionType			= INV.strTransactionType	
	, strInvoiceComments			= INVOICEDETAIL.strInvoiceComments
	, strPaymentComments			= L.strInvoiceComments
	, strCustomerComments			= CAST('' AS NVARCHAR(MAX))
	, strItemType					= INVOICEDETAIL.strItemType
	, dblTotalWeight				= ISNULL(INV.dblTotalWeight, 0)
	, strVFDDocumentNumber			= INVOICEDETAIL.strVFDDocumentNumber
	, ysnHasEmailSetup				= CAST(0 AS BIT)
	, ysnHasRecipeItem				= CAST(0 AS BIT)
	, ysnHasVFDDrugItem        		= CAST(0 AS BIT)
	, ysnHasProvisional				= CAST(0 AS BIT)
	, strProvisional				= CAST('' AS NVARCHAR(500))
	, dblTotalProvisional			= CAST(0 AS NUMERIC(18, 6))
	, ysnPrintInvoicePaymentDetail 	= @ysnPrintInvoicePaymentDetail
	, ysnListBundleSeparately		= ISNULL(INVOICEDETAIL.ysnListBundleSeparately, CAST(0 AS BIT))
	, strLotNumber					= CAST('' AS NVARCHAR(200))
	, blbLogo                  		= ISNULL(SMLP.imgLogo, CASE WHEN ISNULL(SELECTEDINV.ysnStretchLogo, 0) = 1 THEN @blbStretchedLogo ELSE @blbLogo END)
	, strAddonDetailKey				= INVOICEDETAIL.strAddonDetailKey
	, strBOLNumberDetail			= INVOICEDETAIL.strBOLNumberDetail
	, ysnHasAddOnItem				= CAST(0 AS BIT)
	, intEntityUserId				= @intEntityUserId
	, strRequestId					= @strRequestId
	, strInvoiceFormat				= SELECTEDINV.strInvoiceFormat
	, blbSignature					= INV.blbSignature
	, ysnStretchLogo				= ISNULL(SELECTEDINV.ysnStretchLogo, 0)
	, strSubFormula					= INVOICEDETAIL.strSubFormula	
	, dtmCreated					= @dtmCurrentDate
	, ysnIncludeEntityName			= CAST(0 AS BIT)
	, strFooterComments				= INV.strFooterComments
	, intOriginalInvoiceId			= INV.intOriginalInvoiceId
	, dblServiceChargeAPR			= ISNULL(INVOICEDETAIL.dblServiceChargeAPR, 0.00)
	, strLogoType					= CASE WHEN SMLP.imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
	, intOneLinePrintId				= 1
	, strTicketNumbers				= INV.strTicketNumbers
	, dblPercentFull				= INVOICEDETAIL.dblPercentFull
	, intItemId						= INVOICEDETAIL.intItemId
FROM dbo.tblARInvoice INV
INNER JOIN #STANDARDINVOICES SELECTEDINV ON INV.intInvoiceId = SELECTEDINV.intInvoiceId
INNER JOIN #LOCATIONS L ON INV.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN tblSMTerm TERM ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT 
		 intInvoiceId				= ID.intInvoiceId
		,intInvoiceDetailId			= ID.intInvoiceDetailId
		,intCommentTypeId			= ID.intCommentTypeId
		,dblTotalTax				= CASE WHEN ISNULL(ID.dblComputedGrossPrice, 0) = 0 THEN ID.dblTotalTax ELSE 0 END
		,dblQtyShipped				= ID.dblQtyShipped
		,dblQtyOrdered				= ID.dblQtyOrdered
		,dblDiscount				= ID.dblDiscount
		,dblComputedGrossPrice		= ID.dblComputedGrossPrice	
		,dblPrice                 	= CASE WHEN ISNULL(PRICING.strPricing, '') = 'MANUAL OVERRIDE' THEN ID.dblPrice ELSE ISNULL(NULLIF(ID.dblComputedGrossPrice, 0), ID.dblPrice) END
		,dblTotal					= ID.dblTotal
		,strVFDDocumentNumber		= ID.strVFDDocumentNumber
		,strUnitMeasure				= UM.strUnitMeasure
		,strItemNo					= ITEM.strItemNo
		,strInvoiceComments			= CASE WHEN @ysnIncludeHazmatMessage = 0 OR ITEM.ysnHazardMaterial = 0 THEN ITEM.strInvoiceComments 
										ELSE ISNULL(NULLIF(ITEM.strInvoiceComments, '') + CHAR(13)+CHAR(10), '') + ISNULL(NULLIF(ITEMTAG.strMessage, ''), '') END
		,strItemType				= ITEM.strType
		,strItemDescription			= CASE WHEN ISNULL(ID.strItemDescription, '') <> '' THEN ID.strItemDescription ELSE ITEM.strDescription END
		,ysnListBundleSeparately	= ITEM.ysnListBundleSeparately
		,dblPercentFull				= ID.dblPercentFull
		,strAddonDetailKey			= NULL
		,ysnAddonParent				= CAST(0 AS BIT)
		,strBOLNumberDetail			= ID.strBOLNumberDetail
		,strSubFormula				= ID.strSubFormula
		,dblServiceChargeAmountDue	= ID.dblServiceChargeAmountDue
		,dblServiceChargeAPR		= ID.dblServiceChargeAPR		
		,intSCInvoiceId				= ID.intSCInvoiceId
		,intItemId					= ID.intItemId
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN tblICItem ITEM WITH (NOLOCK) ON ID.intItemId = ITEM.intItemId	
	LEFT JOIN tblICItemUOM IUOM ON ID.intItemUOMId = IUOM.intItemUOMId
	LEFT JOIN tblICTag ITEMTAG WITH (NOLOCK) ON ITEM.intHazmatTag = ITEMTAG.intTagId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId	
	LEFT JOIN (
		SELECT DISTINCT
			   intTransactionId
			 , intTransactionDetailId
			 , strPricing
		FROM dbo.tblARPricingHistory WITH (NOLOCK)
		WHERE ysnApplied = 1
		  AND ISNULL(strPricing, '') <> ''
	) PRICING ON ID.intInvoiceId = PRICING.intTransactionId
			 AND ID.intInvoiceDetailId = PRICING.intTransactionDetailId	
	
	UNION ALL

	SELECT intInvoiceId					= DF.intInvoiceId
		 , intInvoiceDetailId			= 9999999
		 , intCommentTypeId				= NULL
		 , dblTotalTax					= DF.dblTax
		 , dblQtyShipped				= ISNULL(QTY.dblTotalQty, 1)
		 , dblQtyOrdered				= 0
		 , dblDiscount					= 0
		 , dblComputedGrossPrice		= 0	
		 , dblPrice                 	= 0
		 , dblTotal						= DF.dblTax
		 , strVFDDocumentNumber			= NULL
		 , strUnitMeasure				= NULL
		 , strItemNo					= NULL
		 , strInvoiceComments			= NULL
		 , strItemType					= NULL
		 , strItemDescription			= TC.strTaxCode
		 , ysnListBundleSeparately		= NULL		 
		 , dblPercentFull				= NULL
		 , strAddonDetailKey			= NULL
		 , ysnAddonParent				= NULL
		 , strBOLNumberDetail			= NULL
		 , strSubFormula				= NULL	 	 
		 , dblServiceChargeAmountDue	= NULL
		 , dblServiceChargeAPR			= NULL
		 , intSCInvoiceId				= NULL
		 , intItemId					= NULL
	FROM dbo.tblARInvoiceDeliveryFee DF WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON DF.intTaxCodeId = TC.intTaxCodeId
	OUTER APPLY (
		SELECT dblTotalQty = SUM(dblQtyShipped)
		FROM tblARInvoiceDetail ID
		INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
		INNER JOIN tblSMTaxCodeRate TCR ON ITEM.intCategoryId = TCR.intGasolineItemCategoryId
		WHERE ID.intInvoiceId = DF.intInvoiceId
		GROUP BY ID.intInvoiceId
	) QTY
) INVOICEDETAIL ON INV.intInvoiceId = INVOICEDETAIL.intInvoiceId
LEFT JOIN tblSMCurrency CURRENCY ON INV.intCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN tblEMEntity SALESPERSON ON INV.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN tblEMEntity SHIPVIA ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN tblEMEntityLocation ENTITYLOCATION ON ENTITYLOCATION.intEntityLocationId = INV.intBillToLocationId
LEFT JOIN tblSMFreightTerms FREIGHT ON INV.intFreightTermId = FREIGHT.intFreightTermId
LEFT JOIN (
	SELECT intInvoiceId			= ID.intInvoiceId
		 , dblSSTTax 			= SUM(CASE WHEN UPPER(strTaxClass) = 'STATE SALES TAX (SST)' OR ID.dblComputedGrossPrice = 0 THEN dblAdjustedTax ELSE 0 END)
		 , dblNonSSTTax 		= SUM(CASE WHEN UPPER(strTaxClass) <> 'STATE SALES TAX (SST)' AND ID.dblComputedGrossPrice <> 0 THEN dblAdjustedTax ELSE 0 END)
		 , dblIncludePrice		= SUM(CASE WHEN ysnIncludeInvoicePrice = 1 THEN CASE WHEN ISNULL(ID.dblQtyShipped, 0) <> 0 THEN IDT.dblAdjustedTax / ID.dblQtyShipped ELSE 0 END ELSE 0 END)
		 , dblIncludePriceTotal	= SUM(CASE WHEN ysnIncludeInvoicePrice = 1 THEN dblAdjustedTax ELSE 0 END)
	FROM tblARInvoiceDetailTax IDT
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
	INNER JOIN tblSMTaxClass TCLASS ON IDT.intTaxClassId = TCLASS.intTaxClassId
	WHERE ((IDT.ysnTaxExempt = 1 AND ISNULL(ID.dblComputedGrossPrice, 0) <> 0) OR (IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0))
	  AND (NULL IS NULL OR ID.intItemId <> NULL)
	GROUP BY ID.intInvoiceId
) TOTALTAX ON TOTALTAX.intInvoiceId = INV.intInvoiceId
LEFT JOIN tblSMLogoPreference SMLP ON SMLP.intCompanyLocationId = INV.intCompanyLocationId AND (SMLP.ysnARInvoice = 1 OR SMLP.ysnDefault = 1)

--CUSTOMERS
SELECT intEntityCustomerId	= C.intEntityId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnIncludeEntityName	= C.ysnIncludeEntityName
	 , strCustomerComments  = EM.strMessage
INTO #CUSTOMERS
FROM tblARCustomer C
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM #INVOICES
) STAGING ON C.intEntityId = STAGING.intEntityCustomerId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strMessage
	FROM tblEMEntityMessage
	WHERE strMessageType = 'Invoice'
) EM ON C.intEntityId = EM.intEntityId

--SHIP TO FOR TM SITE
UPDATE I
SET strShipTo = CONSUMPTIONSITE.strSiteFullAddress
FROM #INVOICES I 
CROSS APPLY (
	SELECT TOP 1 strSiteFullAddress = ISNULL(RTRIM(S.strSiteAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(S.strCity), '') + ISNULL(RTRIM(', ' + S.strState), '') + ISNULL(RTRIM(', ' + S.strZipCode), '') + ISNULL(RTRIM(', ' + S.strCountry), '')
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
	WHERE intInvoiceId = I.intInvoiceId 
	  AND ID.intSiteId IS NOT NULL
) CONSUMPTIONSITE
WHERE I.strType = 'Tank Delivery'

--UPDATE CUSTOMER
UPDATE I
SET strCustomerNumber		= C.strCustomerNumber
  , strCustomerName			= C.strCustomerName
  , strCustomerComments		= C.strCustomerComments
  , ysnIncludeEntityName	= C.ysnIncludeEntityName
  , strBillTo				= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + I.strBillTo ELSE I.strBillTo END
  , strShipTo				= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + I.strShipTo ELSE I.strShipTo END
FROM #INVOICES I
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId

--RECIPE ITEM COUNT
UPDATE I
SET ysnHasRecipeItem = CAST(1 AS BIT) 
FROM #INVOICES I
INNER JOIN (
	SELECT intInvoiceId			= intInvoiceId
		 , intRecipeItemCount	= COUNT(*)
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE intRecipeId IS NOT NULL
	GROUP BY intInvoiceId
	HAVING COUNT(*) > 0
) RECIPEITEM ON RECIPEITEM.intInvoiceId = I.intInvoiceId 

--VFD ITEM COUNT
UPDATE I
SET ysnHasVFDDrugItem = CAST(1 AS BIT) 
FROM #INVOICES I
INNER JOIN (
	SELECT intInvoiceId			= intInvoiceId
		 , intVFDDrugItemCount	= COUNT(*) 
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE ISNULL(strVFDDocumentNumber, '') <> ''
	GROUP BY intInvoiceId
	HAVING COUNT(*) > 0
) VFDDRUGITEM ON VFDDRUGITEM.intInvoiceId = I.intInvoiceId
	 
--UPDATE NEGATIVE AMOUNTS
UPDATE I
SET dblInvoiceSubtotal	= dblInvoiceSubtotal * -1
  , dblShipping			= dblShipping * -1
  , dblTax				= dblTax * -1
  , dblInvoiceTotal		= dblInvoiceTotal * -1
  , dblQtyShipped		= dblQtyShipped * -1
  , dblQtyOrdered		= dblQtyOrdered * -1
  , dblTotalTax			= dblTotalTax * -1
  , dblItemPrice		= dblItemPrice * -1
FROM #INVOICES I
WHERE I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')

--COMMENTS
UPDATE I
SET strComments	= dbo.fnEliminateHTMLTags(I.strComments, 0)
FROM #INVOICES I
WHERE I.strComments IS NOT NULL
  AND I.strComments <> ''

--HEADER COMMENT
UPDATE I
SET strInvoiceHeaderComment	= ISNULL(HEADER.strMessage, I.strComments)
FROM #INVOICES I
OUTER APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Header'
	  AND M.strType = I.strType
	  AND M.strSource = I.strTransactionType
	ORDER BY M.[intDocumentMaintenanceId] DESC
		   , ISNULL(I.intEntityCustomerId, -10 * M.intDocumentMaintenanceId) DESC
		   , ISNULL(I.intCompanyLocationId, -100 * M.intDocumentMaintenanceId) DESC
) HEADER

--FOOTER COMMENT
UPDATE I
SET strInvoiceFooterComment	= ISNULL(FOOTER.strMessage, I.strFooterComments)
FROM #INVOICES I
OUTER APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Footer'
	  AND M.strType = I.strType
	  AND M.strSource = I.strTransactionType
	ORDER BY M.[intDocumentMaintenanceId] DESC
		   , ISNULL(I.intEntityCustomerId, -10 * M.intDocumentMaintenanceId) DESC
		   , ISNULL(I.intCompanyLocationId, -100 * M.intDocumentMaintenanceId) DESC
) FOOTER

--EMAIL COUNT
UPDATE I
SET ysnHasEmailSetup = CAST(1 AS BIT)
FROM #INVOICES I
CROSS APPLY (
	SELECT intEmailSetupCount	= COUNT(*)
	FROM tblEMEntity B
	INNER JOIN tblEMEntityToContact AS C ON B.intEntityId = C.intEntityId 
	INNER JOIN dbo.tblEMEntity AS D ON C.intEntityContactId = D.intEntityId
	WHERE ISNULL(D.strEmail, '') <> '' 
	  AND D.strEmailDistributionOption LIKE '%' + I.strTransactionType + '%'
	  AND B.intEntityId = I.intEntityCustomerId
	HAVING COUNT(*) > 0
) EMAILSETUP

--PROVISIONAL
UPDATE I
SET ysnHasProvisional	= CAST(1 AS BIT)
  , strProvisional		= PROVISIONAL.strProvisionalDescription
  , dblTotalProvisional	= PROVISIONAL.dblProvisionalTotal	 
FROM #INVOICES I
CROSS APPLY (
	SELECT TOP 1 strProvisionalDescription = 'Less Payment Received: Provisional Invoice No. ' + ISNULL(strInvoiceNumber, '') + ' dated ' + CONVERT(VARCHAR(10), dtmDate, 110)
			   , dblProvisionalTotal	   = dblPayment	    
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE strType = 'Provisional'
	  AND ysnProcessed = 1
	  AND intInvoiceId = I.intOriginalInvoiceId
) PROVISIONAL

--LOT NUMBERS
UPDATE I
SET strLotNumber = LOT.strLotNumbers
FROM #INVOICES I
CROSS APPLY (
	SELECT strLotNumbers = LEFT(strLotNumber, LEN(strLotNumber) - 1)
	FROM (
		SELECT CAST(ICLOT.strLotNumber AS VARCHAR(200)) + ', '
		FROM dbo.tblARInvoiceDetailLot IDL WITH(NOLOCK)		
		INNER JOIN dbo.tblICLot ICLOT WITH(NOLOCK) ON IDL.intLotId = ICLOT.intLotId
		WHERE IDL.intInvoiceDetailId = I.intInvoiceDetailId
		FOR XML PATH ('')
	) IDLOT (strLotNumber)
) LOT

--SERVICE CHARGE DETAILS
UPDATE I
SET dtmDueDate						= CASE WHEN I.strType = 'Service Charge' THEN I.dtmDueDate ELSE INVSC.dtmDueDate END
  , dtmDateSC						= INVSC.dtmDate
  , strServiceChareInvoiceNumber	= INVSC.strInvoiceNumber
  , strServiceChargeItem			= 'Service Charge on Past Due ' + CHAR(13) + 'Balance as of: ' +  CONVERT(VARCHAR(10), I.dtmDate, 101)
  , intDaysOld               		= DATEDIFF(DAYOFYEAR, CASE WHEN ISNULL(INVSC.ysnForgiven, 0) = 0 AND ISNULL(INVSC.ysnCalculated, 0) = 1 THEN INVSC.dtmDueDate ELSE INVSC.dtmCalculated END, CAST((CASE WHEN INVSC.ysnPaid = 1 THEN PAYMENT.dtmDatePaid ELSE I.dtmDate END) AS DATE))
  , strItem							= INVSC.strInvoiceNumber
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblARInvoice INVSC ON INVSC.intInvoiceId = ID.intSCInvoiceId
LEFT JOIN (
	SELECT dtmDatePaid		= MAX(dtmDatePaid)
		 , intInvoiceId		= ARPD.intInvoiceId
	FROM tblARPaymentDetail ARPD
	INNER JOIN tblARPayment ARP ON ARPD.intPaymentId = ARP.intPaymentId
	GROUP BY ARPD.intInvoiceId
) PAYMENT ON ID.intSCInvoiceId = PAYMENT.intInvoiceId
WHERE I.strInvoiceFormat IN ('By Customer Balance', 'By Invoice') 
  AND ID.intSCInvoiceId IS NOT NULL

--CONTRACT DETAILS
UPDATE I
SET dblContractBalance		= CD.dblBalance
  , strContractNumber		= CH.strContractNumber
  , strContractNoSeq		= CH.strContractNumber + ' / ' + CAST(CD.intContractSeq AS NVARCHAR(100))
  , strCustomerContract		= CH.strCustomerContract
  , strCustomerReference	= NULLIF(CH.strCustomerContract, '')
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
WHERE ID.intCommentTypeId IS NULL
  AND ID.intContractDetailId IS NOT NULL

--SALES ORDER
UPDATE I
SET strBOLNumber	= SO.strBOLNumber
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblSOSalesOrderDetail SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
WHERE I.strBOLNumber IS NULL
  AND ID.intSalesOrderDetailId IS NOT NULL

--RECIPE
UPDATE I
SET intRecipeId			= R.intRecipeId
  , intOneLinePrintId	= R.intOneLinePrintId
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblMFRecipe R ON ID.intRecipeId = R.intRecipeId
WHERE ID.intRecipeId IS NOT NULL

--SITE TMO
UPDATE I
SET intSiteId				= S.intSiteID
  , strSiteNumber			= (CASE WHEN S.intSiteNumber < 9 THEN '00' + CONVERT(VARCHAR, S.intSiteNumber) ELSE '0' + CONVERT(VARCHAR,intSiteNumber) END ) + ' - ' + S.strDescription
  , dblEstimatedPercentLeft	= S.dblEstimatedPercentLeft
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
WHERE ID.intSiteId IS NOT NULL

--LOAD SHIPMENT
UPDATE I
SET strCustomerReference	= CASE WHEN I.strCustomerReference IS NULL THEN NULLIF(LG.strCustomerReference, '') END
  , strSalesReference		= NULLIF(LG.strCustomerReference, '')
  , strPurchaseReference	= NULLIF(LG.strExternalLoadNumber, '')
  , strLoadNumber			= LG.strLoadNumber
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblLGLoadDetail LGD WITH (NOLOCK) ON ID.intLoadDetailId = LGD.intLoadDetailId
INNER JOIN tblLGLoad LG ON LG.intLoadId = LGD.intLoadId	
WHERE ID.intLoadDetailId IS NOT NULL

--SCALE TICKET
UPDATE I
SET strTicketNumber			= T.strTicketNumber
  , strTicketNumberDate		= T.strTicketNumber + ' - ' + CONVERT(NVARCHAR(50), T.dtmTicketDateTime, 101)
  , strTrailer				= SVT.strTrailerNumber
  , strSeals				= SCN.strSealNumber
  , strTruckDriver			= T.strTruckName
  , strCustomerReference	= CASE WHEN I.strCustomerReference IS NULL THEN NULLIF(LG.strCustomerReference, '') END
  , strSalesReference		= CASE WHEN I.strSalesReference IS NULL THEN NULLIF(LG.strCustomerReference, '') END
  , strPurchaseReference	= CASE WHEN I.strPurchaseReference IS NULL THEN NULLIF(LG.strExternalLoadNumber, '') END
  , strLoadNumber			= CASE WHEN I.strLoadNumber IS NULL THEN LG.strLoadNumber END
FROM #INVOICES I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
LEFT JOIN tblSMShipViaTrailer SVT ON T.intEntityShipViaTrailerId = SVT.intEntityShipViaTrailerId 
LEFT JOIN dbo.tblSCTicketSealNumber TSN ON T.intTicketId = TSN.intTicketId
LEFT JOIN tblSCSealNumber SCN ON SCN.intSealNumberId = TSN.intSealNumberId
LEFT JOIN tblLGLoad LG ON T.intLoadId = LG.intLoadId
WHERE ID.intTicketId IS NOT NULL

--XREF ITEM
UPDATE I
SET strItemNo				= XREF.strCustomerProduct
  , strItem					= ISNULL(XREF.strCustomerProduct, '') + ' - ' + ISNULL(XREF.strProductDescription, '')
  , strItemDescription		= XREF.strProductDescription
FROM #INVOICES I
CROSS APPLY (
	SELECT TOP 1 ICX.strCustomerProduct
			   , ICX.strProductDescription
	FROM tblICItemCustomerXref ICX
	WHERE ICX.intItemId = I.intItemId
	  AND ICX.intCustomerId = I.intEntityCustomerId
	  AND (ICX.intItemLocationId IS NULL OR (ICX.intItemLocationId IS NOT NULL AND ICX.intItemLocationId = I.intCompanyLocationId))
	ORDER BY ICX.intItemCustomerXrefId ASC
) XREF
WHERE I.intItemId IS NOT NULL

INSERT INTO tblARInvoiceReportStagingTable WITH (TABLOCK) (
	  intInvoiceId
	, intEntityCustomerId
	, intCompanyLocationId
	, strCompanyName
	, strCompanyAddress
	, strCompanyInfo
	, strCompanyPhoneNumber
	, strCompanyEmail
	, strType
	, strCustomerName
	, strCustomerNumber
	, strLocationName
	, dtmDate
	, dtmPostDate
	, strCurrency
	, strInvoiceNumber
	, strBillToLocationName
	, strBillTo
	, strShipTo
	, strSalespersonName
	, strPONumber
	, strBOLNumber
	, strShipVia
	, strTerm
	, dtmShipDate
	, dtmDueDate
	, strFreightTerm
	, strDeliverPickup
	, strComments
	, strInvoiceHeaderComment
	, strInvoiceFooterComment
	, dblInvoiceSubtotal
	, dblShipping
	, dblTax
	, dblInvoiceTotal
	, dblAmountDue
	, strItemNo
	, intInvoiceDetailId
	, dblContractBalance
	, strContractNumber
	, strContractNoSeq
	, strItem
	, strItemDescription
	, strUnitMeasure
	, dblQtyShipped
	, dblQtyOrdered
	, dblDiscount
	, dblTotalTax
	, dblPrice
	, dblItemPrice
	, strPaid
	, strPosted
	, strTransactionType
	, intRecipeId
	, intOneLinePrintId
	, strInvoiceComments
	, strPaymentComments
	, strCustomerComments
	, strItemType
	, dblTotalWeight
	, strVFDDocumentNumber
	, ysnHasEmailSetup
	, ysnHasRecipeItem
	, ysnHasVFDDrugItem
	, ysnHasProvisional
	, strProvisional
	, dblTotalProvisional
	, ysnPrintInvoicePaymentDetail
	, ysnListBundleSeparately
	, strTicketNumbers
	, strSiteNumber
	, dblEstimatedPercentLeft
	, dblPercentFull
	, strEntityContract
	, strTicketNumber
	, strTicketNumberDate
	, strCustomerReference
	, strSalesReference
	, strPurchaseReference
	, strLoadNumber
	, strTruckDriver
	, strTrailer
	, strSeals
	, strLotNumber
	, blbLogo
	, strAddonDetailKey
	, strBOLNumberDetail
	, ysnHasAddOnItem
	, intEntityUserId
	, strRequestId
	, strInvoiceFormat
	, blbSignature
	, ysnStretchLogo
	, strSubFormula
	, dtmCreated
	, strServiceChargeItem
	, intDaysOld
	, strServiceChareInvoiceNumber
	, dtmDateSC
	, dblServiceChargeAPR
	, strLogoType
)
SELECT 
	  intInvoiceId
	, intEntityCustomerId
	, intCompanyLocationId
	, strCompanyName
	, strCompanyAddress
	, strCompanyInfo
	, strCompanyPhoneNumber
	, strCompanyEmail
	, strType
	, strCustomerName
	, strCustomerNumber
	, strLocationName
	, dtmDate
	, dtmPostDate
	, strCurrency
	, strInvoiceNumber
	, strBillToLocationName
	, strBillTo
	, strShipTo
	, strSalespersonName
	, strPONumber
	, strBOLNumber
	, strShipVia
	, strTerm
	, dtmShipDate
	, dtmDueDate
	, strFreightTerm
	, strDeliverPickup
	, strComments
	, strInvoiceHeaderComment
	, strInvoiceFooterComment
	, dblInvoiceSubtotal
	, dblShipping
	, dblTax
	, dblInvoiceTotal
	, dblAmountDue
	, strItemNo
	, intInvoiceDetailId
	, dblContractBalance
	, strContractNumber
	, strContractNoSeq
	, strItem
	, strItemDescription
	, strUnitMeasure
	, dblQtyShipped
	, dblQtyOrdered
	, dblDiscount
	, dblTotalTax
	, dblPrice
	, dblItemPrice
	, strPaid
	, strPosted
	, strTransactionType
	, intRecipeId
	, intOneLinePrintId
	, strInvoiceComments
	, strPaymentComments
	, strCustomerComments
	, strItemType
	, dblTotalWeight
	, strVFDDocumentNumber
	, ysnHasEmailSetup
	, ysnHasRecipeItem
	, ysnHasVFDDrugItem
	, ysnHasProvisional
	, strProvisional
	, dblTotalProvisional
	, ysnPrintInvoicePaymentDetail
	, ysnListBundleSeparately
	, strTicketNumbers
	, strSiteNumber
	, dblEstimatedPercentLeft
	, dblPercentFull
	, strCustomerContract
	, strTicketNumber
	, strTicketNumberDate
	, strCustomerReference
	, strSalesReference
	, strPurchaseReference
	, strLoadNumber
	, strTruckDriver
	, strTrailer
	, strSeals
	, strLotNumber
	, blbLogo
	, strAddonDetailKey
	, strBOLNumberDetail
	, ysnHasAddOnItem
	, intEntityUserId
	, strRequestId
	, strInvoiceFormat
	, blbSignature
	, ysnStretchLogo
	, strSubFormula
	, dtmCreated
	, strServiceChargeItem
	, intDaysOld
	, strServiceChareInvoiceNumber
	, dtmDateSC
	, dblServiceChargeAPR
	, strLogoType
FROM #INVOICES

--UPDATE STAGING
UPDATE STAGING
SET intDetailCount 		= ISNULL(REGULARITEMS.intInvoiceDetailCount, 0) + ISNULL(SUBFORMULA.intInvoiceDetailCount, 0)
  , ysnHasSubFormula	= CASE WHEN ISNULL(SUBFORMULA.intInvoiceDetailCount, 0) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM tblARInvoiceReportStagingTable STAGING 
OUTER APPLY (
	SELECT COUNT(*) AS intInvoiceDetailCount
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE intInvoiceId = STAGING.intInvoiceId
	  AND ISNULL(strSubFormula, '') = ''
	GROUP BY intInvoiceId
) REGULARITEMS
OUTER APPLY (
	SELECT COUNT(DISTINCT strSubFormula) AS intInvoiceDetailCount
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
	WHERE intInvoiceId = STAGING.intInvoiceId
	  AND ISNULL(strSubFormula, '') <> ''
) SUBFORMULA
WHERE STAGING.intEntityUserId = @intEntityUserId 
  AND STAGING.strRequestId = @strRequestId 
  AND STAGING.strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 2', 'Format 2 - With Laid in Cost')
  
EXEC dbo.uspARInvoiceDetailTaxReport @intEntityUserId, @strRequestId

DELETE FROM tblARInvoiceTaxReportStagingTable 
WHERE intEntityUserId = @intEntityUserId 
  AND strRequestId = @strRequestId 
  AND ysnIncludeInvoicePrice = 1
  AND strInvoiceType = 'Transport Delivery'
  AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 2', 'Format 9 - Berry Oil', 'Format 2 - With Laid in Cost')