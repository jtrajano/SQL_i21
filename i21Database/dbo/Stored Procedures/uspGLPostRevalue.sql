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
DECLARE @intReverseID INT
DECLARE @strConsolidationNumber NVARCHAR(30)


		DECLARE @errorNum INT
		DECLARE @dateNow DATETIME
		SELECT @dateNow = GETDATE()
		DECLARE @errorMsg NVARCHAR(300) = ''
		
		SELECT @strMessage = dbo.fnGLValidateRevaluePeriod(@intConsolidationId,@ysnPost) 
		IF @strMessage <> ''
			GOTO _raiserror



		IF @ysnRecap = 0 
		BEGIN
			IF @ysnPost = 1
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId AND ysnPosted = 1)
				BEGIN
					SET @strMessage ='The transaction is already posted.'
					GOTO _raiserror
				END
				EXEC [dbo].uspGLGetNewID 3, @strPostBatchId OUTPUT
			END
			ELSE
			BEGIN
				SELECT @strPostBatchId =  NEWID()
			END
		END

		-- For Bank Transfer Accounts
		DECLARE @tblBankTransferAccounts TABLE
		(
			strModule NVARCHAR(50),
			strType NVARCHAR(50),
			AccountId INT,
			Offset INT
		)

		DECLARE 
			@strAccountErrorMessage NVARCHAR(255),
			@strTransactionType NVARCHAR(255),
			@intGLFiscalYearPeriodId INT

		SELECT 
			@intGLFiscalYearPeriodId = intGLFiscalYearPeriodId,
			@strTransactionType = strTransactionType,
			@strConsolidationNumber = strConsolidationNumber
		FROM tblGLRevalue 
		WHERE intConsolidationId = @intConsolidationId

		-- Validate CM revaluation
		SELECT @strMessage = dbo.fnCMValidateCMRevaluation(@intGLFiscalYearPeriodId, @strTransactionType, @ysnPost)
		IF @strMessage IS NOT NULL
			GOTO _raiserror

		IF (@strTransactionType IN ('CM Forwards', 'CM In-Transit', 'CM Swaps'))
		BEGIN
			DECLARE @tblTransactions TABLE (
				strTransactionId NVARCHAR(100)
			)
			DECLARE @strCurrentTransaction NVARCHAR(100)

			INSERT INTO @tblTransactions
			SELECT DISTINCT strTransactionId
			FROM tblGLRevalueDetails WHERE intConsolidationId = @intConsolidationId

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblTransactions)
			BEGIN
				SELECT TOP 1 @strCurrentTransaction = strTransactionId FROM @tblTransactions
				BEGIN TRY
					INSERT @tblBankTransferAccounts EXEC dbo.uspCMGetBankTransferGLRevalueAccount @strCurrentTransaction, @strTransactionType
				END TRY
				BEGIN CATCH
					SELECT  @strMessage = ERROR_MESSAGE(); 
					GOTO _raiserror
				END CATCH

				DELETE	@tblTransactions WHERE strTransactionId = @strCurrentTransaction
			END
		END

	IF @ysnPost =1 
	BEGIN
		WITH cte as(
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
			,[intAccountId]	= CASE WHEN A.strModule IN ('CM Forwards', 'CM In-Transit', 'CM Swaps') THEN BankTransferAccount.AccountId ELSE G.AccountId	END
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
		OUTER APPLY (
			SELECT TOP 1 AccountId from @tblBankTransferAccounts f 
			WHERE A.strType COLLATE Latin1_General_CI_AS = f.strType COLLATE Latin1_General_CI_AS 
			AND f.strModule COLLATE Latin1_General_CI_AS = A.strModule COLLATE Latin1_General_CI_AS
			AND f.Offset = A.OffSet
		) BankTransferAccount

		DECLARE @dtmReverseDate DATETIME
		SELECT TOP 1 @dtmReverseDate = dtmReverseDate , @strMessage = 'Forex Gain/Loss account setting is required in Company Configuration screen for ' +  strTransactionType + ' transaction type.' FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId
		IF EXISTS(Select TOP 1 1 FROM @PostGLEntries WHERE intAccountId IS NULL)
		BEGIN
			GOTO _raiserror
		END
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

				UPDATE @PostGLEntries set intTransactionId = @intReverseID 
				WHERE [strTransactionType]	= 'Revalue Currency Reversal'
			END
			ELSE
			BEGIN
				UPDATE GL SET ysnIsUnposted = 1
				FROM tblGLDetail GL
				WHERE strTransactionId in (@strConsolidationNumber , @strConsolidationNumber +'-R')
				DELETE FROM tblGLRevalue WHERE strConsolidationNumber = @strConsolidationNumber +'-R'
			END		
			
			EXEC uspGLBookEntries @PostGLEntries, @ysnPost

		END
		ELSE
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
			UPDATE tblGLRevalue SET ysnPosted = @ysnPost WHERE intConsolidationId in ( @intConsolidationId, @intReverseID)
			
			
			IF @strTransactionType = 'GL' 
				UPDATE tblGLFiscalYearPeriod SET ysnRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'AR' 
				UPDATE tblGLFiscalYearPeriod SET ysnARRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'AP' 
				UPDATE tblGLFiscalYearPeriod SET ysnAPRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'INV' 
				UPDATE tblGLFiscalYearPeriod SET ysnINVRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CT' 
				UPDATE tblGLFiscalYearPeriod SET ysnCTRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CM' 
				UPDATE tblGLFiscalYearPeriod SET ysnCMRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'FA' 
				UPDATE tblGLFiscalYearPeriod SET ysnFARevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CM Forwards'
				UPDATE tblGLFiscalYearPeriod SET ysnCMForwardsRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CM In-Transit'
				UPDATE tblGLFiscalYearPeriod SET ysnCMInTransitRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId
			IF @strTransactionType = 'CM Swaps'
				UPDATE tblGLFiscalYearPeriod SET ysnCMSwapsRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId

			IF @strTransactionType = 'All' 
				UPDATE tblGLFiscalYearPeriod SET 
					ysnRevalued 	=	@ysnPost,
					ysnARRevalued =		@ysnPost,
					ysnAPRevalued =		@ysnPost,
					ysnINVRevalued =	@ysnPost,
					ysnCTRevalued =		@ysnPost,
					ysnCMRevalued =		@ysnPost,
					ysnFARevalued =     @ysnPost,
					ysnCMForwardsRevalued =		@ysnPost,
					ysnCMInTransitRevalued =	@ysnPost,
					ysnCMSwapsRevalued =		@ysnPost
				WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId

			
		END
	SELECT @strPostBatchId PostBatchId
	GOTO _end

_raiserror:
	RAISERROR(@strMessage ,11,1)
	RETURN

_end:

