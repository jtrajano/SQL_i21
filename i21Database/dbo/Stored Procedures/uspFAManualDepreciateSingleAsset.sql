CREATE PROCEDURE [dbo].[uspFAManualDepreciateSingleAsset]
	@intAssetId INT,
	@intBookId INT = 1,
	@intLedgerId INT = NULL,
	@dtmDepreciationDate DATETIME,
	@dblDepreciation NUMERIC(18,6),
	@strBatchId NVARCHAR(100),
	@strTransaction NVARCHAR(50) = 'Depreciation',
    @intEntityId INT = 1
AS
	DECLARE @Id Id
	DECLARE @IdGood FixedAssetLedgerTypeTable
	DECLARE @tblError TABLE (  
		intAssetId INT NOT NULL,  
		strError NVARCHAR(400) NULL,
		intLedgerId INT NULL
	)
	DECLARE @strTransactionId NVARCHAR(100)
	
	INSERT INTO @Id SELECT @intAssetId

	INSERT INTO @tblError 
      SELECT intAssetId , strError, intLedgerId FROM fnFAValidateAssetDepreciation(1, @intBookId, @Id)

	UPDATE BD
		SET ysnFullyDepreciated = 1
	FROM tblFABookDepreciation BD JOIN @tblError E ON E.intAssetId = BD.intAssetId
	WHERE intBookId = @intBookId
	AND strError = 'Asset already fully depreciated.'
	AND (CASE WHEN @intLedgerId IS NOT NULL THEN CASE WHEN BD.intLedgerId = @intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1

	UPDATE A
		SET ysnDisposed = 1
	FROM tblFAFixedAsset A JOIN @tblError E ON A.intAssetId = A.intAssetId
	WHERE strError = 'Asset was already disposed.'

	INSERT INTO @IdGood
    SELECT A.intId, ISNULL(@intLedgerId, B.intLedgerId) 
	FROM @Id A LEFT JOIN @tblError B ON A.intId = B.intAssetId
	WHERE B.intAssetId IS NULL 
 
	IF NOT EXISTS (SELECT TOP 1 1 FROM @IdGood)
	  GOTO LogError

	 -- Get Accounts Overridden by Location Segment
	DECLARE @tblOverrideAccount TABLE (
		intAssetId INT,
		intAccountId INT,
		intTransactionType INT,
		intNewAccountId INT  NULL,
		strNewAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
	)
	INSERT INTO @tblOverrideAccount (
		intAssetId
		,intAccountId
		,intTransactionType
		,intNewAccountId
		,strNewAccountId
		,strError
	)
    SELECT 
		DepreciationAccount.intAssetId
		,DepreciationAccount.intAccountId
		,DepreciationAccount.intTransactionType
		,DepreciationAccount.intNewAccountId
		,DepreciationAccount.strNewAccountId
		,DepreciationAccount.strError
	FROM tblFAFixedAsset A
    JOIN @IdGood B ON A.intAssetId = B.intId
    OUTER APPLY (
		SELECT * FROM dbo.fnFAGetOverrideAccount(A.intAssetId, CASE WHEN @strTransaction = 'Imported' THEN A.[intExpenseAccountId] ELSE A.[intDepreciationAccountId] END, CASE WHEN @strTransaction = 'Imported' THEN 2 ELSE 3 END)
	) DepreciationAccount
    UNION ALL
    SELECT 
		AccumulatedDepreciationAccount.intAssetId
		,AccumulatedDepreciationAccount.intAccountId
		,AccumulatedDepreciationAccount.intTransactionType
		,AccumulatedDepreciationAccount.intNewAccountId
		,AccumulatedDepreciationAccount.strNewAccountId
		,AccumulatedDepreciationAccount.strError
	FROM tblFAFixedAsset A
    JOIN @IdGood B ON A.intAssetId = B.intId
    OUTER APPLY (
		SELECT * FROM dbo.fnFAGetOverrideAccount(A.intAssetId, A.[intAccumulatedAccountId], 4)
	) AccumulatedDepreciationAccount

    -- Validate override accounts
	IF EXISTS(SELECT TOP 1 1 FROM @tblOverrideAccount WHERE intNewAccountId IS NULL AND strError IS NOT NULL)
	BEGIN
        INSERT INTO @tblError
        SELECT A.intAssetId, O.strError, B.intLedgerId
        FROM tblFAFixedAsset A  
        JOIN @IdGood B 
            ON A.intAssetId = B.intId
        JOIN @tblOverrideAccount O
            ON O.intAssetId = B.intId
        WHERE O.intNewAccountId IS NULL AND O.strError IS NOT NULL

        GOTO LogError
	END
    
    -- Validate depreciation value against the basis
    DECLARE @dblDepreciationBasis NUMERIC(18, 6), @dblDepreciationToDate NUMERIC(18, 6)
    SELECT TOP 1 @dblDepreciationBasis = dblDepreciationBasis, @dblDepreciationToDate = dblDepreciationToDate
    FROM tblFAFixedAssetDepreciation 
    WHERE intAssetId = @intAssetId
        AND intBookId = @intBookId
        AND (CASE WHEN @intLedgerId IS NOT NULL THEN CASE WHEN intLedgerId = @intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1
    ORDER BY intAssetDepreciationId DESC, dtmDepreciationToDate DESC 

    IF ((@dblDepreciationToDate + @dblDepreciation) > @dblDepreciationBasis)
        SET @dblDepreciation = @dblDepreciationBasis - @dblDepreciationToDate

    DECLARE @intDefaultCurrencyId INT, @ysnMultiCurrency BIT = 0
    SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

    SELECT 
        @ysnMultiCurrency = CASE WHEN ISNULL(BD.intFunctionalCurrencyId, ISNULL(A.intFunctionalCurrencyId, @intDefaultCurrencyId)) = ISNULL(BD.intCurrencyId, A.intCurrencyId) THEN 0 ELSE 1 END
    FROM tblFABookDepreciation BD
    JOIN tblFAFixedAsset A ON A.intAssetId = BD.intAssetId
    WHERE BD.intAssetId = @intAssetId
        AND BD.intBookId = @intBookId
        AND (CASE WHEN (@intLedgerId IS NOT NULL) THEN (CASE WHEN BD.intLedgerId = @intLedgerId THEN 1 ELSE 0 END) ELSE 1 END) = 1

	EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strTransactionId OUTPUT  
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
        [strBatchId],
        [intCurrencyId],
        [intFunctionalCurrencyId],
        [intLedgerId]
    )  
    SELECT DISTINCT
        @intAssetId,
        @intBookId,
        D.intDepreciationMethodId,
        E.dblBasis,  
        E.dblDepreciationBasis,
        BD.dtmPlacedInService,  
        NULL,  
	    @dtmDepreciationDate,
        E.dblDepreciationToDate + @dblDepreciation,  
        @dblDepreciation,
        ROUND((@dblDepreciation * BD.dblRate), 2),
        BD.dblSalvageValue,
        CASE WHEN ISNULL(E.dblFunctionalBasis, 0) > 0 THEN E.dblFunctionalBasis ELSE E.dblBasis END,
        CASE WHEN ISNULL(E.dblFunctionalDepreciationBasis, 0) > 0 THEN E.dblFunctionalDepreciationBasis ELSE E.dblDepreciationBasis END,
        CASE WHEN ISNULL(ROUND((@dblDepreciation * BD.dblRate), 2), 0) > 0 THEN ROUND((@dblDepreciation * BD.dblRate), 2) ELSE @dblDepreciation END,
        CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END,
        CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE 1 END,  
        @strTransaction,  
        @strTransactionId,  
        D.strDepreciationType,  
        D.strConvention,
        @strBatchId,
        BD.intCurrencyId,
        BD.intFunctionalCurrencyId,
        @intLedgerId
    FROM tblFAFixedAsset F 
    JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
    JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
    OUTER APPLY (
        SELECT TOP 1
            FAD.dblBasis,
            FAD.dblDepreciationBasis,
            FAD.dblDepreciationToDate,
            FAD.dblFunctionalBasis,
            FAD.dblFunctionalDepreciationBasis
        FROM tblFAFixedAssetDepreciation FAD
        WHERE FAD.intAssetId = @intAssetId
            AND FAD.intBookId = @intBookId
            AND (CASE WHEN @intLedgerId IS NOT NULL THEN CASE WHEN FAD.intLedgerId = @intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1
        ORDER BY FAD.intAssetDepreciationId DESC, FAD.dtmDepreciationToDate DESC
    ) E
    WHERE F.intAssetId = @intAssetId
    AND BD.intBookId = @intBookId
    AND (
        CASE WHEN @intLedgerId IS NOT NULL 
		THEN CASE WHEN (BD.intLedgerId = @intLedgerId) THEN 1 ELSE 0 END
		ELSE 1 END
    ) = 1

    IF (@intBookId = 1)
    BEGIN
        DECLARE @GLEntries RecapTableType
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
            ,[intLedgerId]
            ,[intCompanyLocationId]
        )
        SELECT   
            [strTransactionId]  = @strTransactionId
            ,[intTransactionId]  = A.[intAssetId]  
            ,[intAccountId]   = OverrideAccount.[intNewAccountId]
            ,[strDescription]  = A.[strAssetDescription]  
            ,[strReference]   = A.[strAssetId]  
            ,[dtmTransactionDate] = FAD.dtmDepreciationToDate
            ,[dblDebit]    = ROUND(ISNULL(FAD.dblFunctionalDepreciation, FAD.dblDepreciation), 2)  
            ,[dblCredit]   = 0  
            ,[dblDebitForeign]  = CASE WHEN ISNULL(@ysnMultiCurrency, 0) = 0 THEN 0 ELSE ROUND(FAD.dblDepreciation, 2) END 
            ,[dblCreditForeign]  = 0  
            ,[dblDebitReport]  = 0  
            ,[dblCreditReport]  = 0  
            ,[dblReportingRate]  = 0  
            ,[dblForeignRate]  = 0  
            ,[dblDebitUnit]   = 0  
            ,[dblCreditUnit]  = 0  
            ,[dtmDate]    =  FAD.dtmDepreciationToDate 
            ,[ysnIsUnposted]  = 0   
            ,[intConcurrencyId]  = 1  
            ,[intCurrencyId]  = A.intCurrencyId
            ,[dblExchangeRate] = ISNULL(FAD.dblRate, 1)
            ,[intUserId]   = 0  
            ,[intEntityId]   = @intEntityId     
            ,[dtmDateEntered]  = GETDATE()  
            ,[strBatchId]   = @strBatchId  
            ,[strCode]    = 'AMDPR'            
            ,[strJournalLineDescription] = ''  
            ,[intJournalLineNo]  = A.[intAssetId]     
            ,[strTransactionType] = 'Depreciation'  
            ,[strTransactionForm] = 'Fixed Assets'  
            ,[strModuleName]  = 'Fixed Assets'
            ,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
            ,[intLedgerId] = FAD.intLedgerId
            ,[intCompanyLocationId] = A.intCompanyLocationId
        FROM tblFAFixedAsset A  
        JOIN @IdGood B ON A.intAssetId = B.intId
        JOIN @tblOverrideAccount OverrideAccount 
		ON OverrideAccount.intAssetId = B.intId AND OverrideAccount.intAccountId = CASE WHEN @strTransaction = 'Imported' THEN A.[intExpenseAccountId] ELSE A.[intDepreciationAccountId] END
        OUTER APPLY(
            SELECT TOP 1 B.[dtmDepreciationToDate], B.dblDepreciation, B.dblFunctionalDepreciation, B.dblRate, B.intLedgerId
            FROM tblFAFixedAssetDepreciation B 
            WHERE B.intAssetId = A.[intAssetId] 
            AND ISNULL(intBookId,1) = @intBookId
            AND (CASE WHEN @intLedgerId IS NOT NULL THEN (CASE WHEN B.intLedgerId = @intLedgerId THEN 1 ELSE 0 END) ELSE 1 END) = 1
            ORDER BY B.intAssetDepreciationId DESC
        )FAD

        UNION ALL  
        SELECT   
            [strTransactionId]  = @strTransactionId  
            ,[intTransactionId]  = A.[intAssetId]  
            ,[intAccountId]   = OverrideAccount.[intNewAccountId]
            ,[strDescription]  = A.[strAssetDescription]  
            ,[strReference]   = A.[strAssetId]  
            ,[dtmTransactionDate] = FAD.dtmDepreciationToDate
            ,[dblDebit]    = 0  
            ,[dblCredit]   = ROUND(ISNULL(FAD.dblFunctionalDepreciation, FAD.dblDepreciation), 2)  
            ,[dblDebitForeign]  = 0  
            ,[dblCreditForeign]  = CASE WHEN ISNULL(@ysnMultiCurrency, 0) = 0 THEN 0 ELSE ROUND(FAD.dblDepreciation, 2) END  
            ,[dblDebitReport]  = 0  
            ,[dblCreditReport]  = 0  
            ,[dblReportingRate]  = 0  
            ,[dblForeignRate]  = 0  
            ,[dblDebitUnit]   = 0  
            ,[dblCreditUnit]  = 0  
            ,[dtmDate]    = FAD.dtmDepreciationToDate
            ,[ysnIsUnposted]  = 0   
            ,[intConcurrencyId]  = 1  
            ,[intCurrencyId]  = A.intCurrencyId  
            ,[dblExchangeRate]  = ISNULL(FAD.dblRate, 1)  
            ,[intUserId]   = 0  
            ,[intEntityId]   = @intEntityId     
            ,[dtmDateEntered]  = GETDATE()  
            ,[strBatchId]   = @strBatchId  
            ,[strCode]    = 'AMDPR'  
            ,[strJournalLineDescription] = ''  
            ,[intJournalLineNo]  = A.[intAssetId]     
            ,[strTransactionType] = 'Depreciation'  
            ,[strTransactionForm] = 'Fixed Assets'  
            ,[strModuleName]  = 'Fixed Assets'  
            ,[intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
            ,[intLedgerId] = FAD.intLedgerId
            ,[intCompanyLocationId] = A.intCompanyLocationId
        FROM tblFAFixedAsset A  
        JOIN @IdGood B ON A.intAssetId = B.intId
        JOIN @tblOverrideAccount OverrideAccount 
		ON OverrideAccount.intAssetId = B.intId AND OverrideAccount.intAccountId = A.[intAccumulatedAccountId]
        OUTER APPLY(
            SELECT TOP 1 B.[dtmDepreciationToDate], B.dblDepreciation, B.dblFunctionalDepreciation, B.dblRate, B.intLedgerId
            FROM tblFAFixedAssetDepreciation B 
            WHERE B.intAssetId = A.[intAssetId] 
            AND ISNULL(intBookId,1) = @intBookId
            AND (CASE WHEN @intLedgerId IS NOT NULL THEN (CASE WHEN B.intLedgerId = @intLedgerId THEN 1 ELSE 0 END) ELSE 1 END) = 1
            ORDER BY B.intAssetDepreciationId DESC
        )FAD

		DECLARE @GLEntries2 RecapTableType
		INSERT INTO @GLEntries2 SELECT * FROM @GLEntries 
		DELETE FROM @GLEntries2 WHERE dblDebit = 0 AND dblCredit = 0

        IF EXISTS(SELECT TOP 1 1 FROM @GLEntries2)  
        BEGIN
            DECLARE @PostResult INT  
            EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries2, @ysnPost = 1, @SkipICValidation = 1  
            IF @@ERROR <> 0 OR @PostResult <> 0 RETURN --1  
        END
    END

	LogError: