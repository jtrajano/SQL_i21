﻿CREATE VIEW vyuAPBill
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
	F.strUserName AS strUserId
FROM
	tblAPBill A
	INNER JOIN 
		(tblAPVendor B INNER JOIN tblEntity B1 ON B.intEntityId = B1.intEntityId)
	ON A.intVendorId = B.intVendorId
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
	LEFT JOIN dbo.tblSMUserSecurity F ON A.intEntityId = F.intEntityId