﻿CREATE VIEW [dbo].[vyuAPUnpostedTransaction]
WITH SCHEMABINDING
	AS 

SELECT	DISTINCT
		APB.intBillId AS intTransactionId, 
		APB.strBillId AS strTransactionId, 
		CASE  WHEN APB.intTransactionType = 1	THEN 'Bill' 
			  WHEN APB.intTransactionType = 2	THEN 'Vendor Prepayment' 
			  WHEN APB.intTransactionType = 3	THEN 'Debit Memo' 
			  WHEN APB.intTransactionType = 6	THEN 'Bill Template' 
			  WHEN APB.intTransactionType = 8	THEN 'Vendor Overpayment' 
			  ELSE 'Not Bill Type'
		END AS strTransactionType,
		APB.intEntityId,
		US.strUserName,
		ISNULL(APB.strReference, '') AS strDescription,
		APB.dtmDate
FROM dbo.tblAPBill APB
INNER JOIN dbo.tblSMUserSecurity US ON APB.intEntityId = US.[intEntityUserSecurityId]
WHERE 
	ISNULL(ysnPosted, 0) = 0 AND 
	APB.intTransactionType NOT IN (6,8,2,9,11,12) AND		   --Will not show (BillTemplate/ Over Payment / Prepayment / 1099Ajd / Claims  / Payment reversal)
	APB.ysnForApproval != 1	AND								   --Will not show For Approval Bills
	APB.ysnRecurring != 1 AND								   --Will not show Recurring Voucher Transaction 
    (APB.ysnApproved = 0)									   --Will not show Rejected approval bills

UNION 

SELECT DISTINCT 
		APP.intPaymentId AS intTransactionId,
		APP.strPaymentRecordNum AS strTransactionId, 
		'Payment' AS strTransactionType,
		APP.intEntityId,
		US.strUserName,
		ISNULL(APP.strNotes, '') AS strDescription,
		APP.dtmDateCreated AS dtmDate
FROM dbo.tblAPPayment APP
INNER JOIN dbo.tblAPPaymentDetail APD ON APP.intPaymentId = APD.intPaymentId
INNER JOIN dbo.tblSMPaymentMethod SMP ON APP.intPaymentMethodId = SMP.intPaymentMethodID
INNER JOIN dbo.tblSMUserSecurity US ON US.[intEntityUserSecurityId] = APP.intEntityId
WHERE APP.ysnPosted = 0 AND APP.strPaymentInfo NOT LIKE '%Voided%'