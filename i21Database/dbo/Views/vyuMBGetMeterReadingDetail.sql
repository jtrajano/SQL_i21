CREATE VIEW [dbo].[vyuMBGetMeterReadingDetail]
	AS 
	
SELECT MRDetail.intMeterReadingDetailId
	, MRDetail.intMeterReadingId
	, MR.strTransactionId
	, MR.intEntityCustomerId
	, MR.strCustomerName
	, MR.strCustomerNumber
	, MR.intEntityLocationId
	, MR.strCustomerLocation
	, MR.strCompanyLocation
	, MR.dtmTransaction
	, MRDetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, MRDetail.dblGrossPrice
	, MRDetail.dblNetPrice
	, MADetail.strMeterKey
	, MADetail.dblLastMeterReading
	, MRDetail.dblCurrentReading
	, dblQuantitySold = MRDetail.dblCurrentReading - MADetail.dblLastMeterReading
	, MADetail.dblLastTotalSalesDollar
	, MRDetail.dblCurrentDollars
	, dblDollarsSold = MRDetail.dblCurrentDollars - MRDetail.dblCurrentDollars
	, MRDetail.intSort
FROM tblMBMeterReadingDetail MRDetail
LEFT JOIN vyuMBGetMeterReading MR ON MR.intMeterReadingId = MRDetail.intMeterReadingId
LEFT JOIN tblICItem Item ON Item.intItemId = MRDetail.intItemId
LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intEntityCustomerId = MR.intEntityCustomerId AND MADetail.intEntityLocationId = MR.intEntityLocationId