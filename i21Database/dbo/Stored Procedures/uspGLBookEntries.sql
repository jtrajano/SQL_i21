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
-- 	DECLARATION 
--------------------------------------------------------------------------------------------------------------------------------------

DECLARE @dblDebitCreditBalance NUMERIC(18,2)

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF VALIDATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	START OF THE VALIDATION
------------------------------------------------------------------------------------------------------------------------------------

-- When doing a post or unpost, check for any invalid G/L Account ids. 
-- When doing a recap, ignore any invalid G/L account id's. 
IF EXISTS (SELECT TOP 1 1 FROM @GLEntries WHERE intAccountId IS NULL)
BEGIN 
	-- 'Failed. Invalid G/L account id found.'
	RAISERROR (50002,11,1)
	GOTO Exit_BookGLEntries
END		
;
-- Check if the debit and credit amounts are balanced. 
SELECT	@dblDebitCreditBalance = SUM(dblDebit) - SUM(dblCredit) 
FROM	@GLEntries

IF ISNULL(@dblDebitCreditBalance, 0) <> 0 
BEGIN
	-- If not balanced, throw an error. 
	RAISERROR (50003,11,1)
	GOTO Exit_BookGLEntries	
END 
;
-- Check if the debit and credit amounts are balanced. 
-- This time join the temporary table with the GL Account table. 
-- It ensures the amounts are using valid account id's (existing and active account id's)
SELECT	@dblDebitCreditBalance = SUM(dblDebit) - SUM(dblCredit) 
FROM	@GLEntries GLEntries INNER JOIN dbo.tblGLAccount
			ON GLEntries.intAccountId = tblGLAccount.intAccountId
WHERE	ISNULL(tblGLAccount.ysnActive, 0) = 1
;
IF ISNULL(@dblDebitCreditBalance, 0) <> 0
BEGIN
	-- Debit and credit amounts are not balanced.
	RAISERROR (50003,11,1)
	GOTO Exit_BookGLEntries	
END 
;
-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 FROM @GLEntries WHERE [dbo].isOpenAccountingDate(dtmDate) = 0)
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR(50005, 11, 1)
	GOTO Exit_BookGLEntries
END
;
--------------------------------------------------------------------------------------------------------------------------------------
--  END OF VALIDATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	BOOK THE G/L ENTRIES TO THE tblGLDetail table.
--------------------------------------------------------------------------------------------------------------------------------------
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
		CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
;
--=====================================================================================================================================
-- 	UPSERT DATA TO THE SUMMARY TABLE 
---------------------------------------------------------------------------------------------------------------------------------------
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
	)
;


--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------
Exit_BookGLEntries:
