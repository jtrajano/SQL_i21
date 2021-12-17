CREATE VIEW [dbo].[vyuFAAPBill]
AS 
SELECT
	AP.intBillId,
	AP.strBillId,
	AP.intEntityVendorId,	-- Vendor Id
	B1.strName strVendorName,-- Vendor Name	
	AP.strVendorOrderNumber,-- Invoice No
	AP.dtmBillDate,			-- Invoice Date
	CASE WHEN (AP.intTransactionType IN (3,8,11)) OR (AP.intTransactionType IN (2, 13) AND AP.ysnPrepayHasPayment = 1) THEN AP.dblTotal * -1 ELSE AP.dblTotal END AS dblTotal, -- Invoice Amount
	CASE AP.intTransactionType
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
	AP.intConcurrencyId
FROM tblAPBill AP
INNER JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId) 
	ON AP.[intEntityVendorId] = B.[intEntityId]
