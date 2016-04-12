CREATE VIEW [dbo].[vyuMBGetFuelPointPriceChangeDetail]
	AS 
	
SELECT FPPriceChangeDetail.intFuelPointPriceChangeDetailId
	, FPPriceChangeDetail.intFuelPointPriceChangeId
	, FPPriceChangeDetail.dtmDate
	, FPPriceChangeDetail.strFuelingPoint
	, FPPriceChangeDetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, FPPriceChangeDetail.dblPrice
	, FPPriceChangeDetail.ysnBilled
	, FPPriceChangeDetail.intSort
FROM tblMBFuelPointPriceChangeDetail FPPriceChangeDetail
LEFT JOIN tblICItem Item ON Item.intItemId = FPPriceChangeDetail.intItemId
