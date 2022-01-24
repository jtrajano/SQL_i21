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
	 , strType						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard'
     , strCustomerName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strCustomerNumber			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strLocationName				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , dtmDate						DATETIME		NOT NULL
	 , dtmPostDate					DATETIME		NOT NULL
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
	 , strItem						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strItemDescription			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
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

SELECT TOP 1 @intItemForFreightId = intItemForFreightId 
FROM tblTRCompanyPreference
ORDER BY intCompanyPreferenceId DESC
	  
--LOGO
SELECT TOP 1 @blbLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Header'
ORDER BY A.intAttachmentId DESC

--STRETCHED LOGO
SELECT TOP 1 @blbStretchedLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Stretched Header'
ORDER BY A.intAttachmentId DESC

SET @blbStretchedLogo = ISNULL(@blbStretchedLogo, @blbLogo)

--AR PREFERENCE
SELECT TOP 1 @ysnPrintInvoicePaymentDetail	= ysnPrintInvoicePaymentDetail
		   , @strInvoiceReportName			= strInvoiceReportName
FROM dbo.tblARCompanyPreference WITH (NOLOCK)
ORDER BY intCompanyPreferenceId DESC

--COMPANY INFO
SELECT TOP 1 @strCompanyFullAddress	= strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
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
	 , strFullAddress			= L.strAddress + CHAR(13) + char(10) + L.strCity + ', ' + L.strStateProvince + ', ' + L.strZipPostalCode + ', ' + L.strCountry 
INTO #LOCATIONS
FROM tblSMCompanyLocation L

DELETE FROM tblARInvoiceReportStagingTable 
WHERE	
(
   intEntityUserId = @intEntityUserId 
   AND strRequestId = @strRequestId 
   AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')
)
OR		dtmCreated < DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) 
OR		dtmCreated IS NULL

--MAIN QUERY
INSERT INTO #INVOICES WITH (TABLOCK) (
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
	 , intSiteId
	 , ysnIncludeEntityName
	 , strFooterComments
	 , intOriginalInvoiceId
)
SELECT intInvoiceId				= INV.intInvoiceId
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , intEntityCustomerId		= INV.intEntityCustomerId
	 , strCompanyName			= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE @strCompanyName END
	 , strCompanyAddress		= CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
									   WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
									   WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
								  END
	 , strCompanyInfo			= CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
									   WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
									   WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
								  END  + CHAR(10) + ISNULL(@strEmail,'')   + CHAR(10) + ISNULL(@strPhone,'')
	 , strCompanyPhoneNumber	= @strPhone
	 , strCompanyEmail			= @strEmail
	 , strType					= ISNULL(INV.strType, 'Standard')
     , strCustomerName			= CAST('' AS NVARCHAR(100))
	 , strCustomerNumber        = CAST('' AS NVARCHAR(100))
	 , strLocationName			= L.strLocationName
	 , dtmDate					= CAST(INV.dtmDate AS DATE)
	 , dtmPostDate				= INV.dtmPostDate
	 , strCurrency				= CURRENCY.strCurrency	 	 
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strBillToLocationName	= INV.strBillToLocationName
	 , strBillTo				= ISNULL(RTRIM(ENTITYLOCATION.strCheckPayeeName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(INV.strBillToCity), '') + ISNULL(RTRIM(', ' + INV.strBillToState), '') + ISNULL(RTRIM(', ' + INV.strBillToZipCode), '') + ISNULL(RTRIM(', ' + INV.strBillToCountry), '')
	 , strShipTo				= ISNULL(RTRIM(INV.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(INV.strShipToCity), '') + ISNULL(RTRIM(', ' + INV.strShipToState), '') + ISNULL(RTRIM(', ' + INV.strShipToZipCode), '') + ISNULL(RTRIM(', ' + INV.strShipToCountry), '')	 
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
	 , strDeliverPickup			= FREIGHT.strFobPoint
	 , strComments				= INV.strComments
	 , strInvoiceHeaderComment	= CAST('' AS NVARCHAR(MAX))
	 , strInvoiceFooterComment	= CAST('' AS NVARCHAR(MAX))
	 , dblInvoiceSubtotal		= (ISNULL(INV.dblInvoiceSubtotal, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END)
	 , dblShipping				= ISNULL(INV.dblShipping, 0)
	 , dblTax					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN (ISNULL(INVOICEDETAIL.dblTotalTax, 0) - CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) * INVOICEDETAIL.dblQtyShipped ELSE 0 END) ELSE NULL END
	 , dblInvoiceTotal			= ISNULL(INV.dblInvoiceTotal, 0) - ISNULL(INV.dblProvisionalAmount, 0) - CASE WHEN ISNULL(@strInvoiceReportName, 'Standard') <> 'Format 2 - Mcintosh' THEN 0 ELSE ISNULL(TOTALTAX.dblNonSSTTax, 0) END 
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , strItemNo				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strItemNo ELSE NULL END
	 , intInvoiceDetailId		= ISNULL(INVOICEDETAIL.intInvoiceDetailId, 0)
	 , dblContractBalance		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.dblBalance ELSE NULL END
	 , strContractNumber		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strContractNumber ELSE NULL END
	 , strContractNoSeq			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strContractNumber + ' - ' + CAST(INVOICEDETAIL.intContractSeq AS NVARCHAR(100)) ELSE NULL END
	 , strItem					= CASE WHEN ISNULL(INVOICEDETAIL.strItemNo, '') = '' THEN ISNULL(INVOICEDETAIL.strItemDescription, INVOICEDETAIL.strSCInvoiceNumber) ELSE LTRIM(RTRIM(INVOICEDETAIL.strItemNo)) + '-' + ISNULL(INVOICEDETAIL.strItemDescription, '') END
	 , strItemDescription		= INVOICEDETAIL.strItemDescription
	 , strUnitMeasure			= INVOICEDETAIL.strUnitMeasure
	 , dblQtyShipped			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblQtyShipped, 0) END
	 , dblQtyOrdered			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblQtyOrdered, 0) END
	 , dblDiscount				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									ISNULL(INVOICEDETAIL.dblDiscount, 0) / 100
								  ELSE NULL END
	 , dblTotalTax				= CASE WHEN ISNULL(@strInvoiceReportName, 'Standard') <> 'Format 2 - Mcintosh' THEN ISNULL(INV.dblTax, 0) - CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END ELSE ISNULL(TOTALTAX.dblSSTTax, 0) END
	 , dblPrice					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblPrice, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) ELSE 0 END ELSE NULL END
	 , dblItemPrice				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN (ISNULL(INVOICEDETAIL.dblTotal, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END) ELSE NULL END
	 , strPaid					= CASE WHEN ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strPosted				= CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END
	 , strTransactionType		= INV.strTransactionType
	 , intRecipeId				= INVOICEDETAIL.intRecipeId
	 , intOneLinePrintId		= ISNULL(INVOICEDETAIL.intOneLinePrintId, 1)
	 , strInvoiceComments		= INVOICEDETAIL.strInvoiceComments
	 , strPaymentComments		= L.strInvoiceComments
	 , strCustomerComments		= CAST('' AS NVARCHAR(MAX))
	 , strItemType				= INVOICEDETAIL.strItemType
	 , dblTotalWeight			= ISNULL(INV.dblTotalWeight, 0)
	 , strVFDDocumentNumber		= INVOICEDETAIL.strVFDDocumentNumber
	 , ysnHasEmailSetup			= CAST(0 AS BIT)
	 , ysnHasRecipeItem			= CAST(0 AS BIT)
	 , ysnHasVFDDrugItem        = CAST(0 AS BIT)
	 , ysnHasProvisional		= CAST(0 AS BIT)
	 , strProvisional			= CAST('' AS NVARCHAR(500))
	 , dblTotalProvisional		= CAST(0 AS NUMERIC(18, 6))
	 , ysnPrintInvoicePaymentDetail = @ysnPrintInvoicePaymentDetail
	 , ysnListBundleSeparately	= ISNULL(INVOICEDETAIL.ysnListBundleSeparately, CAST(0 AS BIT))
	 , strTicketNumbers			= CAST('' AS NVARCHAR(500))
	 , strSiteNumber			= INVOICEDETAIL.strSiteNumber
	 , dblEstimatedPercentLeft	= INVOICEDETAIL.dblEstimatedPercentLeft
	 , dblPercentFull			= INVOICEDETAIL.dblPercentFull
	 , strCustomerContract		= INVOICEDETAIL.strCustomerContract
	 , strTicketNumber 			= INVOICEDETAIL.strTicketNumber
	 , strTicketNumberDate		= INVOICEDETAIL.strTicketNumberDate
	 , strCustomerReference		= INVOICEDETAIL.strCustomerReference
	 , strSalesReference		= INVOICEDETAIL.strSalesReference
	 , strPurchaseReference		= INVOICEDETAIL.strPurchaseReference
	 , strLoadNumber			= INVOICEDETAIL.strLoadNumber
	 , strTruckDriver			= INVOICEDETAIL.strTruckName
	 , strTrailer				= INVOICEDETAIL.strTrailerNumber
	 , strSeals					= INVOICEDETAIL.strSealNumber
	 , strLotNumber				= CAST('' AS NVARCHAR(200))
	 , blbLogo                  = CASE WHEN ISNULL(SELECTEDINV.ysnStretchLogo, 0) = 1 THEN @blbStretchedLogo ELSE @blbLogo END
	 , strAddonDetailKey		= INVOICEDETAIL.strAddonDetailKey
	 , strBOLNumberDetail		= INVOICEDETAIL.strBOLNumberDetail
	 , ysnHasAddOnItem			= CAST(0 AS BIT)
	 , intEntityUserId			= @intEntityUserId
	 , strRequestId				= @strRequestId
	 , strInvoiceFormat			= SELECTEDINV.strInvoiceFormat
	 , blbSignature				= INV.blbSignature
	 , ysnStretchLogo			= ISNULL(SELECTEDINV.ysnStretchLogo, 0)
	 , strSubFormula			= INVOICEDETAIL.strSubFormula	
	 , dtmCreated				= GETDATE()
	 , strServiceChargeItem		= CASE WHEN SELECTEDINV.strInvoiceFormat IN ('By Customer Balance', 'By Invoice') 
										THEN 'Service Charge on Past Due ' + CHAR(13) + 'Balance as of: ' +  CONVERT(VARCHAR(10), INV.dtmDate, 101)
										ELSE ''
								  END
	 , intDaysOld               = CASE WHEN SELECTEDINV.strInvoiceFormat IN ('By Customer Balance', 'By Invoice') 
										THEN DATEDIFF(DAYOFYEAR, INVOICEDETAIL.dtmToCalculate, CAST(INV.dtmDate AS DATE))
										ELSE 0
								  END
	 , strServiceChareInvoiceNumber = INVOICEDETAIL.strSCInvoiceNumber
	 , dtmDateSC				 =  INVOICEDETAIL.dtmDateSC
	 , intSiteId				= INVOICEDETAIL.intSiteID
	 , ysnIncludeEntityName		= CAST(0 AS BIT)
	 , strFooterComments		= INV.strFooterComments
	 , intOriginalInvoiceId		= INV.intOriginalInvoiceId
FROM dbo.tblARInvoice INV
INNER JOIN #STANDARDINVOICES SELECTEDINV ON INV.intInvoiceId = SELECTEDINV.intInvoiceId
INNER JOIN #LOCATIONS L ON INV.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN tblSMTerm TERM ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT intInvoiceId				= ID.intInvoiceId
	     , intInvoiceDetailId		= ID.intInvoiceDetailId
		 , intCommentTypeId			= ID.intCommentTypeId
		 , dblTotalTax				= CASE WHEN ISNULL(ID.dblComputedGrossPrice, 0) = 0 THEN ID.dblTotalTax ELSE 0 END
		 , dblQtyShipped			= ID.dblQtyShipped
		 , dblQtyOrdered			= ID.dblQtyOrdered
		 , dblDiscount				= ID.dblDiscount
		 , dblComputedGrossPrice	= ID.dblComputedGrossPrice	
		 , dblPrice                 = CASE WHEN ISNULL(PRICING.strPricing, '') = 'MANUAL OVERRIDE' THEN ID.dblPrice ELSE ISNULL(NULLIF(ID.dblComputedGrossPrice, 0), ID.dblPrice) END
		 , dblTotal					= ID.dblTotal
		 , strVFDDocumentNumber		= ID.strVFDDocumentNumber
		 , strUnitMeasure			= UM.strUnitMeasure
		 , intContractSeq			= CD.intContractSeq
		 , dblBalance				= CD.dblBalance
		 , strContractNumber		= CH.strContractNumber
		 , strCustomerContract		= CH.strCustomerContract
		 , strItemNo				= ITEM.strItemNo
		 , strInvoiceComments		= ITEM.strInvoiceComments
		 , strItemType				= ITEM.strType
		 , strItemDescription		= CASE WHEN ISNULL(ID.strItemDescription, '') <> '' THEN ID.strItemDescription ELSE ITEM.strDescription END
		 , strBOLNumber				= SO.strBOLNumber
		 , ysnListBundleSeparately	= ITEM.ysnListBundleSeparately
		 , intRecipeId				= RECIPE.intRecipeId
		 , intOneLinePrintId		= RECIPE.intOneLinePrintId
		 , intSiteID				= [SITE].intSiteID
		 , strSiteNumber			= (CASE WHEN [SITE].intSiteNumber < 9 THEN '00' + CONVERT(VARCHAR, [SITE].intSiteNumber) ELSE '0' + CONVERT(VARCHAR,intSiteNumber) END ) + ' - ' + [SITE].strDescription
		 , dblEstimatedPercentLeft	= [SITE].dblEstimatedPercentLeft
		 , strTicketNumber			= SC.strTicketNumber
		 , strTicketNumberDate		= SC.strTicketNumber + ' - ' + CONVERT(NVARCHAR(50), SC.dtmTicketDateTime, 101) 
		 , strTrailerNumber			= SVT.strTrailerNumber
		 , strSealNumber			= SCN.strSealNumber
		 , strCustomerReference		= ISNULL(NULLIF(SC.strCustomerReference,''), ISNULL(NULLIF(CH.strCustomerContract,''), ISNULL(LGLOAD.strCustomerReference,'')))
		 , strSalesReference		= ISNULL(NULLIF(LGLOAD.strCustomerReference, ''), LGS.strCustomerReference)
	 	 , strPurchaseReference		= ISNULL(NULLIF(LGLOAD.strExternalLoadNumber, ''), LGS.strExternalLoadNumber)
		 , strLoadNumber			= ISNULL(LGLOAD.strLoadNumber, LGS.strLoadNumber)
		 , strTruckName				= SC.strTruckName
		 , dblPercentFull			= ID.dblPercentFull
		 , strAddonDetailKey		= NULL
		 , ysnAddonParent			= CAST(0 AS BIT)
		 , strBOLNumberDetail		= ID.strBOLNumberDetail
		 , strSubFormula			= ID.strSubFormula
		 , strSCInvoiceNumber		= INVSC.strInvoiceNumber
		 , dtmDateSC				= INVSC.dtmDate
		 , dtmToCalculate			= CASE WHEN ISNULL(INVSC.ysnForgiven, 0) = 0 AND ISNULL(INVSC.ysnCalculated, 0) = 1 THEN INVSC.dtmDueDate ELSE INVSC.dtmCalculated END		 
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN tblICItem ITEM WITH (NOLOCK) ON ID.intItemId = ITEM.intItemId
	LEFT JOIN tblARInvoice INVSC ON INVSC.intInvoiceId = ID.intSCInvoiceId
	LEFT JOIN tblICItemUOM IUOM ON ID.intItemUOMId = IUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId
	LEFT JOIN tblSOSalesOrderDetail SOD WITH (NOLOCK) ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	LEFT JOIN tblSOSalesOrder SO WITH (NOLOCK) ON SOD.intSalesOrderId = SO.intSalesOrderId	
	LEFT JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = ID.intContractDetailId
	LEFT JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId		
	LEFT JOIN tblMFRecipe RECIPE WITH (NOLOCK) ON ID.intRecipeId = RECIPE.intRecipeId	
	LEFT JOIN tblTMSite [SITE] ON [SITE].intSiteID = ID.intSiteId
	LEFT JOIN tblSCTicket SC ON ID.intTicketId = SC.intTicketId
	LEFT JOIN tblSMShipViaTrailer SVT ON SC.intEntityShipViaTrailerId = SVT.intEntityShipViaTrailerId 
	LEFT JOIN dbo.tblSCTicketSealNumber TSN ON SC.intTicketId = TSN.intTicketId
	LEFT JOIN tblSCSealNumber SCN ON SCN.intSealNumberId = TSN.intSealNumberId
	LEFT JOIN tblLGLoad LGS ON SC.intLoadId = LGS.intLoadId	
	LEFT JOIN tblLGLoadDetail LGDETAIL WITH (NOLOCK) ON ID.intLoadDetailId = LGDETAIL.intLoadDetailId
	LEFT JOIN dbo.tblLGLoad LGLOAD ON LGLOAD.intLoadId = LGDETAIL.intLoadId	
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
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceId
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
	INNER JOIN tblSMTaxClass TCLASS ON IDT.intTaxClassId = TCLASS.intTaxClassId
	WHERE ((IDT.ysnTaxExempt = 1 AND ISNULL(ID.dblComputedGrossPrice, 0) <> 0) OR (IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0))
	  AND ID.intItemId <> @intItemForFreightId
	GROUP BY ID.intInvoiceId
) TOTALTAX ON TOTALTAX.intInvoiceId = INV.intInvoiceId

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

--SCALE TICKETS
UPDATE I
SET strTicketNumbers = SCALETICKETS.strTicketNumbers
FROM #INVOICES I
CROSS APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
		INNER JOIN (
			SELECT intTicketId
				 , strTicketNumber 
			FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intTicketId IS NOT NULL
		  AND I.intInvoiceId = ID.intInvoiceId
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS
	 
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
CROSS APPLY (
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
CROSS APPLY (
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

INSERT INTO tblARInvoiceReportStagingTable WITH (TABLOCK) (
	   intInvoiceId
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
)
SELECT intInvoiceId
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
  AND STAGING.strInvoiceFormat <> 'Format 1 - MCP' 
  
EXEC dbo.uspARInvoiceDetailTaxReport @intEntityUserId, @strRequestId

DELETE FROM tblARInvoiceTaxReportStagingTable 
WHERE intEntityUserId = @intEntityUserId 
  AND strRequestId = @strRequestId 
  AND ysnIncludeInvoicePrice = 1
  AND strInvoiceType = 'Transport Delivery'
  AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')