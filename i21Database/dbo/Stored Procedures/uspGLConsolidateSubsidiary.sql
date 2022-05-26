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
	@strAccountId NVARCHAR(30)= ''''

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
		DECLARE @tbl TABLE( strAccountId nvarchar(30))

		INSERT INTO @tbl (strAccountId)
		SELECT A.strAccountId from dbo.vyuGLDetail A
			LEFT JOIN [ParentDbName].dbo.tblGLAccount B
			on A.strAccountId= B.strAccountId
			WHERE A.dtmDate BETWEEN @dtmStartDate AND @dtmEndDate AND B.strAccountId IS NULL
			AND intSubsidiaryCompanyId IS NULL
			GROUP BY A.strAccountId


		IF EXISTS (SELECT 1 FROM @tbl)
		BEGIN
			SELECT TOP 1 @strAccountId= strAccountId FROM @tbl
			RAISERROR (''Account id %s is not existing in [ParentDbName] '', 16,1,@strAccountId);  
			RETURN
		END
			
		DECLARE @tbl1 TABLE( strCurrency nvarchar(30))
		DECLARE @strCurrency NVARCHAR(10)

		INSERT INTO @tbl1 (strCurrency)
		SELECT A.strCurrency from dbo.vyuGLDetail A
			LEFT JOIN [ParentDbName].dbo.tblSMCurrency B
			on A.strCurrency= B.strCurrency
			WHERE A.dtmDate BETWEEN @dtmStartDate AND @dtmEndDate AND B.strCurrency IS NULL
			AND intSubsidiaryCompanyId IS NULL
			GROUP BY A.strCurrency

		IF EXISTS (SELECT 1 FROM @tbl1)
		BEGIN
			SELECT TOP 1 @strCurrency= strCurrency FROM @tbl1
			RAISERROR (''Currency %s is not existing in [ParentDbName] '', 16,1,@strCurrency);  
			RETURN
		END

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
			   ,B.intAccountId
			   ,[dblDebit]
			   ,[dblCredit]
			   ,[dblDebitUnit]
			   ,[dblCreditUnit]
			   ,[strDescription]
			   ,[strCode]
			   ,[strReference]
			   ,D.intCurrencyID
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
				FROM tblGLDetail A 
				CROSS APPLY(
					SELECT strAccountId, strCurrency FROM vyuGLDetail WHERE intGLDetailId = A.intGLDetailId
				)C		
				CROSS APPLY( 
					SELECT intAccountId from
					[ParentDbName].dbo.tblGLAccount where strAccountId = C.strAccountId 
				) B
				CROSS APPLY( 
					SELECT intCurrencyID from
					[ParentDbName].dbo.tblSMCurrency where strCurrency = C.strCurrency 
				) D

				WHERE dtmDate BETWEEN @dtmStartDate AND @dtmEndDate
				AND ysnIsUnposted =0
				AND intSubsidiaryCompanyId IS NULL
			UPDATE [ParentDbName].dbo.tblGLConsolidateLog
			SET strComment= ''Successfully consolidated'' ,
			intRowInserted = @@ROWCOUNT,
			intConcurrencyId = intConcurrencyId + 1,
			ysnSuccess = 1
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
