/*
	DEVELOPER NOTE
	- This view is patterned against the customer search ( vyuEMEntityCustomerSearch ). this is primarily used for AR Receive payment customer combo box for the ticket > AR-8795
	- this is to toggle where the data is coming from
	- there should be no changes here, unless vyuEMEntityCustomerSearch has one
*/
CREATE VIEW [dbo].[vyuEMEntityVendorSearch]
	AS 
SELECT DISTINCT
	  intEntityId			= Vendor.intEntityId
	, strCustomerNumber		= entityToVendor.strEntityNo
	, strName				= entityToVendor.strName
	, strAccountNumber		= '' COLLATE Latin1_General_CI_AS--ISNULL(Vendor.strAccountNumber,'')
	, strPhone				= entityPhone.strPhone
	, strSalesPersonName	= '' COLLATE Latin1_General_CI_AS--entityToSalesperson.strName
	, intSalespersonId		= null--Vendor.intSalespersonId
	, strCurrency			= custCurrency.strCurrency
	, strWarehouse			= '' COLLATE Latin1_General_CI_AS--entityLocation.strLocationName
	, intWarehouseId		= -99--ISNULL(entityLocation.intCompanyLocationId, -99)
	, dblCreditLimit		= CAST(0 AS NUMERIC(18,6))--CUSTOMER.dblCreditLimit
	, strPricingLevelName	= '' COLLATE Latin1_General_CI_AS--entityLocationPricingLevel.strPricingLevelName
	, dtmOriginationDate	= entityToVendor.dtmOriginationDate
	, dtmLastInvoice		= null
	, dtmLastPayment		= null
	, ysnActive				= Vendor.ysnPymtCtrlActive
	, strMobile				= entityContact.strMobile
	, strEmail				= entityContact.strEmail
	, strContactName		= entityContact.strName
	, intEntityContactId	= entityContact.intEntityId
	, strLineOfBusiness		= dbo.fnEMGetEntityLineOfBusiness(Vendor.intEntityId) COLLATE Latin1_General_CI_AS
	, strClass				= entityClass.strClass
	, ysnHasBudgetSetup		= CAST(0 AS BIT)
	, intPaymentMethodId	= Vendor.intPaymentMethodId
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
	, intShipToId			= Vendor.intShipFromId
	, intBillToId			= Vendor.intBillToId
	, dblARBalance			= CAST(0 AS NUMERIC(18, 6))--Vendor.dblARBalance
	, strTerm				= custTerm.strTerm
	, intCurrencyId			= Vendor.intCurrencyId
	, intTermsId			= Vendor.intTermsId
	, intLineOfBusinessIds	= LINEOFBUSINESS.intEntityLineOfBusinessIds COLLATE Latin1_General_CI_AS
	, ysnProspect			= entityType.Prospect
	, ysnCustomer			= entityType.Customer
	, ysnCreditHold			= CAST(0 AS BIT)--CUSTOMER.ysnCreditHold
	, ysnExemptCreditCardFee = CAST(0 AS BIT)
	, intFreightTermId		= ISNULL(shipLocation.intFreightTermId, custLocation.intFreightTermId)
	, strFreightTerm		= fTerms.strFreightTerm
	, strFobPoint			= fTerms.strFobPoint
	, intShipViaId			= custLocation.intShipViaId
	, strShipViaName		= shipVia.strShipVia
	, strInternalNotes		= entityToVendor.strInternalNotes
	, ysnPORequired			= CAST(0 AS BIT)--ISNULL(CUSTOMER.ysnPORequired, CAST(0 AS BIT))
	, intCreditStopDays		= 0--CUSTOMER.intCreditStopDays
	, strCreditCode			= '' COLLATE Latin1_General_CI_AS--CUSTOMER.strCreditCode
	, dtmCreditLimitReached = null--CUSTOMER.dtmCreditLimitReached
	, intCreditLimitReached = NULL--DATEDIFF(DAYOFYEAR, CUSTOMER.dtmCreditLimitReached, GETDATE())
	, ysnHasPastDueBalances	= CAST(0 AS BIT) 
	, strEntityType = 'Vendor' COLLATE Latin1_General_CI_AS
	, ysnHasCustomerCreditApprover	= NULL--CAST(CASE WHEN CUSTOMERCREDITAPPROVER.intApproverCount > 0 THEN 1 ELSE 0 END AS BIT)
	, dblShipToLongitude		= shipLocation.dblLongitude
	, dblShipToLatitude			= shipLocation.dblLatitude
	, strAccountType = CASE WHEN Vendor.intVendorType = 1 THEN 'Company' ELSE 'Person' END
	, intDisbursementBankAccountId	= NULL
	, strDisbursementBankAccountNo	= NULL
	, strPaymentInstructions		= NULL
FROM tblAPVendor Vendor
INNER JOIN tblEMEntity entityToVendor ON Vendor.intEntityId = entityToVendor.intEntityId
--LEFT JOIN tblEMEntity entityToSalesperson ON Vendor.intSalespersonId = entityToSalesperson.intEntityId
LEFT JOIN tblEMEntityToContact entityToContact ON entityToVendor.intEntityId = entityToContact.intEntityId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity entityContact ON entityContact.intEntityId = entityToContact.intEntityContactId AND entityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntityLocation custLocation ON Vendor.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation shipLocation ON Vendor.intShipFromId = shipLocation.intEntityLocationId
LEFT JOIN tblEMEntityLocation billLocation ON Vendor.intBillToId = billLocation.intEntityLocationId
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityToContact.intEntityContactId = entityPhone.intEntityId
LEFT JOIN tblSMTerm entityLocationTerm ON custLocation.intTermsId = entityLocationTerm.intTermID
LEFT JOIN tblSMCurrency custCurrency ON Vendor.intCurrencyId = custCurrency.intCurrencyID
--LEFT JOIN tblSMCompanyLocation entityLocation ON custLocation.intWarehouseId = entityLocation.intCompanyLocationId
LEFT JOIN vyuEMEntityType entityType ON Vendor.intEntityId = entityType.intEntityId
--LEFT JOIN tblSMCompanyLocationPricingLevel entityLocationPricingLevel ON Vendor.intCompanyLocationPricingLevelId = entityLocationPricingLevel.intCompanyLocationPricingLevelId
LEFT JOIN tblEMEntityClass entityClass ON entityToVendor.intEntityClassId = entityClass.intEntityClassId
LEFT JOIN tblSMPaymentMethod custPaymentMethod ON Vendor.intPaymentMethodId = custPaymentMethod.intPaymentMethodID
LEFT JOIN tblSMTerm custTerm ON Vendor.intTermsId = custTerm.intTermID
LEFT JOIN tblSMFreightTerms fTerms ON ISNULL(shipLocation.intFreightTermId, custLocation.intFreightTermId) = fTerms.intFreightTermId
LEFT JOIN tblSMShipVia shipVia on shipLocation.intShipViaId = shipVia.intEntityId
OUTER APPLY (
	SELECT intEntityLineOfBusinessIds = intLineOfBusinessId
	FROM (
		SELECT CAST(intLineOfBusinessId AS VARCHAR(200)) + CASE WHEN CAST(intLineOfBusinessId AS VARCHAR(200)) <> NULL THEN '|^|' ELSE '' END
		FROM dbo.tblEMEntityLineOfBusiness WITH(NOLOCK)
		WHERE intEntityId = Vendor.intEntityId
		FOR XML PATH ('')
	) INV (intLineOfBusinessId)
) LINEOFBUSINESS
WHERE (entityType.Vendor = 1)
