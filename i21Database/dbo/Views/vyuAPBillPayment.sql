CREATE VIEW [dbo].[vyuAPBillPayment]
AS
SELECT 
A.intBillId
,A.strBillId
,A.dblTotal
,Payments.dblPayment AS dblPayment
,Payments.dblDiscount AS dblDiscount
,Payments.dblInterest AS dblInterest
,Payments.dblWithheld AS dblWithheld
,A.[intEntityVendorId]
,Payments.[intEntityVendorId] AS intPaymentVendor
,A.ysnPosted
,A.ysnPaid
,A.ysnOrigin
FROM tblAPBill A
	LEFT JOIN 
	(
		SELECT 
			B.[intEntityVendorId]
			,C.intBillId
			,SUM(dblPayment) dblPayment
			,SUM(dblDiscount) dblDiscount
			,SUM(dblInterest) dblInterest
			,SUM(C.dblWithheld) dblWithheld
		FROM tblAPPayment B 
			LEFT JOIN tblAPPaymentDetail C 
		ON B.intPaymentId = C.intPaymentId
		WHERE B.ysnPosted = 1
		GROUP BY [intEntityVendorId], intBillId
	) Payments
	ON A.intBillId = Payments.intBillId