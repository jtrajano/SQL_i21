CREATE VIEW [dbo].[vyuMBGetFuelPointReading]
	AS
	
SELECT FPReading.intFuelPointReadingId
	, FPReading.intEntityCustomerId
	, FPReading.intConcurrencyId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, FPReading.intEntityLocationId
	, strEntityLocationName = EntityLocation.strLocationName 
	--, strLocationName = EntityLocation.strLocationName 
	, FPReading.dtmDate
	, FPReading.intSort
FROM tblMBFuelPointReading FPReading
LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = FPReading.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = FPReading.intEntityLocationId