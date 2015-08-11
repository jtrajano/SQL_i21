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
WHERE ISNULL(ysnPosted, 0) = 0
