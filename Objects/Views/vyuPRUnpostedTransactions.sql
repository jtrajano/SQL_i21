CREATE VIEW [dbo].[vyuPRUnpostedTransactions]
AS 
	SELECT
		strPaycheckId	AS [strTransactionId]
		,'Paycheck'  COLLATE Latin1_General_CI_AS AS [strTransactionType]
		,dtmPayDate		AS [dtmDate]
	FROM tblPRPaycheck
	WHERE ysnPosted = 0
	  AND ysnVoid = 0