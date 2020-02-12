CREATE VIEW [dbo].[vyuAPReceiptClearingGL]
AS 

SELECT 
DISTINCT
    ad.strAccountId
    ,ad.intAccountId
    ,t.strTransactionId
    ,t.intTransactionDetailId
    ,t.intTransactionId
    ,t.intItemId
FROM 
	tblICInventoryTransaction t 
	INNER JOIN tblGLDetail gd
		ON t.strTransactionId = gd.strTransactionId
		AND t.intInventoryTransactionId = gd.intJournalLineNo
	INNER JOIN vyuGLAccountDetail ad
		ON gd.intAccountId = ad.intAccountId
WHERE
	--t.strTransactionId = receipt.strReceiptNumber
	--AND t.intItemId = receiptItem.intItemId
	ad.intAccountCategoryId = 45
	AND t.ysnIsUnposted = 0 
	AND (gd.dblCredit != 0 OR gd.dblDebit != 0)
