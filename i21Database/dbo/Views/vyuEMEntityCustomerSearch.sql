CREATE VIEW [dbo].[vyuEMEntityCustomerSearch]
	AS SELECT DISTINCT
	cust.intEntityId, 
	cust.strCustomerNumber, 
	entityToCustomer.strName AS strName,
	entityPhone.strPhone,
	entityToSalesperson.strName AS strSalesPersonName,
	cust.intSalespersonId,
	custCurrency.strCurrency,
	entityLocation.strLocationName AS strWarehouse,
	intWarehouseId = ISNULL(entityLocation.intCompanyLocationId, -99),
	cust.dblCreditLimit,
	entityLocationPricingLevel.strPricingLevelName,
	entityToCustomer.dtmOriginationDate,
	--MAX(custInvoice.dtmDate) AS dtmLastInvoice,
	--MAX(custPayment.dtmDatePaid) AS dtmLastPayment,
	dtmLastInvoice = (SELECT MAX(INV.dtmDate) FROM tblARInvoice INV WHERE INV.intEntityCustomerId = cust.intEntityId ),
	dtmLastPayment = (SELECT MAX(PAYMENT.dtmDatePaid) FROM tblARPayment PAYMENT WHERE PAYMENT.intEntityCustomerId = cust.intEntityId ),
	
	cust.ysnActive,
	entityContact.strMobile,
	entityContact.strEmail,
	entityContact.strName AS strContactName,
	entityContact.intEntityId AS intEntityContactId,
	LOB.strLineOfBusiness,
	entityClass.strClass,
	ysnHasBudgetSetup = CAST(CASE WHEN (SELECT TOP 1 1 FROM tblARCustomerBudget WHERE intEntityCustomerId = cust.intEntityId) = 1 THEN 1 ELSE 0 END AS BIT),
	cust.intPaymentMethodId,
	custPaymentMethod.strPaymentMethod,
	custLocation.strLocationName,
	custLocation.strAddress,
	custLocation.strCity,
	custLocation.strState,
	custLocation.strZipCode,
	custLocation.strCountry,
	shipLocation.strLocationName AS strShipToLocationName,
	shipLocation.strAddress AS strShipToAddress,
	shipLocation.strCity AS strShipToCity,
	shipLocation.strState AS strShipToState,
	shipLocation.strZipCode AS strShipToZipCode,
	shipLocation.strCountry AS strShipToCountry,
	billLocation.strLocationName AS strBillToLocationName,
	billLocation.strAddress AS strBillToAddress,
	billLocation.strCity AS strBillToCity,
	billLocation.strState AS strBillToState,
	billLocation.strZipCode AS strBillToZipCode,
	billLocation.strCountry AS strBillToCountry,
	cust.intShipToId,
	cust.intBillToId,
	custTerm.strTerm AS strTerm,
	cust.intCurrencyId,
	cust.intTermsId,
	STUFF((SELECT '|^|' + CONVERT(VARCHAR,intLineOfBusinessId) FROM tblEMEntityLineOfBusiness te WHERE te.intEntityId = cust.intEntityId FOR XML PATH('')),1,3,'') as intLineOfBusinessIds,
	entityType.Prospect AS ysnProspect,
	cust.ysnCreditHold,
	custLocation.intFreightTermId,
	fTerms.strFreightTerm,
	custLocation.intShipViaId,
	strShipViaName = shipVia.strShipVia
FROM tblARCustomer cust
INNER JOIN tblEMEntity entityToCustomer ON cust.intEntityId = entityToCustomer.intEntityId
LEFT JOIN tblEMEntity entityToSalesperson ON cust.intSalespersonId = entityToSalesperson.intEntityId
LEFT JOIN tblEMEntityToContact entityToContact ON entityToCustomer.intEntityId = entityToContact.intEntityId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity entityContact ON entityContact.intEntityId = entityToContact.intEntityContactId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntityLocation custLocation ON cust.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation shipLocation ON cust.intShipToId = shipLocation.intEntityLocationId
LEFT JOIN tblEMEntityLocation billLocation ON cust.intBillToId = billLocation.intEntityLocationId
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityToContact.intEntityContactId = entityPhone.intEntityId
LEFT JOIN tblSMTerm entityLocationTerm ON custLocation.intTermsId = entityLocationTerm.intTermID
LEFT JOIN tblSMCurrency custCurrency ON cust.intCurrencyId = custCurrency.intCurrencyID
LEFT JOIN tblSMCompanyLocation entityLocation ON custLocation.intWarehouseId = entityLocation.intCompanyLocationId
LEFT JOIN vyuEMEntityType entityType ON cust.intEntityId = entityType.intEntityId
LEFT JOIN tblSMCompanyLocationPricingLevel entityLocationPricingLevel ON cust.intCompanyLocationPricingLevelId = entityLocationPricingLevel.intCompanyLocationPricingLevelId
/*LEFT JOIN tblARInvoice custInvoice ON cust.intEntityId = custInvoice.intEntityCustomerId
LEFT JOIN tblARPayment custPayment ON cust.intEntityId = custPayment.intEntityCustomerId*/
LEFT JOIN tblEMEntityLineOfBusiness entityLOB ON cust.intEntityId = entityLOB.intEntityId
LEFT JOIN tblSMLineOfBusiness LOB ON entityLOB.intLineOfBusinessId = LOB.intLineOfBusinessId
LEFT JOIN tblEMEntityClass entityClass ON entityToCustomer.intEntityClassId = entityClass.intEntityClassId
LEFT JOIN tblSMPaymentMethod custPaymentMethod ON cust.intPaymentMethodId = custPaymentMethod.intPaymentMethodID
LEFT JOIN tblSMTerm custTerm ON cust.intTermsId = custTerm.intTermID
LEFT JOIN tblSMFreightTerms fTerms ON custLocation.intFreightTermId = fTerms.intFreightTermId
LEFT JOIN tblSMShipVia shipVia on custLocation.intShipViaId = shipVia.intEntityId
WHERE		
		entityType.Customer = 1 -- check if entity is a customer
		OR
		entityType.Prospect = 1
		/*OR 
		custInvoice.dtmDate = (SELECT MAX(dtmDate) FROM tblARInvoice x WHERE x.intEntityCustomerId = x.intEntityCustomerId)*/
/*GROUP BY 
	cust.intEntityId,
	cust.strCustomerNumber, 
	entityToCustomer.strName, 
	entityToSalesperson.strName, 
	custLocation.strAddress,
	custLocation.strCity,
	custLocation.strState,
	custLocation.strZipCode,
	custCurrency.strCurrency,
	entityLocation.strLocationName,
	entityLocation.intCompanyLocationId,
	custLocation.intWarehouseId,
	cust.dblCreditLimit,
	entityLocationPricingLevel.strPricingLevelName,
	entityToCustomer.dtmOriginationDate,
	cust.ysnActive,
	entityPhone.strPhone,
	entityContact.strMobile,
	entityContact.strEmail,
	entityContact.strName,
	LOB.strLineOfBusiness,
	entityClass.strClass,
	custPaymentMethod.strPaymentMethod,
	cust.intPaymentMethodId,
	custLocation.strLocationName,
	custLocation.strAddress,
	custLocation.strCity,
	custLocation.strState,
	custLocation.strZipCode,
	custLocation.strCountry,
	shipLocation.strLocationName,
	shipLocation.strAddress,
	shipLocation.strCity,
	shipLocation.strState,
	shipLocation.strZipCode,
	shipLocation.strCountry,
	billLocation.strLocationName,
	billLocation.strAddress,
	billLocation.strCity,
	billLocation.strState,
	billLocation.strZipCode,
	billLocation.strCountry,
	cust.intShipToId,
	cust.intBillToId,
	custTerm.strTerm,
	cust.intSalespersonId,
	cust.intCurrencyId,
	cust.intTermsId,
	entityContact.intEntityId,
	entityType.Prospect,
	cust.ysnCreditHold*/
GO