CREATE VIEW [dbo].[vyuMBGetMeterAccountDetail]
	AS 
	
SELECT MADetail.intMeterAccountDetailId
	, MA.intMeterAccountId
	, MA.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, MA.intEntityLocationId
	, strCustomerLocation = EntityLocation.strLocationName
	, EntityLocation.strAddress
	, EntityLocation.strCity
	, EntityLocation.strState
	, EntityLocation.strZipCode
	, MA.intConsignmentGroupId
	, ConGroup.strConsignmentGroup
	, MA.intCompanyLocationId
	, strCompanyLocation = Location.strLocationName
	, MADetail.strMeterKey
	, MADetail.intItemId
	, Item.strItemNo
	, strItemDescription = strDescription
	, MADetail.strWorksheetSequence
	, MADetail.strMeterCustomerId
	, MADetail.strMeterFuelingPoint
	, MADetail.strMeterProductNumber
	, MADetail.dblLastMeterReading
	, MADetail.dblLastTotalSalesDollar
	, MADetail.intSort
FROM tblMBMeterAccountDetail MADetail 
LEFT JOIN tblMBMeterAccount MA ON MA.intMeterAccountId = MADetail.intMeterAccountId
LEFT JOIN tblICItem Item ON Item.intItemId = MADetail.intItemId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = MA.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MA.intEntityLocationId
LEFT JOIN tblMBConsignmentGroup ConGroup ON ConGroup.intConsignmentGroupId = MA.intConsignmentGroupId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = MA.intCompanyLocationId