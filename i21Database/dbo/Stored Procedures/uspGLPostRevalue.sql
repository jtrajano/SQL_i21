CREATE PROCEDURE [dbo].[uspGLPostRevalue]
	@intConsolidationId			AS INT = 1,
	@ysnPost					AS BIT = 1,
	@ysnRecap					AS BIT = 0,
	@intEntityId				AS INT = 1
AS

DECLARE @PostGLEntries RecapTableType
DECLARE @ReversePostGLEntries RecapTableType
DECLARE @strPostBatchId NVARCHAR(100) = ''
DECLARE @strReversePostBatchId NVARCHAR(100) = ''
DECLARE @strMessage NVARCHAR(100)
DECLARE @errorNum INT
DECLARE @dateNow DATETIME
SELECT @dateNow = GETDATE()
DECLARE @errorMsg NVARCHAR(300) = ''
DECLARE @dtmReverseDate DATETIME
DECLARE @missingAccountMessage NVARCHAR(150)
DECLARE @intReverseID INT
DECLARE @strConsolidationNumber NVARCHAR(30)


IF EXISTS (SELECT TOP 1 1  FROM dbo.fnGLValidateRevaluePeriod(@intConsolidationId))
BEGIN
	DECLARE @errorCode INT , @strModule  NVARCHAR(50), @strStatus NVARCHAR(10)
	SELECT TOP 1 @strMessage = REPLACE(REPLACE(strMessage,'{0}',strModule), '{1}',strStatus) FROM dbo.fnGLValidateRevaluePeriod(@intConsolidationId) A
	JOIN  dbo.[fnGLGetGLEntriesErrorMessage]() B ON A.errorCode = B.intErrorCode
	RAISERROR (@strMessage,11,1)
	RETURN
END

SELECT TOP 1 @dtmReverseDate = dtmReverseDate , 
@intReverseID =intReverseId,@strConsolidationNumber = strConsolidationNumber,
@missingAccountMessage = 'Forex Gain/Loss account setting is required in Company Configuration screen for ' +  strTransactionType + ' transaction type.' 
FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId



IF @ysnRecap = 0 AND @ysnPost = 1
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId AND ysnPosted = 1)
		BEGIN
			RAISERROR ('The transaction is already posted.',11,1)
			RETURN
		END
	EXEC [dbo].uspGLGetNewID 3, @strPostBatchId OUTPUT
	END
ELSE
	SELECT @strPostBatchId =  NEWID()
IF @ysnPost = 1
	BEGIN
		;WITH cte as(
			SELECT 
			 [strTransactionId]		= B.strConsolidationNumber
			,[intTransactionId]		= B.intConsolidationId
			,[strDescription]		= A.strTransactionId
			
			,[dtmTransactionDate]	= B.dtmDate
			,[dblDebit]				= CASE	WHEN dblUnrealizedGain < 0 THEN ABS(dblUnrealizedGain)
											WHEN dblUnrealizedLoss < 0 THEN 0
											ELSE dblUnrealizedLoss END 
			,[dblCredit]			= CASE	WHEN dblUnrealizedLoss < 0 THEN ABS(dblUnrealizedLoss)
											WHEN dblUnrealizedGain < 0 THEN 0
											ELSE dblUnrealizedGain END	
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= B.intFunctionalCurrencyId
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId		
			,[dtmDateEntered]		= @dateNow
			,[strBatchId]			= @strPostBatchId
			,[strCode]				= 'REVAL'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intConsolidationDetailId]			
			,[strTransactionType]	= 'Revalue Currency'
			,[strTransactionForm]	= 'Revalue Currency'
			,B.dtmReverseDate
			,strModule = B.strTransactionType
			,A.strType
			,Offset = 0
		FROM [dbo].tblGLRevalueDetails A INNER JOIN [dbo].tblGLRevalue B 
			ON A.intConsolidationId = B.intConsolidationId
			WHERE B.intConsolidationId = @intConsolidationId
		),cte1 AS
		(
			SELECT 
				 [strTransactionId]		
				,[intTransactionId]		
				,[strDescription]		
				,[dtmTransactionDate]	
				,[dblDebit]	
				,[dblCredit]
				,[dtmDate]				
				,[ysnIsUnposted]		
				,[intConcurrencyId]		
				,[intCurrencyId]		
				,[intUserId]			
				,[intEntityId]			
				,[dtmDateEntered]		
				,strBatchId
				,[strCode]				
				,[strJournalLineDescription] 
				,[intJournalLineNo]		
				,[strTransactionType]	
				,[strTransactionForm]
				,strModule	
				,OffSet = 0
				,strType
			FROM
			cte 
			UNION ALL
			SELECT 
				 [strTransactionId]		
				,[intTransactionId]		
				,[strDescription]		
				,[dtmTransactionDate]	
				,[dblDebit]				= dblCredit				
				,[dblCredit]			= dblDebit			
				,[dtmDate]				
				,[ysnIsUnposted]		
				,[intConcurrencyId]		
				,[intCurrencyId]		
				,[intUserId]			
				,[intEntityId]			
				,[dtmDateEntered]	
				,strBatchId	
				,[strCode]				
				,[strJournalLineDescription] 
				,[intJournalLineNo]		
				,[strTransactionType]	
				,[strTransactionForm]	
				,strModule
				,OffSet = 1
				,strType
			FROM
			cte 
		)

		--SELECT * FROM cte
		INSERT INTO @PostGLEntries(
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,strModuleName
			)			
		SELECT 
			 [strTransactionId]		
			,[intTransactionId]		
			,[intAccountId]	= G.AccountId		
			,[strDescription]		
			,[dtmTransactionDate]	
			,[dblDebit]				
			,[dblCredit]			
			,[dtmDate]				
			,[ysnIsUnposted]		
			,[intConcurrencyId]		
			,[intCurrencyId]		
			,[intUserId]			
			,[intEntityId]			
			,[dtmDateEntered]		
			,[strBatchId]	
			,[strCode]		
			,[strJournalLineDescription] 
			,[intJournalLineNo]		
			,[strTransactionType]	
			,[strTransactionForm]
			,'General Ledger'
		FROM cte1 A
		OUTER APPLY (
			SELECT TOP 1 AccountId from dbo.fnGLGetRevalueAccountTable() f 
			WHERE A.strType COLLATE Latin1_General_CI_AS = f.strType COLLATE Latin1_General_CI_AS 
			AND f.strModule COLLATE Latin1_General_CI_AS = A.strModule COLLATE Latin1_General_CI_AS
			AND f.OffSet  = A.OffSet
		)G
		IF EXISTS(Select TOP 1 1 FROM @PostGLEntries WHERE intAccountId IS NULL)
				RAISERROR (  @missingAccountMessage ,11,1)

		INSERT INTO @PostGLEntries(
			[strTransactionId] 
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,strModuleName
		)

		SELECT
			 [strTransactionId] + '-R'
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[dtmTransactionDate]
			,[dblCredit]
			,[dblDebit]
			,[dtmDate] = @dtmReverseDate
			,[ysnIsUnposted] = 0
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]	= 'Revalue Currency Reversal'
			,[strTransactionForm]
			,strModuleName
		FROM @PostGLEntries
			

	END
ELSE
BEGIN
	INSERT INTO @PostGLEntries(
			[strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[intCurrencyId]
		,[intUserId]
		,[intEntityId]			
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]			
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[strTransactionType]
		,[strTransactionForm]
		,strModuleName
		)			
	SELECT 
		[strTransactionId]		
		,[intTransactionId]		
		,[intAccountId]
		,[strDescription]		
		,[dtmTransactionDate]	
		,[dblCredit]	
		,[dblDebit]				
		,[dtmDate]				
		,[ysnIsUnposted] = 1
		,[intConcurrencyId]		
		,[intCurrencyId]		
		,[intUserId]			
		,[intEntityId]			
		,[dtmDateEntered]		
		,[strBatchId]	
		,[strCode]				
		,[strJournalLineDescription] 
		,[intJournalLineNo]		
		,[strTransactionType]	
		,[strTransactionForm]
		,strModuleName
	FROM tblGLDetail A
	
	WHERE strTransactionId IN(@strConsolidationNumber ,@strConsolidationNumber + '-R' )
END


IF @ysnRecap = 0
BEGIN
	DECLARE @strReverseRevalueId NVARCHAR(100)
	
	EXEC [dbo].uspGLGetNewID 3, @strReversePostBatchId OUTPUT 		
				--EXEC [dbo].uspGLGetNewID 116, @strReverseRevalueId OUTPUT 	

	IF (@ysnPost = 1)
	BEGIN
			INSERT INTO [dbo].[tblGLRevalue]
				([strConsolidationNumber]
				,[intGLFiscalYearPeriodId]
				,[intFiscalYearId]
				,[dtmDate] 
				,[intFunctionalCurrencyId]
				,[intTransactionCurrencyId]
				,[strTransactionType]
				,[dblForexRate]
				,[intConcurrencyId]
				,[intRateTypeId]
				,[ysnPosted]
				,strDescription
				,intEntityId)
			SELECT 
				strConsolidationNumber + '-R'
				,[intGLFiscalYearPeriodId]
				,[intFiscalYearId]
				,[dtmDate]= dtmReverseDate
				,[intFunctionalCurrencyId]
				,[intTransactionCurrencyId]
				,[strTransactionType] 
				,[dblForexRate]
				,[intConcurrencyId]=1
				,[intRateTypeId]
				,0
				,'Reversal of ' + strConsolidationNumber
				,@intEntityId
				FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId

			SELECT @intReverseID = SCOPE_IDENTITY()

			UPDATE tblGLRevalue SET intReverseId = @intReverseID WHERE intConsolidationId = @intConsolidationId
			INSERT INTO [dbo].[tblGLRevalueDetails]
				([intConsolidationId]
				,[strTransactionType]
				,[strTransactionId]
				,[dtmDate]
				,[dtmDueDate]
				,[strVendorName]
				,[strCommodity]
				,[strLineOfBusiness]
				,[strLocation]
				,[strTicket]
				,[strContractId]
				,[strItemId]
				,[dblQuantity]
				,[dblUnitPrice]
				,[dblTransactionAmount]
				,[intCurrencyId]
				,[intCurrencyExchangeRateTypeId]
				,[dblHistoricForexRate]
				,[dblHistoricAmount]
				,[dblNewForexRate]
				,[dblNewAmount]
				,[dblUnrealizedGain]
				,[dblUnrealizedLoss]
				,[intConcurrencyId]
				,[strType])
			SELECT 
				@intReverseID
				,[strTransactionType]
				,[strTransactionId]
				,[dtmDate]
				,[dtmDueDate]
				,[strVendorName]
				,[strCommodity]
				,[strLineOfBusiness]
				,[strLocation]
				,[strTicket]
				,[strContractId]
				,[strItemId]
				,[dblQuantity]
				,[dblUnitPrice]
				,[dblTransactionAmount]
				,[intCurrencyId]
				,[intCurrencyExchangeRateTypeId]
				,[dblHistoricForexRate]
				,[dblHistoricAmount]
				,[dblNewForexRate]
				,[dblNewAmount]
				,[dblUnrealizedGain] = [dblUnrealizedLoss]
				,[dblUnrealizedLoss] = [dblUnrealizedGain]
				,[intConcurrencyId]
				,[strType]
			FROM tblGLRevalueDetails
			WHERE intConsolidationId = @intConsolidationId
			UPDATE @PostGLEntries set intTransactionId = @intReverseID WHERE [strTransactionType]	= 'Revalue Currency Reversal'
		--;WITH cte as(
		--	SELECT 
		--	[strTransactionId]		= B.strConsolidationNumber
		--	,[intTransactionId]		= B.intConsolidationId
		--	,[strDescription]		= A.strTransactionId
	
		--	,[dtmTransactionDate]	= B.dtmDate
		--	,[dblDebit]				= A.dblUnrealizedLoss
		--	,[dblCredit]			= A.dblUnrealizedGain
		--	,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
		--	,[ysnIsUnposted]		= 0 
		--	,[intConcurrencyId]		= 1
		--	,[intCurrencyId]		= B.intFunctionalCurrencyId
		--	,[intUserId]			= 0
		--	,[intEntityId]			= B.intEntityId	
		--	,[dtmDateEntered]		= @dateNow
		--	,[strBatchId]			= @strReversePostBatchId
		--	,[strCode]				= 'REVAL'
		--	,[strJournalLineDescription] = ''
		--	,[intJournalLineNo]		= A.[intConsolidationDetailId]			
		--	,[strTransactionType]	= 'Revalue Currency Reversal'
		--	,[strTransactionForm]	= 'Revalue Currency'
		--	,B.dtmReverseDate
		--	,strModule = B.strTransactionType
		--	,A.strType
		--	,Offset = 0
		--	FROM [dbo].tblGLRevalueDetails A INNER JOIN [dbo].tblGLRevalue B 
		--		ON A.intConsolidationId = B.intConsolidationId
		--		WHERE B.intConsolidationId = @intReverseID
		--),cte1 AS
		--(
		--SELECT 
		--	[strTransactionId]		
		--	,[intTransactionId]		
		--	,[strDescription]		
		--	,[dtmTransactionDate]	
		--	,[dblDebit]	
		--	,[dblCredit]
		--	,[dtmDate]				
		--	,[ysnIsUnposted]		
		--	,[intConcurrencyId]		
		--	,[intCurrencyId]		
		--	,[intUserId]			
		--	,[intEntityId]			
		--	,[dtmDateEntered]		
		--	,strBatchId
		--	,[strCode]				
		--	,[strJournalLineDescription] 
		--	,[intJournalLineNo]		
		--	,[strTransactionType]	
		--	,[strTransactionForm]
		--	,strModule	
		--	,OffSet = 0
		--	,strType
		--FROM
		--cte 
		--UNION ALL
		--SELECT 
		--	[strTransactionId]		
		--	,[intTransactionId]		
		--	,[strDescription]		
		--	,[dtmTransactionDate]	
		--	,[dblDebit]				= dblCredit				
		--	,[dblCredit]			= dblDebit			
		--	,[dtmDate]				
		--	,[ysnIsUnposted]		
		--	,[intConcurrencyId]		
		--	,[intCurrencyId]		
		--	,[intUserId]			
		--	,[intEntityId]			
		--	,[dtmDateEntered]	
		--	,strBatchId	
		--	,[strCode]				
		--	,[strJournalLineDescription] 
		--	,[intJournalLineNo]		
		--	,[strTransactionType]	
		--	,[strTransactionForm]	
		--	,strModule
		--	,OffSet = 1
		--	,strType
		--FROM
		--cte 
		--)
		--INSERT INTO @ReversePostGLEntries(
		--	[strTransactionId]
		--	,[intTransactionId]
		--	,[intAccountId]
		--	,[strDescription]
		--	,[dtmTransactionDate]
		--	,[dblDebit]
		--	,[dblCredit]
		--	,[dtmDate]
		--	,[ysnIsUnposted]
		--	,[intConcurrencyId]	
		--	,[intCurrencyId]
		--	,[intUserId]
		--	,[intEntityId]			
		--	,[dtmDateEntered]
		--	,[strBatchId]
		--	,[strCode]			
		--	,[strJournalLineDescription]
		--	,[intJournalLineNo]
		--	,[strTransactionType]
		--	,[strTransactionForm]
		--	,strModuleName
		--	)	
		--	SELECT
		--		[strTransactionId]
		--		,[intTransactionId]
		--		,[intAccountId] = G.AccountId
		--		,[strDescription]
		--		,[dtmTransactionDate]
		--		,[dblDebit]  
		--		,[dblCredit] 
		--		,[dtmDate] = @dtmReverseDate
		--		,[ysnIsUnposted]
		--		,[intConcurrencyId]	
		--		,[intCurrencyId]
		--		,[intUserId]
		--		,[intEntityId]			
		--		,[dtmDateEntered]
		--		,[strBatchId] = @strReversePostBatchId
		--		,[strCode]			
		--		,[strJournalLineDescription]
		--		,[intJournalLineNo]
		--		,[strTransactionType] = 'Revalue Currency Reversal'
		--		,[strTransactionForm]
		--		,'General Ledger'
		--	FROM
		--		cte1 A
		--	OUTER APPLY (
		--		SELECT TOP 1 AccountId from dbo.fnGLGetRevalueAccountTable() f 
		--		WHERE A.strType COLLATE Latin1_General_CI_AS = f.strType COLLATE Latin1_General_CI_AS 
		--		AND f.strModule COLLATE Latin1_General_CI_AS = A.strModule COLLATE Latin1_General_CI_AS
		--		AND f.OffSet  = A.OffSet
		--	)G
	END
					
	EXEC uspGLBookEntries @PostGLEntries, @ysnPost
	IF @ysnPost = 0
	BEGIN
		UPDATE GL 
		SET ysnIsUnposted = 1 
		from tblGLDetail GL
		WHERE strTransactionId in (@strConsolidationNumber , @strConsolidationNumber +'-R')
	END
		
		
	
		
	--EXEC uspGLBookEntries @ReversePostGLEntries, @ysnPost
END -- ysnRecap = 0
ELSE-- ysnRecap = 1
BEGIN

	DECLARE @RecapTable RecapTableType
	INSERT INTO @RecapTable (
			[strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[intCurrencyId]
		,[intUserId]
		,[intEntityId]			
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]			
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[strTransactionType]
		,[strTransactionForm]
		,strModuleName
	)
	SELECT
		[strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[intCurrencyId]
		,[intUserId]
		,[intEntityId]			
		,[dtmDateEntered]
		,[strBatchId]= @strPostBatchId
		,[strCode]			
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[strTransactionType]
		,[strTransactionForm]
		,strModuleName
	FROM @PostGLEntries
		
	EXEC uspGLPostRecap @RecapTable, @intEntityId
	
END
		if @ysnRecap = 0
		BEGIN

			IF @ysnPost = 1
				UPDATE tblGLRevalue SET ysnPosted = 1 WHERE intConsolidationId in ( @intConsolidationId, @intReverseID)
			ELSE
			BEGIN
				UPDATE tblGLRevalue SET ysnPosted = 0 WHERE intConsolidationId in ( @intConsolidationId)
				DELETE FROM tblGLRevalue WHERE intConsolidationId = @intReverseID
			END

			
			DECLARE @intGLFiscalYearPeriodId INT, @strTransactionType NVARCHAR(4)
			SELECT @intGLFiscalYearPeriodId= intGLFiscalYearPeriodId ,@strTransactionType = strTransactionType  FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId

			
			IF @strTransactionType = 'AR' 
				UPDATE tblGLFiscalYearPeriod SET ysnARRevalued = 1 WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'AP' 
				UPDATE tblGLFiscalYearPeriod SET ysnAPRevalued = 1 WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'INV' 
				UPDATE tblGLFiscalYearPeriod SET ysnINVRevalued = 1 WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CT' 
				UPDATE tblGLFiscalYearPeriod SET ysnCTRevalued = 1 WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CM' 
				UPDATE tblGLFiscalYearPeriod SET ysnCMRevalued = 1 WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId

			IF @strTransactionType = 'All' 
				UPDATE tblGLFiscalYearPeriod SET 
					ysnARRevalued =		1,
					ysnAPRevalued =		1,
					ysnINVRevalued =	1,
					ysnCTRevalued =		1,
					ysnCMRevalued =		1
				WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId

			
		END
	SELECT @strPostBatchId PostBatchId--,	@strReversePostBatchId ReversePostBatchId
