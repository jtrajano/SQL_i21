CREATE VIEW [dbo].[vyuTRFGetOpenTradeFinanceNumbers]

AS

SELECT tf.intTradeFinanceId 
	, tf.strTradeFinanceNumber 
	, tfLog.intBankId
	, tfLog.strBank
	, tfLog.intBankAccountId
	, tfLog.strBankAccount
	, tfLog.strTransactionType
FROM tblTRFTradeFinance tf
CROSS APPLY (
	SELECT TOP 1 
		tfLogs.strTradeFinanceTransaction 
		, tfLogs.intBankId
		, tfLogs.strBank
		, tfLogs.intBankAccountId
		, tfLogs.strBankAccount
		, tfLogs.intStatusId
		, tfLogs.strTransactionType
	FROM tblTRFTradeFinanceLog tfLogs
	WHERE tfLogs.strTradeFinanceTransaction = tf.strTradeFinanceNumber
	AND dblFinanceQty > 0
	ORDER BY dtmTransactionDate DESC
) tfLog
WHERE tfLog.intStatusId = 1
AND tfLog.strTransactionType = tf.strTransactionType
