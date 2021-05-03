CREATE VIEW [dbo].[vyuRestApiVoucherChecks]
AS
SELECT 
	  p.intPaymentId
	, p.intBillId
	, pp.strPaymentRecordNum strRecordNo
	, pp.intEntityId
	, pp.strVendorId strVendorNo
	, p.intLocationId
	, v.strName strVendorName
	, pp.intCurrencyId
	, pp.strCurrency
	, pp.dtmDatePaid
	, pp.dblAmountPaid
	, pp.strPaymentInfo strCheckNumber
FROM vyuAPBillPayment p
INNER JOIN vyuAPPayments pp ON pp.intPaymentId = p.intPaymentId
INNER JOIN vyuAPRestApiVoucher v ON v.intVoucherId = p.intBillId
WHERE pp.strPaymentMethod = 'Check'