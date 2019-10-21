CREATE VIEW [dbo].[vyuMBGetMeterAccountDetail]
	AS 
	
SELECT MADetail.intMeterAccountDetailId
	, MA.intMeterAccountId
	, MA.intEntityCustomerId
	, MA.strCustomerName
	, MA.strCustomerNumber
	, MA.intEntityLocationId
	, MA.strCustomerLocation
	, MA.intTaxGroupId
	, MA.strAddress
	, MA.strCity
	, MA.strState
	, MA.strZipCode
	, MA.intTermId
	, MA.strTerm
	, MA.strTermCode
	, MA.intPriceType
	, MA.strPriceType
	, MA.intConsignmentGroupId
	, MA.strConsignmentGroup
	, MA.strRateType
	, MA.intCompanyLocationId
	, MA.strCompanyLocation
	, MADetail.strMeterKey
	, dblGrossPrice = ItemPrice.dblSalePrice + 0 -- ADD taxes
	, dblNetPrice = ItemPrice.dblSalePrice
	, MADetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, MADetail.strWorksheetSequence
	, MADetail.strMeterCustomerId
	, MADetail.strMeterFuelingPoint
	, MADetail.strMeterProductNumber
	, MADetail.dblLastMeterReading
	, MADetail.dblLastTotalSalesDollar
	, MADetail.intSort
FROM vyuMBGetMeterAccount MA
LEFT JOIN tblMBMeterAccountDetail MADetail ON MA.intMeterAccountId = MADetail.intMeterAccountId
LEFT JOIN tblICItem Item ON Item.intItemId = MADetail.intItemId
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = MADetail.intItemId AND ItemLocation.intLocationId = MA.intCompanyLocationId
LEFT JOIN tblICItemPricing ItemPrice ON ItemPrice.intItemId = MADetail.intItemId AND ItemPrice.intItemLocationId = ItemLocation.intItemLocationId
