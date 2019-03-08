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
	A.intTermsId AS intTermsId,
	editTerm.intTermID AS intNewTermsId,
	term.strTerm AS strTerm,
	editTerm.strTerm AS strNewTerm,
	A.ysnPosted,
	A.ysnPaid,
	CAST(CASE WHEN edit.intId IS NULL THEN 0 ELSE 1 END AS BIT) ysnSelected,
	edit.intEntityId AS intUserId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityId]
	OUTER APPLY tblAPBillEditField editField
	LEFT JOIN dbo.tblAPBillEdit edit
		ON A.intBillId = edit.intBillId
	LEFT JOIN dbo.tblSMTerm term
		ON A.intTermsId = term.intTermID
	LEFT JOIN dbo.tblSMTerm editTerm
		ON editTerm.intTermID = editField.intTermsId
	OUTER APPLY (
		SELECT TOP 1 intContractDetailId FROM tblAPBillDetail detail
		WHERE 
			detail.intBillId = A.intBillId
		AND detail.intContractDetailId > 0
	) details
	OUTER APPLY (
		SELECT C.intTermId, restrictedTerm.intCount intCount FROM tblAPVendorTerm C 
		OUTER APPLY (
			SELECT COUNT(*) intCount FROM tblAPVendorTerm C2 WHERE C2.intEntityVendorId = A.intEntityVendorId
		) restrictedTerm
		WHERE 
			C.intEntityVendorId = A.intEntityVendorId
	) vendorTerm
WHERE 
	A.ysnPaid = 0
AND A.intTransactionType = 1
AND details.intContractDetailId IS NULL
AND (
		(vendorTerm.intCount > 0 AND vendorTerm.intTermId = editField.intTermsId) --if there is term on edit field and term have data on restriction
		OR
		(vendorTerm.intCount > 0 AND NULLIF(editField.intTermsId, 0) IS NULL) --if there is term data restriction and no value of term on edit field
		OR
		(vendorTerm.intCount IS NULL) --no vendor term restriction setup
	)
--ORDER BY A.intBillId OFFSET 1 ROWS FETCH NEXT 500 ROWS ONLY
	

