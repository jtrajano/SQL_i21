CREATE VIEW [dbo].[vyuMBGetFuelPointReadingDetail]
	AS
	
SELECT FPReadingDetail.intFuelPointReadingDetailId
	, FPReadingDetail.intFuelPointReadingId
	, FPReading.strCustomerName
	, FPReading.strCustomerNumber
	, FPReading.strLocationName
	, FPReading.dtmDate
	, FPReadingDetail.strFuelingPoint
	, FPReadingDetail.strProductNo
	, FPReadingDetail.dblVolume
	, FPReadingDetail.dblPrice
	, FPReadingDetail.intSort
FROM tblMBFuelPointReadingDetail FPReadingDetail
LEFT JOIN vyuMBGetFuelPointReading FPReading ON FPReading.intFuelPointReadingId = FPReadingDetail.intFuelPointReadingId