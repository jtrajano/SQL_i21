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
		(tblAPVendor B INNER JOIN tblEntity B1 ON B.intEntityVendorId = B1.intEntityId)
	ON A.intVendorId = B.intEntityVendorId
	INNER JOIN tblGLAccount C
		ON A.intAccountId = C.intAccountId
	OUTER APPLY
	(
		SELECT TOP 1
			D.intBillId
			,E.strPaymentInfo
		FROM tblAPPaymentDetail D
			INNER JOIN tblAPPayment E ON D.intPaymentId = E.intPaymentId
		WHERE E.ysnPosted = 1 AND A.intBillId = D.intBillId
		ORDER BY intBillId, E.dtmDatePaid DESC --get only the latest payment
	) Payment