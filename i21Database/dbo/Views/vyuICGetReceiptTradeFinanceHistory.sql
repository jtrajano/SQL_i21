CREATE VIEW vyuICGetReceiptTradeFinanceHistory
AS
	SELECT 
		r.intInventoryReceiptId
		,tfh.* 
	FROM 
		tblICInventoryReceipt r 
		CROSS APPLY (
			SELECT 
				intTradeFinanceHistoryId = MIN (tfh.intTradeFinanceHistoryId)  
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.strTradeFinanceNumber = r.strTradeFinanceNumber 		
		) firstLog 
		CROSS APPLY (
			SELECT 
				* 
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.strTradeFinanceNumber = r.strTradeFinanceNumber 
				AND (
					tfh.strTransactionNumber = r.strReceiptNumber
					OR tfh.intTradeFinanceHistoryId <= firstLog.intTradeFinanceHistoryId
				)
		) tfh 
GO 