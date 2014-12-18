CREATE PROCEDURE uspGLBookEntries
	@GLEntries RecapTableType READONLY
	,@ysnPost AS BIT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	VALIDATION
------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspGLValidateGLEntries @GLEntries;
	IF @@ERROR <> 0	GOTO Exit_BookGLEntries;
END 
;
--=====================================================================================================================================
-- 	BOOK THE G/L ENTRIES TO THE tblGLDetail table.
--------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Add the G/L entries from the temporary table to the permanent table (tblGLDetail)
	INSERT INTO dbo.tblGLDetail (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
	)
	SELECT 
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit] = Debit.Value
			,[dblCredit] = Credit.Value 
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
	FROM	@GLEntries GLEntries 
			CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit;
END
;
--=====================================================================================================================================
-- 	UPSERT DATA TO THE SUMMARY TABLE 
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	MERGE	
	INTO	dbo.tblGLSummary 
	WITH	(HOLDLOCK) 
	AS		gl_summary 
	USING (
				SELECT	intAccountId
						,dtmDate = dbo.fnRemoveTimeOnDate(GLEntries.dtmDate)
						,dblDebit = CASE WHEN @ysnPost = 1 THEN Debit.Value ELSE Credit.Value * -1 END 
						,dblCredit = CASE WHEN @ysnPost = 1 THEN Credit.Value ELSE Debit.Value * -1 END 
						,dblDebitUnit 
						,dblCreditUnit
						,strCode
				FROM	@GLEntries GLEntries
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
	) AS Source_Query  
		ON gl_summary.intAccountId = Source_Query.intAccountId
		AND gl_summary.strCode = Source_Query.strCode 
		AND dbo.fnDateEquals(gl_summary.dtmDate, Source_Query.dtmDate) = 1

	-- Update an existing gl summary record
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblDebit = gl_summary.dblDebit + Source_Query.dblDebit 
				,dblCredit = gl_summary.dblCredit + Source_Query.dblCredit 
				,intConcurrencyId = intConcurrencyId + 1

	-- Insert a new gl summary record 
	WHEN NOT MATCHED  THEN 
		INSERT (
			intAccountId
			,dtmDate
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strCode
			,intConcurrencyId
		)
		VALUES (
			Source_Query.intAccountId
			,Source_Query.dtmDate
			,Source_Query.dblDebit
			,Source_Query.dblCredit
			,Source_Query.dblDebitUnit
			,Source_Query.dblCreditUnit
			,Source_Query.strCode
			,1
		);
END
;

--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------
Exit_BookGLEntries:
