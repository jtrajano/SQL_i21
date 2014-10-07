CREATE VIEW [dbo].[vyuAPPaymentDetail]
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
FROM tblAPPaymentDetail A
	INNER JOIN tblAPPayment B
		ON A.intPaymentId = B.intPaymentId
	INNER JOIN tblAPBill C
		ON A.intBillId = C.intBillId
	INNER JOIN tblAPVendor D
		ON B.intVendorId = D.intVendorId
	INNER JOIN tblEntity E
		ON D.intEntityId = E.intEntityId
	INNER JOIN tblGLAccount F
		ON A.intAccountId = F.intAccountId
	INNER JOIN tblSMTerm G
		ON C.intTermsId = G.intTermID