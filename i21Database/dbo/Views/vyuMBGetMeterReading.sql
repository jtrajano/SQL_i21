CREATE VIEW [dbo].[vyuMBGetMeterReading]
	AS 
	
SELECT MR.intMeterReadingId
	, MR.strTransactionId
	, MR.intMeterAccountId
	, MA.intEntityCustomerId
	, MA.strCustomerName
	, MA.strCustomerNumber
	, MA.intEntityLocationId
	, MA.strCustomerLocation
	, MA.strCompanyLocation
	, MR.dtmTransaction
	, MR.intSort
FROM tblMBMeterReading MR
LEFT JOIN vyuMBGetMeterAccount MA ON MA.intMeterAccountId = MR.intMeterAccountId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = MA.intCompanyLocationId