CREATE VIEW [dbo].[vyuMBGetMeterAccountDetail]
	AS 
	
SELECT MADetail.intMeterAccountDetailId
	, MADetail.intMeterAccountId
	, MA.intEntityCustomerId
	, MA.strCustomerName
	, MA.strCustomerNumber
	, MA.intEntityLocationId
	, MA.strCustomerLocation
	, MA.intConsignmentGroupId
	, MA.strConsignmentGroup
	, MA.intCompanyLocationId
	, MA.strCompanyLocation
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
LEFT JOIN vyuMBGetMeterAccount MA ON MA.intMeterAccountId = MADetail.intMeterAccountId
LEFT JOIN tblICItem Item ON Item.intItemId = MADetail.intItemId
