CREATE VIEW [dbo].[vyuAPRptVendorHistory]
AS

SELECT 
	strVendorId = APV.strVendorId
	,APV.[intEntityVendorId]
	,ISNULL(APV.strVendorId, '') + ' - ' + isnull(E.strName,'''') as strVendorIdName 
	,APB.dtmDate
	,APB.dtmBillDate
	,intTransactionId = APB.intBillId 
	,CASE WHEN APB.intTransactionType = 1 THEN 'Bill' 
		  WHEN APB.intTransactionType = 2	THEN 'Vendor Prepayment' 
		  WHEN APB.intTransactionType = 3	THEN 'Debit Memo' 
	 ELSE 'Not Bill Type'
	 END AS strTransactionType 
	,strBillId = APB.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,CASE WHEN APB.intTransactionType IN (2,3) THEN (CASE WHEN APB.dblTotal > 0  
												        THEN ISNULL(APB.dblTotal * -1,0) 
														ELSE ISNULL(APB.dblTotal,0) 
												     END)
	 ELSE ISNULL(APB.dblTotal,0) 
	 END AS dblTotal
	,dblDiscount = ISNULL(Payments.dblDiscount,0)
	,dblWithheld = ISNULL(Payments.dblWithheld,0)
	,dblInterest = ISNULL(Payments.dblInterest,0)
	,dblAmountPaid = ISNULL(Payments.dblPayment, 0) - ISNULL(Payments.dblWithheld,0)
	,APB.ysnPaid
	,strVendorOrderNumber
	,APB.strReference
	,dblAmountDue = CASE WHEN APB.intTransactionType IN (2,3) THEN (CASE WHEN APB.dblTotal > 0  
																	   THEN ISNULL(APB.dblTotal * -1,0) 
																	   ELSE ISNULL(APB.dblTotal,0) 
																    END)
					ELSE ISNULL(APB.dblTotal,0) 
					END - ((Payments.dblPayment + Payments.dblDiscount) - Payments.dblInterest)
FROM dbo.tblAPBill APB
LEFT JOIN dbo.tblAPVendor APV
	ON APV.[intEntityVendorId] = APB.[intEntityVendorId]
LEFT JOIN dbo.tblEntity E
	ON E.intEntityId = APV.intEntityVendorId
OUTER APPLY
(
	SELECT
		APPD.intBillId
		,SUM(APPD.dblPayment) dblPayment
		,SUM(APPD.dblDiscount) dblDiscount
		,SUM(APPD.dblInterest) dblInterest
		,SUM(APPD.dblWithheld) dblWithheld
	FROM dbo.tblAPPayment APP
		INNER JOIN dbo.tblAPPaymentDetail APPD
			ON APP.intPaymentId = APPD.intPaymentId
	WHERE APP.ysnPosted = 1 AND APB.intBillId = APPD.intBillId
	GROUP BY APPD.intBillId
) Payments
WHERE  
		APB.ysnForApproval != 1									   --Will not show For Approval Bills
	AND (APB.ysnApproved != 0 AND APB.dtmApprovalDate IS NOT NULL) --Will not show Rejected approval bills
	AND APB.intTransactionType != 6								   --Will not showBillTemplate