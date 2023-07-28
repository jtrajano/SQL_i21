--liquibase formatted sql

-- changeset Von:vyuICGetReceiptTradeFinanceHistory.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW vyuICGetReceiptTradeFinanceHistory
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



