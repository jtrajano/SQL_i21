CREATE PROCEDURE [dbo].[uspFADisposeAsset]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@intEntityId		AS INT				= 1,
	@strTransactionId	AS NVARCHAR(20)	= '' OUTPUT,
	@successfulCount	AS INT				= 0 OUTPUT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION;

DECLARE @strAssetId NVARCHAR(20)
DECLARE @ErrorMessage NVARCHAR(MAX)
--=====================================================================================================================================
-- 	POPULATE FIXEDASSETS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #AssetID(
			[intAssetId] [int] NOT NULL
		)

DECLARE @tblAsset TABLE (
			[strAssetId] NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
			[intAssetId] [int] NOT NULL,
			dtmDispose DATETIME NOT NULL,
			ysnOpenPeriod BIT NOT NULL,
			totalDepre NUMERIC(18,6),
			totalForeignDepre NUMERIC(18,6),
			strTransactionId NVARCHAR(20)
		)
IF (ISNULL(@Param, '') <> '') 
	INSERT INTO #AssetID EXEC (@Param)
ELSE
	INSERT INTO #AssetID( intAssetid ) SELECT [intAssetId] FROM tblFAFixedAsset

--START GETTING THE DISPOSAL DATE AND CHECKING IT AGAINST FISCAL PERIOD
INSERT INTO @tblAsset
SELECT
B.strAssetId,
A.intAssetId,
D.dtmDepreciationToDate,
F.ysnOpenPeriod,
0,
0,
NULL
FROM #AssetID A 
JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId
JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId AND BD.intBookId = 1
OUTER APPLY(
	SELECT TOP 1 DATEADD(DAY,1, dtmDepreciationToDate)dtmDepreciationToDate 
	FROM tblFAFixedAssetDepreciation WHERE intAssetId = A.intAssetId
	ORDER BY dtmDepreciationToDate DESC
)D
OUTER APPLY(
	SELECT ISNULL(ysnOpen,0) &  ISNULL(ysnFAOpen,0) ysnOpenPeriod FROM tblGLFiscalYearPeriod WHERE 
	D.dtmDepreciationToDate BETWEEN
	dtmStartDate AND dtmEndDate
)F

WHERE isnull(ysnAcquired,0) = 1 AND isnull(ysnDisposed,0) = 0 AND isnull(ysnDepreciated,0) = 1

UPDATE A SET 
dtmDispose = F.dtmStartDate,
ysnOpenPeriod = 1
FROM @tblAsset A 
CROSS APPLY(
	SELECT TOP 1 dtmStartDate FROM tblGLFiscalYearPeriod 
	WHERE dtmDispose < dtmStartDate
	AND (ISNULL(ysnOpen,0) &  ISNULL(ysnFAOpen,0)) = 1
	ORDER BY dtmStartDate 
)F
WHERE ysnOpenPeriod = 0

IF EXISTS(SELECT TOP 1 1 FROM @tblAsset WHERE ysnOpenPeriod = 0)
BEGIN
	SELECT TOP 1 @strAssetId = strAssetId FROM @tblAsset WHERE ysnOpenPeriod = 0
	SET @ErrorMessage = @strAssetId + ' does not have an open fiscal period to dispose'
	RAISERROR(@ErrorMessage, 16,1)
	GOTO Post_Rollback
END

IF NOT EXISTS(SELECT 1 FROM @tblAsset)
BEGIN
	RAISERROR('There are no assets for disposal or asset is not yet depreciated', 16,1)
	GOTO Post_Rollback
END

WHILE EXISTS( SELECT TOP 1 1 FROM @tblAsset WHERE strTransactionId IS NULL)
BEGIN
	SELECT TOP 1 @strAssetId = strAssetId FROM @tblAsset WHERE strTransactionId IS NULL
	EXEC uspSMGetStartingNumber 111, @strTransactionId OUTPUT
	UPDATE @tblAsset SET strTransactionId = @strTransactionId FROM @tblAsset where strAssetId = @strAssetId
END


--END GETTING THE DISPOSAL DATE AND CHECKING IT AGAINST FISCAL PERIOD

DECLARE @strBatchId AS NVARCHAR(100)= ''
EXEC uspSMGetStartingNumber 3, @strBatchId OUTPUT
	
--=====================================================================================================================================
-- 	UNPOSTING FIXEDASSETS TRANSACTIONS ysnPost = 0
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT	
		SELECT TOP 1 @strAssetId= strAssetId FROM tblFAFixedAsset A JOIN #AssetID B on A.intAssetId = B.intAssetId
		SET @Param = 'SELECT intGLDetailId FROM tblGLDetail WHERE strReference = ''' + @strAssetId + ''' AND strCode = ''AMDIS'' AND ysnIsUnposted=0'
		IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLDetail WHERE strBatchId = @strBatchId))
			BEGIN
				DECLARE @ReverseResult INT
				EXEC @ReverseResult  = [dbo].[uspFAReverseGLEntries] @strBatchId,@Param, @ysnRecap, NULL, @intEntityId, @intCount	OUT
				IF @ReverseResult <> 0 RETURN -1
				SET @successfulCount = @intCount
				IF ISNULL(@ysnRecap,0) = 0
					IF(@intCount > 0)
					BEGIN
						UPDATE tblFAFixedAsset SET ysnDisposed = 0 WHERE intAssetId IN (SELECT intAssetId FROM #AssetID)				
					END									
			END
		
		GOTO Post_Commit;
	END


--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
Post_Transaction:


DECLARE @intDefaultCurrencyId INT, @ysnMultiCurrency BIT = 0, @intDefaultCurrencyExchangeRateTypeId INT, @intRealizedGainLossAccountId INT
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
SELECT @intDefaultCurrencyExchangeRateTypeId = dbo.fnFAGetDefaultCurrencyExchangeRateTypeId() 
SELECT TOP 1 @intRealizedGainLossAccountId = intFixedAssetsRealizedId FROM tblSMMultiCurrency
DECLARE @dblMonthEndSpotRate NUMERIC(18,6), @dblCurrentRate NUMERIC(18,6), @dblRate NUMERIC(18,6), @dtmDispose DATETIME,
	@dblTotalForeignDepreHistoric NUMERIC(18,6), @dblTotalForeignDepreMonthEnd NUMERIC(18,6), @dblTotalForeignDepreCurrent NUMERIC(18,6)


IF ISNULL(@ysnRecap, 0) = 0
	BEGIN				
		SELECT @dblRate = CASE WHEN ISNULL(BD.dblRate, 0) > 0 
					THEN BD.dblRate 
					ELSE 
						CASE WHEN ISNULL(F.dblForexRate, 0) > 0 
						THEN F.dblForexRate 
						ELSE 1 
						END 
					END,
				@dblMonthEndSpotRate = ISNULL(dbo.fnGetForexRate(EOMONTH(BD.dtmPlacedInService), F.intCurrencyId, ISNULL(F.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)), 1),
				@dblCurrentRate = ISNULL(dbo.fnGetForexRate(GETDATE(), F.intCurrencyId, ISNULL(F.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)), 1),
				@ysnMultiCurrency = CASE WHEN ISNULL(BD.intFunctionalCurrencyId, ISNULL(F.intFunctionalCurrencyId, @intDefaultCurrencyId)) = ISNULL(BD.intCurrencyId, F.intCurrencyId) THEN 0 ELSE 1 END
		FROM tblFAFixedAsset F 
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
        WHERE BD.intBookId = 1


		UPDATE A 
		SET totalDepre = G.S, totalForeignDepre = G.dblSumForeign
		FROM  @tblAsset A
		OUTER APPLY(
			SELECT 
			SUM(dblCredit - dblDebit) S,
			SUM(dblCreditForeign - dblDebitForeign) dblSumForeign
			FROM tblGLDetail GL
			JOIN tblFAFixedAsset FA ON FA.intAssetId = A.intAssetId
			WHERE FA.intAccumulatedAccountId = GL.intAccountId
			AND strCode = 'AMDPR'
			AND ysnIsUnposted = 0
			AND A.strAssetId = GL.strReference
			GROUP BY FA.strAssetId
		) G

		SELECT 
			@dblTotalForeignDepreHistoric = (totalForeignDepre * @dblRate),
			@dblTotalForeignDepreMonthEnd = (totalForeignDepre * @dblMonthEndSpotRate),
			@dblTotalForeignDepreCurrent = (totalForeignDepre * @dblCurrentRate)
		FROM @tblAsset

		 INSERT INTO tblFAFixedAssetDepreciation (  
                [intAssetId],  
                [intBookId],
                [intDepreciationMethodId],  
                [dblBasis],  
                [dtmDateInService],  
                [dtmDispositionDate],  
                [dtmDepreciationToDate],  
                [dblDepreciationToDate],  
                [dblSalvageValue],
                [dblFunctionalBasis],
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
                F.intAssetId,
                1,
                D.intDepreciationMethodId,
                BD.dblCost - BD.dblSalvageValue,  
                BD.dtmPlacedInService,  
                A.dtmDispose,
				A.dtmDispose,
				CASE WHEN @ysnMultiCurrency = 0 THEN A.totalDepre ELSE A.totalForeignDepre END,  
                BD.dblSalvageValue,
                (BD.dblCost - BD.dblSalvageValue) * @dblRate,
                CASE WHEN @ysnMultiCurrency = 0 THEN A.totalDepre * @dblRate ELSE A.totalDepre END,
                CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue * @dblRate END,
                @dblRate,    
                'Dispose',  
                A.strTransactionId,  
                D.strDepreciationType,  
                D.strConvention,
                @strBatchId
                FROM tblFAFixedAsset F 
				JOIN @tblAsset A ON A.intAssetId = F.intAssetId
                JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
                JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
                WHERE BD.intBookId = 1


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
		)
		SELECT 
			 [strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAccumulatedAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN @ysnMultiCurrency = 0 THEN B.totalDepre ELSE CASE WHEN B.totalForeignDepre > 0 THEN (B.totalForeignDepre * @dblRate) ELSE B.totalDepre END END
			,[dblCredit]			= 0
			,[dblDebitForeign]		= CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE B.totalForeignDepre END
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= B.[dtmDispose]
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= @dblRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AMDIS' --FA
								
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Fixed Assets'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
			,[intCurrencyExchangeRateTypeId] = ISNULL(A.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)
		
		FROM tblFAFixedAsset A 
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId

		--WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)
		UNION ALL
		SELECT 
			 [strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAssetAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= 0
			,[dblCredit]			= CASE WHEN @ysnMultiCurrency = 0 THEN A.[dblCost] ELSE A.[dblCost] * @dblRate END
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE A.[dblCost] END
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= B.[dtmDispose]
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= @dblRate
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AMDIS' --FA
								
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Fixed Assets'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
			,[intCurrencyExchangeRateTypeId] = ISNULL(A.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)
		
		FROM tblFAFixedAsset A
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId
		
		UNION ALL
		SELECT 
			 [strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intGainLossAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN @ysnMultiCurrency = 0
										THEN
											CASE WHEN A.dblCost > B.totalDepre THEN A.dblCost - B.totalDepre ELSE 0 END
										ELSE
											CASE WHEN A.dblCost > B.totalForeignDepre
											THEN (A.dblCost - B.totalForeignDepre) * @dblMonthEndSpotRate +
												CASE WHEN @dblCurrentRate > @dblRate
													THEN A.dblCost * (@dblCurrentRate - @dblRate)
													ELSE 0
												  END
											ELSE 0 
										END
									  END
			,[dblCredit]			= CASE WHEN @ysnMultiCurrency = 0
										THEN 
											CASE WHEN B.totalDepre > A.dblCost THEN B.totalDepre - A.dblCost ELSE 0 END
										ELSE
											CASE WHEN B.totalForeignDepre > A.dblCost
											THEN (B.totalForeignDepre - A.dblCost) * @dblMonthEndSpotRate +
											  CASE WHEN @dblRate > @dblCurrentRate
												THEN A.dblCost * (@dblRate - @dblCurrentRate)
												ELSE 0
											  END
											ELSE 0 
										END
									  END
			,[dblDebitForeign]		= CASE WHEN @ysnMultiCurrency = 0
										THEN 0
										ELSE
											CASE WHEN A.dblCost > B.totalForeignDepre THEN A.dblCost - B.totalForeignDepre ELSE 0 END
										END
			,[dblCreditForeign]		= CASE WHEN @ysnMultiCurrency = 0
										THEN 0
										ELSE
											CASE WHEN B.totalForeignDepre > A.dblCost THEN B.totalForeignDepre - A.dblCost ELSE 0 END
										END
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= B.[dtmDispose]
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 0
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AMDIS' --FA
								
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Fixed Assets'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
			,[intCurrencyExchangeRateTypeId] = ISNULL(A.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)
		
		FROM tblFAFixedAsset A
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> A.dblCost

		-- IF MultiCurreny, do Realized Gain or Loss
		IF (@ysnMultiCurrency = 1 AND @intRealizedGainLossAccountId IS NOT NULL)
		BEGIN
			-- If Credit and Debit for Realized Gain or Loss is zero -> do no create GL Entry.
			-- Credit and Debit will be zero if historic rate, month end spot rate and current rate were all the same.
			DECLARE
				@dblRealizedDebit INT = 0,
				@dblRealizedCredit INT = 0

			SELECT 
				@dblRealizedDebit = CASE WHEN (CASE WHEN (@dblTotalForeignDepreHistoric > @dblTotalForeignDepreMonthEnd) 
										THEN @dblTotalForeignDepreHistoric - @dblTotalForeignDepreMonthEnd ELSE 0 END) = 0
									THEN 
										(CASE WHEN @dblRate > @dblCurrentRate THEN A.dblCost * (@dblRate - @dblCurrentRate) ELSE 0 END)
									ELSE @dblTotalForeignDepreHistoric - @dblTotalForeignDepreMonthEnd
									END,
				@dblRealizedCredit = CASE WHEN (CASE WHEN (@dblTotalForeignDepreMonthEnd > @dblTotalForeignDepreHistoric)
										THEN @dblTotalForeignDepreHistoric - @dblTotalForeignDepreHistoric ELSE 0 END ) = 0
									THEN
										(CASE WHEN @dblCurrentRate > @dblRate THEN A.dblCost * (@dblCurrentRate - @dblRate) ELSE 0 END)
									ELSE @dblTotalForeignDepreHistoric - @dblTotalForeignDepreHistoric
									END
										
			FROM tblFAFixedAsset A
			JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> A.dblCost

			IF (@dblRealizedCredit <> 0 AND @dblRealizedDebit <> 0)
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
				 [strTransactionId]		= B.strTransactionId
				,[intTransactionId]		= A.[intAssetId]
				,[intAccountId]			= @intRealizedGainLossAccountId
				,[strDescription]		= A.[strAssetDescription]
				,[strReference]			= A.strAssetId
				,[dtmTransactionDate]	= A.[dtmDateAcquired]
				,[dblDebit]				= @dblRealizedDebit
				,[dblCredit]			= @dblRealizedCredit
				,[dblDebitForeign]		= 0
				,[dblCreditForeign]		= 0
				,[dblDebitReport]		= 0
				,[dblCreditReport]		= 0
				,[dblReportingRate]		= 0
				,[dblForeignRate]		= 0
				,[dblDebitUnit]			= 0
				,[dblCreditUnit]		= 0
				,[dtmDate]				= B.[dtmDispose]
				,[ysnIsUnposted]		= 0 
				,[intConcurrencyId]		= 1
				,[intCurrencyId]		= A.intCurrencyId
				,[dblExchangeRate]		= 0
				,[intUserId]			= 0
				,[intEntityId]			= @intEntityId			
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @strBatchId
				,[strCode]				= 'AMDIS' --FA
								
				,[strJournalLineDescription] = ''
				,[intJournalLineNo]		= A.[intAssetId]			
				,[strTransactionType]	= 'Fixed Assets'
				,[strTransactionForm]	= 'Fixed Assets'
				,[strModuleName]		= 'Fixed Assets'
				,[intCurrencyExchangeRateTypeId] = ISNULL(A.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)
				FROM tblFAFixedAsset A
				JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> A.dblCost
			END
			--UNION
			--SELECT
			-- [strTransactionId]		= B.strTransactionId
			--,[intTransactionId]		= A.[intAssetId]
			--,[intAccountId]			= @intRealizedGainLossAccountId
			--,[strDescription]		= A.[strAssetDescription]
			--,[strReference]			= A.strAssetId
			--,[dtmTransactionDate]	= A.[dtmDateAcquired]
			--,[dblDebit]				= CASE WHEN @dblRate > @dblCurrentRate
			--							THEN A.dblCost * (@dblRate - @dblCurrentRate)
			--							ELSE 0
			--						  END
			--,[dblCredit]			= CASE WHEN @dblCurrentRate > @dblRate
			--							THEN A.dblCost * (@dblCurrentRate - @dblRate)
			--							ELSE 0
			--						  END
			--,[dblDebitForeign]		= 0
			--,[dblCreditForeign]		= 0
			--,[dblDebitReport]		= 0
			--,[dblCreditReport]		= 0
			--,[dblReportingRate]		= 0
			--,[dblForeignRate]		= 0
			--,[dblDebitUnit]			= 0
			--,[dblCreditUnit]		= 0
			--,[dtmDate]				= B.[dtmDispose]
			--,[ysnIsUnposted]		= 0 
			--,[intConcurrencyId]		= 1
			--,[intCurrencyId]		= A.intCurrencyId
			--,[dblExchangeRate]		= 0
			--,[intUserId]			= 0
			--,[intEntityId]			= @intEntityId			
			--,[dtmDateEntered]		= GETDATE()
			--,[strBatchId]			= @strBatchId
			--,[strCode]				= 'AMDIS' --FA
								
			--,[strJournalLineDescription] = ''
			--,[intJournalLineNo]		= A.[intAssetId]			
			--,[strTransactionType]	= 'Fixed Assets'
			--,[strTransactionForm]	= 'Fixed Assets'
			--,[strModuleName]		= 'Fixed Assets'
			--,[intCurrencyExchangeRateTypeId] = ISNULL(A.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)
			--FROM tblFAFixedAsset A
			--JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> A.dblCost
		END


		BEGIN TRY
			EXEC uspGLBookEntries @GLEntries, @ysnPost
		END TRY
		BEGIN CATCH		
			SET @ErrorMessage  = ERROR_MESSAGE()
			RAISERROR(@ErrorMessage, 11, 1)

			IF @@ERROR <> 0	GOTO Post_Rollback;
		END CATCH
		

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	UPDATE FIXEDASSETS TABLE
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE A
SET [ysnDisposed] = 1,
dtmDispositionDate = dtmDispose,
strDispositionNumber = @strTransactionId
FROM
tblFAFixedAsset A
JOIN @tblAsset B ON B.intAssetId = A.intAssetId


--remove from undepreciated
DELETE A FROM tblFAFiscalAsset A JOIN
@tblAsset B on B.intAssetId = A.intAssetId

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID FIXEDASSETS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM @tblAsset)


--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	GOTO Post_Exit

Post_Exit: