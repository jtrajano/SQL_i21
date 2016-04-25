CREATE VIEW [dbo].[vyuMBGetMeterReadingDetail]
	AS 
	
SELECT MRDetail.intMeterReadingDetailId
	, MR.intMeterReadingId
	, MR.strTransactionId
	, MR.intEntityCustomerId
	, MR.strCustomerName
	, MR.strCustomerNumber
	, MR.intEntityLocationId
	, MR.strCustomerLocation
	, MR.strCompanyLocation
	, MR.dtmTransaction
	, MADetail.intItemId
	, MADetail.strItemNo
	, MADetail.strItemDescription
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
FROM vyuMBGetMeterReading MR
LEFT JOIN tblMBMeterReadingDetail MRDetail ON MR.intMeterReadingId = MRDetail.intMeterReadingId
LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId