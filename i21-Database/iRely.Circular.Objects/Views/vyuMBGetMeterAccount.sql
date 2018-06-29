CREATE VIEW [dbo].[vyuMBGetMeterAccount]
	AS 

SELECT MA.intMeterAccountId
	, MA.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, MA.intEntityLocationId
	, strCustomerLocation = EntityLocation.strLocationName
	, EntityLocation.strAddress
	, EntityLocation.strCity
	, EntityLocation.strState
	, EntityLocation.strZipCode
	, MA.intTermId
	, Term.strTerm
	, Term.strTermCode
	, MA.intPriceType
	, strPriceType = (
		CASE WHEN MA.intPriceType = 1 THEN 'Gross'
			WHEN MA.intPriceType = 2 THEN 'Net' END
	)
	, MA.intConsignmentGroupId
	, ConGroup.strConsignmentGroup
	, ConGroup.strRateType
	, MA.intCompanyLocationId
	, strCompanyLocation = Location.strLocationName
	, EntityLocation.intTaxGroupId
	, MA.intSort
FROM tblMBMeterAccount MA
LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = MA.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MA.intEntityLocationId
LEFT JOIN tblSMTerm Term ON Term.intTermID = MA.intTermId
LEFT JOIN tblMBConsignmentGroup ConGroup ON ConGroup.intConsignmentGroupId = MA.intConsignmentGroupId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = MA.intCompanyLocationId