CREATE PROCEDURE [dbo].[uspGLConsolidateSubsidiary]
	@dBName NVARCHAR(50) = '',
	@CompanyId INT,
	@dtmDate DATETIME,
	@strCompanyName NVARCHAR(50),
	@parentDbName NVARCHAR(50)
AS
DECLARE @sql NVARCHAR(MAX)
DECLARE @strCommand NVARCHAR(MAX)

SET @strCommand =
'USE [consolidatingDb]
DECLARE @ysnOpen BIT, @ysnUnpostedTrans BIT, 
	@intFiscalYearId INT,@intFiscalPeriodId INT,
	@dtmStartDate DATETIME,	@dtmEndDate DATETIME

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

IF @dtmStartDate IS NULL
BEGIN
	INSERT INTO ##ConsolidateResult
	SELECT ''[CompanyName]'', 0 , 0, '' Fiscal Period not existing in subsidiary company.'' strResult
	RETURN
END



exec dbo.uspGLGetAllUnpostedTransactionsByFiscal @intFiscalYearId,
1,
@intFiscalPeriodId,
''GL'' ,@ysnUnpostedTrans OUT
	
IF @ysnOpen = 1 or @ysnUnpostedTrans = 1 
BEGIN
	
	DECLARE @strResult NVARCHAR(1000)
	IF @ysnOpen =1 and @ysnUnpostedTrans = 0 SET @strResult = ''Fiscal Period is still open in the subsidiary company.''
	IF @ysnOpen =0 and @ysnUnpostedTrans = 1 SET @strResult = ''Fiscal Period have unposted transactions in the subsidiary company.''
	IF @ysnOpen =1 and @ysnUnpostedTrans = 1 SET @strResult = ''Fiscal Period is still open and have unposted transactions in the subsidiary company.''
	
	SELECT @ysnOpen = CASE WHEN @ysnOpen = 1 THEN 0 ELSE 1 END
	SELECT @ysnUnpostedTrans = CASE WHEN @ysnUnpostedTrans = 1 THEN 0 ELSE 1 END
	
	INSERT INTO ##ConsolidateResult
	SELECT ''[CompanyName]'', @ysnOpen ysnFiscalOpen, @ysnUnpostedTrans ysnUnpostedTrans, @strResult strResult
END
ELSE
BEGIN
	
		
		DELETE FROM [ParentDbName].dbo.tblGLDetail WHERE intCompanyId = [CompanyId]
		
	
		INSERT INTO [ParentDbName].dbo.tblGLDetail (
			[intCompanyId]
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
			   --,[ysnExported]
			   --,[dtmExportedDate]
				FROM tblGLDetail 
				WHERE dtmDate BETWEEN @dtmStartDate AND @dtmEndDate
				AND ysnIsUnposted =0
			
				INSERT INTO ##ConsolidateResult
				SELECT ''[CompanyName]'', 0 , 0 , ''Successfully consolidated'' strResult
END		
		
		
'
SET @strCommand =REPLACE(REPLACE(REPLACE( REPLACE(REPLACE( @strCommand, '[consolidatingDb]',@dBName),'[CompanyId]',@CompanyId),'[dtmDateConsolidate]', @dtmDate),'[CompanyName]', @strCompanyName), '[ParentDbName]', @parentDbName)
EXEC sp_executesql @strCommand