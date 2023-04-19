CREATE VIEW [dbo].[vyuAPVendorStatement]
AS
--VOUCHERS
SELECT 
	A.intBillId,
	A.strVendorOrderNumber,
	dbo.fnAPGetVoucherTransactionType2(A.intTransactionType) strTransactionType,
	A.dtmBillDate,
	A.dtmDueDate,
	A.intCurrencyId,
	(B.dblTotal + B.dblTax) * (CASE WHEN A.intTransactionType IN (3,11) THEN -1 ELSE 1 END) dblTotal,
	B.intContractHeaderId,
	C.strDescription,
	A.intEntityVendorId,
	A.intShipToId,
	1 intOrder
FROM tblAPBill A
LEFT JOIN tblAPBillDetail B ON B.intBillId = A.intBillId
LEFT JOIN tblICItem C ON C.intItemId = B.intItemId
WHERE A.ysnPosted = 1
AND A.intTransactionType <> 15

--PAID PREPAYMENTS
UNION ALL
SELECT
	A.intBillId,
	A.strVendorOrderNumber,
	dbo.fnAPGetVoucherTransactionType2(A.intTransactionType),
	A.dtmBillDate,
	A.dtmDueDate,
	A.intCurrencyId,
	(B.dblTotal + B.dblTax) * -1,
	B.intContractHeaderId,
	C.strDescription,
	A.intEntityVendorId,
	A.intShipToId,
	1 intOrder
FROM tblAPBill A
LEFT JOIN tblAPBillDetail B ON B.intBillId = A.intBillId
LEFT JOIN tblICItem C ON C.intItemId = B.intItemId
WHERE A.ysnPosted = 1 AND A.intTransactionType IN (2, 13)

--DELETED VOUCHERS
UNION ALL
SELECT 
	A.intBillId,
	A.strVendorOrderNumber,
	dbo.fnAPGetVoucherTransactionType2(A.intTransactionType),
	A.dtmBillDate,
	A.dtmDueDate,
	A.intCurrencyId,
	(B.dblTotal + B.dblTax) * (CASE WHEN A.intTransactionType IN (3,11) THEN -1 ELSE 1 END),
	B.intContractHeaderId,
	C.strDescription,
	A.intEntityVendorId,
	A.intShipToId,
	2 intOrder
FROM .tblAPBillArchive A	
LEFT JOIN tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN tblICItem C ON C.intItemId = B.intItemId
WHERE A.ysnPosted = 1
AND A.intTransactionType <> 15

--AP PAYMENTS
UNION ALL
SELECT
	NULL,
	NULL,
	'Payment',
	A.dtmDatePaid,
	A.dtmDatePaid,
	A.intCurrencyId,
	B.dblPayment * -1,
	NULL,
	'PAYMENT ' + '(' + A.strPaymentRecordNum + ')',
	A.intEntityVendorId,
	A.intCompanyLocationId,
	3 intOrder
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON B.intPaymentId = A.intPaymentId
LEFT JOIN tblAPBill C ON C.intBillId = ISNULL(B.intBillId, B.intOrigBillId) AND C.intTransactionType <> 15
LEFT JOIN tblAPBillArchive D ON D.intBillId = ISNULL(B.intBillId, B.intOrigBillId) AND D.intTransactionType <> 15
WHERE A.ysnPosted = 1 AND B.ysnOffset = 0

--AR PAYMENTS
UNION ALL
SELECT
	NULL,
	NULL,
	'Payment',
	A.dtmDatePaid,
	A.dtmDatePaid,
	A.intCurrencyId,
	B.dblPayment * -1,
	NULL,
	'PAYMENT ' + '(' + A.strRecordNumber + ')',
	A.intEntityCustomerId,
	A.intLocationId,
	3 intOrder
FROM tblARPayment A
INNER JOIN tblARPaymentDetail B ON B.intPaymentId = A.intPaymentId
LEFT JOIN tblAPBill C ON C.intBillId = B.intBillId AND C.intTransactionType <> 15
WHERE A.ysnPosted = 1

--PREPAYMENTS APPLIED TO PAYMENT
UNION ALL
SELECT
	ISNULL(C.intBillId, D.intBillId) intBillId,
	ISNULL(C.strVendorOrderNumber, D.strVendorOrderNumber) strVendorOrderNumber,
	dbo.fnAPGetVoucherTransactionType2(ISNULL(C.intTransactionType, D.intTransactionType)),
	A.dtmDatePaid,
	A.dtmDatePaid,
	A.intCurrencyId,
	B.dblPayment * -1,
	NULL,
	'APPLIED VENDOR PREPAYMENT ' + '(' + A.strPaymentRecordNum + ')',
	A.intEntityVendorId,
	A.intCompanyLocationId,
	5 intOrder
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON B.intPaymentId = A.intPaymentId
LEFT JOIN tblAPBill C ON C.intBillId = ISNULL(B.intBillId, B.intOrigBillId) AND C.intTransactionType <> 15
LEFT JOIN tblAPBillArchive D ON D.intBillId = ISNULL(B.intBillId, B.intOrigBillId) AND D.intTransactionType <> 15
WHERE A.ysnPosted = 1 AND B.ysnOffset = 1

--PREPAYMENTS APPLIED TO VOUCHERS
UNION ALL
SELECT 
	B.intBillId,
	B.strVendorOrderNumber,
	dbo.fnAPGetVoucherTransactionType2(B.intTransactionType),
	C.dtmDate,
	C.dtmDate,
	C.intCurrencyId,
	A.dblAmountApplied,
	NULL,
	'APPLIED VENDOR PREPAYMENT ' + '(' + C.strVendorOrderNumber + ')',
	C.intEntityVendorId,
	C.intShipToId,
	5 intOrder
FROM tblAPAppliedPrepaidAndDebit A
INNER JOIN tblAPBill B ON B.intBillId = A.intTransactionId
INNER JOIN tblAPBill C ON C.intBillId = A.intBillId
WHERE C.ysnPosted = 1 AND A.ysnApplied = 1
AND C.intTransactionType <> 15

--VOUCHERS WITH APPLIED PAYMENTS
UNION ALL
SELECT 
	C.intBillId,
	C.strVendorOrderNumber,
	dbo.fnAPGetVoucherTransactionType2(C.intTransactionType),
	C.dtmDate,
	C.dtmDate,
	C.intCurrencyId,
	A.dblAmountApplied * -1,
	NULL,
	'APPLIED VENDOR PREPAYMENT ' + '(' + B.strVendorOrderNumber + ')',
	C.intEntityVendorId,
	C.intShipToId,
	5 intOrder
FROM tblAPAppliedPrepaidAndDebit A
INNER JOIN tblAPBill B ON B.intBillId = A.intTransactionId
INNER JOIN tblAPBill C ON C.intBillId = A.intBillId
WHERE C.ysnPosted = 1 AND A.ysnApplied = 1
AND C.intTransactionType <> 15
