﻿CREATE PROCEDURE [dbo].[uspGLBatchPostEntries]
	@GLEntries RecapTableType READONLY
	,@strBatchId AS NVARCHAR(100)	= ''
	,@intEntityId AS INT
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
	DELETE tblGLPostResult WHERE dtmDate < DATEADD(day, -1, GETDATE())

	DECLARE  @FoundErrors TABLE (
		strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,strText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,intErrorCode INT
	)
	INSERT INTO @FoundErrors
	SELECT	Errors.strTransactionId
		,Errors.strText
		,Errors.intErrorCode
	FROM dbo.fnGetGLEntriesErrors(@GLEntries, @ysnPost) Errors

	INSERT INTO tblGLPostResult (strBatchId,intTransactionId,strTransactionId,strDescription,dtmDate,intEntityId,strTransactionType)
			SELECT DISTINCT @strBatchId AS strBatchId,A.intTransactionId AS intTransactionId,A.strTransactionId as strTransactionId, B.strText AS strDescription,
			GETDATE() AS dtmDate,@intEntityId,A.strTransactionType
			FROM @GLEntries A  JOIN @FoundErrors B ON A.strTransactionId = B.strTransactionId
	
	
	--EXEC dbo.uspGLValidateGLEntries @GLEntries;
	--IF @@ERROR <> 0 GOTO Exit_BookGLEntries;
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
			,[strDocument]
			,[strComments]
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
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
			,[dblDebitForeign]            
            ,[dblCreditForeign]
            ,[dblDebitReport]
            ,[dblCreditReport]
            ,[dblForeignRate]
			,[dblReportingRate]
			,[intConcurrencyId]
	)
	SELECT 
			dbo.fnRemoveTimeOnDate([dtmDate])
			,[strBatchId]
			,[intAccountId]
			,[dblDebit] = Debit.Value 
			,[dblCredit] = Credit.Value
			,[dblDebitUnit] = DebitUnit.Value
			,[dblCreditUnit] = CreditUnit.Value
			,[strDescription]
			,[strCode]
			,[strReference]
			,[strDocument]
			,[strComments]
			,[intCurrencyId]
			,[intCurrencyExchangeRateTypeId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,dbo.fnRemoveTimeOnDate([dtmTransactionDate])
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
			,[dblDebitForeign]            
            ,[dblCreditForeign]
            ,[dblDebitReport]
            ,[dblCreditReport]
            ,[dblForeignRate]
			,[dblReportingRate]
			,[intConcurrencyId]
	FROM	@GLEntries GLEntries 
			CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Credit
			CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) DebitUnit
			CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) CreditUnit
	WHERE strTransactionId NOT IN (select strTransactionId from @FoundErrors)
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
						,strCode
						,dblDebit = SUM(CASE WHEN @ysnPost = 1 THEN Debit.Value ELSE Credit.Value * -1 END)
						,dblCredit = SUM(CASE WHEN @ysnPost = 1 THEN Credit.Value ELSE Debit.Value * -1 END)
						,dblDebitUnit = SUM(CASE WHEN @ysnPost = 1 THEN DebitUnit.Value ELSE CreditUnit.Value * -1 END)
						,dblCreditUnit = SUM(CASE WHEN @ysnPost = 1 THEN CreditUnit.Value ELSE DebitUnit.Value * -1 END)						
				FROM	@GLEntries GLEntries
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) DebitUnit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0))  CreditUnit
				WHERE strTransactionId NOT IN (select strTransactionId from @FoundErrors)
				GROUP BY intAccountId, dbo.fnRemoveTimeOnDate(GLEntries.dtmDate), strCode
	) AS Source_Query  
		ON gl_summary.intAccountId = Source_Query.intAccountId
		AND gl_summary.strCode = Source_Query.strCode 
		AND dbo.fnDateEquals(gl_summary.dtmDate, Source_Query.dtmDate) = 1

	-- Update an existing gl summary record
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblDebit = gl_summary.dblDebit + Source_Query.dblDebit 
				,dblCredit = gl_summary.dblCredit + Source_Query.dblCredit 
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1

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