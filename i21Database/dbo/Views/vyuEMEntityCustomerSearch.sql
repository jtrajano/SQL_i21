/*
	DEVELOPER NOTE
	- Any changes here in terms of column add - delete, please update (vyuEMEntityVendorSearch) as well
	- if there is no way to get the same value, just put null or default value to the added column
*/
CREATE VIEW [dbo].[vyuEMEntityCustomerSearch]
AS 
SELECT intEntityId			= CUSTOMER.intEntityId
	, strCustomerNumber		= entityToCustomer.strEntityNo
	, strName				= entityToCustomer.strName
	, strAccountNumber		= ISNULL(CUSTOMER.strAccountNumber,'')
	, strPhone				= entityPhone.strPhone
	, strSalesPersonName	= entityToSalesperson.strName
	, intSalespersonId		= ISNULL(shipLocation.intSalespersonId, CUSTOMER.intSalespersonId)
	, strCurrency			= custCurrency.strCurrency
	, strWarehouse			= entityLocation.strLocationName
	, intWarehouseId		= ISNULL(entityLocation.intCompanyLocationId, -99)
	, dblCreditLimit		= CUSTOMER.dblCreditLimit
	, strPricingLevelName	= entityLocationPricingLevel.strPricingLevelName
	, dtmOriginationDate	= entityToCustomer.dtmOriginationDate
	, dtmLastInvoice		= LASTINVOICE.dtmDate
	, dtmLastPayment		= LASTPAYMENT.dtmDatePaid
	, ysnActive				= CUSTOMER.ysnActive
	, strMobile				= entityContact.strMobile
	, strEmail				= entityContact.strEmail
	, strContactName		= entityContact.strName
	, intEntityContactId	= entityContact.intEntityId
	, strClass				= entityClass.strClass
	, ysnHasBudgetSetup		= ISNULL(BUDGET.ysnHasBudgetSetup, CAST(0 AS BIT))
	, intPaymentMethodId	= CUSTOMER.intPaymentMethodId
	, strPaymentMethod		= custPaymentMethod.strPaymentMethod
	, strLocationName		= custLocation.strLocationName
	, strAddress			= custLocation.strAddress
	, strCity				= custLocation.strCity
	, strState				= custLocation.strState
	, strZipCode			= custLocation.strZipCode
	, strCountry			= custLocation.strCountry
	, strShipToLocationName	= shipLocation.strLocationName
	, strShipToAddress		= shipLocation.strAddress
	, strShipToCity			= shipLocation.strCity
	, strShipToState		= shipLocation.strState
	, strShipToZipCode		= shipLocation.strZipCode
	, strShipToCountry		= shipLocation.strCountry
	, strBillToLocationName	= billLocation.strLocationName
	, strBillToAddress		= billLocation.strAddress
	, strBillToCity			= billLocation.strCity
	, strBillToState		= billLocation.strState
	, strBillToZipCode		= billLocation.strZipCode
	, strBillToCountry		= billLocation.strCountry
	, intShipToId			= shipLocation.intEntityLocationId
	, intBillToId			= billLocation.intEntityLocationId
	, dblARBalance			= CUSTOMER.dblARBalance
	, strTerm				= custTerm.strTerm
	, intCurrencyId			= CUSTOMER.intCurrencyId
	, intTermsId			= CUSTOMER.intTermsId
	, ysnProspect			= entityType.Prospect
	, ysnCustomer			= entityType.Customer
	, ysnCreditHold			= CUSTOMER.ysnCreditHold
	, ysnExemptCreditCardFee = CUSTOMER.ysnExemptCreditCardFee
	, intFreightTermId		= ISNULL(shipLocation.intFreightTermId, custLocation.intFreightTermId)
	, strFreightTerm		= fTerms.strFreightTerm
	, strFobPoint			= fTerms.strFobPoint
	, intShipViaId			= custLocation.intShipViaId
	, strShipViaName		= shipVia.strShipVia
	, strInternalNotes		= entityToCustomer.strInternalNotes
	, ysnPORequired			= ISNULL(CUSTOMER.ysnPORequired, CAST(0 AS BIT))
	, intCreditStopDays		= CUSTOMER.intCreditStopDays
	, strCreditCode			= CUSTOMER.strCreditCode
	, dtmCreditLimitReached = CUSTOMER.dtmCreditLimitReached
	, intCreditLimitReached = DATEDIFF(DAYOFYEAR, CUSTOMER.dtmCreditLimitReached, GETDATE())
	, ysnHasPastDueBalances	= CAST(0 AS BIT)
	, strEntityType = CASE WHEN entityType.Prospect = 1 THEN 'Prospect' ELSE 'Customer' END COLLATE Latin1_General_CI_AS
	, ysnHasCustomerCreditApprover	= CAST(CASE WHEN CUSTOMERCREDITAPPROVER.intApproverCount > 0 THEN 1 ELSE 0 END AS BIT)
	, CUSTOMER.ysnApplySalesTax
	, dblShipToLongitude		= shipLocation.dblLongitude
	, dblShipToLatitude			= shipLocation.dblLatitude
	, strAccountType = NULLIF(CUSTOMER.strType, '')
	, intDefaultPayFromBankAccountId = CUSTOMER.intDefaultPayFromBankAccountId
	, strDefaultPayFromBankAccountNo = CUSTOMER.strDefaultPayFromBankAccountNo
	, strPaymentInstructions		= CMBA.strPaymentInstructions
FROM tblARCustomer CUSTOMER  WITH (NOLOCK) 
INNER JOIN tblEMEntity entityToCustomer ON CUSTOMER.intEntityId = entityToCustomer.intEntityId
LEFT JOIN tblEMEntityToContact entityToContact ON entityToCustomer.intEntityId = entityToContact.intEntityId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity entityContact ON entityContact.intEntityId = entityToContact.intEntityContactId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntityLocation custLocation ON CUSTOMER.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation shipLocation ON CUSTOMER.intShipToId = shipLocation.intEntityLocationId AND shipLocation.ysnActive = 1
LEFT JOIN tblEMEntityLocation billLocation ON CUSTOMER.intBillToId = billLocation.intEntityLocationId AND billLocation.ysnActive = 1
LEFT JOIN tblEMEntity entityToSalesperson ON entityToSalesperson.intEntityId = ISNULL(shipLocation.intSalespersonId, CUSTOMER.intSalespersonId)
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityToContact.intEntityContactId = entityPhone.intEntityId
LEFT JOIN tblSMTerm entityLocationTerm ON custLocation.intTermsId = entityLocationTerm.intTermID
LEFT JOIN tblSMCurrency custCurrency ON CUSTOMER.intCurrencyId = custCurrency.intCurrencyID
LEFT JOIN tblSMCompanyLocation entityLocation ON custLocation.intWarehouseId = entityLocation.intCompanyLocationId
LEFT JOIN vyuEMEntityType entityType ON CUSTOMER.intEntityId = entityType.intEntityId
LEFT JOIN tblSMCompanyLocationPricingLevel entityLocationPricingLevel ON CUSTOMER.intCompanyLocationPricingLevelId = entityLocationPricingLevel.intCompanyLocationPricingLevelId
LEFT JOIN tblEMEntityClass entityClass ON entityToCustomer.intEntityClassId = entityClass.intEntityClassId
LEFT JOIN tblSMPaymentMethod custPaymentMethod ON CUSTOMER.intPaymentMethodId = custPaymentMethod.intPaymentMethodID
LEFT JOIN tblSMTerm custTerm ON CUSTOMER.intTermsId = custTerm.intTermID
LEFT JOIN tblSMFreightTerms fTerms ON ISNULL(shipLocation.intFreightTermId, custLocation.intFreightTermId) = fTerms.intFreightTermId
LEFT JOIN tblSMShipVia shipVia on shipLocation.intShipViaId = shipVia.intEntityId
LEFT JOIN (
	SELECT dtmDate				= MAX(INV.dtmDate)
		 , intEntityCustomerId	= INV.intEntityCustomerId
	FROM dbo.tblARInvoice INV WITH (NOLOCK) 
	GROUP BY INV.intEntityCustomerId
) LASTINVOICE ON LASTINVOICE.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT dtmDatePaid			= MAX(PAYMENT.dtmDatePaid)
		 , intEntityCustomerId	= PAYMENT.intEntityCustomerId 
	FROM dbo.tblARPayment PAYMENT WITH (NOLOCK) 
	GROUP BY PAYMENT.intEntityCustomerId
) LASTPAYMENT ON LASTPAYMENT.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT ysnHasBudgetSetup	= CASE WHEN COUNT(*) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		 , intEntityCustomerId	= CB.intEntityCustomerId
	FROM dbo.tblARCustomerBudget CB WITH (NOLOCK)
	GROUP BY CB.intEntityCustomerId 
) BUDGET ON BUDGET.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT intApproverCount		= COUNT(ARC.intEntityId)
		 , intEntityId			= ARC.intEntityId
	FROM dbo.tblARCustomer ARC
	INNER JOIN dbo.tblEMEntityRequireApprovalFor ERA
		ON ARC.intEntityId = ERA.[intEntityId]
	INNER JOIN tblSMScreen SC
		ON ERA.intScreenId = SC.intScreenId
		AND SC.strScreenName = 'Invoice'
	GROUP BY ARC.intEntityId 
) CUSTOMERCREDITAPPROVER ON CUSTOMERCREDITAPPROVER.intEntityId = CUSTOMER.intEntityId
LEFT JOIN vyuCMBankAccount CMBA ON CMBA.intBankAccountId = ISNULL(CUSTOMER.intDefaultPayFromBankAccountId, 0)
WHERE (entityType.Customer = 1 OR entityType.Prospect = 1)
GO