CREATE VIEW vyuAPVendorHistory
WITH SCHEMABINDING
AS
SELECT 
	tblAPVendor.intEntityId
	,intVendorId = tblAPVendor.intVendorId
	,strVendorId = tblAPVendor.strVendorId
	,A.dtmDate
	,intTransactionId = A.intBillId 
	,strTransactionType = 'Bill'
	,strBillId = A.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,dblTotal = ISNULL(A.dblTotal,0)
	,dblDiscount = A.dblDiscount
	,dblWithheld = A.dblWithheld
	,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END
	,A.ysnPaid
	,A.dblAmountDue

FROM dbo.tblAPBill A
		LEFT JOIN (dbo.tblAPPayment B1 INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId)
		 ON A.intBillId = B.intBillId
		LEFT JOIN dbo.tblAPVendor
			ON tblAPVendor.intVendorId = A.intVendorId
WHERE 
1 = CASE WHEN B1.intPaymentId IS NULL 
		THEN 1
		ELSE
			(CASE WHEN B1.ysnPosted = 1 THEN 1 ELSE 0 END)
		END 
GROUP BY A.intBillId,
	A.dtmDate,
	A.dblTotal,
	A.dblDiscount,
	A.dblWithheld,
	tblAPVendor.intVendorId,
	tblAPVendor.strVendorId,
	tblAPVendor.intEntityId,
	tblAPVendor.intVendorId,
    strVendorOrderNumber,
	A.strBillId,
	A.ysnPaid,
	A.dblAmountDue
