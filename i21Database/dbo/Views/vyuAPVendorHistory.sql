CREATE VIEW vyuAPVendorHistory
WITH SCHEMABINDING
AS
SELECT 
	tblAPVendor.intEntityVendorId as intEntityId
	,intVendorId = tblAPVendor.intEntityVendorId
	,strVendorId = tblAPVendor.strVendorId
	,A.dtmDate
	,intTransactionId = A.intBillId 
	,strTransactionType = 'Bill'
	,strBillId = A.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,dblTotal = ISNULL(A.dblTotal,0)
	,dblDiscount = ISNULL(B.dblDiscount, 0)
	,dblWithheld = ISNULL(B.dblWithheld, 0)
	,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END
	,A.ysnPaid
	,A.dblAmountDue
FROM dbo.tblAPBill A
		LEFT JOIN (dbo.tblAPPayment B1 
						INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
						LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId)
		 ON A.intBillId = B.intBillId
		LEFT JOIN dbo.tblAPVendor
			ON tblAPVendor.intEntityVendorId = A.intVendorId
WHERE 
1 = CASE WHEN B1.intPaymentId IS NULL 
		THEN 1
		ELSE
			(CASE WHEN B1.ysnPosted = 1 OR C.strTransactionId IS NOT NULL THEN 1 ELSE 0 END)
		END 
GROUP BY A.intBillId,
	A.dtmDate,
	A.dblTotal,
	B.dblDiscount,
	B.dblWithheld,
	tblAPVendor.intEntityVendorId,
	tblAPVendor.strVendorId,
	tblAPVendor.intEntityVendorId,
	--tblAPVendor.intVendorId,
    strVendorOrderNumber,
	A.strBillId,
	A.ysnPaid,
	A.dblAmountDue
