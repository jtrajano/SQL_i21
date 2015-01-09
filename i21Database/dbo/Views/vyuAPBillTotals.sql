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
	ELSE 'Unknown Type' END AS TransactionType
,A.ysnOrigin
,A.ysnPosted
FROM tblAPBill A
	INNER JOIN (SELECT intBillId,SUM(dblTotal) AS dblTotal FROM tblAPBillDetail GROUP BY intBillId) Details
		ON A.intBillId = Details.intBillId