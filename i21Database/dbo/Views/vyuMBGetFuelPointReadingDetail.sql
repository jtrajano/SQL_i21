CREATE VIEW [dbo].[vyuMBGetFuelPointReadingDetail]
	AS
	
SELECT FPReadingDetail.intFuelPointReadingDetailId
	, FPReadingDetail.intFuelPointReadingId
	, FPReadingDetail.dtmDate
	, FPReadingDetail.strFuelingPoint
	, FPReadingDetail.strProductNo
	, FPReadingDetail.dblVolume
	, FPReadingDetail.dblPrice
	, FPReadingDetail.intSort
FROM tblMBFuelPointReadingDetail FPReadingDetail