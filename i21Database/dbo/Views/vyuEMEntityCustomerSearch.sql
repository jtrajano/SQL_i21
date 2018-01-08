CREATE VIEW [dbo].[vyuEMEntityCustomerSearch]
	AS SELECT DISTINCT
	cust.intEntityId, 
	cust.strCustomerNumber, 
	entityToCustomer.strName AS strCustomerName,
	entityPhone.strPhone,
	custLocation.strAddress,
	entityToSalesperson.strName AS strSalesPerson, 
	custLocation.strCity,
	custLocation.strState,
	custLocation.strZipCode,
	custCurrency.strCurrency,
	entityLocation.strLocationName AS strWarehouse,
	intWarehouseId = ISNULL(entityLocation.intCompanyLocationId, -99),
	cust.dblCreditLimit,
	entityLocationPricingLevel.strPricingLevelName,
	entityToCustomer.dtmOriginationDate,
	entityLocationTerm.strTerm,
	MAX(custInvoice.dtmDate) AS dtmLastInvoice,
	MAX(custPayment.dtmDatePaid) AS dtmLastPayment,
	cust.ysnActive,
	entityContact.strMobile,
	entityContact.strEmail,
	LOB.strLineOfBusiness,
	entityClass.strClass
FROM tblARCustomer cust
INNER JOIN tblEMEntity entityToCustomer ON cust.intEntityId = entityToCustomer.intEntityId
LEFT JOIN tblEMEntity entityToSalesperson ON cust.intSalespersonId = entityToSalesperson.intEntityId
LEFT JOIN tblEMEntityToContact entityToContact ON entityToCustomer.intEntityId = entityToContact.intEntityId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity entityContact ON entityContact.intEntityId = entityToContact.intEntityContactId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntityLocation custLocation ON cust.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityToContact.intEntityContactId = entityPhone.intEntityId
LEFT JOIN tblSMTerm entityLocationTerm ON custLocation.intTermsId = entityLocationTerm.intTermID
LEFT JOIN tblSMCurrency custCurrency ON cust.intCurrencyId = custCurrency.intCurrencyID
LEFT JOIN tblSMCompanyLocation entityLocation ON custLocation.intWarehouseId = entityLocation.intCompanyLocationId
LEFT JOIN vyuEMEntityType entityType ON cust.intEntityId = entityType.intEntityId
LEFT JOIN tblSMCompanyLocationPricingLevel entityLocationPricingLevel ON cust.intCompanyLocationPricingLevelId = entityLocationPricingLevel.intCompanyLocationPricingLevelId
LEFT JOIN tblARInvoice custInvoice ON cust.intEntityId = custInvoice.intEntityCustomerId
LEFT JOIN tblARPayment custPayment ON cust.intEntityId = custPayment.intEntityCustomerId
LEFT JOIN tblEMEntityLineOfBusiness entityLOB ON cust.intEntityId = entityLOB.intEntityId
LEFT JOIN tblSMLineOfBusiness LOB ON entityLOB.intLineOfBusinessId = LOB.intLineOfBusinessId
LEFT JOIN tblEMEntityClass entityClass ON entityToCustomer.intEntityClassId = entityClass.intEntityClassId

WHERE		
		entityType.Customer = 1 -- check if entity is a customer
		OR custInvoice.dtmDate = (SELECT MAX(dtmDate) FROM tblARInvoice x WHERE x.intEntityCustomerId = x.intEntityCustomerId)
GROUP BY 
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
	intWarehouseId,
	cust.dblCreditLimit,
	entityLocationPricingLevel.strPricingLevelName,
	entityToCustomer.dtmOriginationDate,
	entityLocationTerm.strTerm,
	cust.ysnActive,
	entityPhone.strPhone,
	entityContact.strMobile,
	entityContact.strEmail,
	LOB.strLineOfBusiness,
	entityClass.strClass
GO