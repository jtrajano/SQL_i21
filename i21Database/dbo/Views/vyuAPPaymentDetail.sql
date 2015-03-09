CREATE VIEW [dbo].[vyuAPPaymentDetail]
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
	INNER JOIN dbo.tblAPBill C
		ON A.intBillId = C.intBillId
	INNER JOIN dbo.tblAPVendor D
		ON B.intVendorId = D.intEntityVendorId
	INNER JOIN dbo.tblEntity E
		ON D.intEntityVendorId = E.intEntityId
	INNER JOIN dbo.tblGLAccount F
		ON A.intAccountId = F.intAccountId
	INNER JOIN dbo.tblSMTerm G
		ON C.intTermsId = G.intTermID