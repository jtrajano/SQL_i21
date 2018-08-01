CREATE VIEW [dbo].[vyuMBILInvoice]
	AS
	
SELECT Invoice.intInvoiceId
	, Invoice.strInvoiceNo
	, Invoice.intOrderId
	, Invoice.intEntityCustomerId
	, strCustomerNo = Customer.strEntityNo
	, strCustomerName = Customer.strName
	, Invoice.intLocationId
	, Location.strLocationName
	, Invoice.strType
	, Invoice.dtmDeliveryDate
	, Invoice.dtmInvoiceDate
	, Invoice.intDriverId
	, Driver.strDriverNo
	, Driver.strDriverName
	, Invoice.intShiftId
	, Shift.intShiftNumber
	, Invoice.strComments
	, Invoice.dblTotal
	, Invoice.intTermId
	, Invoice.ysnPosted
	, Invoice.intConcurrencyId
FROM tblMBILInvoice Invoice
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = Invoice.intEntityCustomerId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Invoice.intLocationId
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Invoice.intDriverId
LEFT JOIN tblMBILShift Shift ON Shift.intShiftId = Invoice.intShiftId
LEFT JOIN tblSMTerm Term ON Term.intTermID = Invoice.intTermId