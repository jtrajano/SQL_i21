﻿CREATE VIEW vyuICGetReceiptTradeFinanceHistory
AS
	SELECT 
		r.intInventoryReceiptId
		,tfh.* 
		,ba.strNickname
	FROM 
		tblICInventoryReceipt r 
		-- Get the TF related to the IR. 
		CROSS APPLY (
			SELECT DISTINCT 
				tfh.intTradeFinanceId
				,tfh.strTradeFinanceNumber
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.strTransactionNumber = r.strReceiptNumber						
		) tf
		-- Get the first "Inventory" log in the history. 
		CROSS APPLY (
			SELECT 
				intTradeFinanceHistoryId = MIN (tfh.intTradeFinanceHistoryId)  
			FROM 
				tblTRFTradeFinanceHistory tfh
			WHERE
				tfh.intTradeFinanceId = tf.intTradeFinanceId
				AND tfh.strTransactionNumber = r.strReceiptNumber
		) firstLog 
		-- Get all the related history records. 
		CROSS APPLY (
			SELECT 
				* 
			FROM 
				tblTRFTradeFinanceHistory tfh 
			WHERE				
				tfh.strTradeFinanceNumber = tf.strTradeFinanceNumber				
				AND (
					tfh.strTransactionNumber = r.strReceiptNumber
					OR (
						tfh.intTradeFinanceHistoryId <= firstLog.intTradeFinanceHistoryId
						AND tfh.strTransactionType NOT IN ('Inventory')
					)
				)				
		) tfh
		INNER JOIN tblCMBankAccount ba
			ON ba.intBankAccountId = r.intBankAccountId