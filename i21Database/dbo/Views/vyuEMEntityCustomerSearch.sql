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
	entityLocationPricingLevel.strPricingLevelName,
	entityToCustomer.dtmOriginationDate,
	entityLocationTerm.strTerm,
	MAX(custInvoice.dtmDate) AS dtmLastInvoice,
	MAX(custPayment.dtmDatePaid) AS dtmLastPayment,
	cust.ysnActive
FROM tblARCustomer cust
INNER JOIN tblEMEntity entityToCustomer ON cust.intEntityId = entityToCustomer.intEntityId
LEFT JOIN tblEMEntity entityToSalesperson ON cust.intSalespersonId = entityToSalesperson.intEntityId
LEFT JOIN tblEMEntityToContact entityContact ON entityToCustomer.intEntityId = entityContact.intEntityId AND entityContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntityLocation custLocation ON cust.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityContact.intEntityContactId = entityPhone.intEntityId
LEFT JOIN tblSMTerm entityLocationTerm ON custLocation.intTermsId = entityLocationTerm.intTermID
LEFT JOIN tblSMCurrency custCurrency ON cust.intCurrencyId = custCurrency.intCurrencyID
LEFT JOIN tblSMCompanyLocation entityLocation ON custLocation.intWarehouseId = entityLocation.intCompanyLocationId
LEFT JOIN vyuEMEntityType entityType ON cust.intEntityId = entityType.intEntityId
LEFT JOIN tblSMCompanyLocationPricingLevel entityLocationPricingLevel ON cust.intCompanyLocationPricingLevelId = entityLocationPricingLevel.intCompanyLocationPricingLevelId
LEFT JOIN tblARInvoice custInvoice ON cust.intEntityId = custInvoice.intEntityCustomerId
LEFT JOIN tblARPayment custPayment ON cust.intEntityId = custPayment.intEntityCustomerId
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
	entityLocationPricingLevel.strPricingLevelName,
	entityToCustomer.dtmOriginationDate,
	entityLocationTerm.strTerm,
	cust.ysnActive,
	entityPhone.strPhone
GO