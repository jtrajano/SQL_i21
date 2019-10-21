CREATE VIEW [dbo].[vyuMBGetFuelPointPriceChangeDetail]
	AS 
	
SELECT FPPriceChangeDetail.intFuelPointPriceChangeDetailId
	, FPPriceChangeDetail.intFuelPointPriceChangeId
	, FPPriceChange.intEntityCustomerId
	, FPPriceChange.strCustomerName
	, FPPriceChange.strCustomerNumber
	, FPPriceChange.intEntityLocationId
	, FPPriceChange.strLocationName
	, FPPriceChange.dtmDate
	, FPPriceChangeDetail.strFuelingPoint
	, FPPriceChangeDetail.strProductNo
	, FPPriceChangeDetail.dblPrice
	, FPPriceChangeDetail.ysnBilled
	, FPPriceChangeDetail.intSort
FROM tblMBFuelPointPriceChangeDetail FPPriceChangeDetail
LEFT JOIN vyuMBGetFuelPointPriceChange FPPriceChange ON FPPriceChange.intFuelPointPriceChangeId = FPPriceChangeDetail.intFuelPointPriceChangeId
