CREATE VIEW vyuICGetReceiptTradeFinanceHistory
AS
	SELECT 
		r.intInventoryReceiptId
		,tfh.* 
	FROM 
		tblICInventoryReceipt r 
		-- Get the TF related to the IR. 
		CROSS APPLY (
			SELECT DISTINCT 
				tfh.intTradeFinanceId
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.strTransactionNumber = r.strReceiptNumber						
		) tf
		-- Get the first log in the history. 
		CROSS APPLY (
			SELECT 
				intTradeFinanceHistoryId = MIN (tfh.intTradeFinanceHistoryId)  
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.intTradeFinanceId = tf.intTradeFinanceId
		) firstLog 
		-- Get all the related history records. 
		CROSS APPLY (
			SELECT 
				* 
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.intTradeFinanceId = tf.intTradeFinanceId
				AND (
					tfh.strTransactionNumber = r.strReceiptNumber
					OR tfh.intTradeFinanceHistoryId <= firstLog.intTradeFinanceHistoryId
				)
		) tfh 
GO 