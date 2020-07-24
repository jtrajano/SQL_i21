CREATE VIEW [dbo].[vyuMBILInvoice]
	AS
	
SELECT Invoice.intInvoiceId
	, Invoice.strInvoiceNo
	, Invoice.intOrderId
	, (SELECT TOP 1 strOrderNumber FROM tblMBILOrder WHERE intOrderId = Invoice.intOrderId) AS strOrderNumber
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
	, InvoiceShift.intShiftNumber
	, CASE WHEN InvoiceShift.intShiftNumber IS NULL THEN CONVERT(NVARCHAR(50),InvoiceShift.strShiftNo)  ELSE CONVERT(NVARCHAR(50),InvoiceShift.intShiftNumber) END as strShiftNo
	, Invoice.strComments
	, Invoice.strVoidComments
	, ISNULL(dblTotal,0) as dblTotal
	, Invoice.intTermId
	, Term.strTerm
	, Invoice.ysnPosted
	, Invoice.ysnVoided
	, Invoice.dtmPostedDate
	, Invoice.dtmVoidedDate
	, Invoice.inti21InvoiceId
	, stri21InvoiceNo = i21Invoice.strInvoiceNumber
	, Invoice.intConcurrencyId
	, strStatus = dbo.fnMBILGetInvoiceStatus(Invoice.intEntityCustomerId, NULL) COLLATE Latin1_General_CI_AS
FROM tblMBILInvoice Invoice
--LEFT JOIN tblMBILInvoiceItem InvoiceItem ON InvoiceItem.intInvoiceId = Invoice.intInvoiceId
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = Invoice.intEntityCustomerId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Invoice.intLocationId
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Invoice.intDriverId
LEFT JOIN tblMBILShift InvoiceShift ON InvoiceShift.intShiftId = Invoice.intShiftId
LEFT JOIN tblMBILOrder InvoiceOrder ON InvoiceOrder.intOrderId = Invoice.intOrderId
LEFT JOIN tblSMTerm Term ON Term.intTermID = InvoiceOrder.intTermId
LEFT JOIN tblARInvoice i21Invoice ON i21Invoice.intInvoiceId = Invoice.inti21InvoiceId