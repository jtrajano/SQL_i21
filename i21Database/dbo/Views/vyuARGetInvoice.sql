CREATE VIEW [dbo].[vyuARGetInvoice]
AS 
SELECT intInvoiceId							= INV.intInvoiceId
	 , strInvoiceNumber						= INV.strInvoiceNumber
     , strTransactionType					= INV.strTransactionType
     , strType								= INV.strType
     , intEntityCustomerId					= INV.intEntityCustomerId
     , intCompanyLocationId					= INV.intCompanyLocationId
     , intAccountId							= INV.intAccountId
     , intCurrencyId						= INV.intCurrencyId
     , intTermId							= INV.intTermId
	 , intPeriodsToAccrue					= INV.intPeriodsToAccrue
     , dtmDate								= INV.dtmDate
     , dtmDueDate							= INV.dtmDueDate
     , dtmShipDate							= INV.dtmShipDate
     , dtmPostDate							= INV.dtmPostDate
     , dblInvoiceSubtotal					= INV.dblInvoiceSubtotal
     , dblBaseInvoiceSubtotal				= INV.dblBaseInvoiceSubtotal
     , dblShipping							= INV.dblShipping
     , dblBaseShipping						= INV.dblBaseShipping
     , dblTax								= INV.dblTax
     , dblBaseTax							= INV.dblBaseTax
     , dblInvoiceTotal						= INV.dblInvoiceTotal
     , dblBaseInvoiceTotal					= INV.dblBaseInvoiceTotal
     , dblDiscount							= INV.dblDiscount
     , dblBaseDiscount						= INV.dblBaseDiscount
     , dblDiscountAvailable					= INV.dblDiscountAvailable
     , dblBaseDiscountAvailable				= INV.dblBaseDiscountAvailable
	 , dblTotalTermDiscount					= INV.dblTotalTermDiscount
	 , dblBaseTotalTermDiscount				= INV.dblBaseTotalTermDiscount
	 , dblTotalTermDiscountExemption		= INV.dblTotalTermDiscountExemption
	 , dblBaseTotalTermDiscountExemption	= INV.dblBaseTotalTermDiscountExemption
     , dblInterest							= INV.dblInterest
     , dblBaseInterest						= INV.dblBaseInterest
     , dblAmountDue							= CASE WHEN INV.ysnFromProvisional = 1 AND INV.dblProvisionalAmount > 0 
												THEN CASE WHEN INV.dblInvoiceTotal > INV.dblProvisionalAmount OR INV.dblInvoiceTotal = INV.dblProvisionalAmount
													THEN ISNULL(INV.dblInvoiceTotal, 0) - ISNULL(INV.dblPayment, 0) - ISNULL(PROVISIONALPAYMENT.dblPayment, 0) 
													ELSE ISNULL(INV.dblInvoiceTotal, 0) - ISNULL(INV.dblPayment, 0)  - ISNULL(INV.dblProvisionalAmount, 0) - ISNULL(PROVISIONALPAYMENT.dblPayment, 0) 
													END
												ELSE INV.dblAmountDue 
											  END 
     , dblBaseAmountDue						= CASE WHEN INV.ysnFromProvisional = 1 AND INV.dblBaseProvisionalAmount > 0 
												THEN CASE WHEN INV.dblBaseInvoiceTotal > INV.dblBaseProvisionalAmount OR INV.dblInvoiceTotal = INV.dblBaseProvisionalAmount
													THEN ISNULL(INV.dblBaseInvoiceTotal, 0) - ISNULL(INV.dblBasePayment, 0) - ISNULL(PROVISIONALPAYMENT.dblBasePayment, 0) 
													ELSE ISNULL(INV.dblBaseInvoiceTotal, 0) - ISNULL(INV.dblBasePayment, 0)  - ISNULL(INV.dblBaseProvisionalAmount, 0) - ISNULL(PROVISIONALPAYMENT.dblBasePayment, 0) 
													END
												ELSE INV.dblAmountDue 
											  END
     , dblPayment							= INV.dblPayment
     , dblBasePayment						= INV.dblBasePayment
     , dblProvisionalAmount					= INV.dblProvisionalAmount
     , dblBaseProvisionalAmount				= INV.dblBaseProvisionalAmount
	 , dblCurrencyExchangeRate				= INV.dblCurrencyExchangeRate
     , intEntitySalespersonId				= INV.intEntitySalespersonId
     , intFreightTermId						= INV.intFreightTermId
     , intShipViaId							= INV.intShipViaId
     , intPaymentMethodId					= INV.intPaymentMethodId
     , strInvoiceOriginId					= INV.strInvoiceOriginId	
     , strFooterComments					= INV.strFooterComments
     , intShipToLocationId					= INV.intShipToLocationId
     , strShipToLocationName				= INV.strShipToLocationName
     , strShipToAddress						= INV.strShipToAddress
     , strShipToCity						= INV.strShipToCity
     , strShipToState						= INV.strShipToState
     , strShipToZipCode						= INV.strShipToZipCode
     , strShipToCountry						= INV.strShipToCountry
     , intBillToLocationId					= INV.intBillToLocationId
     , strBillToLocationName				= INV.strBillToLocationName
     , strBillToAddress						= INV.strBillToAddress
     , strBillToCity						= INV.strBillToCity
     , strBillToState						= INV.strBillToState
     , strBillToZipCode						= INV.strBillToZipCode
     , strBillToCountry						= INV.strBillToCountry
     , ysnPosted							= INV.ysnPosted
     , ysnPaid								= INV.ysnPaid
     , ysnPaidCPP                           = INV.ysnPaidCPP
     , ysnProcessed							= INV.ysnProcessed
     , ysnRecurring							= INV.ysnRecurring
     , ysnForgiven							= INV.ysnForgiven
     , ysnCalculated						= INV.ysnCalculated
     , ysnSplitted							= INV.ysnSplitted
     , ysnImpactInventory					= INV.ysnImpactInventory
     , ysnImportedFromOrigin				= INV.ysnImportedFromOrigin
     , ysnImportedAsPosted					= INV.ysnImportedAsPosted
	 , ysnExcludeFromPayment				= INV.ysnExcludeFromPayment
	 , ysnFromProvisional					= INV.ysnFromProvisional
     , ysnReturned							= INV.ysnReturned
     , intPaymentId							= INV.intPaymentId
     , intSplitId							= INV.intSplitId
     , intDistributionHeaderId				= INV.intDistributionHeaderId
     , intLoadDistributionHeaderId			= INV.intLoadDistributionHeaderId
     , strActualCostId						= INV.strActualCostId
     , strImportFormat						= INV.strImportFormat
     , strContractApplyTo                   = INV.strContractApplyTo
     , intSourceId							= INV.intSourceId
     , intShipmentId						= INV.intShipmentId
     , intTransactionId						= INV.intTransactionId
     , intMeterReadingId					= INV.intMeterReadingId
     , intContractHeaderId					= INV.intContractHeaderId
     , intOriginalInvoiceId					= INV.intOriginalInvoiceId
     , intLoadId							= INV.intLoadId
     , intEntityId							= INV.intEntityId
     , dblTotalWeight						= INV.dblTotalWeight
     , intEntityContactId					= INV.intEntityContactId
     , intEntityApplicatorId				= INV.intEntityApplicatorId
     , intDocumentMaintenanceId				= INV.intDocumentMaintenanceId
     , intTruckDriverId						= INV.intTruckDriverId
     , intTruckDriverReferenceId			= INV.intTruckDriverReferenceId
     , intConcurrencyId						= INV.intConcurrencyId
     , ysnCancelled							= INV.ysnCancelled
	 , ysnRejected							= INV.ysnRejected
     , ysnProcessedToNSF					= INV.ysnProcessedToNSF
     , ysnFromItemContract                  = INV.ysnFromItemContract
     , intLineOfBusinessId					= INV.intLineOfBusinessId
	 , strBOLNumber							= INV.strBOLNumber
     , strPaymentInfo						= INV.strPaymentInfo
	 , intICTId								= INV.intICTId
     , intSalesOrderId						= INV.intSalesOrderId
	 , intBookId							= INV.intBookId
	 , intSubBookId							= INV.intSubBookId
	 , strMobileBillingShiftNo				= INV.strMobileBillingShiftNo
     , ysnRefundProcessed					= INV.ysnRefundProcessed	
	 , strPONumber							= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE INV.strPONumber END
	 , strDeliverPickup						= '' COLLATE Latin1_General_CI_AS
     , strComments							= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE INV.strComments END
	 , strDocumentCode						= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE ISNULL(DOC.strCode, '') END
	 , strCode								= ISNULL(DOC.strCode, '')
     , strTitle								= CASE WHEN INV.strType = 'POS' THEN ISNULL(POS.strComment, '') ELSE ISNULL(DOC.strTitle, '') END
	 , strLineOfBusiness					= LOB.strLineOfBusiness
	 , strCustomerNumber					= CUS.strCustomerNumber
     , strCustomerName						= CUS.strName
     , intEntityLineOfBusinessIds			= CUS.intEntityLineOfBusinessIds COLLATE Latin1_General_CI_AS
     , ysnCreditHold						= CUS.ysnCreditHold
     , dblCreditLimit						= CUS.dblCreditLimit
     , dblARBalance							= CUS.dblARBalance
     , ysnPORequired						= CUS.ysnPORequired
     , ysnCustomerCreditHold				= CUS.ysnCreditHold
	 , strCurrency							= CUR.strCurrency
     , strLocationName						= CLOC.strLocationName
     , strSalespersonName					= SPER.strName
     , strContactName						= INVCON.strName
	 , strApplicatorName					= APER.strName
	 , strApplicatorType					= APER.strType
     , strShipVia							= SHIPVIA.strShipVia
     , strAccountId							= ACCT.strAccountId
	 , strTerm								= TERM.strTerm
	 , dblTermDiscountRate					= TERM.dblDiscountEP
     , strFreightTerm						= FTERMS.strFreightTerm
     , strFobPoint							= FTERMS.strFobPoint
     , strTruckDriverName					= DPER.strName
     , strTruckNo							= TREF.strData
	 , strSplitNumber						= CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE SPLIT.strSplitNumber END
	 , strPaymentMethod						= PMETHOD.strPaymentMethod
	 , strICTName							= ISNULL(ICT.strICTName, '')
	 , strSourceSONumber					= SO.strSalesOrderNumber
	 , strBook								= CBOOK.strBook
	 , strSubBook							= CSBOOK.strSubBook
	 , intCreditStopDays					= CUS.intCreditStopDays
	 , strCreditCode						= CUS.strCreditCode
	 , intPurchaseSale						= LG.intPurchaseSale
     , strReceiptNumber						= ISNULL(POS.strReceiptNumber,POSMixedTransactionCreditMemo.strReceiptNumber)
     , strEODNumber							= ISNULL(POS.strEODNo,POSMixedTransactionCreditMemo.strEODNo)
     , strEODStatus                         = CASE WHEN POS.ysnClosed = 1 OR POSMixedTransactionCreditMemo.ysnClosed = 1 THEN 'Completed' ELSE 'Open' END
     , strEODPOSDrawerName                  = ISNULL(POS.strPOSDrawerName, POSMixedTransactionCreditMemo.strPOSDrawerName)
	 , intCreditLimitReached				= CUS.intCreditLimitReached
	 , dtmCreditLimitReached				= CUS.dtmCreditLimitReached
     , ysnFromIntegration                   = CASE WHEN ISNULL(INV.intLoadId, 0) <> 0 OR ISNULL(INV.intDistributionHeaderId, 0) <> 0 OR ISNULL(INV.intLoadDistributionHeaderId, 0) <> 0 OR ISNULL(INV.intMeterReadingId, 0) <> 0 OR ISNULL(INTEG.intInvoiceId, 0) <> 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	 , ysnValidCreditCode					= INV.ysnValidCreditCode
	 , ysnServiceChargeCredit				= INV.ysnServiceChargeCredit
	 , blbSignature							= INV.blbSignature
     , ysnHasPricingLayer                   = CASE WHEN ISNULL(APAR.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
     , dblProvisionalPayment				= CASE WHEN ysnFromProvisional = 1 AND dblProvisionalAmount > 0 THEN PROVISIONALPAYMENT.dblPayment ELSE 0 END 
	 , dblProvisionalBasePayment			= CASE WHEN ysnFromProvisional = 1 AND dblBaseProvisionalAmount > 0 THEN PROVISIONALPAYMENT.dblBasePayment ELSE 0 END 
     , ysnHasCreditApprover					= CAST(CASE WHEN CUSTOMERCREDITAPPROVER.intApproverCount > 0 OR USERCREDITAPPROVER.intApproverCount > 0 THEN 1 ELSE 0 END AS BIT)
FROM tblARInvoice INV WITH (NOLOCK)
INNER JOIN (
    SELECT intEntityId
		 , strCustomerNumber
		 , intEntityLineOfBusinessIds
		 , ysnCreditHold
		 , dblCreditLimit
		 , dblARBalance
		 , ysnPORequired
		 , strName
		 , intCreditStopDays
		 , strCreditCode
		 , intEntityContactId
		 , intCreditLimitReached
		 , dtmCreditLimitReached
    FROM vyuARCustomerSearch WITH (NOLOCK)
) CUS ON CUS.intEntityId = INV.intEntityCustomerId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM tblSMCompanyLocation WITH (NOLOCK) 
) CLOC ON INV.intCompanyLocationId = CLOC.intCompanyLocationId
LEFT JOIN (
	SELECT intDocumentMaintenanceId
		 , strCode
		 , strTitle 
	FROM tblSMDocumentMaintenance WITH (NOLOCK)
) DOC ON INV.intDocumentMaintenanceId = DOC.intDocumentMaintenanceId
LEFT JOIN (
	SELECT intLineOfBusinessId
 	     , strLineOfBusiness 
	FROM tblSMLineOfBusiness WITH (NOLOCK)
) LOB ON INV.intLineOfBusinessId = LOB.intLineOfBusinessId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency 
	FROM tblSMCurrency WITH (NOLOCK)  
) CUR ON INV.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK)
) SPER ON INV.intEntitySalespersonId = SPER.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK)
) INVCON ON INV.intEntityContactId = INVCON.intEntityId
LEFT JOIN (
	SELECT TOP 1 A.intEntityId
			   , strName
			   , B.strType
	FROM tblEMEntity A WITH (NOLOCK)
	INNER JOIN tblEMEntityType B WITH (NOLOCK) ON B.intEntityId = A.intEntityId
) APER ON INV.intEntityApplicatorId = APER.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strShipVia
	FROM tblSMShipVia WITH (NOLOCK)
) SHIPVIA ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN (
	SELECT intAccountId
		 , strAccountId 
	FROM tblGLAccount WITH (NOLOCK)
) ACCT ON INV.intAccountId = ACCT.intAccountId
LEFT JOIN (
	SELECT intTermID
		 , strTerm
		 , dblDiscountEP
	FROM tblSMTerm WITH (NOLOCK)
) TERM ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
		 , strFobPoint
	FROM tblSMFreightTerms WITH (NOLOCK)
) FTERMS ON INV.intFreightTermId = FTERMS.intFreightTermId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM tblEMEntity WITH (NOLOCK) 
) DPER ON INV.intTruckDriverId = DPER.intEntityId
LEFT JOIN (
	SELECT intTruckDriverReferenceId
		 , strData 
	FROM tblSCTruckDriverReference  WITH (NOLOCK)
) TREF ON INV.intTruckDriverReferenceId = TREF.intTruckDriverReferenceId
LEFT JOIN (
	SELECT intSplitId
		 , strSplitNumber 
	FROM tblEMEntitySplit WITH (NOLOCK)
) SPLIT ON INV.intSplitId = SPLIT.intSplitId
LEFT JOIN (
	SELECT intPaymentMethodID
		 , strPaymentMethod 
	FROM tblSMPaymentMethod WITH (NOLOCK)
) PMETHOD ON INV.intPaymentMethodId = PMETHOD.intPaymentMethodID
LEFT JOIN ( 
	SELECT intICTId
		 , strICTName 
	FROM tblARICT WITH (NOLOCK)
) ICT ON INV.intICTId = ICT.intICTId
LEFT JOIN ( 
	SELECT intSalesOrderId
		 , strSalesOrderNumber 
	FROM tblSOSalesOrder WITH (NOLOCK)
) SO ON INV.intSalesOrderId = SO.intSalesOrderId
LEFT JOIN (
	SELECT intBookId
		 , strBook
	FROM tblCTBook WITH (NOLOCK)
) CBOOK ON INV.intBookId = CBOOK.intBookId
LEFT JOIN (
	SELECT intSubBookId
		 , strSubBook
	FROM tblCTSubBook  WITH (NOLOCK)
) CSBOOK ON INV.intSubBookId = CSBOOK.intSubBookId
LEFT JOIN (
	SELECT intLoadId
		 , intPurchaseSale
	FROM dbo.tblLGLoad WITH (NOLOCK)
) LG ON INV.intLoadId = LG.intLoadId
LEFT JOIN (
    SELECT intInvoiceId
		 , intCreditMemoId
         , strReceiptNumber
         , strEODNo
         , strPOSDrawerName
		 , EOD.ysnClosed
		 , POS.strComment
    FROM dbo.tblARPOS POS WITH (NOLOCK)
    INNER JOIN dbo.tblARPOSLog POSLOG WITH (NOLOCK) ON POS.intPOSLogId = POSLOG.intPOSLogId
    INNER JOIN dbo.tblARPOSEndOfDay EOD WITH (NOLOCK) ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
	INNER JOIN dbo.tblSMCompanyLocationPOSDrawer DRAWER WITH (NOLOCK) ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId 
) POS ON (INV.intInvoiceId = POS.intInvoiceId OR INV.intInvoiceId = POS.intCreditMemoId) 
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
) POSMixedTransactionCreditMemo ON INV.intInvoiceId = POSMixedTransactionCreditMemo.intCreditMemoId
AND INV.strType = 'POS'
OUTER APPLY (
    SELECT TOP 1 ID.intInvoiceId
    FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
    WHERE INV.intInvoiceId = ID.intInvoiceId
      AND (ISNULL(intTicketId, 0) <> 0 OR ISNULL(intInventoryShipmentItemId, 0) <> 0 OR ISNULL(intLoadDetailId, 0) <> 0)
) INTEG
LEFT JOIN (
    SELECT ID.intInvoiceId
    FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
    INNER JOIN tblCTPriceFixationDetailAPAR APAR ON ID.intInvoiceDetailId = APAR.intInvoiceDetailId
    GROUP BY ID.intInvoiceId
) APAR ON APAR.intInvoiceId = INV.intInvoiceId
LEFT OUTER JOIN (
	SELECT  intInvoiceId, PD.dblPayment, dblBasePayment, P.ysnPosted
	FROM	tblARPaymentDetail PD
	INNER JOIN tblARPayment P
	ON PD.intPaymentId = P.intPaymentId
) PROVISIONALPAYMENT ON PROVISIONALPAYMENT.intInvoiceId = INV.intOriginalInvoiceId AND PROVISIONALPAYMENT.ysnPosted = 1
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