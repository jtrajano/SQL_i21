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
	DECLARE @errorCode INT
	EXEC  @errorCode = dbo.uspGLValidateGLEntries @GLEntries;
	IF @errorCode > 0	RETURN @errorCode
END 
;
--=====================================================================================================================================
-- 	BOOK THE G/L ENTRIES TO THE tblGLDetail table.
--------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Add the G/L entries from the temporary table to the permanent table (tblGLDetail)
	DECLARE @intCompanyId INT
	SELECT TOP 1 @intCompanyId=intCompanySetupID from tblSMCompanySetup
	DECLARE @dtmDateEntered DATETIME
	SELECT @dtmDateEntered = GETDATE()
	INSERT INTO dbo.tblGLDetail (
			[dtmDate]
			,[strBatchId]
			,[intCompanyId]
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
			,@intCompanyId
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
			,@dtmDateEntered
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
			,DebitForeign.Value
            ,CreditForeign.Value
            ,ISNULL([dblDebitReport],0)
            ,ISNULL([dblCreditReport],0)
            ,[dblForeignRate]
			,ISNULL([dblReportingRate],0)
			,[intConcurrencyId]
	FROM	@GLEntries GLEntries 
			CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
			CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitForeign, 0) - ISNULL(GLEntries.dblCreditForeign, 0)) DebitForeign
			CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitForeign, 0) - ISNULL(GLEntries.dblCreditForeign, 0))  CreditForeign
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
						,dblDebitForeign = SUM(CASE WHEN @ysnPost = 1 THEN DebitForeign.Value ELSE CreditForeign.Value * -1 END)
						,dblCreditForeign = SUM(CASE WHEN @ysnPost = 1 THEN CreditForeign.Value ELSE DebitForeign.Value * -1 END)
						,dblDebitUnit = SUM(CASE WHEN @ysnPost = 1 THEN DebitUnit.Value ELSE CreditUnit.Value * -1 END)
						,dblCreditUnit = SUM(CASE WHEN @ysnPost = 1 THEN CreditUnit.Value ELSE DebitUnit.Value * -1 END)						
				FROM	@GLEntries GLEntries
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitForeign, 0) - ISNULL(GLEntries.dblCreditForeign, 0)) DebitForeign
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitForeign, 0) - ISNULL(GLEntries.dblCreditForeign, 0))  CreditForeign
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) DebitUnit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0))  CreditUnit
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
				,dblDebitForeign = gl_summary.dblDebitForeign + Source_Query.dblDebitForeign
				,dblCreditForeign = gl_summary.dblCreditForeign + Source_Query.dblCreditForeign
				,dblCreditUnit = gl_summary.dblCreditUnit + Source_Query.dblCreditUnit
				,dblDebitUnit = gl_summary.dblDebitUnit + Source_Query.dblDebitUnit
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1

	-- Insert a new gl summary record 
	WHEN NOT MATCHED  THEN 
		INSERT (
			intAccountId
			,intCompanyId
			,dtmDate
			,dblDebit
			,dblCredit
			,dblDebitForeign
			,dblCreditForeign
			,dblDebitUnit
			,dblCreditUnit
			,strCode
			,intConcurrencyId
		)
		VALUES (
			Source_Query.intAccountId
			,@intCompanyId
			,Source_Query.dtmDate
			,Source_Query.dblDebit
			,Source_Query.dblCredit
			,Source_Query.dblDebitForeign
			,Source_Query.dblCreditForeign
			,Source_Query.dblDebitUnit
			,Source_Query.dblCreditUnit
			,Source_Query.strCode
			,1
		);
END;

RETURN 0

