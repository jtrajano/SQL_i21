CREATE VIEW [dbo].[vyuMBGetFuelPointReadingDetail]
	AS
	
SELECT FPReadingDetail.intFuelPointReadingDetailId
	, FPReadingDetail.intFuelPointReadingId
	, FPReadingDetail.dtmDate
	, FPReadingDetail.strFuelingPoint
	, FPReadingDetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, FPReadingDetail.dblVolume
	, FPReadingDetail.dblPrice
	, FPReadingDetail.intSort
FROM tblMBFuelPointReadingDetail FPReadingDetail
LEFT JOIN tblICItem Item ON Item.intItemId = FPReadingDetail.intItemId