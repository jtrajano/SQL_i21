CREATE VIEW [dbo].[vyuPRUnpostedTransactions]
AS 
	SELECT
		strPaycheckId	AS [strTransactionId]
		,'Paycheck'		AS [strTransactionType]
		,dtmPayDate		AS [dtmDate]
	FROM tblPRPaycheck
	WHERE ysnPosted = 0
	  AND ysnVoid = 0