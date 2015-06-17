CREATE VIEW vyuAPBill
WITH SCHEMABINDING
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
	A.intEntityVendorId,
	B1.strName,
	C.strAccountId,
	Payment.strPaymentInfo,
	Payment.strBankAccountNo,
	F.strUserName AS strUserId,
	Payment.ysnPrinted,
	Payment.ysnVoid,
	Payment.intPaymentId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEntity B1 ON B.[intEntityVendorId] = B1.intEntityId)
	ON A.[intEntityVendorId] = B.[intEntityVendorId]
	INNER JOIN dbo.tblGLAccount C
		ON A.intAccountId = C.intAccountId
	OUTER APPLY
	(
		SELECT TOP 1
			D.intBillId
			,D.intPaymentId
			,D.strPaymentInfo
			,D.strBankAccountNo
			,D.ysnPrinted
			,D.ysnVoid
		FROM dbo.vyuAPBillPayment D
		WHERE A.intBillId = D.intBillId
		ORDER BY D.intBillId, D.dtmDatePaid DESC --get only the latest payment
	) Payment
	LEFT JOIN dbo.tblEntityCredential F ON A.intEntityId = F.intEntityId
