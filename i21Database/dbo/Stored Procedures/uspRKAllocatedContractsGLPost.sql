CREATE PROCEDURE uspRKAllocatedContractsGLPost
	  @intAllocatedContractsGainOrLossHeaderId INT
	, @intUserId INT

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
	FROM tblRKAllocatedContractsGainOrLossHeader
	WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

	SELECT @strCommodityCode = strCommodityCode
	FROM tblICCommodity WHERE intCommodityId = @intCommodityId

	SELECT TOP 1 @dtmPreviousGLPostDate = dtmPostDate
		, @dtmPreviousGLReverseDate = dtmReverseDate
	FROM tblRKAllocatedContractsGainOrLossHeader 
	WHERE ysnPosted = 1 AND intCommodityId = @intCommodityId
	ORDER BY dtmPostDate DESC

	DECLARE @intAllocatedContractGainOrLossId INT
		, @strAllocatedContractGainOrLossId NVARCHAR(40)
		, @strAllocatedContractGainOrLossIdDescription NVARCHAR(255)
		, @intAllocatedContractGainOrLossOffsetId INT
		, @strAllocatedContractGainOrLossOffsetId NVARCHAR(40)
		, @strAllocatedContractGainOrLossOffsetIdDescription NVARCHAR(255)

	SELECT 
		  @intAllocatedContractGainOrLossId = intAllocatedContractGainOrLossId 
		, @intAllocatedContractGainOrLossOffsetId = intAllocatedContractGainOrLossOffsetId
		, @ysnM2MAllowGLPostToNonFunctionalCurrency = ysnM2MAllowGLPostToNonFunctionalCurrency
	FROM tblRKCompanyPreference

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
		RAISERROR('GL Post Date cannot be less than or equal to the previous post date', 16, 1)
	END

	IF (ISNULL(@ysnM2MAllowGLPostToNonFunctionalCurrency, 0) = 0 AND @intCurrencyId <> @intFunctionalCurrencyId)
	BEGIN
		RAISERROR('GL are posted to Non-Functional Currency', 16, 1)
	END

	DECLARE @GLAccounts TABLE(strCategory NVARCHAR(100)
		, intAccountId INT
		, strAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, ysnHasError BIT
		, strAccountDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS)

	INSERT INTO @GLAccounts
	SELECT strCategory = 'intAllocatedContractGainOrLossId'
		, fn.intAccountId
		, strAccountNo
		, ysnHasError
		, strAccountDescription = CASE WHEN fn.ysnHasError = 1 THEN fn.strErrorMessage ELSE gl.strDescription END
	FROM dbo.fnRKGetAccountIdForLocationLOB('Allocated Contracts Gain or Loss', @intAllocatedContractGainOrLossId, @intCommodityId, @intLocationId) fn
	LEFT JOIN tblGLAccount gl ON gl.intAccountId = fn.intAccountId

	UNION ALL
	SELECT strCategory = 'intAllocatedContractGainOrLossOffsetId'
		, fn.intAccountId
		, strAccountNo
		, ysnHasError
		, strAccountDescription = CASE WHEN fn.ysnHasError = 1 THEN fn.strErrorMessage ELSE gl.strDescription END
	FROM dbo.fnRKGetAccountIdForLocationLOB('Allocated Contracts Gain or Loss Offset', @intAllocatedContractGainOrLossOffsetId, @intCommodityId, @intLocationId) fn
	LEFT JOIN tblGLAccount gl ON gl.intAccountId = fn.intAccountId

	--============================================================
	-- SETUP VALIDATION
	--=============================================================
	SELECT * INTO #tmpPostRecap
	FROM tblRKAllocatedContractsPostRecap 
	WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

	IF (@dtmCurrenctGLPostDate IS NULL)
	BEGIN
		SELECT TOP 1 @dtmCurrenctGLPostDate = dtmPostDate FROM #tmpPostRecap
	END

	DECLARE @tblResult TABLE (Result NVARCHAR(200))

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
	BEGIN
		DECLARE @strTransactionId NVARCHAR(50)
			, @intTransactionId INT
			, @strContractNumber NVARCHAR(50)
			, @intContractSeq NVARCHAR(20)
			, @intAllocatedContractsPostRecapId INT
			, @strTransactionType NVARCHAR(100)
			, @dblAmount NUMERIC(18, 6)
			, @intAccountId INT
			, @strAccountNo NVARCHAR(MAX)
			, @ysnHasError BIT
			, @strAccountDescription NVARCHAR(MAX)
		
		SELECT TOP 1 @intAllocatedContractsPostRecapId = intAllocatedContractsPostRecapId
			, @strTransactionId = strTransactionId
			, @intTransactionId = intTransactionId
			, @strTransactionType = strTransactionType
			, @dblAmount = (dblDebit + dblCredit)
			
		FROM #tmpPostRecap

		IF (@strTransactionType = 'Allocated Contracts Gain or Loss' )
		BEGIN
			SELECT TOP 1 @intAccountId = intAccountId
				, @strAccountNo = strAccountNo
				, @ysnHasError = ysnHasError
				, @strAccountDescription = strAccountDescription
			FROM @GLAccounts WHERE strCategory = 'intAllocatedContractGainOrLossId'
		END
		ELSE IF (@strTransactionType = 'Allocated Contracts Gain or Loss Offset' )
		BEGIN
			SELECT TOP 1 @intAccountId = intAccountId
				, @strAccountNo = strAccountNo
				, @ysnHasError = ysnHasError
				, @strAccountDescription = strAccountDescription
			FROM @GLAccounts WHERE strCategory = 'intAllocatedContractGainOrLossOffsetId'
		END
		

		IF (@ysnHasError = 1)
		BEGIN
			INSERT INTO @tblResult(Result)
			VALUES(@strAccountDescription)
		END
		ELSE
		BEGIN
			UPDATE tblRKAllocatedContractsPostRecap
			SET intAccountId = @intAccountId
				, strAccountId = @strAccountNo
				, strAccountDescription = @strAccountDescription
			WHERE intAllocatedContractsPostRecapId = @intAllocatedContractsPostRecapId
		END

		DELETE FROM #tmpPostRecap WHERE intAllocatedContractsPostRecapId = @intAllocatedContractsPostRecapId
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
		SELECT [dtmPostDate]
			, @batchId
			, [intAccountId]
			, ROUND([dblDebit],2)
			, ROUND([dblCredit],2)
			, [dblDebitForeign] = ROUND([dblDebitForeign], 2)
			, [dblCreditForeign] = ROUND([dblCreditForeign], 2)
			, ROUND([dblDebitUnit],2)
			, ROUND([dblCreditUnit],2)
			, [strAccountDescription]
			, [intCurrencyId]
			, [dtmTransactionDate]
			, [strTransactionId]
			, [intTransactionId]
			, 'Allocated Contracts Gain or Loss'--[strTransactionType]
			, [strTransactionForm]
			, [strModuleName]
			, [intConcurrencyId]
			, [dblExchangeRate]
			, GETDATE() --[dtmDateEntered]
			, [ysnIsUnposted]
			, [strCode]
			, [strReference]  
			, [intEntityId]
			, [intUserId]  
			, [intSourceLocationId]
			, [intSourceUOMId]
		FROM tblRKAllocatedContractsPostRecap
		WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

		EXEC dbo.uspGLBookEntries @GLEntries,1 --@ysnPost

		UPDATE tblRKAllocatedContractsPostRecap 
		SET   ysnIsUnposted = 1
			, strBatchId = @strBatchId 
		WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
		
		UPDATE tblRKAllocatedContractsGainOrLossHeader 
		SET   ysnPosted = 1
			, dtmPostDate = @dtmCurrenctGLPostDate
			, strBatchId = @batchId
			, dtmUnpostDate = NULL
		WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId


		--Post Reversal using the reversal date
	
		DECLARE @ReverseGLEntries AS RecapTableType,
				@strReversalBatchId AS NVARCHAR(100)
		EXEC uspSMGetStartingNumber 3, @strReversalBatchId OUT

		INSERT INTO @ReverseGLEntries (
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
		SELECT @dtmGLReverseDate
			, @strReversalBatchId
			, [intAccountId]
			, ROUND([dblCredit],2) --Reversal - credit value will become debit value
			, ROUND([dblDebit],2)
			, [dblDebitForeign] = ROUND([dblCreditForeign], 2)  --Reversal - credit value will become debit value
			, [dblCreditForeign] = ROUND([dblDebitForeign], 2)
			, ROUND([dblCreditUnit],2)
			, ROUND([dblDebitUnit],2)
			, [strAccountDescription]
			, [intCurrencyId]
			, @dtmGLReverseDate --[dtmTransactionDate]
			, [strTransactionId]
			, [intTransactionId]
			, 'Allocated Contracts Gain or Loss'--[strTransactionType]
			, [strTransactionForm]
			, [strModuleName]
			, [intConcurrencyId]
			, [dblExchangeRate]
			, GETDATE() --[dtmDateEntered]
			, 0
			, [strCode]
			, [strReference]  
			, [intEntityId]
			, [intUserId]  
			, [intSourceLocationId]
			, [intSourceUOMId]
		FROM tblRKAllocatedContractsPostRecap
		WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

		EXEC dbo.uspGLBookEntries @ReverseGLEntries,1 

	
		UPDATE tblRKAllocatedContractsPostRecap 
		SET strReversalBatchId = @strReversalBatchId 
		WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId


		EXEC uspSMAuditLog 
		     @keyValue = @intAllocatedContractsGainOrLossHeaderId       -- Primary Key Value of the Match Derivatives. 
		   , @screenName = 'RiskManagement.view.AllocatedContractsGainOrLoss'        -- Screen Namespace
		   , @entityId = @intUserId     -- Entity Id.
		   , @actionType = 'Posted'       -- Action Type
		   , @changeDescription = ''     -- Description
		   , @fromValue = ''          -- Previous Value
		   , @toValue = ''           -- New Value
	

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