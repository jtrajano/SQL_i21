CREATE VIEW [dbo].[vyuMBGetMeterReading]
	AS 
	
SELECT MR.intMeterReadingId
	, MR.strTransactionId
	, MR.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, MR.intEntityLocationId
	, strCustomerLocation = EntityLocation.strLocationName
	, strCompanyLocation = Location.strLocationName
	, MR.dtmTransaction
	, MR.intSort
FROM tblMBMeterReading MR
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = MR.intEntityCustomerId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MR.intEntityLocationId
LEFT JOIN tblMBMeterAccount MA ON MA.intEntityCustomerId = MR.intEntityCustomerId AND MA.intEntityLocationId = MR.intEntityLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = MA.intCompanyLocationId
