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
CREATE FUNCTION fnGetGLEntriesErrors (
	@GLEntriesToValidate RecapTableType READONLY
)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Failed. Invalid G/L account id found.
		SELECT	strTransactionId
				,strText = FORMATMESSAGE(50001)
				,intErrorCode = 50001
		FROM	@GLEntriesToValidate GLEntries 
		WHERE	NOT EXISTS (SELECT intAccountId FROM tblGLAccount WHERE tblGLAccount.intAccountId = GLEntries.intAccountId)

		-- Debit and credit amounts are not balanced.
		UNION ALL 
		SELECT	SubQuery.strTransactionId
				,strText = FORMATMESSAGE(50003)
				,intErrorCode = 50003
		FROM	(
					SELECT	ToValidate.strTransactionId
							,dblDebit = SUM(ISNULL(ToValidate.dblDebit, 0))
							,dblCredit = SUM(ISNULL(ToValidate.dblCredit, 0))
					FROM	@GLEntriesToValidate ToValidate INNER JOIN dbo.tblGLAccount
								ON ToValidate.intAccountId = tblGLAccount.intAccountId
					GROUP BY ToValidate.strTransactionId 
				) SubQuery
		WHERE	SubQuery.dblDebit <> SubQuery.dblCredit

		-- Unable to find an open fiscal year period to match the transaction date.
		UNION ALL 
		SELECT	strTransactionId
				,strText = FORMATMESSAGE(50005)
				,intErrorCode = 50005
		FROM	(SELECT DISTINCT strTransactionId, dtmDate FROM @GLEntriesToValidate) GLEntries
		WHERE	dbo.isOpenAccountingDate(dtmDate) = 0

	) AS Query		
)