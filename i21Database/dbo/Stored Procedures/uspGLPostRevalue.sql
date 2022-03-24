CREATE PROCEDURE uspGLPostRevalue
	@intConsolidationId			AS INT,
	@ysnPost					AS BIT,
	@ysnRecap					AS BIT,
	@intEntityId				AS INT
AS
DECLARE @PostGLEntries RecapTableType
DECLARE @ReversePostGLEntries RecapTableType
DECLARE @PostGLEntries2 RecapTableType
DECLARE @strPostBatchId NVARCHAR(100) = ''
DECLARE @strReversePostBatchId NVARCHAR(100) = ''
DECLARE @strMessage NVARCHAR(MAX)
DECLARE @intReverseID INT
DECLARE @strConsolidationNumber NVARCHAR(30)
DECLARE @tblPostError TABLE(
	strPostBatchId NVARCHAR(40),
	strMessage NVARCHAR(MAX),
	strTransactionId NVARCHAR(40)
)

--BEGIN TRANSACTION

		DECLARE @errorNum INT
		DECLARE @dateNow DATETIME
		SELECT @dateNow = GETDATE()
		DECLARE @errorMsg NVARCHAR(300) = ''
		
		SELECT @strMessage = dbo.fnGLValidateRevaluePeriod(@intConsolidationId,@ysnPost) 
		IF @strMessage <> ''
			GOTO _raiserror

		IF @ysnRecap = 1
			SELECT @strPostBatchId =  NEWID()
		ELSE
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
			@intGLFiscalYearPeriodId INT,
			@strPeriod NVARCHAR(30)

		SELECT 
			@intGLFiscalYearPeriodId = A.intGLFiscalYearPeriodId,
			@strTransactionType = strTransactionType,
			@strConsolidationNumber = strConsolidationNumber,
			@strPeriod = strPeriod
		FROM tblGLRevalue A JOIN
		tblGLFiscalYearPeriod P on A.intGLFiscalYearPeriodId = P.intGLFiscalYearPeriodId
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
		DECLARE @defaultType NVARCHAR(20) 
		SELECT TOP 1 @defaultType = f.strType  from dbo.fnGLGetRevalueAccountTable() f 
		WHERE f.strModule COLLATE Latin1_General_CI_AS = @strTransactionType;
		
		WITH cte as(
			SELECT 
			 [strTransactionId]		= B.strConsolidationNumber
			,[intTransactionId]		= B.intConsolidationId
			,[strDescription]		= A.strTransactionId	
			,[dtmTransactionDate]	= B.dtmDate
			,[dblDebit]				= ISNULL(CASE	WHEN dblUnrealizedGain < 0 THEN ABS(dblUnrealizedGain)
											WHEN dblUnrealizedLoss < 0 THEN 0
											ELSE dblUnrealizedLoss END,0)
			,[dblCredit]			= ISNULL(CASE	WHEN dblUnrealizedLoss < 0 THEN ABS(dblUnrealizedLoss)
											WHEN dblUnrealizedGain < 0 THEN 0
											ELSE dblUnrealizedGain END,0)
			,[dtmDate]				= ISNULL(B.[dtmDate], GETDATE())
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= B.intFunctionalCurrencyId
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId		
			,[dtmDateEntered]		= @dateNow
			,[strBatchId]			= @strPostBatchId
			,[strCode]				= 'REVAL'
			,[intJournalLineNo]		= A.[intConsolidationDetailId]			
			,[strTransactionType]	= 'Revalue Currency'
			,[strTransactionForm]	= 'Revalue Currency'
			,B.dtmReverseDate
			,strModule = B.strTransactionType
			,A.strType
			,Offset = 0
			,A.intAccountIdOverride
			,A.intLocationSegmentOverrideId
			,A.intLOBSegmentOverrideId
			,A.intCompanySegmentOverrideId
			--,intOverrideLocationAccountId = Loc.intAccountId
			--,intOverrideLOBAccountId = A.intItemGLAccountId
		FROM [dbo].tblGLRevalueDetails A RIGHT JOIN [dbo].tblGLRevalue B 
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
				,[strJournalLineDescription] = 'Revalue '+ @strTransactionType + ' '  + @strPeriod 
				,[intJournalLineNo]		
				,[strTransactionType]	
				,[strTransactionForm]
				,strModule	
				,OffSet = 0
				,strType = ISNULL(strType,@defaultType)
				,intAccountIdOverride
				,intLocationSegmentOverrideId
				,intLOBSegmentOverrideId
				,intCompanySegmentOverrideId
				--,intOverrideLocationAccountId
				--,intOverrideLOBAccountId
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
				,[strJournalLineDescription] = 'Offset Revalue '+ @strTransactionType + ' '  + @strPeriod 
				,[intJournalLineNo]		
				,[strTransactionType]	
				,[strTransactionForm]	
				,strModule
				,OffSet = 1
				,strType = ISNULL(strType,@defaultType)
				,intAccountIdOverride
				,intLocationSegmentOverrideId
				,intLOBSegmentOverrideId
				,intCompanySegmentOverrideId
				--,intOverrideLocationAccountId
				--,intOverrideLOBAccountId
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
			,intAccountIdOverride
			,intLocationSegmentOverrideId
			,intLOBSegmentOverrideId
			,intCompanySegmentOverrideId
			--,intOverrideLocationAccountId
			--,intOverrideLOBAccountId
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
			,intAccountIdOverride
			,intLocationSegmentOverrideId
			,intLOBSegmentOverrideId
			,intCompanySegmentOverrideId
			--,intOverrideLocationAccountId
			--,intOverrideLOBAccountId
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


		INSERT INTO @PostGLEntries (
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
			,intAccountIdOverride
			,intLocationSegmentOverrideId
			,intLOBSegmentOverrideId
			,intCompanySegmentOverrideId
		)
		SELECT 
		 	[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[dtmTransactionDate]
			,[dblCredit]
			,[dblDebit]
			,[dtmDate] = U.dtmReverseDate
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription] = 'Reverse Revalue '+ @strTransactionType + ' '  + @strPeriod 
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,strModuleName
			,intAccountIdOverride
			,intLocationSegmentOverrideId
			,intLOBSegmentOverrideId
			,intCompanySegmentOverrideId
		FROM @PostGLEntries
		OUTER APPLY(
			SELECT dtmReverseDate FROM tblGLRevalue  WHERE intConsolidationId = @intConsolidationId
		)U



		--BEGIN TODO : transfer this on this procedure
		-- DECLARE  @tbl TABLE(
		-- 	intId int IDENTITY(1,1),
		-- 	intOverrideLocationAccountId INT,
		-- 	intOverrideLOBAccountId INT,
		-- 	intOrigAccountId INT,
		-- 	intNewGLAccountId INT NULL,
		-- 	strMessage NVARCHAR(MAX),
		-- 	ysnOverriden BIT,
		-- 	strOverrideLocationAccountId NVARCHAR(40),
		-- 	strOverrideLOBAccountId NVARCHAR(40),
		-- 	strNewAccountId NVARCHAR(40),
		-- 	strOrigAccountId NVARCHAR(40)
		-- )
		-- INSERT into @tbl (intNewGLAccountId, intOverrideLocationAccountId,intOverrideLOBAccountId,intOrigAccountId, strMessage, strNewAccountId)
		-- SELECT intNewGLAccountId, intOverrideLocationAccountId,intOverrideLOBAccountId,intOrigAccountId, strMessage, strNewAccountId FROM 
		-- dbo.fnGLOverridePostAccounts(@PostGLEntries)
		-- IF EXISTS(SELECT 1 FROM @tbl WHERE strMessage IS NOT NULL  OR intNewGLAccountId is null)
		-- BEGIN
		-- 	INSERT INTO @tblPostError(strTransactionId, strMessage)
		-- 	SELECT A.strDescription, strMessage
		-- 	FROM @tbl B JOIN   @PostGLEntries A 
		-- 	ON 
		-- 	A.intOverrideLocationAccountId=B.intOverrideLocationAccountId 
		-- 	AND A.intOverrideLOBAccountId = B.intOverrideLOBAccountId 
		-- 	AND A.intAccountId = B.intOrigAccountId
		-- 	WHERE strMessage IS NOT NULL OR intNewGLAccountId is null
		-- 	GOTO _raiserror
		-- END
		-- ELSE
		-- 	UPDATE A  SET intAccountId = intNewGLAccountId
		-- 	FROM  @PostGLEntries A JOIN @tbl B ON 
		-- 	A.intOverrideLocationAccountId=B.intOverrideLocationAccountId 
		-- 	AND A.intOverrideLOBAccountId = B.intOverrideLOBAccountId 
		-- 	AND A.intAccountId = B.intOrigAccountId


		--BEGIN TODO : transfer this on this procedure

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
			,[strBatchId] = @strPostBatchId
			,[strCode]				
			,[strJournalLineDescription] 
			,[intJournalLineNo]		
			,[strTransactionType]	
			,[strTransactionForm]
			,strModuleName
		FROM tblGLDetail A	
		WHERE strTransactionId = @strConsolidationNumber
		AND ysnIsUnposted = 0

	END
		IF @ysnRecap = 0 
		BEGIN

			INSERT INTO @PostGLEntries2
			SELECT *
			from fnGLOverridePostAccounts(@PostGLEntries) A 
			
				
			IF EXISTS(SELECT 1 FROM @PostGLEntries2 WHERE strOverrideAccountError IS NOT NULL )
	
				GOTO _raiseOverrideError
			
			EXEC uspGLBookEntries @PostGLEntries2, @ysnPost, 1 ,1

			IF @@ERROR <> 0 GOTO _end

			IF @ysnPost = 0
				UPDATE GL SET ysnIsUnposted = 1
				FROM tblGLDetail GL
				WHERE strTransactionId = @strConsolidationNumber
				AND ysnIsUnposted = 0
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
				,intAccountIdOverride
				,intLocationSegmentOverrideId
				,intLOBSegmentOverrideId
				,intCompanySegmentOverrideId
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
				,intAccountIdOverride
				,intLocationSegmentOverrideId
				,intLOBSegmentOverrideId
				,intCompanySegmentOverrideId
			FROM @PostGLEntries


			INSERT INTO @PostGLEntries2
			SELECT *
			from fnGLOverridePostAccounts(@PostGLEntries) A 

			EXEC uspGLPostRecap @PostGLEntries2, @intEntityId

			IF EXISTS(SELECT 1 FROM @PostGLEntries2 WHERE strOverrideAccountError IS NOT NULL )
				GOTO _raiseOverrideError
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


	_raiseOverrideError:
		set @strMessage = 'Error overriding accounts.' + @strPostBatchId
		RAISERROR( @strMessage,11,1)
		GOTO _end

	_raiserror:
		RAISERROR( @strMessage,11,1)
	--END
		
_end:

