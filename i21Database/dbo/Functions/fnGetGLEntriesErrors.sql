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
		SELECT	TOP 1
				strTransactionId
				,FORMATMESSAGE(60001) strText
				,60001 intErrorCode
				,strModuleName
		FROM	@GLEntriesToValidate GLEntries 
		WHERE	NOT EXISTS (SELECT intAccountId FROM dbo.tblGLAccount Account WHERE Account.intAccountId = GLEntries.intAccountId)
		ORDER BY GLEntries.strTransactionId
		-- Debit and credit amounts are not balanced.
		UNION ALL 
		SELECT	TOP 1
				SubQuery.strTransactionId
				,FORMATMESSAGE(60003) strText
				,60003 intErrorCode
				,strModuleName
		FROM	(
					SELECT	ToValidate.strTransactionId
							,SUM(ISNULL(ToValidate.dblDebit, 0)) dblDebit
							,SUM(ISNULL(ToValidate.dblCredit, 0)) dblCredit
							,ToValidate.strModuleName
					FROM	@GLEntriesToValidate ToValidate INNER JOIN dbo.tblGLAccount Account
								ON ToValidate.intAccountId = Account.intAccountId
					GROUP BY ToValidate.strTransactionId,ToValidate.strModuleName
				) SubQuery
				
		WHERE	SubQuery.dblDebit <> SubQuery.dblCredit
		ORDER BY SubQuery.strTransactionId
		UNION ALL
		SELECT	TOP 1
				SubQuery.strTransactionId
				,'Foreign Debit and credit amounts are not balanced.' strText
				,60003 intErrorCode
				,strModuleName
		FROM	(
					SELECT	ToValidate.strTransactionId
							,SUM(ISNULL(ToValidate.dblDebitForeign, 0)) dblDebit
							,SUM(ISNULL(ToValidate.dblCreditForeign, 0)) dblCredit
							,ToValidate.strModuleName
					FROM	@GLEntriesToValidate ToValidate INNER JOIN dbo.tblGLAccount Account
								ON ToValidate.intAccountId = Account.intAccountId
					GROUP BY ToValidate.strTransactionId,ToValidate.strModuleName
				) SubQuery
		WHERE	SubQuery.dblDebit <> SubQuery.dblCredit
		ORDER BY SubQuery.strTransactionId

		-- Unable to find an open fiscal year period to match the transaction date.
		-- Allow audit adjustment transactions to be posted to a closed fiscal year period
		UNION ALL 
		SELECT	TOP 1
				strTransactionId
				,FORMATMESSAGE(60004) strText
				,60004 intErrorCode
				,GLEntries.strModuleName
		FROM	(SELECT DISTINCT strTransactionId, dtmDate,strModuleName FROM @GLEntriesToValidate WHERE ISNULL(strCode, '') <>'AA' AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')) GLEntries
		WHERE	dbo.isOpenAccountingDate(dtmDate) = 0
		ORDER BY GLEntries.strTransactionId
		UNION ALL 

		-- G/L entries are expected. Cannot continue because it is missing.
		SELECT	NULL strTransactionId 
				,FORMATMESSAGE(60005)
				,60005 intErrorCode
				,NULL strModuleName
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM @GLEntriesToValidate)

		--Cannot continue if Module status in fiscal year period is closed (CM,AR,INV,AP)
		UNION ALL 
		SELECT	TOP 1 strTransactionId
				,FORMATMESSAGE(60009,GLEntries.strModuleName) strText
				,60009 intErrorCode
				,strModuleName
		FROM	(SELECT DISTINCT strTransactionId, dtmDate,strModuleName FROM @GLEntriesToValidate WHERE ISNULL(strCode, '') <>'AA' AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')) GLEntries
		WHERE	dbo.isOpenAccountingDateByModule(dtmDate,strModuleName) = 0
		ORDER BY GLEntries.strTransactionId
		UNION ALL 
		SELECT	TOP 1 A.strTransactionId
				,FORMATMESSAGE(60015 ,B.strAccountId) AS strText
				,60015 intErrorCode
				,A.strModuleName
		FROM	@GLEntriesToValidate A JOIN
		dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
		WHERE	B.ysnActive = 0 
		ORDER BY A.strTransactionId

	) AS Query		
)