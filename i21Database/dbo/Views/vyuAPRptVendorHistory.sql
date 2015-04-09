﻿CREATE VIEW [dbo].[vyuAPRptVendorHistory]
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
		,dblTotal = ISNULL(A.dblTotal,0)
		,dblDiscount = A.dblDiscount
		,dblWithheld = A.dblWithheld
		,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END
		,A.ysnPaid
		,strVendorOrderNumber
		,A.strReference
		,A.dblAmountDue
	FROM dbo.tblAPBill A
			LEFT JOIN (dbo.tblAPPayment B1 INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId)
			 ON A.intBillId = B.intBillId
			LEFT JOIN dbo.tblAPVendor
				ON tblAPVendor.[intEntityVendorId] = A.[intEntityVendorId]
	WHERE 
	1 = CASE WHEN B1.intPaymentId IS NULL 
		THEN 1
		ELSE
			(CASE WHEN B1.ysnPosted = 1 THEN 1 ELSE 0 END)
		END 
	GROUP BY A.intBillId,
		A.dtmDate,
		A.dtmBillDate,
		A.dblTotal,
		A.dblDiscount,
		A.dblWithheld,
		A.strReference,
		A.intTransactionType,
		tblAPVendor.strVendorId,
		tblAPVendor.[intEntityVendorId],
		tblAPVendor.[intEntityVendorId],
		strVendorOrderNumber,
		A.strBillId,
		A.ysnPaid,
		A.dblAmountDue
	
