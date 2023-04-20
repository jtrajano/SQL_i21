CREATE VIEW [dbo].[vyuMBGetFuelPointReadingDetail]
	AS
	
SELECT FPReadingDetail.intFuelPointReadingDetailId
	, FPReadingDetail.intConcurrencyId
	, FPReadingDetail.intFuelPointReadingId
	, FPReading.intEntityCustomerId
	, FPReading.strCustomerName
	, FPReading.strCustomerNumber
	, FPReading.intEntityLocationId
	, strLocationName = FPReading.strEntityLocationName
	, FPReading.dtmDate
	, FPReadingDetail.strFuelingPoint
	, FPReadingDetail.strProductNo
	, FPReadingDetail.dblVolume
	, FPReadingDetail.dblPrice
	, FPReadingDetail.intSort
FROM tblMBFuelPointReadingDetail FPReadingDetail
LEFT JOIN vyuMBGetFuelPointReading FPReading ON FPReading.intFuelPointReadingId = FPReadingDetail.intFuelPointReadingId