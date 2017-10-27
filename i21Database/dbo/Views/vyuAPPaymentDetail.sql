﻿CREATE VIEW [dbo].[vyuAPPaymentDetail]
WITH SCHEMABINDING
AS 
SELECT 
	A.intPaymentDetailId,
	B.strPaymentRecordNum,
	B.strNotes,
	A.dblPayment,
	A.dblWithheld,
	A.dblDiscount,
	A.dblInterest,
	A.dblTotal,
	A.dblAmountDue,
	C.strBillId,
	C.strVendorOrderNumber,
	C.dtmDueDate,
	D.strVendorId,
	E.strName,
	F.strAccountId,
	G.strTerm
FROM dbo.tblAPPaymentDetail A
	INNER JOIN dbo.tblAPPayment B
		ON A.intPaymentId = B.intPaymentId
	LEFT JOIN dbo.tblAPBill C
		ON ISNULL(A.intBillId,A.intOrigBillId) = C.intBillId
	INNER JOIN dbo.tblAPVendor D
		ON B.[intEntityVendorId] = D.[intEntityId]
	INNER JOIN dbo.tblEMEntity E
		ON D.[intEntityId] = E.intEntityId
	INNER JOIN dbo.tblGLAccount F
		ON A.intAccountId = F.intAccountId
	INNER JOIN dbo.tblSMTerm G
		ON C.intTermsId = G.intTermID