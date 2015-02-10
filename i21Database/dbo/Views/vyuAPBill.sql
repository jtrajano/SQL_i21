CREATE VIEW vyuAPBill
AS
SELECT
	A.intBillId,
	A.strBillId,
	A.dblTotal,
	A.ysnPosted,
	A.ysnPaid,
	A.dtmDate,
	A.dtmBillDate,
	A.strVendorOrderNumber,
	A.intTransactionType,
	B1.strName,
	C.strAccountId,
	Payment.strPaymentInfo
FROM
	tblAPBill A
	INNER JOIN 
		(tblAPVendor B INNER JOIN tblEntity B1 ON B.intEntityId = B1.intEntityId)
	ON A.intVendorId = B.intVendorId
	INNER JOIN tblGLAccount C
		ON A.intAccountId = C.intAccountId
	LEFT JOIN vyuAPBillLatestPayment AS Payment ON A.intBillId = Payment.intBillId AND Id = 1 --get only the latest payment info