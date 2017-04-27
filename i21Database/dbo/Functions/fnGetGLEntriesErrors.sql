/**
* This function will validate the GL entries for post (or unpost) and it will return any error found. 
* 
* Sample usage: 
*	DECLARE @GLEntries AS RecapTableType
*
*	SELECT	*
*	FROM	dbo.fnGetGLEntriesErrors(@GLEntries)
* 
*/
CREATE FUNCTION [dbo].[fnGetGLEntriesErrors] (
	@GLEntriesToValidate RecapTableType READONLY
)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Failed. Invalid G/L account id found.
		SELECT	strTransactionId
				,strText = 'Invalid G/L account id found.'
				,intErrorCode = 60001
				,strModuleName
		FROM	@GLEntriesToValidate GLEntries 
		WHERE	NOT EXISTS (SELECT intAccountId FROM tblGLAccount WHERE tblGLAccount.intAccountId = GLEntries.intAccountId)

		-- Debit and credit amounts are not balanced.
		UNION ALL 
		SELECT	SubQuery.strTransactionId
				,strText = 'Debit and credit amounts are not balanced.'
				,intErrorCode = 60003
				,strModuleName
		FROM	(
					SELECT	ToValidate.strTransactionId
							,dblDebit = SUM(ISNULL(ToValidate.dblDebit, 0))
							,dblCredit = SUM(ISNULL(ToValidate.dblCredit, 0))
							,ToValidate.strModuleName
					FROM	@GLEntriesToValidate ToValidate INNER JOIN dbo.tblGLAccount
								ON ToValidate.intAccountId = tblGLAccount.intAccountId
					GROUP BY ToValidate.strTransactionId,ToValidate.strModuleName
				) SubQuery
				
		WHERE	SubQuery.dblDebit <> SubQuery.dblCredit

		-- Unable to find an open fiscal year period to match the transaction date.
		-- Allow audit adjustment transactions to be posted to a closed fiscal year period
		UNION ALL 
		SELECT	strTransactionId
				,strText = 'Unable to find an open fiscal year period to match the transaction date.'
				,intErrorCode = 60004
				,strModuleName
		FROM	(SELECT DISTINCT strTransactionId, dtmDate,strModuleName FROM @GLEntriesToValidate WHERE ISNULL(strCode, '') !='AA' AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')) GLEntries
		WHERE	dbo.isOpenAccountingDate(dtmDate) = 0

		UNION ALL 

		-- G/L entries are expected. Cannot continue because it is missing.
		SELECT	strTransactionId = NULL 
				,strText = 'G/L entries are expected. Cannot continue because it is missing.'
				,intErrorCode = 60005
				,strModuleName = NULL
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM @GLEntriesToValidate)

		--Cannot continue if Module status in fiscal year period is closed (CM,AR,INV,AP)
		UNION ALL 
		SELECT	strTransactionId
				,strText = 'Unable to find an open fiscal year period for %s module to match the transaction date.'
				,intErrorCode = 60009
				,strModuleName
		FROM	(SELECT DISTINCT strTransactionId, dtmDate,strModuleName FROM @GLEntriesToValidate WHERE ISNULL(strCode, '') !='AA' AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')) GLEntries
		WHERE	dbo.isOpenAccountingDateByModule(dtmDate,strModuleName) = 0

	) AS Query		
)