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
	, MR.intCompanyLocationId
	, MR.strCompanyLocation
	, MR.dtmTransaction
	, MADetail.intMeterAccountId
	, MADetail.intMeterAccountDetailId
	, MR.strInvoiceComment
	, MR.intInvoiceId
	, MR.strInvoiceNumber
	, MADetail.intItemId
	, MADetail.strItemNo
	, MADetail.strItemDescription
	, intItemUOMId = ItemLocation.intIssueUOMId
	, strUnitMeasure = ItemLocation.strIssueUOM
	, MRDetail.dblGrossPrice
	, MRDetail.dblNetPrice
	, MADetail.strMeterKey
	, MRDetail.dblLastReading
	, MRDetail.dblCurrentReading
	, dblQuantitySold = MRDetail.dblCurrentReading - MRDetail.dblLastReading
	, MRDetail.dblLastDollars
	, MRDetail.dblCurrentDollars
	, dblDollarsSold = MRDetail.dblCurrentDollars - MRDetail.dblLastDollars
	, MR.ysnPosted
	, MR.dtmPostedDate
	, MRDetail.intSort
FROM vyuMBGetMeterReading MR
LEFT JOIN tblMBMeterReadingDetail MRDetail ON MR.intMeterReadingId = MRDetail.intMeterReadingId
LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId
LEFT JOIN vyuICGetItemLocation ItemLocation ON ItemLocation.intItemId = MADetail.intItemId AND ItemLocation.intLocationId = MR.intCompanyLocationId