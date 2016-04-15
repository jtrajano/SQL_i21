﻿CREATE VIEW [dbo].[vyuMBGetMeterAccount]
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
	, MA.intPriceType
	, MADetail.strMeterKey
	, Item.strItemNo
	, MA.intConsignmentGroupId
	, strConsignmentGroup
	, MA.intCompanyLocationId
	, strCompanyLocation = Location.strLocationName
	, MA.intSort
FROM tblMBMeterAccount MA
LEFT JOIN tblMBMeterAccountDetail MADetail ON MADetail.intMeterAccountId = MA.intMeterAccountId
LEFT JOIN tblICItem Item ON Item.intItemId = MADetail.intItemId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = MA.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MA.intEntityLocationId
LEFT JOIN tblMBConsignmentGroup ConGroup ON ConGroup.intConsignmentGroupId = MA.intConsignmentGroupId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = MA.intCompanyLocationId