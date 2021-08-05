CREATE VIEW [dbo].[vyuRestApiVoucherChecks]
AS
SELECT 
	  p.intPaymentId
	, p.intBillId
	, pp.strPaymentRecordNum strRecordNo
	, pp.intEntityId
	, p.intLocationId
	, pp.strPayTo strPayTo
	, pp.intCurrencyId
	, pp.strCurrency
	, pp.dtmDatePaid
	, pp.dblAmountPaid
	, pp.strPaymentInfo strCheckNumber
	, pp.strPaymentMethod
FROM vyuAPBillPayment p
INNER JOIN vyuAPPayments pp ON pp.intPaymentId = p.intPaymentId
INNER JOIN vyuAPRestApiVoucher v ON v.intVoucherId = p.intBillId