CREATE VIEW [dbo].[vyuTFGetTaxAuthorityCountyLocation]
	AS
	
SELECT TACL.intTaxAuthorityCountyLocationId
	, TA.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, Customer.intEntityId
	, Customer.strCustomerNumber
	, Customer.strName
	, EL.intEntityLocationId
	, EL.strLocationName
	, CL.intCountyLocationId
	, CL.strCounty
	, CL.strLocation
FROM tblTFTaxAuthorityCountyLocation TACL
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = TACL.intTaxAuthorityId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityId = TACL.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = TACL.intEntityLocationId
LEFT JOIN tblTFCountyLocation CL ON CL.intCountyLocationId = TACL.intCountyLocationId
