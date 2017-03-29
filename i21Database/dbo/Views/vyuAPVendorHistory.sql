CREATE VIEW vyuAPVendorHistory
--WITH SCHEMABINDING
AS

SELECT 
	tblAPVendor.[intEntityId] as intEntityId
	,intEntityVendorId = tblAPVendor.[intEntityId]
	,strVendorId = tblAPVendor.strVendorId
	,A.dtmDate
	,intTransactionId = A.intBillId 
	,strTransactionType = (CASE WHEN A.intTransactionType = 1	THEN 'Bill' 
								WHEN A.intTransactionType = 2	THEN 'Vendor Prepayment' 
								WHEN A.intTransactionType = 3	THEN 'Debit Memo' 
								ELSE 'Not Bill Type'
						   END)
	,strBillId = A.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,dblTotal = (CASE WHEN A.intTransactionType != 1 AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE ISNULL(A.dblTotal,0) END)
	,dblDiscount = ISNULL(B.dblDiscount, 0)
	,dblWithheld = ISNULL(B.dblWithheld, 0)
	,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END  
	,A.ysnPaid
	,dblAmountDue = (CASE WHEN A.intTransactionType != 1 AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE ISNULL(A.dblAmountDue,0) END) 
	,A.ysnPosted
	,B1.strPaymentInfo
	,B1.dtmDatePaid
	,B1.intPaymentId
FROM dbo.tblAPBill A
		LEFT JOIN (dbo.tblAPPayment B1 
						INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
						LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId)
		 ON A.intBillId = B.intBillId
		LEFT JOIN dbo.tblAPVendor
			ON tblAPVendor.[intEntityId] = A.[intEntityVendorId]
--WHERE 
--1 = CASE WHEN B1.intPaymentId IS NULL 
--		THEN 1
--		ELSE
--			(CASE WHEN B1.ysnPosted = 1 OR C.strTransactionId IS NOT NULL THEN 1 ELSE 0 END)
--		END 
GROUP BY A.intBillId,
	A.dtmDate,
	A.dblTotal,
	B.dblDiscount,
	B.dblWithheld,
	tblAPVendor.[intEntityId],
	tblAPVendor.strVendorId,
	tblAPVendor.[intEntityId],
	--tblAPVendor.intVendorId,
    strVendorOrderNumber,
	A.strBillId,
	A.ysnPaid,
	A.dblAmountDue,
    A.ysnPosted,
	B1.strPaymentInfo,
	B1.intPaymentId,
	A.intTransactionType,
	B1.dtmDatePaid