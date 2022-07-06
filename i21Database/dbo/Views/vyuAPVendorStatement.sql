CREATE VIEW [dbo].[vyuAPVendorStatement]
AS
--VOUCHERS
SELECT 
	A.intBillId,
	A.strBillId,
	dbo.fnAPGetVoucherTransactionType2(A.intTransactionType) strTransactionType,
	A.dtmBillDate,
	A.dtmDueDate,
	A.intCurrencyId,
	(CASE WHEN A.intTransactionType NOT IN (1, 14) THEN -1 ELSE 1 END) * (B.dblTotal + B.dblTax) dblTotal,
	B.intContractHeaderId,
	C.strDescription,
	A.intEntityVendorId,
	A.intShipToId,
	1 intOrder
FROM tblAPBill A
LEFT JOIN tblAPBillDetail B ON B.intBillId = A.intBillId
LEFT JOIN tblICItem C ON C.intItemId = B.intItemId
WHERE A.ysnPosted = 1 AND A.intTransactionType NOT IN (2, 7, 12, 13)

--DELETED VOUCHERS
UNION ALL
SELECT 
	A.intBillId,
	A.strBillId,
	dbo.fnAPGetVoucherTransactionType2(A.intTransactionType) strTransactionType,
	A.dtmBillDate,
	A.dtmDueDate,
	A.intCurrencyId,
	(CASE WHEN A.intTransactionType NOT IN (1, 14) THEN -1 ELSE 1 END) * (B.dblTotal + B.dblTax),
	B.intContractHeaderId,
	C.strDescription,
	A.intEntityVendorId,
	A.intShipToId,
	2 intOrder
FROM .tblAPBillArchive A	
LEFT JOIN tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN tblICItem C ON C.intItemId = B.intItemId
WHERE A.ysnPosted = 1 AND A.intTransactionType NOT IN (2, 7, 12, 13)

--PAYMENTS
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
LEFT JOIN tblAPBill C ON C.intBillId = ISNULL(B.intBillId, B.intOrigBillId)
LEFT JOIN tblAPBillArchive D ON D.intBillId = ISNULL(B.intBillId, B.intOrigBillId)
WHERE A.ysnPosted = 1 AND (C.intBillId IS NOT NULL OR D.intBillId IS NOT NULL) AND (C.intTransactionType NOT IN (2, 7, 12, 13) OR D.intTransactionType NOT IN (2, 7, 12, 13))