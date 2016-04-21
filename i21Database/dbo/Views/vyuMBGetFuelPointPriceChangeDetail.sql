CREATE VIEW [dbo].[vyuMBGetFuelPointPriceChangeDetail]
	AS 
	
SELECT FPPriceChangeDetail.intFuelPointPriceChangeDetailId
	, FPPriceChangeDetail.intFuelPointPriceChangeId
	, FPPriceChange.strCustomerName
	, FPPriceChange.strCustomerNumber
	, FPPriceChange.strLocationName
	, FPPriceChange.dtmDate
	, FPPriceChangeDetail.strFuelingPoint
	, FPPriceChangeDetail.strProductNo
	, FPPriceChangeDetail.dblPrice
	, FPPriceChangeDetail.ysnBilled
	, FPPriceChangeDetail.intSort
FROM tblMBFuelPointPriceChangeDetail FPPriceChangeDetail
LEFT JOIN vyuMBGetFuelPointPriceChange FPPriceChange ON FPPriceChange.intFuelPointPriceChangeId = FPPriceChangeDetail.intFuelPointPriceChangeId
