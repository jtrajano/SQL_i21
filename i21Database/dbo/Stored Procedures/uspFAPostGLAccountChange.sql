CREATE PROCEDURE [dbo].[uspFAPostGLAccountChange]
	@intAssetId		INT,
	@intEntityId	INT,
	@dtmDate		DATETIME,
	@strBatchId		NVARCHAR(100) = '',
	@strTransactionId	NVARCHAR(100) = '' OUTPUT,
	@ysnSuccess		BIT = 0 OUTPUT
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION;

	-- GET ASSET AND ACCUMULATED DEPRECIATION
	DECLARE 
		@dblAssetNetValue NUMERIC(18, 6),
		@dblAssetValue NUMERIC (18, 6),
		@dblAccumulatedDepreciation NUMERIC (18, 6),
		@strErrorMessage NVARCHAR(MAX),
		@ysnHasNewAccountPosted BIT = 0,
		@intProfitCenter INT = NULL,
		@intDueToAccountId INT = NULL,
		@intDueFromAccountId INT = NULL,
		@intOverrideDueToAccountId INT = NULL,
		@intOverrideDueFromAccountId INT = NULL,
		@strOverrideDueToAccountId NVARCHAR(40) = NULL,
		@strOverrideDueFromAccountId NVARCHAR(40) = NULL

	SELECT TOP 1 @intDueFromAccountId = intDueFromAccountId, @intDueToAccountId = intDueToAccountId FROM [dbo].[tblFACompanyPreferenceOption]
	
	SELECT 
		@ysnHasNewAccountPosted = FA.ysnHasNewAccountPosted,
		@intProfitCenter = C.intProfitCenter
	FROM [dbo].[tblFAFixedAsset] FA
	LEFT JOIN [dbo].[tblSMCompanyLocation] C
		ON C.intCompanyLocationId = FA.intCompanyLocationId
	WHERE FA.intAssetId = @intAssetId

	-- VALIDATE OVERRIDE
	SELECT 
		@strOverrideDueToAccountId = [dbo].[fnGLGetOverrideAccountBySegment2](@intDueToAccountId, @intProfitCenter),
		@strOverrideDueFromAccountId = [dbo].[fnGLGetOverrideAccountBySegment2](@intDueFromAccountId, @intProfitCenter)

	SELECT @intOverrideDueToAccountId = intAccountId FROM tblGLAccount WHERE strAccountId = @strOverrideDueToAccountId
	SELECT @intOverrideDueFromAccountId = intAccountId FROM tblGLAccount WHERE strAccountId = @strOverrideDueFromAccountId

	IF (@intOverrideDueToAccountId IS NULL)
	BEGIN
		SET @strErrorMessage  = @strOverrideDueToAccountId + ' is not an existing account for override for Intra-Company Due To Account.'
		RAISERROR(@strErrorMessage, 11, 1)

		GOTO Post_Rollback;
	END
	IF (@intOverrideDueFromAccountId IS NULL)
	BEGIN
		SET @strErrorMessage  = @strOverrideDueFromAccountId + ' is not an existing account for override for Intra-Company Due From Account.'
		RAISERROR(@strErrorMessage, 11, 1)

		GOTO Post_Rollback;
	END

	IF (ISNULL(@ysnHasNewAccountPosted, 0)= 0)
	BEGIN
		SELECT
			@dblAssetValue = Asset.dblAmount,
			@dblAccumulatedDepreciation = AccumulatedDepreciation.dblAmount,
			@dblAssetNetValue = CASE WHEN (Asset.dblAmount < 0)
									THEN ABS(Asset.dblAmount) - (AccumulatedDepreciation.dblAmount)
									ELSE ABS(AccumulatedDepreciation.dblAmount) - ABS(Asset.dblAmount)
									END
		FROM [dbo].[tblFAFixedAsset] FA
		OUTER APPLY (
			SELECT 
				ISNULL(SUM(dblCredit - dblDebit), 0) dblAmount
			FROM tblGLDetail GL
			WHERE 
				GL.intAccountId = ISNULL(FA.intPrevAccumulatedAccountId, FA.intAccumulatedAccountId)
				AND strTransactionType = 'Depreciation'
				AND ysnIsUnposted = 0
				AND GL.strReference = FA.strAssetId
			GROUP BY GL.strReference
		) AccumulatedDepreciation
		OUTER APPLY (
			SELECT 
				ISNULL(SUM(dblCredit - dblDebit), 0) dblAmount
			FROM tblGLDetail GL
			WHERE 
				GL.intAccountId = ISNULL(FA.intPrevAssetAccountId, FA.intAssetAccountId)
				AND strTransactionType = 'Purchase'
				AND ysnIsUnposted = 0
				AND GL.strReference = FA.strAssetId
			GROUP BY GL.strReference
		) Asset
		WHERE FA.intAssetId = @intAssetId
	END
	ELSE 
	BEGIN
		SELECT
			@dblAssetValue = ISNULL(ChangeAccountPurchase.dblAmount, 0),
			@dblAccumulatedDepreciation = ISNULL(ChangeAccountDepereciation.dblAmount, 0),
			@dblAssetNetValue = CASE WHEN (ISNULL(ChangeAccountPurchase.dblAmount, 0) < 0)
									THEN ABS(ISNULL(ChangeAccountPurchase.dblAmount, 0)) - ISNULL(ChangeAccountDepereciation.dblAmount, 0)
									ELSE ABS(ISNULL(ChangeAccountDepereciation.dblAmount, 0)) - ABS(ISNULL(ChangeAccountPurchase.dblAmount, 0))
									END
		FROM [dbo].[tblFAFixedAsset] FA
		OUTER APPLY (
			SELECT TOP 1
				strTransactionId,
				intAssetDepreciationId
			FROM [dbo].[tblFAFixedAssetDepreciation]
			WHERE intAssetId = @intAssetId AND intBookId = 1 AND strTransaction = 'Change Account'
			ORDER BY dtmDepreciationToDate DESC, intAssetDepreciationId DESC
		) LatestChangeAccount
		OUTER APPLY (
			SELECT 
				ISNULL(SUM(dblCredit - dblDebit), 0) dblAmount
			FROM tblGLDetail GL
			WHERE 
				GL.intAccountId = FA.intAssetAccountId
				AND strTransactionType = 'Change Account'
				AND strTransactionId = LatestChangeAccount.strTransactionId
				AND ysnIsUnposted = 0
				AND GL.strReference = FA.strAssetId
			GROUP BY GL.strReference
		) ChangeAccountPurchase
		OUTER APPLY (
			SELECT 
				ISNULL(SUM(dblCredit - dblDebit), 0) dblAmount
			FROM tblGLDetail GL
			WHERE 
				GL.intAccountId = FA.intAccumulatedAccountId
				AND strTransactionType = 'Depreciation'
				AND ysnIsUnposted = 0
				AND GL.strReference = FA.strAssetId
				AND strTransactionId IN (SELECT strTransactionId
					FROM [dbo].[tblFAFixedAssetDepreciation]
					WHERE intAssetId = @intAssetId AND intBookId = 1 AND strTransaction IN ('Change Account', 'Depreciation', 'Imported')
						AND intAssetDepreciationId >= LatestChangeAccount.intAssetDepreciationId
					)
			GROUP BY GL.strReference
		) ChangeAccountDepereciation
		WHERE FA.intAssetId = @intAssetId
	END

	IF (@dblAssetNetValue = 0)
	BEGIN
		SET @strErrorMessage  = 'GL Change Account is not allowed. Asset value less than Accumulated Depreciation is 0.'
		RAISERROR(@strErrorMessage, 11, 1)

		GOTO Post_Rollback;
	END

	-- POST TO GL
	DECLARE @GLEntries RecapTableType

	EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID = @strTransactionId OUTPUT
	DELETE FROM @GLEntries  
    INSERT INTO @GLEntries (
		[strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[strReference]	
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitForeign]			
		,[dblCreditForeign]
		,[dblDebitReport]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intUserId]
		,[intEntityId]			
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]			
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]			
		,[intCurrencyExchangeRateTypeId]
	)

	-- OLD ASSET ACCOUNT
	SELECT 
		[strTransactionId]		= @strTransactionId
		,[intTransactionId]		= A.[intAssetId]
		,[intAccountId]			= A.[intAssetAccountId]
		,[strDescription]		= A.[strAssetDescription]
		,[strReference]			= A.[strAssetId]
		,[dtmTransactionDate]	= A.[dtmDateAcquired]
		,[dblDebit]				= CASE WHEN (@dblAssetValue > 0) THEN @dblAssetValue ELSE 0 END
		,[dblCredit]			= CASE WHEN (@dblAssetValue < 0) THEN ABS(@dblAssetValue) ELSE 0 END
		,[dblDebitForeign]		= 0
		,[dblCreditForeign]		= 0
		,[dblDebitReport]		= 0
		,[dblCreditReport]		= 0
		,[dblReportingRate]		= 0
		,[dblForeignRate]		= 0
		,[dblDebitUnit]			= 0
		,[dblCreditUnit]		= 0
		,[dtmDate]				= @dtmDate
		,[ysnIsUnposted]		= 0 
		,[intConcurrencyId]		= 1
		,[intCurrencyId]		= A.intCurrencyId
		,[dblExchangeRate]		= 1
		,[intUserId]			= 0
		,[intEntityId]			= @intEntityId			
		,[dtmDateEntered]		= GETDATE()
		,[strBatchId]			= @strBatchId
		,[strCode]				= 'AMPUR'
		,[strJournalLineDescription] = ''
		,[intJournalLineNo]		= A.[intAssetId]			
		,[strTransactionType]	= 'Purchase'
		,[strTransactionForm]	= 'Fixed Assets'
		,[strModuleName]		= 'Fixed Assets'
		,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
	FROM [dbo].[tblFAFixedAsset] A
	WHERE A.intAssetId = @intAssetId
	
	-- OLD ACCUMULATE DEPRECIATION ACCOUNT
	IF (ISNULL(@dblAccumulatedDepreciation, 0) <> 0)
	BEGIN
		INSERT INTO @GLEntries (
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitForeign]			
			,[dblCreditForeign]
			,[dblDebitReport]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]			
			,[intCurrencyExchangeRateTypeId]
		)
		SELECT 
			[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAccumulatedAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.[strAssetId]
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN (@dblAccumulatedDepreciation > 0) THEN @dblAccumulatedDepreciation ELSE 0 END
			,[dblCredit]			= CASE WHEN (@dblAccumulatedDepreciation < 0) THEN ABS(@dblAccumulatedDepreciation) ELSE 0 END
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= @dtmDate
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AMDPR'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Depreciation'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
			,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
		FROM [dbo].[tblFAFixedAsset] A
		WHERE A.intAssetId = @intAssetId
	END

	INSERT INTO @GLEntries (
		[strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[strReference]	
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitForeign]			
		,[dblCreditForeign]
		,[dblDebitReport]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intUserId]
		,[intEntityId]			
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]			
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]			
		,[intCurrencyExchangeRateTypeId]
	)
	-- NEW ASSET ACCOUNT
	SELECT 
		[strTransactionId]		= @strTransactionId
		,[intTransactionId]		= A.[intAssetId]
		,[intAccountId]			= A.[intNewAssetAccountId]
		,[strDescription]		= A.[strAssetDescription]
		,[strReference]			= A.[strAssetId]
		,[dtmTransactionDate]	= A.[dtmDateAcquired]
		,[dblDebit]				= CASE WHEN (@dblAssetNetValue > 0) THEN @dblAssetNetValue ELSE 0 END
		,[dblCredit]			= CASE WHEN (@dblAssetNetValue < 0) THEN ABS(@dblAssetNetValue) ELSE 0 END
		,[dblDebitForeign]		= 0
		,[dblCreditForeign]		= 0
		,[dblDebitReport]		= 0
		,[dblCreditReport]		= 0
		,[dblReportingRate]		= 0
		,[dblForeignRate]		= 0
		,[dblDebitUnit]			= 0
		,[dblCreditUnit]		= 0
		,[dtmDate]				= @dtmDate
		,[ysnIsUnposted]		= 0 
		,[intConcurrencyId]		= 1
		,[intCurrencyId]		= A.intCurrencyId
		,[dblExchangeRate]		= 1
		,[intUserId]			= 0
		,[intEntityId]			= @intEntityId			
		,[dtmDateEntered]		= GETDATE()
		,[strBatchId]			= @strBatchId
		,[strCode]				= 'AMDPR'
		,[strJournalLineDescription] = ''
		,[intJournalLineNo]		= A.[intAssetId]			
		,[strTransactionType]	= 'Change Account'
		,[strTransactionForm]	= 'Fixed Assets'
		,[strModuleName]		= 'Fixed Assets'
		,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
	FROM [dbo].[tblFAFixedAsset] A
	WHERE A.intAssetId = @intAssetId
	-- DUE TO
	UNION ALL
	SELECT 
		[strTransactionId]		= @strTransactionId
		,[intTransactionId]		= A.[intAssetId]
		,[intAccountId]			= @intOverrideDueToAccountId
		,[strDescription]		= A.[strAssetDescription]
		,[strReference]			= A.[strAssetId]
		,[dtmTransactionDate]	= A.[dtmDateAcquired]
		,[dblDebit]				= CASE WHEN (@dblAssetNetValue > 0) THEN @dblAssetNetValue ELSE 0 END
		,[dblCredit]			= CASE WHEN (@dblAssetNetValue < 0) THEN ABS(@dblAssetNetValue) ELSE 0 END
		,[dblDebitForeign]		= 0
		,[dblCreditForeign]		= 0
		,[dblDebitReport]		= 0
		,[dblCreditReport]		= 0
		,[dblReportingRate]		= 0
		,[dblForeignRate]		= 0
		,[dblDebitUnit]			= 0
		,[dblCreditUnit]		= 0
		,[dtmDate]				= @dtmDate
		,[ysnIsUnposted]		= 0 
		,[intConcurrencyId]		= 1
		,[intCurrencyId]		= A.intCurrencyId
		,[dblExchangeRate]		= 1
		,[intUserId]			= 0
		,[intEntityId]			= @intEntityId			
		,[dtmDateEntered]		= GETDATE()
		,[strBatchId]			= @strBatchId
		,[strCode]				= 'AMDPR'
		,[strJournalLineDescription] = ''
		,[intJournalLineNo]		= A.[intAssetId]			
		,[strTransactionType]	= 'Change Account'
		,[strTransactionForm]	= 'Fixed Assets'
		,[strModuleName]		= 'Fixed Assets'
		,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
	FROM [dbo].[tblFAFixedAsset] A
	WHERE A.intAssetId = @intAssetId
	-- DUE FROM
	UNION ALL
	SELECT 
		[strTransactionId]		= @strTransactionId
		,[intTransactionId]		= A.[intAssetId]
		,[intAccountId]			= @intOverrideDueFromAccountId
		,[strDescription]		= A.[strAssetDescription]
		,[strReference]			= A.[strAssetId]
		,[dtmTransactionDate]	= A.[dtmDateAcquired]
		,[dblDebit]				= CASE WHEN (@dblAssetNetValue < 0) THEN ABS(@dblAssetNetValue) ELSE 0 END
		,[dblCredit]			= CASE WHEN (@dblAssetNetValue > 0) THEN @dblAssetNetValue ELSE 0 END
		,[dblDebitForeign]		= 0
		,[dblCreditForeign]		= 0
		,[dblDebitReport]		= 0
		,[dblCreditReport]		= 0
		,[dblReportingRate]		= 0
		,[dblForeignRate]		= 0
		,[dblDebitUnit]			= 0
		,[dblCreditUnit]		= 0
		,[dtmDate]				= @dtmDate
		,[ysnIsUnposted]		= 0 
		,[intConcurrencyId]		= 1
		,[intCurrencyId]		= A.intCurrencyId
		,[dblExchangeRate]		= 1
		,[intUserId]			= 0
		,[intEntityId]			= @intEntityId			
		,[dtmDateEntered]		= GETDATE()
		,[strBatchId]			= @strBatchId
		,[strCode]				= 'AMDPR'
		,[strJournalLineDescription] = ''
		,[intJournalLineNo]		= A.[intAssetId]			
		,[strTransactionType]	= 'Change Account'
		,[strTransactionForm]	= 'Fixed Assets'
		,[strModuleName]		= 'Fixed Assets'
		,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
	FROM [dbo].[tblFAFixedAsset] A
	WHERE A.intAssetId = @intAssetId

	BEGIN TRY
		EXEC uspGLBookEntries @GLEntries, 1;
	END TRY
	BEGIN CATCH		
		SET @strErrorMessage  = ERROR_MESSAGE()
		RAISERROR(@strErrorMessage, 11, 1)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END CATCH

	IF @@ERROR <> 0	GOTO Post_Rollback;

	-- UPDATE EXISTING GL ACCOUNTS
	UPDATE [dbo].[tblFAFixedAsset]
	SET
		intPrevAssetAccountId = intAssetAccountId,
		intPrevExpenseAccountId = intExpenseAccountId,
		intPrevDepreciationAccountId = intDepreciationAccountId,
		intPrevAccumulatedAccountId = intAccumulatedAccountId,
		intPrevGainLossAccountId = intGainLossAccountId,
		intPrevSalesOffsetAccountId = intSalesOffsetAccountId,
		intAssetAccountId = intNewAssetAccountId,
		intAccumulatedAccountId = intNewAccumulatedAccountId,
		intExpenseAccountId = ISNULL(intNewExpenseAccountId, intExpenseAccountId),
		intDepreciationAccountId = ISNULL(intNewDepreciationAccountId, intDepreciationAccountId),
		intGainLossAccountId = ISNULL(intNewGainLossAccountId, intGainLossAccountId),
		intSalesOffsetAccountId = ISNULL(intNewSalesOffsetAccountId, intSalesOffsetAccountId),
		intNewAssetAccountId = NULL,
		intNewExpenseAccountId = NULL,
		intNewDepreciationAccountId = NULL,
		intNewAccumulatedAccountId = NULL,
		intNewGainLossAccountId = NULL,
		intNewSalesOffsetAccountId = NULL,
		ysnHasNewAccountPosted = 1
	WHERE intAssetId = @intAssetId;

	-- ADD ENTRY TO CHANGE ACCOUNT LOG
	DECLARE @intLogSuccessCount INT
	EXEC uspFAAddGLAccountChangeLog @intAssetId = @intAssetId, @strChange = 'GL change account posted.', @intEntityId = @intEntityId, @intSuccessfulCount = @intLogSuccessCount OUTPUT;
	
	-- ADD ENTRY TO Depreciation History
	INSERT INTO tblFAFixedAssetDepreciation (  
        [intAssetId],  
        [intBookId],
        [intDepreciationMethodId],  
        [dblBasis],  
        [dblDepreciationBasis],  
        [dtmDateInService],  
        [dtmDispositionDate],  
        [dtmDepreciationToDate],  
        [dblDepreciationToDate],  
        [dblDepreciation],
        [dblFunctionalDepreciation],  
        [dblSalvageValue],
        [dblFunctionalBasis],
        [dblFunctionalDepreciationBasis],
        [dblFunctionalDepreciationToDate],
        [dblFunctionalSalvageValue],
        [dblRate],  
        [strTransaction],  
        [strTransactionId],  
        [strType],  
        [strConvention],
        [strBatchId]
	)  
	SELECT  
        @intAssetId,
        1,
        D.intDepreciationMethodId,
        Dep.dblBasis,  
        Dep.dblDepreciationBasis,
        BD.dtmPlacedInService,  
        NULL,  
		@dtmDate,
        0,  
        0,
        0,
        Dep.dblSalvageValue,
        Dep.dblFunctionalBasis,
        Dep.dblFunctionalDepreciationBasis,
        0,
        Dep.dblSalvageValue,
        1,  
        'Change Account',
        @strTransactionId,  
        D.strDepreciationType,  
        D.strConvention,
        @strBatchId
    FROM tblFAFixedAsset F 
    JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
    JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
    OUTER APPLY (
        SELECT TOP 1
			dblBasis, dblFunctionalBasis, dblSalvageValue, dblFunctionalSalvageValue, dblDepreciationBasis, dblFunctionalDepreciationBasis
		FROM [dbo].[tblFAFixedAssetDepreciation]
		WHERE intAssetId = @intAssetId AND intBookId = 1
		ORDER BY dtmDepreciationToDate DESC, intAssetDepreciationId DESC
    ) Dep
    WHERE F.intAssetId = @intAssetId

	SET @ysnSuccess = 1

Post_Commit:
	COMMIT TRANSACTION
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	GOTO Post_Exit

Post_Exit: