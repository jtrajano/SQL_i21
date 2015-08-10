CREATE VIEW [dbo].[vyuAPRptVendorHistory]
AS
SELECT 
		 strVendorId = APV.strVendorId
		,APV.[intEntityVendorId]
		,ISNULL(APV.strVendorId, '') + ' - ' + isnull(E.strName,'''') as strVendorIdName 
		,APB.dtmDate
		,APB.dtmBillDate
		,intTransactionId = APB.intBillId 
		,CASE WHEN APB.intTransactionType = 1	THEN 'Bill' 
			  WHEN APB.intTransactionType = 2	THEN 'Vendor Prepayment' 
			  WHEN APB.intTransactionType = 3	THEN 'Debit Memo' 
		 ELSE 'Not Bill Type'
		 END AS strTransactionType 
		,strBillId = APB.strBillId
		,strInvoiceNumber = APB.strVendorOrderNumber
		,dblTotal = (CASE WHEN APB.intTransactionType != 1 AND APB.dblTotal > 0 THEN APB.dblTotal * -1 ELSE APB.dblTotal END)
		,dblDiscount = ISNULL(Payments.dblDiscount,0)
		,dblWithheld = ISNULL(Payments.dblWithheld,0)
		,dblInterest = ISNULL(Payments.dblInterest,0)
		,dblAmountPaid = ISNULL(Payments.dblPayment, 0) - ISNULL(Payments.dblWithheld,0)
		,strPaymentInfo = Payments.strPaymentInfo
		,dtmDatePaid = Payments.dtmDatePaid
		,APB.ysnPaid
		,APB.strVendorOrderNumber
		,APB.strReference
		,dblAmountDue = (CASE WHEN APB.intTransactionType != 1 AND APB.dblTotal > 0  THEN APB.dblTotal * -1 ELSE APB.dblTotal END) -
						ISNULL(((Payments.dblPayment + Payments.dblDiscount) - Payments.dblInterest),0)
	FROM dbo.tblAPBill APB
	LEFT JOIN dbo.tblAPVendor APV
		ON APV.[intEntityVendorId] = APB.[intEntityVendorId]
	LEFT JOIN dbo.tblEntity E
		ON E.intEntityId = APV.intEntityVendorId
	OUTER APPLY
	(
		SELECT
			 APPD.intBillId
			,APP.strPaymentInfo
			,APP.dtmDatePaid
			,SUM(CASE WHEN APB2.intTransactionType != 1 AND APPD.dblPayment > 0 THEN APPD.dblPayment * -1 ELSE APPD.dblPayment END) dblPayment
			,SUM(APPD.dblDiscount) dblDiscount
			,SUM(APPD.dblInterest) dblInterest
			,SUM(APPD.dblWithheld) dblWithheld
		FROM dbo.tblAPPayment APP
			INNER JOIN dbo.tblAPPaymentDetail APPD
				ON APP.intPaymentId = APPD.intPaymentId
			INNER JOIN dbo.tblAPBill APB2
				ON APB2.intBillId = APPD.intBillId
		WHERE APP.ysnPosted = 1 AND APB.intBillId = APPD.intBillId
		GROUP BY APPD.intBillId, APP.strPaymentInfo,APP.dtmDatePaid
	) Payments
	WHERE  
			APB.ysnForApproval != 1									   --Will not show For Approval Bills
		AND (APB.ysnApproved = 0 AND APB.dtmApprovalDate IS NULL)	   --Will not show Rejected approval bills
		AND APB.intTransactionType != 6								   --Will not showBillTemplate