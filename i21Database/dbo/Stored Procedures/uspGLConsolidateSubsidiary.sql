CREATE PROCEDURE [dbo].[uspGLConsolidateSubsidiary]
	@dBName NVARCHAR(50) = '',
	@CompanyId INT,
	@dtmDate DATETIME
AS
DECLARE @sql NVARCHAR(MAX)
DECLARE @strCommand NVARCHAR(MAX)

SET @strCommand =
'
BEGIN TRY
BEGIN TRAN
	DECLARE @dtmStartDate DATETIME
	DECLARE @dtmEndDate DATETIME
	DECLARE @ysnOpen BIT
	DECLARE @intCompanySetupID INT
	SELECT TOP 1 @dtmStartDate = dtmStartDate, @dtmEndDate = dtmEndDate from tblGLFiscalYearPeriod WHERE ''[dtmDateConsolidate]'' BETWEEN dtmStartDate and dtmEndDate
	SELECT top 1 @intCompanySetupID= intCompanySetupID FROM tblSMCompanySetup
	DELETE FROM tblGLDetail where intCompanyId <> @intCompanySetupID AND intCompanyId IS NOT NULL
	INSERT INTO tblGLDetail (
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
           ,c.[intAccountId]
           ,[dblDebit]
           ,[dblCredit]
           ,[dblDebitUnit]
           ,[dblCreditUnit]
           ,a.[strDescription]
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
           ,a.[intConcurrencyId]
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
			FROM [consolidatingDb].dbo.tblGLDetail a 
			JOIN [consolidatingDb].dbo.tblGLAccount b on a.intAccountId =b.intAccountId 
			JOIN [consolidatingDb].dbo.tblSMCompanySetup d  on d.intCompanySetupID = a.intCompanyId
			JOIN dbo.tblGLAccount c ON b.strAccountId = c.strAccountId
			WHERE a.dtmDate BETWEEN @dtmStartDate AND @dtmEndDate
			EXEC uspGLSummaryRecalculate
			SELECT ''Successfully consolidated'' strResult
	IF @@TRANCOUNT > 0 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT  ''Error inserting data from [consolidatingDb] :''  + Error_message() strResult
	END CATCH
'
SET @strCommand =REPLACE( REPLACE(REPLACE( @strCommand, '[consolidatingDb]',@dBName),'[CompanyId]',@CompanyId),'[dtmDateConsolidate]', @dtmDate)
EXEC sp_executesql @strCommand