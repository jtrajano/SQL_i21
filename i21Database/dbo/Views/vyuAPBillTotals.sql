CREATE VIEW [dbo].[vyuAPBillTotals]
AS
SELECT 
A.intBillId
,A.strBillId
,A.dblTotal
,A.intAccountId
,Details.dblTotal AS dblDetailTotal
,CASE WHEN A.intTransactionType = 1 THEN 'Bill'
	WHEN A.intTransactionType = 2 THEN 'Vendor Prepayment'
	WHEN A.intTransactionType = 3 THEN 'Debit Memo'
	WHEN A.intTransactionType = 12 THEN 'Prepayment Reversal'
	WHEN A.intTransactionType = 13 THEN 'Basis Advance'
	ELSE 'Unknown Type' END COLLATE Latin1_General_CI_AS AS TransactionType
,A.ysnOrigin
,A.ysnPosted
FROM tblAPBill A
	INNER JOIN (SELECT intBillId,SUM(dblTotal) AS dblTotal FROM tblAPBillDetail GROUP BY intBillId) Details
		ON A.intBillId = Details.intBillId