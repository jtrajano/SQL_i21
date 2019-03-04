CREATE VIEW [dbo].[vyuAPVoucherForEdit]
AS

SELECT
	A.strBillId,
	A.intBillId,
	CASE A.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2,13) AND A.ysnPrepayHasPayment = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	-- CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2,13) AND A.ysnPrepayHasPayment = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	-- CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2,13) AND A.ysnPrepayHasPayment = 1) THEN A.dblPayment * -1 ELSE A.dblPayment END AS dblPayment,
	A.dtmDate,
	A.dtmBillDate,
	A.dtmDueDate,
	A.strVendorOrderNumber,
	A.intTransactionType,
	B.strVendorId,
	A.intEntityVendorId,
	B1.strName,
	A.intTermsId,
	term.strTerm,
	A.ysnPosted,
	A.ysnPaid,
	CAST(CASE WHEN edit.intId IS NULL THEN 0 ELSE 1 END AS BIT) ysnSelected,
	edit.intEntityId AS intUserId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityId]
	LEFT JOIN dbo.tblSMTerm term
		ON A.intTermsId = term.intTermID
	LEFT JOIN dbo.tblAPBillEdit edit
		ON A.intBillId = edit.intBillId
WHERE 
	A.ysnPaid = 0
AND A.intTransactionType = 1
	

