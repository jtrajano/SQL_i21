CREATE VIEW [dbo].[vyuMBILShiftTransaction]
	AS
	
SELECT strRecordType = 'Invoice'
	, intReferenceId = Invoice.intInvoiceId
	, strRefNo = Invoice.strInvoiceNo
	, intEntityId = Invoice.intEntityCustomerId
	, Invoice.strCustomerNo
	, Invoice.strCustomerName
	, dblTotal = Invoice.dblTotal
	, Invoice.ysnPosted
FROM vyuMBILInvoice Invoice

UNION ALL

SELECT strRecordType = 'Payment'
	, intReferenceId = Payment.intPaymentId
	, strRefNo = Payment.strPaymentNo
	, strCustomerNumber = Entity.strEntityNo
	, intEntityId = Payment.intEntityCustomerId
	, strCustomerName = Entity.strName
	, dblTotal = Payment.dblPayment
	, Payment.ysnPosted
FROM tblMBILPayment Payment
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = Payment.intEntityCustomerId