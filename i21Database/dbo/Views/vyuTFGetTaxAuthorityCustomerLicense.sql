CREATE VIEW [dbo].[vyuTFGetTaxAuthorityCustomerLicense]
	AS
	
SELECT CustLicense.intTaxAuthorityCustomerLicenseId
	, TA.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, TA.strDescription
	, CustLicense.intEntityId
	, Customer.strCustomerNumber
	, Customer.strName
	, CustLicense.strLicenseNumber
	, CustLicense.intConcurrencyId
FROM tblTFTaxAuthorityCustomerLicense CustLicense
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = CustLicense.intTaxAuthorityId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = CustLicense.intEntityId