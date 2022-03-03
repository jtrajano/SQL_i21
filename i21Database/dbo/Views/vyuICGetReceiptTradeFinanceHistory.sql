CREATE VIEW vyuICGetReceiptTradeFinanceHistory
AS
	SELECT 
		r.intInventoryReceiptId
		,tfh.* 
	FROM 
		tblICInventoryReceipt r INNER JOIN tblTRFTradeFinanceHistory tfh
			ON r.strTradeFinanceNumber = tfh.strTradeFinanceNumber
GO 