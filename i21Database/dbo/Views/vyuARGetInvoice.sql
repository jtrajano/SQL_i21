﻿CREATE VIEW [dbo].[vyuARGetInvoice]
	AS 
	
	
SELECT 
	
	INV.intInvoiceId,
    INV.strInvoiceNumber,
    INV.strTransactionType,
    INV.strType,
    INV.intEntityCustomerId,
    INV.intCompanyLocationId,
    INV.intAccountId,
    INV.intCurrencyId,
    INV.intTermId,
    INV.intPeriodsToAccrue,
    INV.dtmDate,
    INV.dtmDueDate,
    INV.dtmShipDate,
    INV.dtmPostDate,
    INV.dblInvoiceSubtotal,
    INV.dblBaseInvoiceSubtotal,
    INV.dblShipping,
    INV.dblBaseShipping,
    INV.dblTax,
    INV.dblBaseTax,
    INV.dblInvoiceTotal,
    INV.dblBaseInvoiceTotal,
    INV.dblDiscount,
    INV.dblBaseDiscount,
    INV.dblDiscountAvailable,
    INV.dblBaseDiscountAvailable,
    INV.dblInterest,
    INV.dblBaseInterest,
    INV.dblAmountDue,
    INV.dblBaseAmountDue,
    INV.dblPayment,
    INV.dblBasePayment,
    INV.dblProvisionalAmount,
    INV.dblBaseProvisionalAmount,
    INV.intEntitySalespersonId,
    INV.intFreightTermId,
    INV.intShipViaId,
    INV.intPaymentMethodId,
    INV.strInvoiceOriginId,
	
    INV.strFooterComments,
    INV.intShipToLocationId,
    INV.strShipToLocationName,
    INV.strShipToAddress,
    INV.strShipToCity,
    INV.strShipToState,
    INV.strShipToZipCode,
    INV.strShipToCountry,
    INV.intBillToLocationId,
    INV.strBillToLocationName,
    INV.strBillToAddress,
    INV.strBillToCity,
    INV.strBillToState,
    INV.strBillToZipCode,
    INV.strBillToCountry,
    INV.ysnPosted,
    INV.ysnPaid,
    INV.ysnProcessed,
    INV.ysnRecurring,
    INV.ysnForgiven,
    INV.ysnCalculated,
    INV.ysnSplitted,
    INV.ysnImpactInventory,
    INV.ysnImportedFromOrigin,
    INV.ysnImportedAsPosted,
	INV.ysnExcludeFromPayment,
    INV.ysnReturned,
    INV.intPaymentId,
    INV.intSplitId,
    INV.intDistributionHeaderId,
    INV.intLoadDistributionHeaderId,
    INV.strActualCostId,
    INV.strImportFormat,
    INV.intSourceId,
    INV.intShipmentId,
    INV.intTransactionId,
    INV.intMeterReadingId,
    INV.intContractHeaderId,
    INV.intOriginalInvoiceId,
    INV.intLoadId,
    INV.intEntityId,
    INV.dblTotalWeight,
    INV.intEntityContactId,
    INV.intEntityApplicatorId,
    INV.intDocumentMaintenanceId,
    INV.dblTotalTermDiscount,
    INV.intTruckDriverId,
    INV.intTruckDriverReferenceId,
    INV.intConcurrencyId,
    INV.ysnCancelled,                                      
    INV.intLineOfBusinessId,
	INV.strBOLNumber,
	INV.intICTId,
    INV.intSalesOrderId,

	strPONumber = CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE INV.strPONumber END,                                    
	strDeliverPickup = '' COLLATE Latin1_General_CI_AS,
    strComments = CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE INV.strComments END,
	strDocumentCode = CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE ISNULL(DOC.strCode, '') END,
	strCode = ISNULL(DOC.strCode, ''),
    strTitle = ISNULL(DOC.strTitle, ''),
	strLineOfBusiness = LOB.strLineOfBusiness,

	strCustomerNumber = CUS.strCustomerNumber,
    strCustomerName = CUS.strName,
    intEntityLineOfBusinessIds = CUS.intEntityLineOfBusinessIds COLLATE Latin1_General_CI_AS,
    ysnCreditHold = CUS.ysnCreditHold,
    dblCreditLimit = CUS.dblCreditLimit,
    dblARBalance = CUS.dblARBalance,                                                                            
    ysnPORequired = CUS.ysnPORequired,
    ysnCustomerCreditHold = CUS.ysnCreditHold,
	strCurrency = CUR.strCurrency,	
    strLocationName = CLOC.strLocationName,	
    strSalespersonName = SPER.strName,
    strContactName = INVCON.strName,
	strApplicatorName = APER.strName,
    strShipVia = SHIPVIA.strShipVia,
    strAccountId = ACCT.strAccountId,
	strTerm = TERM.strTerm,
    strFreightTerm = FTERMS.strFreightTerm,
    strFobPoint = FTERMS.strFobPoint,
    strTruckDriverName = DPER.strName,	
    strTruckNo = TREF.strData,
	strSplitNumber = CASE WHEN INV.strType = 'Service Charge' THEN '' ELSE SPLIT.strSplitNumber END,
	strPaymentMethod = PMETHOD.strPaymentMethod,
	strICTName = ISNULL(ICT.strICTName, ''),
	strSourceSONumber = SO.strSalesOrderNumber
FROM 
tblARInvoice INV
JOIN (SELECT intEntityId,					strCustomerNumber, 
				intEntityLineOfBusinessIds,	ysnCreditHold,
				dblCreditLimit,				dblARBalance, 
				ysnPORequired,					strName,
				intEntityContactId
				FROM vyuARCustomerSearch WITH ( NOLOCK) ) CUS
	ON CUS.intEntityId = INV.intEntityCustomerId --AND INV.intEntityContactId = CUS.intEntityContactId
JOIN (SELECT intCompanyLocationId, strLocationName 
			FROM tblSMCompanyLocation WITH ( NOLOCK) ) CLOC
	ON INV.intCompanyLocationId = CLOC.intCompanyLocationId
LEFT JOIN (SELECT intDocumentMaintenanceId, strCode, strTitle 
				FROM tblSMDocumentMaintenance WITH ( NOLOCK)  )DOC
	ON INV.intDocumentMaintenanceId = DOC.intDocumentMaintenanceId
LEFT JOIN ( SELECT  intLineOfBusinessId, strLineOfBusiness 
				FROM tblSMLineOfBusiness WITH ( NOLOCK)  ) LOB
	ON INV.intLineOfBusinessId = LOB.intLineOfBusinessId
LEFT JOIN ( SELECT intCurrencyID, strCurrency 
				FROM tblSMCurrency WITH ( NOLOCK)  ) CUR
	ON INV.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (SELECT intEntityId, strName
				FROM vyuEMSalesperson WITH ( NOLOCK) ) SPER
	ON INV.intEntitySalespersonId = SPER.intEntityId
LEFT JOIN (SELECT intEntityId, strName
				FROM tblEMEntity WITH ( NOLOCK) ) INVCON
	ON INV.intEntityContactId = INVCON.intEntityId
LEFT JOIN (SELECT intEntityId, strName
				FROM tblEMEntity WITH ( NOLOCK) ) APER
	ON INV.intEntityApplicatorId = APER.intEntityId
LEFT JOIN (SELECT intEntityId, strShipVia
				FROM tblSMShipVia WITH ( NOLOCK) ) SHIPVIA
	ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN (SELECT intAccountId, strAccountId 
				FROM tblGLAccount WITH ( NOLOCK) ) ACCT
	ON INV.intAccountId = ACCT.intAccountId
LEFT JOIN (SELECT intTermID, strTerm 
			FROM tblSMTerm WITH ( NOLOCK) ) TERM
	ON INV.intTermId = TERM.intTermID
LEFT JOIN ( SELECT  intFreightTermId, strFreightTerm,
					strFobPoint
			FROM tblSMFreightTerms WITH ( NOLOCK) ) FTERMS
	ON INV.intFreightTermId = FTERMS.intFreightTermId
LEFT JOIN (SELECT intEntityId, strName
				FROM tblEMEntity WITH ( NOLOCK) ) DPER
	ON INV.intTruckDriverId = DPER.intEntityId
LEFT JOIN (SELECT intTruckDriverReferenceId, strData 
				FROM tblSCTruckDriverReference  WITH ( NOLOCK) ) TREF
	ON INV.intTruckDriverReferenceId = TREF.intTruckDriverReferenceId
LEFT JOIN (SELECT intSplitId, strSplitNumber 
				FROM tblEMEntitySplit WITH ( NOLOCK) ) SPLIT
	ON INV.intSplitId = SPLIT.intSplitId
LEFT JOIN ( SELECT  intPaymentMethodID, strPaymentMethod 
				FROM tblSMPaymentMethod WITH ( NOLOCK) ) PMETHOD
	ON INV.intPaymentMethodId = PMETHOD.intPaymentMethodID
LEFT JOIN ( SELECT intICTId, strICTName 
				FROM tblARICT WITH ( NOLOCK) ) ICT
	ON INV.intICTId = ICT.intICTId

LEFT JOIN ( SELECT intSalesOrderId, strSalesOrderNumber 
				FROM tblSOSalesOrder WITH ( NOLOCK) ) SO
	ON INV.intSalesOrderId = SO.intSalesOrderId
		



