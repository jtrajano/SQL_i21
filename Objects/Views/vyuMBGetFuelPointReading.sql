CREATE VIEW [dbo].[vyuMBGetFuelPointReading]
	AS
	
SELECT FPReading.intFuelPointReadingId
	, FPReading.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, FPReading.intEntityLocationId
	, EntityLocation.strLocationName
	, FPReading.dtmDate
	, FPReading.intSort
FROM tblMBFuelPointReading FPReading
LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = FPReading.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = FPReading.intEntityLocationId