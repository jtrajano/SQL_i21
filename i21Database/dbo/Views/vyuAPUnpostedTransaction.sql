CREATE VIEW [dbo].[vyuAPUnpostedTransaction]
WITH SCHEMABINDING
	AS 

SELECT	DISTINCT
		APB.strBillId AS strTransactionId, 
		CASE  WHEN APB.intTransactionType = 1	THEN 'Bill' 
			  WHEN APB.intTransactionType = 2	THEN 'Vendor Prepayment' 
			  WHEN APB.intTransactionType = 3	THEN 'Debit Memo' 
			  WHEN APB.intTransactionType = 6	THEN 'Bill Template' 
			  ELSE 'Not Bill Type'
		END AS strTransactionType,
		APB.dtmDate
FROM dbo.tblAPBill APB
WHERE 
	ISNULL(ysnPosted, 0) = 0 AND 
	APB.intTransactionType != 6 AND							   --Will not show BillTemplate
	APB.ysnForApproval != 1	AND								   --Will not show For Approval Bills
    (APB.ysnApproved = 0 AND APB.dtmApprovalDate IS NULL)	   --Will not show Rejected approval bills  

UNION 

SELECT DISTINCT 
	  APP.strPaymentRecordNum AS strTransactionId, 
	  'Payment' AS strTransactionType,
	 APP.dtmDateCreated AS dtmDate
FROM dbo.tblAPPayment APP
INNER JOIN dbo.tblAPPaymentDetail APD ON APP.intPaymentId = APD.intPaymentId
INNER JOIN dbo.tblSMPaymentMethod SMP ON APP.intPaymentMethodId = SMP.intPaymentMethodID
WHERE APP.ysnPosted = 0