CREATE VIEW [dbo].[vyuAPBillPayment]
AS
SELECT 
A.intBillId
,A.strBillId
,A.dblTotal
,Payments.dblPayment AS dblPayment
,A.intVendorId
,Payments.intVendorId AS intPaymentVendor
,A.ysnPosted
,A.ysnPaid
,A.ysnOrigin
FROM tblAPBill A
	LEFT JOIN 
	(
		SELECT 
			B.intVendorId
			,C.intBillId
			,SUM(dblPayment) + SUM(dblDiscount) dblPayment
		FROM tblAPPayment B 
			LEFT JOIN tblAPPaymentDetail C 
		ON B.intPaymentId = C.intPaymentId
		WHERE B.ysnPosted = 1
		GROUP BY intVendorId, intBillId
	) Payments
	ON A.intBillId = Payments.intBillId