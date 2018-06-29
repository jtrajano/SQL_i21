CREATE VIEW [dbo].[vyuMBGetMeterReading]
	AS 
	
SELECT MR.intMeterReadingId
	, MR.strTransactionId
	, MR.intMeterAccountId
	, MR.intInvoiceId
	, MR.strInvoiceComment
	, Invoice.strInvoiceNumber
	, MA.intEntityCustomerId
	, MA.strCustomerName
	, MA.strCustomerNumber
	, MA.intEntityLocationId
	, MA.strCustomerLocation
	, MA.intCompanyLocationId
	, MA.strCompanyLocation
	, MR.dtmTransaction
	, MR.ysnPosted
	, MR.dtmPostedDate
	, MR.intEntityId
	, MR.intSort
FROM tblMBMeterReading MR
LEFT JOIN vyuMBGetMeterAccount MA ON MA.intMeterAccountId = MR.intMeterAccountId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = MA.intCompanyLocationId
LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = MR.intInvoiceId