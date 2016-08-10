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
	, MADetail.intConsignmentGroupId
	, MADetail.strPriceType
	, MADetail.intTaxGroupId
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
	, dblQuantitySold = ISNULL(MRDetail.dblCurrentReading, 0) - ISNULL(MRDetail.dblLastReading, 0)
	, MRDetail.dblLastDollars
	, MRDetail.dblCurrentDollars
	, dblDollarsSold = ISNULL(MRDetail.dblCurrentDollars, 0) - ISNULL(MRDetail.dblLastDollars, 0)
	, MRDetail.dblDollarsOwed
	, dblDifference = ISNULL(MRDetail.dblDollarsOwed, 0) - (ISNULL(MRDetail.dblCurrentDollars, 0) - ISNULL(MRDetail.dblLastDollars, 0))
	, MR.ysnPosted
	, MR.dtmPostedDate
	, MRDetail.intSort
FROM vyuMBGetMeterReading MR
LEFT JOIN tblMBMeterReadingDetail MRDetail ON MR.intMeterReadingId = MRDetail.intMeterReadingId
LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId
LEFT JOIN vyuICGetItemLocation ItemLocation ON ItemLocation.intItemId = MADetail.intItemId AND ItemLocation.intLocationId = MR.intCompanyLocationId