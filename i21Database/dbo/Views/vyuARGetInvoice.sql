CREATE VIEW [dbo].[vyuARGetInvoice]
AS 
SELECT 
	 intInvoiceId						= INV.intInvoiceId
	,strInvoiceNumber					= INV.strInvoiceNumber
	,strTransactionType					= INV.strTransactionType
	,strType							= INV.strType
	,intEntityCustomerId				= INV.intEntityCustomerId
	,intCompanyLocationId				= INV.intCompanyLocationId
	,intAccountId						= INV.intAccountId
	,intCurrencyId						= INV.intCurrencyId
	,intTermId							= INV.intTermId
	,intPeriodsToAccrue					= INV.intPeriodsToAccrue
	,dtmDate							= INV.dtmDate
	,dtmDueDate							= INV.dtmDueDate
	,dtmShipDate						= INV.dtmShipDate
	,dtmPostDate						= INV.dtmPostDate
	,dblInvoiceSubtotal					= INV.dblInvoiceSubtotal
	,dblBaseInvoiceSubtotal				= INV.dblBaseInvoiceSubtotal
	,dblShipping						= INV.dblShipping
	,dblBaseShipping					= INV.dblBaseShipping
	,dblTax								= INV.dblTax
	,dblBaseTax							= INV.dblBaseTax
	,dblInvoiceTotal					= INV.dblInvoiceTotal
	,dblBaseInvoiceTotal				= INV.dblBaseInvoiceTotal
	,dblDiscount						= INV.dblDiscount
	,dblBaseDiscount					= INV.dblBaseDiscount
	,dblDiscountAvailable				= INV.dblDiscountAvailable
	,dblBaseDiscountAvailable			= INV.dblBaseDiscountAvailable
	,dblTotalTermDiscount				= INV.dblTotalTermDiscount
	,dblBaseTotalTermDiscount			= INV.dblBaseTotalTermDiscount
	,dblTotalTermDiscountExemption		= INV.dblTotalTermDiscountExemption
	,dblBaseTotalTermDiscountExemption	= INV.dblBaseTotalTermDiscountExemption
	,dblInterest						= INV.dblInterest
	,dblBaseInterest					= INV.dblBaseInterest
	,dblAmountDue						= INV.dblAmountDue
	,dblBaseAmountDue					= INV.dblBaseAmountDue
	,dblPayment							= INV.dblPayment + CASE WHEN INV.ysnFromProvisional = 1 AND INV.dblProvisionalAmount > 0 AND INV.ysnExcludeFromPayment = 0 THEN ISNULL(RELATEDINVOICE.dblPayment, 0) ELSE 0 END 
	,dblBasePayment						= INV.dblBasePayment + CASE WHEN INV.ysnFromProvisional = 1 AND INV.dblProvisionalAmount > 0 AND INV.ysnExcludeFromPayment = 0 THEN ISNULL(RELATEDINVOICE.dblBasePayment, 0) ELSE 0 END 
	,dblProvisionalAmount				= INV.dblProvisionalAmount
	,dblBaseProvisionalAmount			= INV.dblBaseProvisionalAmount
	,dblCurrencyExchangeRate			= INV.dblCurrencyExchangeRate
	,intEntitySalespersonId				= INV.intEntitySalespersonId
	,intFreightTermId					= INV.intFreightTermId
	,intShipViaId						= INV.intShipViaId
	,intPaymentMethodId					= INV.intPaymentMethodId
	,strInvoiceOriginId					= INV.strInvoiceOriginId	
	,strFooterComments					= INV.strFooterComments
	,intShipToLocationId				= INV.intShipToLocationId
	,strShipToLocationName				= INV.strShipToLocationName
	,strShipToAddress					= INV.strShipToAddress
	,strShipToCity						= INV.strShipToCity
	,strShipToState						= INV.strShipToState
	,strShipToZipCode					= INV.strShipToZipCode
	,strShipToCountry					= INV.strShipToCountry
	,intBillToLocationId				= INV.intBillToLocationId
	,strBillToLocationName				= INV.strBillToLocationName
	,strBillToAddress					= INV.strBillToAddress
	,strBillToCity						= INV.strBillToCity
	,strBillToState						= INV.strBillToState
	,strBillToZipCode					= INV.strBillToZipCode
	,strBillToCountry					= INV.strBillToCountry
	,ysnPosted							= INV.ysnPosted
	,ysnPaid							= INV.ysnPaid
	,ysnPaidCPP                         = INV.ysnPaidCPP
	,ysnProcessed						= INV.ysnProcessed
	,ysnRecurring						= INV.ysnRecurring
	,ysnForgiven						= INV.ysnForgiven
	,ysnCalculated						= INV.ysnCalculated
	,ysnSplitted						= INV.ysnSplitted
	,ysnImpactInventory					= INV.ysnImpactInventory
	,ysnImportedFromOrigin				= INV.ysnImportedFromOrigin
	,ysnImportedAsPosted				= INV.ysnImportedAsPosted
	,ysnExcludeFromPayment				= INV.ysnExcludeFromPayment
	,ysnFromProvisional					= INV.ysnFromProvisional
	,ysnReturned						= INV.ysnReturned
	,intPaymentId						= INV.intPaymentId
	,intSplitId							= INV.intSplitId
	,intDistributionHeaderId			= INV.intDistributionHeaderId
	,intLoadDistributionHeaderId		= INV.intLoadDistributionHeaderId
	,strActualCostId					= INV.strActualCostId
	,strImportFormat					= INV.strImportFormat
	,strContractApplyTo                 = INV.strContractApplyTo
	,intSourceId						= INV.intSourceId
	,intShipmentId						= INV.intShipmentId
	,intTransactionId					= INV.intTransactionId
	,intMeterReadingId					= INV.intMeterReadingId
	,intContractHeaderId				= INV.intContractHeaderId
	,intOriginalInvoiceId				= INV.intOriginalInvoiceId
	,intLoadId							= INV.intLoadId
	,intEntityId						= INV.intEntityId
	,dblTotalWeight						= INV.dblTotalWeight
	,dblTotalStandardWeight             = INV.dblTotalStandardWeight
	,intEntityContactId					= INV.intEntityContactId
	,intEntityApplicatorId				= INV.intEntityApplicatorId
	,intDocumentMaintenanceId			= INV.intDocumentMaintenanceId
	,intTruckDriverId					= INV.intTruckDriverId
	,intTruckDriverReferenceId			= INV.intTruckDriverReferenceId
	,intConcurrencyId					= INV.intConcurrencyId
	,ysnCancelled						= INV.ysnCancelled
	,ysnRejected						= INV.ysnRejected
	,ysnProcessedToNSF					= INV.ysnProcessedToNSF
	,ysnFromItemContract                = INV.ysnFromItemContract
	,intLineOfBusinessId				= INV.intLineOfBusinessId
	,strBOLNumber						= INV.strBOLNumber
	,strPaymentInfo						= INV.strPaymentInfo
	,intICTId							= INV.intICTId
	,intSalesOrderId					= INV.intSalesOrderId
	,intBookId							= INV.intBookId
	,intSubBookId						= INV.intSubBookId
	,strMobileBillingShiftNo			= INV.strMobileBillingShiftNo
	,ysnRefundProcessed					= INV.ysnRefundProcessed	
	,strPONumber						= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE INV.strPONumber END
	,strDeliverPickup					= '' COLLATE Latin1_General_CI_AS
	,strComments						= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE INV.strComments END
	,strDocumentCode					= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE ISNULL(DOC.strCode,'') END
	,strCode							= ISNULL(DOC.strCode,'')
	,strTitle							= CASE WHEN INV.strType = 'POS' THEN ISNULL(POSINV.strComment,'') ELSE ISNULL(DOC.strTitle,'') END
	,strLineOfBusiness					= LOB.strLineOfBusiness
	,strCustomerNumber					= CUS.strCustomerNumber
	,strCustomerName					= CUS.strName
	,intEntityLineOfBusinessIds			= CUS.intEntityLineOfBusinessIds COLLATE Latin1_General_CI_AS
	,ysnCreditHold						= CUS.ysnCreditHold
	,dblCreditLimit						= CUS.dblCreditLimit
	,dblARBalance						= CUS.dblARBalance
	,ysnPORequired						= CUS.ysnPORequired
	,ysnCustomerCreditHold				= CUS.ysnCreditHold
	,strCurrency						= CUR.strCurrency
	,strLocationName					= CLOC.strLocationName
	,strSalespersonName					= SPER.strName
	,strContactName						= INVCON.strName
	,strApplicatorName					= APER.strName
	,strApplicatorType					= APER.strType
	,strShipVia							= SHIPVIA.strShipVia
	,strAccountId						= ACCT.strAccountId
	,strTerm							= TERM.strTerm
	,dblTermDiscountRate				= TERM.dblDiscountEP
	,strFreightTerm						= FTERMS.strFreightTerm
	,strFobPoint						= FTERMS.strFobPoint
	,strTruckDriverName					= DPER.strName
	,strTruckNo							= TREF.strData
	,strSplitNumber						= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE SPLIT.strSplitNumber END
	,strPaymentMethod					= PMETHOD.strPaymentMethod
	,strICTName							= ISNULL(ICT.strICTName,'')
	,strSourceSONumber					= SO.strSalesOrderNumber
	,strBook							= CBOOK.strBook
	,strSubBook							= CSBOOK.strSubBook
	,strCreditCode						= CUS.strCreditCode
	,intPurchaseSale					= LG.intPurchaseSale
	,strReceiptNumber					= CASE WHEN INV.ysnInterCompany = 1 THEN INV.strReceiptNumber ELSE ISNULL(POSINV.strReceiptNumber, POSCM.strReceiptNumber) END
	,strEODNumber						= ISNULL(POSINV.strEODNo, POSCM.strEODNo)
	,strEODStatus                       = CASE WHEN POSINV.ysnClosed = 1 OR POSCM.ysnClosed = 1 THEN 'Completed' ELSE 'Open' END
	,strEODPOSDrawerName                = ISNULL(POSINV.strPOSDrawerName, POSCM.strPOSDrawerName)
	,ysnFromIntegration                 = CASE WHEN ISNULL(INV.intLoadId,0) <> 0 OR ISNULL(INV.intDistributionHeaderId,0) <> 0 OR ISNULL(INV.intLoadDistributionHeaderId,0) <> 0 OR ISNULL(INV.intMeterReadingId,0) <> 0 OR ISNULL(INTEG.intInvoiceId,0) <> 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	,ysnValidCreditCode					= INV.ysnValidCreditCode
	,ysnServiceChargeCredit				= INV.ysnServiceChargeCredit
	,blbSignature						= INV.blbSignature
	,ysnHasPricingLayer                 = CASE WHEN ISNULL(APAR.intInvoiceId,0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	,dblProvisionalPayment				= CASE WHEN ysnFromProvisional = 1 AND dblProvisionalAmount > 0 THEN RELATEDINVOICE.dblPayment ELSE 0 END 
	,dblProvisionalBasePayment			= CASE WHEN ysnFromProvisional = 1 AND dblBaseProvisionalAmount > 0 THEN RELATEDINVOICE.dblBasePayment ELSE 0 END 
	,ysnHasCreditApprover				= CAST(CASE WHEN CUSTOMERCREDITAPPROVER.intApproverCount > 0 OR USERCREDITAPPROVER.intApproverCount > 0 THEN 1 ELSE 0 END AS BIT)
	,dblCreditStopDays					= ISNULL(CUSTOMERAGING.dblCreditStopDays, 0)
	,intCreditStopDays					= CUS.intCreditStopDays
	,ysnInvoiceReturned					= ISNULL(RELATEDINVOICE.ysnReturned,0)
	,ysnInterCompany					= ISNULL(INV.ysnInterCompany,0)
	,ysnImportFromCSV					= ISNULL(INV.ysnImportFromCSV,0)
	,strInterCompanyName				= INTERCOMPANY.strCompanyName
	,ysnOverrideCashFlow                = INV.ysnOverrideCashFlow
	,dtmCashFlowDate                    = INV.dtmCashFlowDate
	,dblRoundingTotal					= INV.dblRoundingTotal	
	,dblBaseRoundingTotal				= INV.dblBaseRoundingTotal
	,intLocationAccountSegmentId		= GLSEGMENT.intLocationAccountSegmentId
	,intCompanyAccountSegmentId			= GLSEGMENT.intCompanyAccountSegmentId
	,ysnIntraCompany					= CASE WHEN ISNULL(INV.ysnIntraCompany,0) = 1 THEN INV.ysnIntraCompany ELSE ISNULL(ARCOMPANYPREFERENCE.ysnAllowIntraCompanyEntries,0) END
	,dblFreightCharge					= INV.dblFreightCharge
	,strFreightCompanySegment			= CAST(GLCAI.strCode AS NVARCHAR(50)) + ' - ' + GLCAI.strDescription
	,strFreightLocationSegment			= CAST(GLLAI.strCode AS NVARCHAR(50)) + ' - ' + GLLAI.strDescription
	,intProfitCenter					= CLOC.intProfitCenter
	,intOpportunityId					= INV.intOpportunityId
	,strOpportunityName					= OPUR.strName
	,ysnTaxAdjusted							= CAST(CASE WHEN RELATEDINVOICE2.strType = 'Tax Adjustment' AND RELATEDINVOICE2.ysnPosted = 1 THEN 1 ELSE 0 END AS BIT)
	,strPrintFormat							= INV.strPrintFormat
	,dblPercentage							= INV.dblPercentage
	,dblProvisionalTotal					= CASE WHEN INV.dblPercentage <> 100 THEN INV.dblProvisionalTotal ELSE INV.dblInvoiceTotal END
FROM tblARInvoice INV WITH (NOLOCK)
INNER JOIN (
    SELECT 
		 intEntityId
		,strCustomerNumber
		,intEntityLineOfBusinessIds
		,ysnCreditHold
		,dblCreditLimit
		,dblARBalance
		,ysnPORequired
		,strName
		,strCreditCode
		,intEntityContactId
		,intCreditStopDays
		,intInterCompanyId
    FROM vyuARCustomerSearch WITH (NOLOCK)
) CUS ON CUS.intEntityId = INV.intEntityCustomerId
INNER JOIN tblSMCompanyLocation CLOC WITH (NOLOCK) ON INV.intCompanyLocationId = CLOC.intCompanyLocationId
LEFT JOIN tblSMDocumentMaintenance DOC WITH (NOLOCK) ON INV.intDocumentMaintenanceId = DOC.intDocumentMaintenanceId
LEFT JOIN tblSMLineOfBusiness LOB WITH (NOLOCK) ON INV.intLineOfBusinessId = LOB.intLineOfBusinessId
LEFT JOIN tblSMCurrency CUR WITH (NOLOCK) ON INV.intCurrencyId = CUR.intCurrencyID
LEFT JOIN tblEMEntity SPER WITH (NOLOCK) ON INV.intEntitySalespersonId = SPER.intEntityId
LEFT JOIN tblEMEntity INVCON WITH (NOLOCK) ON INV.intEntityContactId = INVCON.intEntityId
LEFT JOIN tblSMShipVia SHIPVIA WITH (NOLOCK) ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN tblGLAccount ACCT WITH (NOLOCK) ON INV.intAccountId = ACCT.intAccountId
LEFT JOIN tblSMTerm TERM WITH (NOLOCK) ON INV.intTermId = TERM.intTermID
LEFT JOIN tblSMFreightTerms FTERMS WITH (NOLOCK) ON INV.intFreightTermId = FTERMS.intFreightTermId
LEFT JOIN tblEMEntity DPER WITH (NOLOCK) ON INV.intTruckDriverId = DPER.intEntityId
LEFT JOIN tblSCTruckDriverReference TREF WITH (NOLOCK) ON INV.intTruckDriverReferenceId = TREF.intTruckDriverReferenceId
LEFT JOIN tblEMEntitySplit SPLIT WITH (NOLOCK) ON INV.intSplitId = SPLIT.intSplitId
LEFT JOIN tblSMPaymentMethod PMETHOD WITH (NOLOCK) ON INV.intPaymentMethodId = PMETHOD.intPaymentMethodID
LEFT JOIN tblARICT ICT WITH (NOLOCK) ON INV.intICTId = ICT.intICTId
LEFT JOIN tblSOSalesOrder SO WITH (NOLOCK) ON INV.intSalesOrderId = SO.intSalesOrderId
LEFT JOIN tblCTBook CBOOK WITH (NOLOCK) ON INV.intBookId = CBOOK.intBookId
LEFT JOIN tblCTSubBook CSBOOK WITH (NOLOCK) ON INV.intSubBookId = CSBOOK.intSubBookId
LEFT JOIN tblLGLoad LG WITH (NOLOCK) ON INV.intLoadId = LG.intLoadId
LEFT JOIN tblCRMOpportunity OPUR WITH (NOLOCK) ON INV.intOpportunityId = OPUR.intOpportunityId

LEFT JOIN (
    SELECT intInvoiceId
		 --, intCreditMemoId
         , strReceiptNumber
         , strEODNo
         , strPOSDrawerName
		 , EOD.ysnClosed
		 , POS.strComment
    FROM dbo.tblARPOS POS WITH (NOLOCK)
    INNER JOIN dbo.tblARPOSLog POSLOG WITH (NOLOCK) ON POS.intPOSLogId = POSLOG.intPOSLogId
    INNER JOIN dbo.tblARPOSEndOfDay EOD WITH (NOLOCK) ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
	INNER JOIN dbo.tblSMCompanyLocationPOSDrawer DRAWER WITH (NOLOCK) ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId 
	WHERE POS.intInvoiceId IS NOT NULL
) POSINV ON INV.intInvoiceId = POSINV.intInvoiceId
     AND INV.strType = 'POS'
LEFT OUTER JOIN (
	SELECT intCreditMemoId
         , ysnClosed
         , strReceiptNumber
         , strEODNo
		 , intItemCount
		 , dblTotal
         , strPOSDrawerName
    FROM dbo.tblARPOS POS WITH (NOLOCK)
    INNER JOIN dbo.tblARPOSLog POSLOG WITH (NOLOCK) ON POS.intPOSLogId = POSLOG.intPOSLogId
    INNER JOIN dbo.tblARPOSEndOfDay EOD WITH (NOLOCK) ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId 
	INNER JOIN dbo.tblSMCompanyLocationPOSDrawer DRAWER WITH (NOLOCK) ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId 
	WHERE intCreditMemoId IS NOT NULL
) POSCM ON INV.intInvoiceId = POSCM.intCreditMemoId
       AND INV.strType = 'POS'
OUTER APPLY (
	SELECT TOP 1 A.intEntityId
			   , A.strName
			   , B.strType
	FROM tblEMEntity A WITH (NOLOCK)
	INNER JOIN tblEMEntityType B WITH (NOLOCK) ON B.intEntityId = A.intEntityId
	WHERE INV.intEntityApplicatorId = A.intEntityId
) APER
OUTER APPLY (
    SELECT TOP 1 ID.intInvoiceId
    FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
    WHERE INV.intInvoiceId = ID.intInvoiceId
      AND (ISNULL(intTicketId,0) <> 0 OR ISNULL(intInventoryShipmentItemId,0) <> 0 OR ISNULL(intLoadDetailId,0) <> 0)
) INTEG
LEFT JOIN (
    SELECT ID.intInvoiceId
    FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
    INNER JOIN tblCTPriceFixationDetailAPAR APAR ON ID.intInvoiceDetailId = APAR.intInvoiceDetailId
    GROUP BY ID.intInvoiceId
) APAR ON APAR.intInvoiceId = INV.intInvoiceId
OUTER APPLY(
	SELECT COUNT(ARC.intEntityId) AS intApproverCount
	FROM dbo.tblARCustomer ARC
	INNER JOIN dbo.tblEMEntityRequireApprovalFor ERA
		ON ARC.intEntityId = ERA.[intEntityId]
	INNER JOIN tblSMScreen SC
		ON ERA.intScreenId = SC.intScreenId
		AND SC.strScreenName = 'Invoice'
	WHERE ARC.intEntityId = INV.intEntityCustomerId
) CUSTOMERCREDITAPPROVER
OUTER APPLY(
	SELECT COUNT(SRA.intEntityUserSecurityId) AS intApproverCount
	FROM dbo.tblSMUserSecurityRequireApprovalFor SRA
	INNER JOIN tblSMScreen SC
	ON SRA.intScreenId = SC.intScreenId
	AND SC.strScreenName = 'Invoice'
	WHERE SRA.intEntityUserSecurityId = INV.intEntityId
) USERCREDITAPPROVER
OUTER APPLY(
	SELECT TOP 1 dblCreditStopDays
	FROM dbo.vyuARCustomerInquiry
	WHERE intEntityCustomerId = INV.intEntityCustomerId
) CUSTOMERAGING
OUTER APPLY(
	SELECT TOP 1 strCompanyName
	FROM dbo.tblSMInterCompany
	WHERE intInterCompanyId = CUS.intInterCompanyId
) INTERCOMPANY
LEFT JOIN
(
	SELECT  
		 intInvoiceId
		,strInvoiceNumber
		,dblPayment
		,dblBasePayment
		,ysnReturned
		,strType
		,ysnPosted
	FROM tblARInvoice  WITH (NOLOCK) 
) RELATEDINVOICE ON RELATEDINVOICE.intInvoiceId = INV.intOriginalInvoiceId
LEFT JOIN
(
	SELECT  
		 intOriginalInvoiceId
		,strType
		,ysnPosted
	FROM tblARInvoice  WITH (NOLOCK) 
) RELATEDINVOICE2 ON RELATEDINVOICE2.intOriginalInvoiceId = INV.intInvoiceId
LEFT JOIN vyuCMBankAccount DBA ON DBA.intBankAccountId = ISNULL(INV.intDefaultPayToBankAccountId,0)
LEFT JOIN vyuCMBankAccount PFCBA ON PFCBA.intBankAccountId = ISNULL(INV.intPayToCashBankAccountId,0)
LEFT JOIN tblCMBank B ON B.intBankId = ISNULL(INV.intBankId,0)
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = ISNULL(INV.intBankAccountId,0)
LEFT JOIN tblCMBorrowingFacility BF ON BF.intBorrowingFacilityId = ISNULL(INV.intBorrowingFacilityId,0)
LEFT JOIN tblCMBorrowingFacilityLimit BFL ON BFL.intBorrowingFacilityLimitId = ISNULL(INV.intBorrowingFacilityLimitId,0)
LEFT JOIN tblCMBorrowingFacilityLimitDetail BFLD ON BFLD.intBorrowingFacilityLimitDetailId = ISNULL(INV.intBorrowingFacilityLimitDetailId,0)
LEFT JOIN tblCMBankValuationRule BVR ON BVR.intBankValuationRuleId = ISNULL(INV.intBankValuationRuleId,0)
LEFT JOIN vyuARTaxLocation TAXLOCATION ON TAXLOCATION.intTaxLocationId = ISNULL(INV.intTaxLocationId,0) AND TAXLOCATION.strType = CASE WHEN INV.strTaxPoint = 'Destination' THEN 'Entity' ELSE 'Company' END
OUTER APPLY(
	SELECT TOP 1 intLocationAccountSegmentId
		       , intCompanyAccountSegmentId
	FROM dbo.vyuARAccountDetail
	WHERE intAccountId = INV.intAccountId
) GLSEGMENT
OUTER APPLY(
	SELECT TOP 1 ysnAllowIntraCompanyEntries
	FROM tblARCompanyPreference
) ARCOMPANYPREFERENCE
OUTER APPLY (
	SELECT TOP 1 intAccountId
			   , strDescription
			   , strCode
	FROM vyuGLCompanyAccountId WITH (NOLOCK)
	WHERE intAccountSegmentId = INV.intFreightCompanySegment
) GLCAI
OUTER APPLY (
	SELECT TOP 1 intAccountId
			   , strDescription
			   , strCode
	FROM vyuGLLocationAccountId WITH (NOLOCK)
	WHERE intAccountSegmentId = INV.intFreightLocationSegment
) GLLAI