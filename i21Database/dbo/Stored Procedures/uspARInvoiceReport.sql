CREATE PROCEDURE [dbo].[uspARInvoiceReport]
	  @tblInvoiceReport		AS InvoiceReportTable READONLY
	, @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @blbLogo						VARBINARY (MAX) = NULL
      , @blbStretchedLogo				VARBINARY (MAX) = NULL
	  , @ysnPrintInvoicePaymentDetail	BIT = 0
	  , @strInvoiceReportName			NVARCHAR(100) = NULL
	  , @strCompanyName					NVARCHAR(200) = NULL
	  , @strAddress						NVARCHAR(200) = NULL
	  , @strCity						NVARCHAR(200) = NULL
	  , @strState						NVARCHAR(200) = NULL
	  , @strZip							NVARCHAR(200) = NULL
	  , @strCountry						NVARCHAR(200) = NULL
	  , @strPhone						NVARCHAR(200) = NULL
	  , @strEmail						NVARCHAR(200) = NULL

--LOGO
SELECT TOP 1 @blbLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Header'

--LOGO
SELECT TOP 1 @blbStretchedLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Stretched Header'

--AR PREFERENCE
SELECT TOP 1 @ysnPrintInvoicePaymentDetail	= ysnPrintInvoicePaymentDetail
		   , @strInvoiceReportName			= strInvoiceReportName
FROM dbo.tblARCompanyPreference WITH (NOLOCK)

--COMPANY INFO
SELECT TOP 1 @strCompanyName = strCompanyName 
		   , @strAddress	 = strAddress
		   , @strCity		 = strCity
		   , @strState		 = strState
		   , @strZip		 = strZip
		   , @strCountry	 = strCountry
		   , @strPhone		 = strPhone
		   , @strEmail		 = strEmail
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

SET @blbStretchedLogo = ISNULL(@blbStretchedLogo, @blbLogo)

DELETE FROM tblARInvoiceReportStagingTable WHERE dtmCreated < DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) OR dtmCreated IS NULL
DELETE FROM tblARInvoiceReportStagingTableCopy WHERE dtmCreated < DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) OR dtmCreated IS NULL

DELETE FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')
INSERT INTO tblARInvoiceReportStagingTable (
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
)
SELECT intInvoiceId				= INV.intInvoiceId
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , strCompanyName			= CASE WHEN [LOCATION].strUseLocationAddress = 'Letterhead' THEN '' ELSE @strCompanyName END
	 , strCompanyAddress		= CASE WHEN ISNULL([LOCATION].strUseLocationAddress, '') = '' OR [LOCATION].strUseLocationAddress = 'No' OR [LOCATION].strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, @strAddress, @strCity, @strState, @strZip, @strCountry, NULL, 0)
									   WHEN [LOCATION].strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, [LOCATION].strAddress, [LOCATION].strCity, [LOCATION].strStateProvince, [LOCATION].strZipPostalCode, [LOCATION].strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Letterhead'
											THEN ''
								  END
	 , strCompanyInfo			= CASE WHEN [LOCATION].strUseLocationAddress IS NULL OR [LOCATION].strUseLocationAddress = 'No' OR [LOCATION].strUseLocationAddress = '' OR [LOCATION].strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, @strAddress, @strCity, @strState, @strZip, @strCountry, NULL, 0)
									   WHEN [LOCATION].strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, [LOCATION].strAddress, [LOCATION].strCity, [LOCATION].strStateProvince, [LOCATION].strZipPostalCode, [LOCATION].strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN [LOCATION].strUseLocationAddress = 'Letterhead'
											THEN ''
								  END  + CHAR(10) + ISNULL(@strEmail,'')   + CHAR(10) + ISNULL(@strPhone,'')
	 , strCompanyPhoneNumber	= @strPhone
	 , strCompanyEmail			= @strEmail
	 , strType					= ISNULL(INV.strType, 'Standard')
     , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber        = CUSTOMER.strCustomerNumber
	 , strLocationName			= [LOCATION].strLocationName
	 , dtmDate					= CAST(INV.dtmDate AS DATE)
	 , dtmPostDate				= INV.dtmPostDate
	 , strCurrency				= CURRENCY.strCurrency	 	 
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strBillToLocationName	= INV.strBillToLocationName
	 , strBillTo				= dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strShipTo				= CASE WHEN INV.strType = 'Tank Delivery' AND CONSUMPTIONSITE.intSiteId IS NOT NULL 
	 									THEN CONSUMPTIONSITE.strSiteFullAddress
										ELSE dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
								  END
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
	 , strComments				= dbo.fnEliminateHTMLTags(INV.strComments, 0)
	 , strInvoiceHeaderComment	= INV.strComments
	 , strInvoiceFooterComment	= INV.strFooterComments
	 , dblInvoiceSubtotal		= (ISNULL(INV.dblInvoiceSubtotal, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END) * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
	 , dblShipping				= ISNULL(INV.dblShipping, 0) * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
	 , dblTax					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN (ISNULL(INVOICEDETAIL.dblTotalTax, 0) - CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) * INVOICEDETAIL.dblQtyShipped ELSE 0 END) * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) ELSE NULL END
	 , dblInvoiceTotal			= (dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) * ISNULL(INV.dblInvoiceTotal, 0)) - ISNULL(INV.dblProvisionalAmount, 0) - CASE WHEN ISNULL(@strInvoiceReportName, 'Standard') <> 'Format 2 - Mcintosh' THEN 0 ELSE ISNULL(TOTALTAX.dblNonSSTTax, 0) END 
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , strItemNo				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strItemNo ELSE NULL END
	 , intInvoiceDetailId		= ISNULL(INVOICEDETAIL.intInvoiceDetailId, 0)
	 , dblContractBalance		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.dblBalance ELSE NULL END
	 , strContractNumber		= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strContractNumber ELSE NULL END
	 , strContractNoSeq			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN INVOICEDETAIL.strContractNumber + ' - ' + CAST(INVOICEDETAIL.intContractSeq AS NVARCHAR(100)) ELSE NULL END
	 , strItem					= CASE WHEN ISNULL(INVOICEDETAIL.strItemNo, '') = '' THEN ISNULL(INVOICEDETAIL.strItemDescription, INVOICEDETAIL.strSCInvoiceNumber) ELSE LTRIM(RTRIM(INVOICEDETAIL.strItemNo)) + '-' + ISNULL(INVOICEDETAIL.strItemDescription, '') END
	 , strItemDescription		= INVOICEDETAIL.strItemDescription
	 , strUnitMeasure			= INVOICEDETAIL.strUnitMeasure
	 , dblQtyShipped			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblQtyShipped, 0) * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) ELSE NULL END
	 , dblQtyOrdered			= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblQtyOrdered, 0) * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) ELSE NULL END
	 , dblDiscount				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN
									ISNULL(INVOICEDETAIL.dblDiscount, 0) / 100
								  ELSE NULL END
	 , dblTotalTax				= dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) * CASE WHEN ISNULL(@strInvoiceReportName, 'Standard') <> 'Format 2 - Mcintosh' THEN ISNULL(INV.dblTax, 0) - CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END ELSE ISNULL(TOTALTAX.dblSSTTax, 0) END
	 , dblPrice					= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN ISNULL(INVOICEDETAIL.dblPrice, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) ELSE 0 END ELSE NULL END
	 , dblItemPrice				= CASE WHEN ISNULL(INVOICEDETAIL.intCommentTypeId, 0) = 0 THEN (ISNULL(INVOICEDETAIL.dblTotal, 0) + CASE WHEN INV.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END) * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) ELSE NULL END
	 , strPaid					= CASE WHEN ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strPosted				= CASE WHEN INV.ysnPosted = 1 THEN 'Yes' ELSE 'No' END
	 , strTransactionType		= INV.strTransactionType
	 , intRecipeId				= INVOICEDETAIL.intRecipeId
	 , intOneLinePrintId		= ISNULL(INVOICEDETAIL.intOneLinePrintId, 1)
	 , strInvoiceComments		= INVOICEDETAIL.strInvoiceComments
	 , strPaymentComments		= [LOCATION].strInvoiceComments
	 , strCustomerComments		= CUSTOMERCOMMENTS.strCustomerComments
	 , strItemType				= INVOICEDETAIL.strItemType
	 , dblTotalWeight			= ISNULL(INV.dblTotalWeight, 0)
	 , strVFDDocumentNumber		= INVOICEDETAIL.strVFDDocumentNumber
	 , ysnHasEmailSetup			= CASE WHEN (ISNULL(EMAILSETUP.intEmailSetupCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasRecipeItem			= CASE WHEN (ISNULL(RECIPEITEM.intRecipeItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasVFDDrugItem        = CASE WHEN (ISNULL(VFDDRUGITEM.intVFDDrugItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , ysnHasProvisional		= CASE WHEN (ISNULL(PROVISIONAL.strProvisionalDescription, '')) <> '' THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , strProvisional			= PROVISIONAL.strProvisionalDescription
	 , dblTotalProvisional		= PROVISIONAL.dblProvisionalTotal	 
	 , ysnPrintInvoicePaymentDetail = @ysnPrintInvoicePaymentDetail
	 , ysnListBundleSeparately	= ISNULL(INVOICEDETAIL.ysnListBundleSeparately, CONVERT(BIT, 0))
	 , strTicketNumbers			= SCALETICKETS.strTicketNumbers
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
	 , strLotNumber				= INVOICEDETAIL.strLotNumber
	 , blbLogo                  = CASE WHEN ISNULL(SELECTEDINV.ysnStretchLogo, 0) = 1 THEN @blbStretchedLogo ELSE @blbLogo END
	 , strAddonDetailKey		= INVOICEDETAIL.strAddonDetailKey
	 , strBOLNumberDetail		= INVOICEDETAIL.strBOLNumberDetail
	 , ysnHasAddOnItem			= CONVERT(BIT, 0)
	 , intEntityUserId			= @intEntityUserId
	 , strRequestId				= @strRequestId
	 , strInvoiceFormat			= SELECTEDINV.strInvoiceFormat
	 , blbSignature				= INV.blbSignature
	 , ysnStretchLogo			= ISNULL(SELECTEDINV.ysnStretchLogo, 0)
	 , strSubFormula			= INVOICEDETAIL.strSubFormula
	 , dtmCreated				= GETDATE()
FROM dbo.tblARInvoice INV WITH (NOLOCK)
INNER JOIN @tblInvoiceReport SELECTEDINV ON INV.intInvoiceId = SELECTEDINV.intInvoiceId
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
		 , strInvoiceComments
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) [LOCATION] ON INV.intCompanyLocationId = [LOCATION].intCompanyLocationId
INNER JOIN (
	SELECT intTermID
		 , strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) TERM ON INV.intTermId = TERM.intTermID
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
		 , strSCInvoiceNumber		= ID.strSCInvoiceNumber
		 , strUnitMeasure			= UOM.strUnitMeasure
		 , intContractSeq			= CONTRACTS.intContractSeq
		 , dblBalance				= CONTRACTS.dblBalance
		 , strContractNumber		= CONTRACTS.strContractNumber
		 , strCustomerContract		= CONTRACTS.strCustomerContract
		 , strItemNo				= ITEM.strItemNo
		 , strInvoiceComments		= ITEM.strInvoiceComments
		 , strItemType				= ITEM.strType
		 , strItemDescription		= CASE WHEN ISNULL(ID.strItemDescription, '') <> '' THEN ID.strItemDescription ELSE ITEM.strDescription END
		 , strBOLNumber				= SO.strBOLNumber
		 , ysnListBundleSeparately	= ITEM.ysnListBundleSeparately
		 , intRecipeId				= RECIPE.intRecipeId
		 , intOneLinePrintId		= RECIPE.intOneLinePrintId
		 , intSiteID				= [SITE].intSiteID
		 , strSiteNumber			= [SITE].strSiteNumber
		 , dblEstimatedPercentLeft	= [SITE].dblEstimatedPercentLeft
		 , strTicketNumber			= SCALE.strTicketNumber
		 , strTicketNumberDate		= SCALE.strTicketNumber + ' - ' + CONVERT(NVARCHAR(50), SCALE.dtmTicketDateTime, 101) 
		 , strTrailerNumber			= SCALE.strTrailerNumber
		 , strSealNumber			= SCALE.strSealNumber
		 , strCustomerReference		= ISNULL(NULLIF(SCALE.strScaleCustomerReference,''), ISNULL(NULLIF(CONTRACTS.strCustomerContract,''), ISNULL(LGLOAD.strCustomerReference,'')))
		 , strSalesReference		= ISNULL(NULLIF(LGLOAD.strCustomerReference, ''), SCALE.strCustomerReference)
	 	 , strPurchaseReference		= ISNULL(NULLIF(LGLOAD.strExternalLoadNumber, ''), SCALE.strExternalLoadNumber)
		 , strLoadNumber			= ISNULL(LGLOAD.strLoadNumber, SCALE.strLoadNumber)
		 , strTruckName				= SCALE.strTruckName
		 , dblPercentFull			= ID.dblPercentFull
		 , strAddonDetailKey		= NULL
		 , ysnAddonParent			= CAST(0 AS BIT)
		 , strBOLNumberDetail		= ID.strBOLNumberDetail
		 , strLotNumber				= LOT.strLotNumbers
		 , strSubFormula			= ID.strSubFormula
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
		FROM dbo.vyuARItemUOM WITH (NOLOCK)
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
		SELECT CH.intContractHeaderId			 
			 , CD.intContractDetailId
			 , CD.intContractSeq
			 , CD.dblBalance
			 , strContractNumber
			 , strCustomerContract
		FROM dbo.tblCTContractHeader CH WITH (NOLOCK)
		LEFT JOIN (
			SELECT intContractHeaderId
				 , intContractDetailId
				 , intContractSeq
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
		SELECT intSiteID
		     , strSiteNumber = (CASE WHEN intSiteNumber < 9 THEN '00' + CONVERT(VARCHAR,intSiteNumber) ELSE '0' + CONVERT(VARCHAR,intSiteNumber) END ) + ' - ' + strDescription
			 , dblEstimatedPercentLeft 
		FROM tblTMSite
	) [SITE] ON [SITE].intSiteID = ID.intSiteId
	LEFT JOIN (
		SELECT SC.intTicketId
			 , SC.strTicketNumber
			 , LG.strCustomerReference
			 , strScaleCustomerReference = SC.strCustomerReference
			 , SC.strTruckName
			 , LG.strLoadNumber
			 , SC.dtmTicketDateTime
			 , SVT.strTrailerNumber
			 , SCN.strSealNumber
			 , LG.strExternalLoadNumber
		FROM dbo.tblSCTicket SC WITH (NOLOCK)
		LEFT JOIN dbo.tblSMShipViaTrailer SVT ON SC.intEntityShipViaTrailerId = SVT.intEntityShipViaTrailerId 
		LEFT JOIN dbo.tblSCTicketSealNumber TSN ON SC.intTicketId = TSN.intTicketId
		LEFT JOIN tblSCSealNumber SCN ON SCN.intSealNumberId = TSN.intSealNumberId
		LEFT JOIN dbo.tblLGLoad LG ON SC.intLoadId = LG.intLoadId
	) SCALE ON ID.intTicketId = SCALE.intTicketId
	LEFT JOIN (
		SELECT LD.intLoadDetailId
			 , L.strLoadNumber
			 , L.strCustomerReference
			 , L.strExternalLoadNumber
		FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
		INNER JOIN dbo.tblLGLoad L ON LD.intLoadId = L.intLoadId
	) LGLOAD ON ID.intLoadDetailId = LGLOAD.intLoadDetailId
	OUTER APPLY (
		SELECT strLotNumbers = LEFT(strLotNumber, LEN(strLotNumber) - 1)
		FROM (
			SELECT CAST(ICLOT.strLotNumber AS VARCHAR(200)) + ', '
			FROM dbo.tblARInvoiceDetailLot IDL WITH(NOLOCK)		
			INNER JOIN dbo.tblICLot ICLOT WITH(NOLOCK) ON IDL.intLotId = ICLOT.intLotId
			WHERE IDL.intInvoiceDetailId = ID.intInvoiceDetailId
			FOR XML PATH ('')
		) IDLOT (strLotNumber)
	) LOT
	LEFT JOIN (
		SELECT DISTINCT
			   intTransactionId
			 , intTransactionDetailId
			 , strPricing
		FROM dbo.tblARPricingHistory WITH (NOLOCK)
		WHERE ysnApplied = 1
	) PRICING ON ID.intInvoiceId = PRICING.intTransactionId
			 AND ID.intInvoiceDetailId = PRICING.intTransactionDetailId	
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
) SHIPVIA ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
		 , strFobPoint
	FROM dbo.tblSMFreightTerms WITH (NOLOCK)
) FREIGHT ON INV.intFreightTermId = FREIGHT.intFreightTermId
OUTER APPLY (
	SELECT dblSSTTax 			= SUM(CASE WHEN UPPER(strTaxClass) = 'STATE SALES TAX (SST)' OR dblComputedGrossPrice = 0 THEN dblAdjustedTax ELSE 0 END)
		 , dblNonSSTTax 		= SUM(CASE WHEN UPPER(strTaxClass) <> 'STATE SALES TAX (SST)' AND dblComputedGrossPrice <> 0 THEN dblAdjustedTax ELSE 0 END)
		 , dblIncludePrice		= SUM(CASE WHEN ysnIncludeInvoicePrice = 1 THEN dblTaxPerQty ELSE 0 END)
		 , dblIncludePriceTotal	= SUM(CASE WHEN ysnIncludeInvoicePrice = 1 THEN dblAdjustedTax ELSE 0 END)
	FROM vyuARTaxDetailReport
	WHERE strTaxTransactionType = 'Invoice'
	  AND intTransactionId = INV.intInvoiceId	  
) TOTALTAX
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
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)
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
OUTER APPLY (
	SELECT strCustomerComments = LEFT(strMessage, LEN(strMessage) - 1)
	FROM (
		SELECT CAST(A.strMessage AS VARCHAR(MAX))  + ', '
		FROM dbo.tblEMEntityMessage A WITH(NOLOCK)
		WHERE A.intEntityId = INV.intEntityCustomerId
		  AND A.strMessageType = 'Invoice'
		FOR XML PATH ('')
	) CC (strMessage)
) CUSTOMERCOMMENTS

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

INSERT INTO tblARInvoiceReportStagingTableCopy (
	  intInvoiceId
	, intCompanyLocationId
	, intEntityCustomerId
	, intEntityUserId
	, intInvoiceDetailId
	, intTaxCodeId
	, intDetailCount
	, intRecipeId
	, intOneLinePrintId
	, intTruckDriverId
	, intBillToLocationId
	, intShipToLocationId
	, intTermId
	, intShipViaId
	, intSiteId
	, intItemId
	, intTicketId
	, strRequestId
	, strCompanyName
	, strCompanyAddress
	, strCompanyInfo
	, strCompanyPhoneNumber
	, strCompanyEmail
	, strCompanyLocation
	, strRemitToAddress
	, strType
	, strTicketType
	, strCustomerName
	, strCustomerNumber
	, strLocationName
	, strLocationNumber
	, strCurrency
	, strInvoiceNumber
	, strSalesOrderNumber
	, strBillToLocationName
	, strShipToLocationName
	, strBillTo
	, strShipTo
	, strSalespersonName
	, strPONumber
	, strBOLNumber
	, strPaymentInfo
	, strShipVia
	, strTerm
	, strFreightTerm
	, strDeliverPickup
	, strInvoiceHeaderComment
	, strInvoiceFooterComment
	, strItemNo
	, strContractNumber
	, strItem
	, strItemDescription
	, strUnitMeasure
	, strUnitMeasureSymbol
	, strPaid
	, strPosted
	, strTaxCode
	, strTransactionType
	, strInvoiceComments
	, strItemComments
	, strPaymentComments
	, strCustomerComments
	, strItemType
	, strVFDDocumentNumber
	, strBOLNumberDetail
	, strProvisional
	, strTicketNumbers
	, strTicketNumber
	, strTicketNumberDate
	, strCustomerReference
	, strSalesReference
	, strPurchaseReference
	, strLoadNumber
	, strEntityContract
	, strSiteNumber
	, strAddonDetailKey
	, strTruckDriver
	, strSource
	, strOrigin
	, strComments
	, strContractNo
	, strContractNoSeq
	, strInvoiceFormat
	, strBargeNumber
	, strCommodity
	, strSubFormula
	, strTrailer
	, strSeals
	, strLotNumber
	, dblInvoiceSubtotal
	, dblShipping
	, dblTax
	, dblInvoiceTotal
	, dblAmountDue
	, dblContractBalance
	, dblQtyShipped
	, dblQtyOrdered
	, dblDiscount
	, dblTotalTax
	, dblPrice
	, dblItemPrice
	, dblTaxDetail
	, dblTotalWeight
	, dblTotalProvisional
	, dblEstimatedPercentLeft
	, dblPercentFull
	, dblInvoiceTax
	, dblPriceWithTax
	, dblTotalPriceWithTax
	, ysnHasEmailSetup
	, ysnHasRecipeItem
	, ysnHasVFDDrugItem
	, ysnHasProvisional
	, ysnPrintInvoicePaymentDetail
	, ysnListBundleSeparately
	, ysnHasAddOnItem
	, ysnStretchLogo
	, ysnHasSubFormula
	, dtmDate
	, dtmPostDate
	, dtmShipDate
	, dtmDueDate
	, dtmLoadedDate
	, dtmScaleDate
	, blbLogo
	, blbSignature
	, dtmCreated
)
SELECT 
	  intInvoiceId
	, intCompanyLocationId
	, intEntityCustomerId
	, intEntityUserId
	, intInvoiceDetailId
	, intTaxCodeId
	, intDetailCount
	, intRecipeId
	, intOneLinePrintId
	, intTruckDriverId
	, intBillToLocationId
	, intShipToLocationId
	, intTermId
	, intShipViaId
	, intSiteId
	, intItemId
	, intTicketId
	, strRequestId
	, strCompanyName
	, strCompanyAddress
	, strCompanyInfo
	, strCompanyPhoneNumber
	, strCompanyEmail
	, strCompanyLocation
	, strRemitToAddress
	, strType
	, strTicketType
	, strCustomerName
	, strCustomerNumber
	, strLocationName
	, strLocationNumber
	, strCurrency
	, strInvoiceNumber
	, strSalesOrderNumber
	, strBillToLocationName
	, strShipToLocationName
	, strBillTo
	, strShipTo
	, strSalespersonName
	, strPONumber
	, strBOLNumber
	, strPaymentInfo
	, strShipVia
	, strTerm
	, strFreightTerm
	, strDeliverPickup
	, strInvoiceHeaderComment
	, strInvoiceFooterComment
	, strItemNo
	, strContractNumber
	, strItem
	, strItemDescription
	, strUnitMeasure
	, strUnitMeasureSymbol
	, strPaid
	, strPosted
	, strTaxCode
	, strTransactionType
	, strInvoiceComments
	, strItemComments
	, strPaymentComments
	, strCustomerComments
	, strItemType
	, strVFDDocumentNumber
	, strBOLNumberDetail
	, strProvisional
	, strTicketNumbers
	, strTicketNumber
	, strTicketNumberDate
	, strCustomerReference
	, strSalesReference
	, strPurchaseReference
	, strLoadNumber
	, strEntityContract
	, strSiteNumber
	, strAddonDetailKey
	, strTruckDriver
	, strSource
	, strOrigin
	, strComments
	, strContractNo
	, strContractNoSeq
	, strInvoiceFormat
	, strBargeNumber
	, strCommodity
	, strSubFormula
	, strTrailer
	, strSeals
	, strLotNumber
	, dblInvoiceSubtotal
	, dblShipping
	, dblTax
	, dblInvoiceTotal
	, dblAmountDue
	, dblContractBalance
	, dblQtyShipped
	, dblQtyOrdered
	, dblDiscount
	, dblTotalTax
	, dblPrice
	, dblItemPrice
	, dblTaxDetail
	, dblTotalWeight
	, dblTotalProvisional
	, dblEstimatedPercentLeft
	, dblPercentFull
	, dblInvoiceTax
	, dblPriceWithTax
	, dblTotalPriceWithTax
	, ysnHasEmailSetup
	, ysnHasRecipeItem
	, ysnHasVFDDrugItem
	, ysnHasProvisional
	, ysnPrintInvoicePaymentDetail
	, ysnListBundleSeparately
	, ysnHasAddOnItem
	, ysnStretchLogo
	, ysnHasSubFormula
	, dtmDate
	, dtmPostDate
	, dtmShipDate
	, dtmDueDate
	, dtmLoadedDate
	, dtmScaleDate
	, blbLogo
	, blbSignature
	, GETDATE() 
FROM tblARInvoiceReportStagingTable STAGING
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