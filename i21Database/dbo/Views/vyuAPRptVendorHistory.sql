CREATE VIEW [dbo].[vyuAPRptVendorHistory]
AS

SELECT 
	strVendorId = tblAPVendor.strVendorId
	,tblAPVendor.[intEntityVendorId]
	--,tblAPVendor.[intEntityVendorId]
	,A.dtmDate
	,A.dtmBillDate
	,intTransactionId = A.intBillId 
	,CASE WHEN A.intTransactionType = 1 THEN 'Bill' 
		WHEN A.intTransactionType = 2 THEN 'Vendor Prepayment' 
		WHEN A.intTransactionType = 3 THEN 'Debit Memo' 
	ELSE 'Not Bill Type'
	END AS strTransactionType 
	,strBillId = A.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,dblTotal = (CASE WHEN A.intTransactionType != 1 AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END)
	,dblDiscount = ISNULL(Payments.dblDiscount,0)
	,dblWithheld = ISNULL(Payments.dblWithheld,0)
	,dblInterest = ISNULL(Payments.dblInterest,0)
	,dblAmountPaid = ISNULL(Payments.dblPayment, 0) - ISNULL(Payments.dblWithheld,0)
	,A.ysnPaid
	,strVendorOrderNumber
	,A.strReference
	,dblAmountDue = (CASE WHEN A.intTransactionType != 1 AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END) - 
				ISNULL(((Payments.dblPayment + Payments.dblDiscount) - Payments.dblInterest),0)
FROM dbo.tblAPBill A
LEFT JOIN dbo.tblAPVendor
	ON tblAPVendor.[intEntityVendorId] = A.[intEntityVendorId]
OUTER APPLY
(
	SELECT
		C.intBillId
		,SUM(CASE WHEN D.intTransactionType != 1 AND C.dblPayment > 0 THEN C.dblPayment * -1 ELSE C.dblPayment END) dblPayment
		,SUM(C.dblDiscount) dblDiscount
		,SUM(C.dblInterest) dblInterest
		,SUM(C.dblWithheld) dblWithheld
	FROM dbo.tblAPPayment B
		INNER JOIN dbo.tblAPPaymentDetail C
			ON B.intPaymentId = C.intPaymentId
		INNER JOIN dbo.tblAPBill D
			ON C.intBillId = D.intBillId
	WHERE B.ysnPosted = 1 
	AND A.intBillId = C.intBillId
	GROUP BY C.intBillId
) Payments