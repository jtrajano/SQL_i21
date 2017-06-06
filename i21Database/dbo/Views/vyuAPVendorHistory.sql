CREATE VIEW vyuAPVendorHistory
--WITH SCHEMABINDING
AS

SELECT 
	tblAPVendor.intEntityVendorId as intEntityId
	,intEntityVendorId = tblAPVendor.intEntityVendorId
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
	,dblDiscount = ISNULL(Payment.dblDiscount, 0)
	,dblWithheld = ISNULL(Payment.dblWithheld, 0)
	,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(Payment.dblPayment),0) END  
	,A.ysnPaid
	,dblAmountDue = (CASE WHEN A.intTransactionType != 1 AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE ISNULL(A.dblAmountDue,0) END) 
	,A.ysnPosted
	,Payment.strPaymentInfo
	,Payment.dtmDatePaid
	,Payment.intPaymentId
FROM dbo.tblAPBill A
		--LEFT JOIN (dbo.tblAPPayment B1 
		--				INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
		--				LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId)
		-- ON A.intBillId = B.intBillId
		 OUTER APPLY(
			SELECT TOP 1 B1.strPaymentInfo,
						 B1.dtmDatePaid,
						 B1.intPaymentId,
						 B.dblDiscount,
						 B.dblWithheld,
						 B.dblPayment FROM dbo.tblAPPayment B1
			INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId
			LEFT JOIN dbo.tblCMBankTransaction C ON B1.strPaymentRecordNum = C.strTransactionId 
			WHERE B.intBillId = A.intBillId
			ORDER BY dtmDatePaid DESC
		 )  Payment     
		LEFT JOIN dbo.tblAPVendor
			ON tblAPVendor.intEntityVendorId = A.[intEntityVendorId]

GROUP BY A.intBillId,
	A.dtmDate,
	A.dblTotal,
	Payment.dblDiscount,
	Payment.dblWithheld,
	tblAPVendor.intEntityVendorId,
	tblAPVendor.strVendorId,
	tblAPVendor.intEntityVendorId,
	--tblAPVendor.intVendorId,
    strVendorOrderNumber,
	A.strBillId,
	A.ysnPaid,
	A.dblAmountDue,
    A.ysnPosted,
	Payment.strPaymentInfo,
	Payment.intPaymentId,
	A.intTransactionType,
	Payment.dtmDatePaid