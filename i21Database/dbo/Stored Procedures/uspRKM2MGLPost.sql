CREATE PROCEDURE uspRKM2MGLPost
	@intM2MHeaderId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @GLEntries AS RecapTableType
		, @batchId NVARCHAR(100)
		, @strBatchId NVARCHAR(100)
		, @ErrMsg NVARCHAR(MAX)
		, @intCommodityId INT
		, @intLocationId INT
		, @dtmCurrenctGLPostDate DATETIME
		, @dtmPreviousGLPostDate DATETIME
		, @dtmGLReverseDate DATETIME
		, @dtmPreviousGLReverseDate DATETIME
		, @strPreviousBatchId NVARCHAR(100)
		, @strCommodityCode NVARCHAR(100)
		, @intCurrencyId INT
		, @intFunctionalCurrencyId INT
		, @ysnM2MAllowGLPostToNonFunctionalCurrency BIT
		, @ysnPosted BIT
		, @strRecordName NVARCHAR(100)

	SELECT @intCommodityId = intCommodityId
		, @dtmCurrenctGLPostDate = dtmPostDate
		, @dtmGLReverseDate = dtmReverseDate 
		, @intLocationId = intLocationId
		, @intCurrencyId = intCurrencyId
		, @ysnPosted = ysnPosted
		, @strRecordName = strRecordName
	FROM tblRKM2MHeader
	WHERE intM2MHeaderId = @intM2MHeaderId

	SELECT @strCommodityCode = strCommodityCode
	FROM tblICCommodity WHERE intCommodityId = @intCommodityId

	SELECT TOP 1 @dtmPreviousGLPostDate = dtmPostDate
		, @dtmPreviousGLReverseDate = dtmReverseDate
	FROM tblRKM2MHeader 
	WHERE ysnPosted = 1 AND intCommodityId = @intCommodityId
	ORDER BY dtmPostDate DESC
	
	SELECT @ysnM2MAllowGLPostToNonFunctionalCurrency = ysnM2MAllowGLPostToNonFunctionalCurrency FROM tblRKCompanyPreference
	SELECT @intFunctionalCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference


	IF (ISNULL(@ysnPosted, 0) = 1)
	BEGIN
		SET @ErrMsg = @strRecordName + ' is already posted.'
		RAISERROR(@ErrMsg, 16, 1)
		RETURN
	END

	IF (@dtmGLReverseDate IS NULL)
	BEGIN
		RAISERROR('Please save the record before posting.', 16, 1)
	END
	IF (CONVERT(DATETIME, @dtmCurrenctGLPostDate) <= CONVERT(DATETIME, @dtmPreviousGLReverseDate))
	BEGIN
		RAISERROR('GL Post Date cannot be less than or equal to the previous post date.', 16, 1)
	END

	IF (ISNULL(@ysnM2MAllowGLPostToNonFunctionalCurrency, 0) = 0 AND @intCurrencyId <> @intFunctionalCurrencyId)
	BEGIN
		RAISERROR('GL are posted to Non-Functional Currency', 16, 1)
	END

	DECLARE @GLAccounts TABLE(strCategory NVARCHAR(100)
		, intAccountId INT
		, strAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, ysnHasError BIT
		, strErrorMessage NVARCHAR(250) COLLATE Latin1_General_CI_AS)

	INSERT INTO @GLAccounts
	EXEC uspRKGetGLAccountsForPosting @intCommodityId = @intCommodityId
		, @intLocationId = @intLocationId

	--============================================================
	-- SETUP VALIDATION
	--=============================================================
	SELECT * INTO #tmpPostRecap
	FROM tblRKM2MPostPreview 
	WHERE intM2MHeaderId = @intM2MHeaderId

	IF (@dtmCurrenctGLPostDate IS NULL)
	BEGIN
		SELECT TOP 1 @dtmCurrenctGLPostDate = dtmDate FROM #tmpPostRecap
	END

	DECLARE @tblResult TABLE (Result NVARCHAR(200))

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
	BEGIN
		DECLARE @strTransactionId NVARCHAR(50)
			, @intTransactionId INT
			, @strContractNumber NVARCHAR(50)
			, @intContractSeq NVARCHAR(20)
			, @intM2MPostPreviewId INT
			, @strTransactionType NVARCHAR(100)
			, @dblAmount NUMERIC(18, 6)
			, @intAccountId INT
			, @strAccountNo NVARCHAR(MAX)
			, @ysnHasError BIT
			, @strErrorMessage NVARCHAR(MAX)
		
		SELECT TOP 1 @intM2MPostPreviewId = intM2MPostPreviewId
			, @strTransactionId = strTransactionId
			, @intTransactionId = intTransactionId
			, @strTransactionType = strTransactionType
			, @dblAmount = (dblDebit + dblCredit)
			
		FROM #tmpPostRecap

		IF (@strTransactionType = 'Mark To Market-Basis' OR @strTransactionType = 'Mark To Market-Basis Intransit')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnBasisId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnBasisId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Basis Offset' OR @strTransactionType = 'Mark To Market-Basis Intransit Offset')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnInventoryBasisIOSId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnInventoryBasisIOSId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures'  OR @strTransactionType = 'Mark To Market-Futures Intransit')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnFuturesId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnFuturesId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Futures Derivative Offset' OR @strTransactionType = 'Mark To Market-Futures Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnInventoryFuturesIOSId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnInventoryFuturesIOSId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Cash' OR @strTransactionType = 'Mark To Market-Cash Intransit' OR @strTransactionType = 'Mark To Market-Cash Inventory')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnCashId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnCashId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Cash Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnInventoryCashIOSId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnInventoryCashIOSId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Ratio')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnRatioId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnRatioId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Ratio Offset')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnInventoryRatioIOSId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnInventoryRatioIOSId'
			END
		END
		ELSE IF (@strTransactionType = 'Mark To Market-Cash Inventory Offset')
		BEGIN
			IF (ISNULL(@dblAmount, 0) >= 0)
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedGainOnInventoryIOSId'
			END
			ELSE
			BEGIN
				SELECT TOP 1 @intAccountId = intAccountId
					, @strAccountNo = strAccountNo
					, @ysnHasError = ysnHasError
					, @strErrorMessage = strErrorMessage
				FROM @GLAccounts WHERE strCategory = 'intUnrealizedLossOnInventoryIOSId'
			END
		END

		IF (@ysnHasError = 1)
		BEGIN
			INSERT INTO @tblResult(Result)
			VALUES(@strErrorMessage)
		END
		ELSE
		BEGIN
			UPDATE tblRKM2MPostPreview
			SET intAccountId = @intAccountId
				, strAccountId = @strAccountNo
			WHERE intM2MPostPreviewId = @intM2MPostPreviewId
		END

		DELETE FROM #tmpPostRecap WHERE intM2MPostPreviewId = @intM2MPostPreviewId
	END

	IF (SELECT COUNT(Result) FROM @tblResult) > 0  
	BEGIN
		SELECT DISTINCT * from @tblResult

		GOTO Exit_Routine
	END

	BEGIN TRANSACTION
		IF (@batchId IS NULL)
		BEGIN
			EXEC uspSMGetStartingNumber 3, @batchId OUT
		END

		SET @strBatchId = @batchId

		INSERT INTO @GLEntries (
			  [dtmDate]
			, [strBatchId]
			, [intAccountId]
			, [dblDebit]
			, [dblCredit]
			, [dblDebitForeign]
			, [dblCreditForeign]
			, [dblDebitUnit]
			, [dblCreditUnit]
			, [strDescription]
			, [intCurrencyId]
			, [dtmTransactionDate]
			, [strTransactionId]
			, [intTransactionId]
			, [strTransactionType]
			, [strTransactionForm]
			, [strModuleName]
			, [intConcurrencyId]
			, [dblExchangeRate]
			, [dtmDateEntered]
			, [ysnIsUnposted]
			, [strCode]
			, [strReference]  
			, [intEntityId]
			, [intUserId]      
			, [intSourceLocationId]
			, [intSourceUOMId]
		)
		SELECT [dtmDate]
			, @batchId
			, [intAccountId]
			, ROUND([dblDebit],2)
			, ROUND([dblCredit],2)
			, [dblDebitForeign] = ROUND([dblDebitForeign], 2)
			, [dblCreditForeign] = ROUND([dblCreditForeign], 2)
			, ROUND([dblDebitUnit],2)
			, ROUND([dblCreditUnit],2)
			, [strDescription]
			, [intCurrencyId]
			, [dtmTransactionDate]
			, [strTransactionId]
			, [intTransactionId]
			, 'Mark To Market'--[strTransactionType]
			, [strTransactionForm]
			, [strModuleName]
			, [intConcurrencyId]
			, [dblExchangeRate]
			, GETDATE() --[dtmDateEntered]
			, [ysnIsUnposted]
			, 'RK'
			, [strReference]  
			, [intEntityId]
			, [intUserId]  
			, [intSourceLocationId]
			, [intSourceUOMId]
		FROM tblRKM2MPostPreview
		WHERE intM2MHeaderId = @intM2MHeaderId

		EXEC dbo.uspGLBookEntries @GLEntries,1 --@ysnPost

		UPDATE tblRKM2MPostPreview SET ysnIsUnposted=1,strBatchId=@strBatchId WHERE intM2MHeaderId = @intM2MHeaderId
		UPDATE tblRKM2MHeader 
		SET	  ysnPosted = 1
			, dtmPostDate = @dtmCurrenctGLPostDate
			, strBatchId = @batchId
			, dtmUnpostDate = NULL 
		WHERE intM2MHeaderId = @intM2MHeaderId


		--Post Reversal using the reversal date
	
		DECLARE @ReverseGLEntries AS RecapTableType,
				@strReversalBatchId AS NVARCHAR(100)
		EXEC uspSMGetStartingNumber 3, @strReversalBatchId OUT

		INSERT INTO @ReverseGLEntries (
			 [dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[intCurrencyId]
			,[dtmTransactionDate]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[ysnIsUnposted]
			,[strCode]
			,[strReference]  
			,[intEntityId]
			,[intUserId]      
			,[intSourceLocationId]
			,[intSourceUOMId]
			)
		SELECT @dtmGLReverseDate
			,@strReversalBatchId
			,[intAccountId]
			,ROUND([dblCredit],2) --Reversal - credit value will become debit value
			,ROUND([dblDebit],2)
			, [dblDebitForeign] = ROUND([dblCreditForeign], 2)  --Reversal - credit value will become debit value
			, [dblCreditForeign] = ROUND([dblDebitForeign], 2)
			,ROUND([dblCreditUnit],2)
			,ROUND([dblDebitUnit],2)
			,[strDescription]
			,[intCurrencyId]
			,@dtmGLReverseDate --[dtmTransactionDate]
			,[strTransactionId]
			,[intTransactionId]
			,'Mark To Market'--[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblExchangeRate]
			,GETDATE() --[dtmDateEntered]
			,0
			,'RK'--[strCode]
			,[strReference]  
			,[intEntityId]
			,[intUserId]  
			,[intSourceLocationId]
			,[intSourceUOMId]
		FROM tblRKM2MPostPreview
		WHERE intM2MHeaderId = @intM2MHeaderId

		EXEC dbo.uspGLBookEntries @ReverseGLEntries,1 
	
		UPDATE tblRKM2MPostPreview SET strReversalBatchId = @strReversalBatchId WHERE intM2MHeaderId = @intM2MHeaderId

	COMMIT TRAN	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	
	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @ErrMsg != ''
	BEGIN
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH

Exit_Routine: