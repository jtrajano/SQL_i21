CREATE VIEW [dbo].[vyuEMEntityCustomerSearch]
AS 
SELECT DISTINCT
	  intEntityId			= CUSTOMER.intEntityId
	, strCustomerNumber		= entityToCustomer.strEntityNo --CUSTOMER.strCustomerNumber
	, strName				= entityToCustomer.strName
	, strPhone				= entityPhone.strPhone
	, strSalesPersonName	= entityToSalesperson.strName
	, intSalespersonId		= CUSTOMER.intSalespersonId
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
	, strLineOfBusiness		= dbo.fnEMGetEntityLineOfBusiness(CUSTOMER.intEntityId) --LOB.strLineOfBusiness
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
	, intShipToId			= CUSTOMER.intShipToId
	, intBillToId			= CUSTOMER.intBillToId
	, dblARBalance			= CUSTOMER.dblARBalance
	, strTerm				= custTerm.strTerm
	, intCurrencyId			= CUSTOMER.intCurrencyId
	, intTermsId			= CUSTOMER.intTermsId
	, intLineOfBusinessIds	= LINEOFBUSINESS.intEntityLineOfBusinessIds
	, ysnProspect			= entityType.Prospect
	, ysnCustomer			= entityType.Customer
	, ysnCreditHold			= CUSTOMER.ysnCreditHold
	, intFreightTermId		= ISNULL(shipLocation.intFreightTermId, custLocation.intFreightTermId)
	, strFreightTerm		= fTerms.strFreightTerm
	, intShipViaId			= custLocation.intShipViaId
	, strShipViaName		= shipVia.strShipVia
	, ysnPORequired			= ISNULL(CUSTOMER.ysnPORequired, CAST(0 AS BIT))
	, strEntityType = CASE WHEN entityType.Prospect = 1 THEN 'Prospect' ELSE 'Customer' END
FROM tblARCustomer CUSTOMER
INNER JOIN tblEMEntity entityToCustomer ON CUSTOMER.intEntityId = entityToCustomer.intEntityId
LEFT JOIN tblEMEntity entityToSalesperson ON CUSTOMER.intSalespersonId = entityToSalesperson.intEntityId
LEFT JOIN tblEMEntityToContact entityToContact ON entityToCustomer.intEntityId = entityToContact.intEntityId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity entityContact ON entityContact.intEntityId = entityToContact.intEntityContactId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntityLocation custLocation ON CUSTOMER.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation shipLocation ON CUSTOMER.intShipToId = shipLocation.intEntityLocationId
LEFT JOIN tblEMEntityLocation billLocation ON CUSTOMER.intBillToId = billLocation.intEntityLocationId
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityToContact.intEntityContactId = entityPhone.intEntityId
LEFT JOIN tblSMTerm entityLocationTerm ON custLocation.intTermsId = entityLocationTerm.intTermID
LEFT JOIN tblSMCurrency custCurrency ON CUSTOMER.intCurrencyId = custCurrency.intCurrencyID
LEFT JOIN tblSMCompanyLocation entityLocation ON custLocation.intWarehouseId = entityLocation.intCompanyLocationId
LEFT JOIN vyuEMEntityType entityType ON CUSTOMER.intEntityId = entityType.intEntityId
LEFT JOIN tblSMCompanyLocationPricingLevel entityLocationPricingLevel ON CUSTOMER.intCompanyLocationPricingLevelId = entityLocationPricingLevel.intCompanyLocationPricingLevelId
--LEFT JOIN tblEMEntityLineOfBusiness entityLOB ON CUSTOMER.intEntityId = entityLOB.intEntityId
--LEFT JOIN tblSMLineOfBusiness LOB ON entityLOB.intLineOfBusinessId = LOB.intLineOfBusinessId
LEFT JOIN tblEMEntityClass entityClass ON entityToCustomer.intEntityClassId = entityClass.intEntityClassId
LEFT JOIN tblSMPaymentMethod custPaymentMethod ON CUSTOMER.intPaymentMethodId = custPaymentMethod.intPaymentMethodID
LEFT JOIN tblSMTerm custTerm ON CUSTOMER.intTermsId = custTerm.intTermID
LEFT JOIN tblSMFreightTerms fTerms ON ISNULL(shipLocation.intFreightTermId, custLocation.intFreightTermId) = fTerms.intFreightTermId
LEFT JOIN tblSMShipVia shipVia on shipLocation.intShipViaId = shipVia.intEntityId
OUTER APPLY (
	SELECT dtmDate = MAX(INV.dtmDate) 
	FROM dbo.tblARInvoice INV WITH (NOLOCK) 
	WHERE INV.intEntityCustomerId = CUSTOMER.intEntityId
) LASTINVOICE
OUTER APPLY (
	SELECT dtmDatePaid = MAX(PAYMENT.dtmDatePaid) 
	FROM dbo.tblARPayment PAYMENT WITH (NOLOCK) 
	WHERE PAYMENT.intEntityCustomerId = CUSTOMER.intEntityId
) LASTPAYMENT
OUTER APPLY (
	SELECT ysnHasBudgetSetup = CASE WHEN COUNT(*) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM dbo.tblARCustomerBudget WITH (NOLOCK)
	WHERE intEntityCustomerId = CUSTOMER.intEntityId
) BUDGET
OUTER APPLY (
	SELECT intEntityLineOfBusinessIds = intLineOfBusinessId
	FROM (
		SELECT CAST(intLineOfBusinessId AS VARCHAR(200)) + CASE WHEN CAST(intLineOfBusinessId AS VARCHAR(200)) <> NULL THEN '|^|' ELSE '' END
		FROM dbo.tblEMEntityLineOfBusiness WITH(NOLOCK)
		WHERE intEntityId = CUSTOMER.intEntityId
		FOR XML PATH ('')
	) INV (intLineOfBusinessId)
) LINEOFBUSINESS
WHERE (entityType.Customer = 1 OR entityType.Prospect = 1)
GO