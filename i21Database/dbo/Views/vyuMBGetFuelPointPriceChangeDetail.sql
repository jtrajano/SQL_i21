CREATE VIEW [dbo].[vyuMBGetFuelPointPriceChangeDetail]
	AS 
	
SELECT FPPriceChangeDetail.intFuelPointPriceChangeDetailId
	, FPPriceChangeDetail.intFuelPointPriceChangeId
	, FPPriceChangeDetail.dtmDate
	, FPPriceChangeDetail.strFuelingPoint
	, FPPriceChangeDetail.strProductNo
	, FPPriceChangeDetail.dblPrice
	, FPPriceChangeDetail.ysnBilled
	, FPPriceChangeDetail.intSort
FROM tblMBFuelPointPriceChangeDetail FPPriceChangeDetail
