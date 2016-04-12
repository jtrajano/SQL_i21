CREATE VIEW [dbo].[vyuMBGetFuelPointReading]
	AS
	
SELECT FPReading.intFuelPointReadingId
	, FPReading.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, FPReading.intEntityLocationId
	, EntityLocation.strLocationName
	, FPReading.dtmDateFrom
	, FPReading.dtmDateTo
	, FPReading.intSort
FROM tblMBFuelPointReading FPReading
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = FPReading.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = FPReading.intEntityLocationId