﻿CREATE VIEW [dbo].[vyuAPRptVendorHistory]
AS

SELECT 
	strVendorId = tblAPVendor.strVendorId
	,tblAPVendor.[intEntityVendorId]
	,ISNULL(tblAPVendor.strVendorId, '') + ' - ' + isnull(tblEntity.strName,'''') as strVendorIdName 
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
	,dblDiscount = ISNULL(Payments.dblDiscount,0)
	,dblWithheld = ISNULL(Payments.dblWithheld,0)
	,dblInterest = ISNULL(Payments.dblInterest,0)
	,dblAmountPaid = ISNULL(Payments.dblPayment, 0) - ISNULL(Payments.dblWithheld,0)
	,A.ysnPaid
	,strVendorOrderNumber
	,A.strReference
	,dblAmountDue = A.dblTotal - ((Payments.dblPayment + Payments.dblDiscount) - Payments.dblInterest)
FROM dbo.tblAPBill A
LEFT JOIN dbo.tblAPVendor
	ON tblAPVendor.[intEntityVendorId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEntity
	ON dbo.tblEntity.intEntityId = dbo.tblAPVendor.intEntityVendorId
OUTER APPLY
(
	SELECT
		C.intBillId
		,SUM(C.dblPayment) dblPayment
		,SUM(C.dblDiscount) dblDiscount
		,SUM(C.dblInterest) dblInterest
		,SUM(C.dblWithheld) dblWithheld
	FROM dbo.tblAPPayment B
		INNER JOIN dbo.tblAPPaymentDetail C
			ON B.intPaymentId = C.intPaymentId
	WHERE B.ysnPosted = 1 AND A.intBillId = C.intBillId
	GROUP BY C.intBillId
) Payments