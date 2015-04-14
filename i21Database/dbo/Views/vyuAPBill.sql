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
	A.dtmDateCreated,
	A.intTransactionType,
	B1.strName,
	C.strAccountId,
	Payment.strPaymentInfo,
	Payment.strBankAccountNo,
	F.strUserName AS strUserId
FROM
	tblAPBill A
	INNER JOIN 
		(tblAPVendor B INNER JOIN tblEntity B1 ON B.[intEntityVendorId] = B1.intEntityId)
	ON A.[intEntityVendorId] = B.[intEntityVendorId]
	INNER JOIN tblGLAccount C
		ON A.intAccountId = C.intAccountId
	OUTER APPLY
	(
		SELECT TOP 1
			D.intBillId
			,E.strPaymentInfo
			,G.strBankAccountNo
		FROM tblAPPaymentDetail D
			INNER JOIN tblAPPayment E ON D.intPaymentId = E.intPaymentId
			INNER JOIN tblCMBankAccount G ON E.intAccountId = G.intGLAccountId
		WHERE E.ysnPosted = 1 AND A.intBillId = D.intBillId
		ORDER BY intBillId, E.dtmDatePaid DESC --get only the latest payment
	) Payment
	LEFT JOIN dbo.tblSMUserSecurity F ON A.intEntityId = F.intEntityId
