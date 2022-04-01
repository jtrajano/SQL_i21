CREATE PROCEDURE [dbo].[uspGLConsolidateSubsidiary]
	@intSubsidiaryCompanyId INT,
	@dtmDate DATETIME,
	@parentDbName NVARCHAR(50),
	@subsidiaryDBName NVARCHAR(50),
	@intConsolidateLogId INT
AS
DECLARE @sql NVARCHAR(MAX)
DECLARE @strCommand NVARCHAR(MAX)

SET @strCommand =
'USE [subSidiaryDbName]
DECLARE @ysnOpen BIT, @ysnUnpostedTrans BIT, 
	@intFiscalYearId INT,@intFiscalPeriodId INT,
	@dtmStartDate DATETIME,	@dtmEndDate DATETIME,
	@dtmCurrentDate DATETIME = GETDATE(),
	@strAccountId NVARCHAR(30)

SELECT @ysnOpen = 0 , @ysnUnpostedTrans = 0

SELECT TOP 1
@ysnOpen=  ysnOpen,
@intFiscalYearId = intFiscalYearId,
@intFiscalPeriodId = intGLFiscalYearPeriodId,
@dtmStartDate = dtmStartDate, 
@dtmEndDate = dtmEndDate
FROM dbo.tblGLFiscalYearPeriod
WHERE ''[dtmDateConsolidate]''
BETWEEN dtmStartDate and dtmEndDate

exec dbo.uspGLGetAllUnpostedTransactionsByFiscal @intFiscalYearId,
1,
@intFiscalPeriodId,
''GL'' ,@ysnUnpostedTrans OUT

IF @ysnOpen = 1 or @ysnUnpostedTrans = 1 
BEGIN
	UPDATE 
	[ParentDbName].dbo.tblGLConsolidateLog
	SET ysnFiscalOpen=case when isnull(@ysnOpen,0) = 0 then 1 else 0 end,
	ysnHasUnposted = @ysnUnpostedTrans,
	strComment=
	CASE 
	WHEN @ysnOpen =1 and @ysnUnpostedTrans = 0 THEN ''Fiscal Period is still open in the subsidiary company.''
	WHEN @ysnOpen =0 and @ysnUnpostedTrans = 1 THEN ''Fiscal Period have unposted transactions in the subsidiary company.''
	WHEN @ysnOpen =1 and @ysnUnpostedTrans = 1 THEN ''Fiscal Period is still open and have unposted transactions in the subsidiary company.''
	ELSE '''' END,
	intConcurrencyId = intConcurrencyId + 1
	WHERE
	intConsolidateLogId = [ConsolidateLogId]
END
	
ELSE
BEGIN
		SELECT TOP 1 @strAccountId = A.strAccountId from dbo.vyuGLDetail A
			LEFT JOIN [ParentDbName].dbo.tblGLAccount B
			on A.strAccountId= B.strAccountId
			WHERE A.dtmDate BETWEEN @dtmStartDate AND @dtmEndDate AND B.strAccountId IS NULL

		IF (@strAccountId IS NOT NULL)
			RAISERROR (''Account id %s is not existing in [ParentDbName] '', 16,1,@strAccountId);  

		DELETE FROM [ParentDbName].dbo.tblGLDetail WHERE intSubsidiaryCompanyId = [CompanyId]
		AND dtmDate BETWEEN @dtmStartDate AND @dtmEndDate
	
		INSERT INTO [ParentDbName].dbo.tblGLDetail (
			intSubsidiaryCompanyId
			,[dtmDate]
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
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[intReconciledId]
			,[dtmReconciled]
			,[ysnReconciled]
			,[ysnRevalued])
		SELECT TOP 10000000
			   [CompanyId]
			   ,[dtmDate]
			   ,[strBatchId]
			   ,B.[intAccountId]
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
			   ,1
			   ,[dblDebitForeign]
			   ,[dblDebitReport]
			   ,[dblCreditForeign]
			   ,[dblCreditReport]
			   ,[dblReportingRate]
			   ,[dblForeignRate]
			   ,[intReconciledId]
			   ,[dtmReconciled]
			   ,[ysnReconciled]
			   ,[ysnRevalued]
				FROM vyuGLDetail A JOIN 
				[ParentDbName].dbo.tblGLAccount B ON A.strAccountId = B.strAccountId
				WHERE dtmDate BETWEEN @dtmStartDate AND @dtmEndDate
				AND ysnIsUnposted =0



			UPDATE [ParentDbName].dbo.tblGLConsolidateLog
			SET strComment= ''Successfully consolidated'' ,
			intRowInserted = @@ROWCOUNT,
			intConcurrencyId = intConcurrencyId + 1
			WHERE intConsolidateLogId = [ConsolidateLogId]
END			
'
SET @strCommand = REPLACE(REPLACE(REPLACE(@strCommand,'  ',''), CHAR(10), ''), CHAR(13), ' ')
SET @strCommand = REPLACE(@strCommand,'[subSidiaryDbName]',@subsidiaryDBName )
SET @strCommand = REPLACE(@strCommand,'[CompanyId]', @intSubsidiaryCompanyId )
SET @strCommand = REPLACE(@strCommand,'[dtmDateConsolidate]',@dtmDate )
SET @strCommand = REPLACE(@strCommand,'[ParentDbName]',@parentDbName )
SET @strCommand = REPLACE(@strCommand,'[ConsolidateLogId]',@intConsolidateLogId )

EXEC sp_executesql @strCommand
