CREATE PROCEDURE [dbo].[uspFADisposeAsset]
	@Id					AS Id READONLY,	
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
DECLARE @tblAsset TABLE (
	[intRowId] INT,
	[strAssetId] NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
	[intAssetId] [int] NOT NULL,
	[dblAssetValue] NUMERIC(18,6),
	[dtmDispose] DATETIME NOT NULL,
	[ysnOpenPeriod] BIT NOT NULL,
	[totalDepre] NUMERIC(18,6),
	[totalForeignDepre] NUMERIC(18,6),
	[dblBasis] NUMERIC(18,6),
	[dblAnnualBasis] NUMERIC(18,6),
	[intMonthDivisor] INT,
	[intDepreciationMethodId] INT,
	[strTransactionId] NVARCHAR(20),
	[intLedgerId] INT,
	[ysnProcessed] BIT
)

-- START GETTING THE DISPOSAL DATE AND CHECKING IT AGAINST FISCAL PERIOD
INSERT INTO @tblAsset
SELECT
	ROW_NUMBER() OVER (ORDER BY A.intId ASC, BD.intBookDepreciationId ASC),
	B.strAssetId,
	A.intId,
	(B.dblCost - ISNULL(B.dblSalvageValue, 0)) + ISNULL(Adjustment.dblAdjustment, 0),
	B.dtmDispositionDate,
	F.ysnOpenPeriod,
	0,
	0,
	B.dblCost - ISNULL(B.dblSalvageValue, 0),
	(E.dblPercentage *.01) * (B.dblCost - ISNULL(B.dblSalvageValue, 0)),
	CASE WHEN M.intMonth > (M.intServiceYear * 12) AND isnull(M.intMonth,0) > 0 THEN M.intMonth ELSE 12 END,
	M.intDepreciationMethodId,
	NULL,
	BD.intLedgerId,
	0
FROM @Id A 
JOIN tblFAFixedAsset B on A.intId = B.intAssetId
JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intId AND BD.intBookId = 1
join tblFADepreciationMethod  M ON  M.intDepreciationMethodId = BD.intDepreciationMethodId
OUTER APPLY(
	SELECT COUNT (*) + 1 intMonth
	FROM tblFAFixedAssetDepreciation FAD
	WHERE FAD.intAssetId = B.intAssetId and ISNULL(FAD.intBookId,1) = BD.intBookId
	AND (CASE WHEN FAD.intLedgerId IS NOT NULL 
					THEN CASE WHEN (FAD.intLedgerId = BD.intLedgerId) THEN 1 ELSE 0 END
					ELSE 1 END) = 1
	AND strTransaction = 'Depreciation'
)Dep
OUTER APPLY(
	SELECT TOP 1 DATEADD(DAY,1, dtmDepreciationToDate)dtmDepreciationToDate 
	FROM tblFAFixedAssetDepreciation WHERE intAssetId = A.intId
	ORDER BY dtmDepreciationToDate DESC
)D
OUTER APPLY(
	SELECT ISNULL(dblPercentage,1) dblPercentage FROM tblFADepreciationMethodDetail 
		WHERE M.[intDepreciationMethodId] = intDepreciationMethodId AND
			intYear = CEILING(
		 	CASE 
			 	WHEN Dep.intMonth > ISNULL(M.intServiceYear,0)* 12 + ISNULL(M.intMonth ,0) 
			 	THEN ISNULL(M.intServiceYear,0)* 12 + ISNULL(M.intMonth ,0)
		  	ELSE
		  		Dep.intMonth -- IF MONTH IS OUT OF RANGE, THIS WILL GET THE LAST PERCENTAGE OF MONTH
		  	END/12.0)
)E
OUTER APPLY(
	SELECT ISNULL(ysnOpen,0) &  ISNULL(ysnFAOpen,0) ysnOpenPeriod FROM tblGLFiscalYearPeriod WHERE 
	D.dtmDepreciationToDate BETWEEN
	dtmStartDate AND dtmEndDate
)F
OUTER APPLY(
	SELECT ISNULL(SUM(BA.dblAdjustment), 0) dblAdjustment
	FROM tblFABasisAdjustment BA
	WHERE BA.intAssetId = A.intId AND BA.intBookId = 1 AND BA.dtmDate <= D.dtmDepreciationToDate AND BA.strAdjustmentType = 'Basis'
) Adjustment
WHERE ISNULL(ysnAcquired,0) = 1 AND isnull(ysnDisposed,0) = 0 AND ISNULL(ysnDepreciated,0) = 1

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
WHERE ysnOpenPeriod = 0 AND A.dtmDispose IS NULL

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

-- END GETTING THE DISPOSAL DATE AND CHECKING IT AGAINST FISCAL PERIOD

DECLARE @strBatchId AS NVARCHAR(100)= ''
EXEC uspSMGetStartingNumber 3, @strBatchId OUTPUT
	
--=====================================================================================================================================
-- 	UNPOSTING FIXEDASSETS TRANSACTIONS ysnPost = 0
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT, @Param NVARCHAR(MAX)
		SELECT TOP 1 @strAssetId= strAssetId FROM tblFAFixedAsset A JOIN @Id B on A.intAssetId = B.intId
		SET @Param = 'SELECT intGLDetailId FROM tblGLDetail WHERE strReference = ''' + @strAssetId + ''' AND strCode = ''AMDIS'' AND ysnIsUnposted=0'
		IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLDetail WHERE strBatchId = @strBatchId))
			BEGIN
				DECLARE @ReverseResult INT
				EXEC @ReverseResult  = [dbo].[uspFAReverseGLEntries] @strBatchId, @Param, @ysnRecap, NULL, @intEntityId, @intCount	OUT
				IF @ReverseResult <> 0 RETURN -1
				SET @successfulCount = @intCount
				IF ISNULL(@ysnRecap,0) = 0
					IF(@intCount > 0)
					BEGIN
						UPDATE tblFAFixedAsset SET ysnDisposed = 0 WHERE intAssetId IN (SELECT intId FROM @Id)				
					END									
			END
		
		GOTO Post_Commit;
	END


--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
Post_Transaction:


DECLARE @intDefaultCurrencyId INT
		,@ysnMultiCurrency BIT = 0
		,@intDefaultCurrencyExchangeRateTypeId INT
		,@intRealizedGainLossAccountId INT
		,@strConvention NVARCHAR(50) = '' COLLATE Latin1_General_CI_AS
		,@dtmDispositionDate DATETIME
		,@ysnFullyDepreciated BIT
		,@dblDepreciationTake NUMERIC(18, 6)
		,@dblAccumulatedDepreciation NUMERIC(18, 6) = 0
		,@dblExpenseAdjustment NUMERIC(18, 6) = 0
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
SELECT TOP 1 @intRealizedGainLossAccountId = intFixedAssetsRealizedId FROM tblSMMultiCurrency
SELECT @intDefaultCurrencyExchangeRateTypeId = dbo.fnFAGetDefaultCurrencyExchangeRateTypeId()

DECLARE @dblCurrentRate NUMERIC(18,6), @dblRate NUMERIC(18,6), @dblDispositionAmount NUMERIC(18, 6)

IF ISNULL(@ysnRecap, 0) = 0
BEGIN
	WHILE EXISTS(SELECT TOP 1 1 FROM @tblAsset WHERE ysnProcessed = 0)
	BEGIN
		DECLARE @intRowId INT, @intLedgerId INT = NULL, @intAssetId INT, @intBookId INT
		
		SELECT TOP 1
				@intRowId = A.intRowId,
				@intLedgerId = A.intLedgerId,
				@intAssetId = A.intAssetId,
				@intBookId = BD.intBookId,
				@dblDispositionAmount = ISNULL(F.dblDispositionAmount, 0),
				@dblRate = CASE WHEN ISNULL(BD.dblRate, 0) > 0 
					THEN BD.dblRate 
					ELSE 
						CASE WHEN ISNULL(F.dblForexRate, 0) > 0 
						THEN F.dblForexRate 
						ELSE 1 
						END 
					END,
				@dblCurrentRate = ISNULL(dbo.fnGetForexRate(A.dtmDispose, F.intCurrencyId, ISNULL(F.intCurrencyExchangeRateTypeId, @intDefaultCurrencyExchangeRateTypeId)), 1),
				@ysnMultiCurrency = CASE WHEN ISNULL(BD.intFunctionalCurrencyId, ISNULL(F.intFunctionalCurrencyId, @intDefaultCurrencyId)) = ISNULL(BD.intCurrencyId, F.intCurrencyId) THEN 0 ELSE 1 END,
				@strConvention = DM.strConvention,
				@dtmDispositionDate = F.dtmDispositionDate,
				@ysnFullyDepreciated = ISNULL(BD.ysnFullyDepreciated, 0)
		FROM tblFAFixedAsset F 
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
		JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = F.intDepreciationMethodId
        WHERE BD.intBookId = 1 AND A.ysnProcessed = 0
			AND (CASE WHEN A.intLedgerId IS NOT NULL
				THEN CASE WHEN A.intLedgerId = BD.intLedgerId THEN 1 ELSE 0 END
				ELSE 1 END) = 1

		-- Rollback if Multi Currency but no Fixed Asset Realized Gain or Loss Account configured
		IF (@ysnMultiCurrency = 1 AND @intRealizedGainLossAccountId IS NULL)
		BEGIN
			RAISERROR('Fixed Asset Realized Gain or Loss Account for Multi Currency was not configured in the Company Configuration.', 16,1)
			GOTO Post_Rollback
		END

		-- Get Accounts Overridden by Location Segment
		DECLARE @tblOverrideAccount TABLE (
			intAssetId INT,
			intAccountId INT,
			intTransactionType INT,
			intNewAccountId INT  NULL,
			strNewAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
			strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
		)

		DELETE @tblOverrideAccount
		INSERT INTO @tblOverrideAccount (
			intAssetId
			,intAccountId
			,intTransactionType
			,intNewAccountId
			,strNewAccountId
			,strError
		)
		SELECT 
			AccumAccountOverride.intAssetId
			,AccumAccountOverride.intAccountId
			,AccumAccountOverride.intTransactionType
			,AccumAccountOverride.intNewAccountId
			,AccumAccountOverride.strNewAccountId
			,AccumAccountOverride.strError
		FROM tblFAFixedAsset F
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
		OUTER APPLY (
			SELECT * FROM dbo.fnFAGetOverrideAccount(F.intAssetId, F.intAccumulatedAccountId, 4)
		) AccumAccountOverride
		WHERE A.intRowId = @intRowId
		UNION ALL
		SELECT 
			AssetAccountOverride.intAssetId
			,AssetAccountOverride.intAccountId
			,AssetAccountOverride.intTransactionType
			,AssetAccountOverride.intNewAccountId
			,AssetAccountOverride.strNewAccountId
			,AssetAccountOverride.strError
		FROM tblFAFixedAsset F
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
		OUTER APPLY (
			SELECT * FROM dbo.fnFAGetOverrideAccount(F.intAssetId, F.intAssetAccountId, 1)
		) AssetAccountOverride
		WHERE A.intRowId = @intRowId
		UNION ALL
		SELECT 
			DepreciationExpenseAccountOverride.intAssetId
			,DepreciationExpenseAccountOverride.intAccountId
			,DepreciationExpenseAccountOverride.intTransactionType
			,DepreciationExpenseAccountOverride.intNewAccountId
			,DepreciationExpenseAccountOverride.strNewAccountId
			,DepreciationExpenseAccountOverride.strError
		FROM tblFAFixedAsset F
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
		OUTER APPLY (
			SELECT * FROM dbo.fnFAGetOverrideAccount(F.intAssetId, F.intDepreciationAccountId, 3)
		) DepreciationExpenseAccountOverride
		WHERE A.intRowId = @intRowId AND @strConvention <> 'Full Month'
		UNION ALL
		SELECT 
			GainLossAccountOverride.intAssetId
			,GainLossAccountOverride.intAccountId
			,GainLossAccountOverride.intTransactionType
			,GainLossAccountOverride.intNewAccountId
			,GainLossAccountOverride.strNewAccountId
			,GainLossAccountOverride.strError
		FROM tblFAFixedAsset F
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
		OUTER APPLY (
			SELECT * FROM dbo.fnFAGetOverrideAccount(F.intAssetId, F.intGainLossAccountId, 5)
		) GainLossAccountOverride
		WHERE A.totalDepre <> A.dblAssetValue
		AND ((A.dblAssetValue - (CASE WHEN @ysnMultiCurrency = 0 THEN A.totalDepre ELSE A.totalForeignDepre END) - @dblDispositionAmount) <> 0)
		AND A.intRowId = @intRowId
		UNION ALL
		SELECT 
			SalesOffsetAccountOverride.intAssetId
			,SalesOffsetAccountOverride.intAccountId
			,SalesOffsetAccountOverride.intTransactionType
			,SalesOffsetAccountOverride.intNewAccountId
			,SalesOffsetAccountOverride.strNewAccountId
			,SalesOffsetAccountOverride.strError
		FROM tblFAFixedAsset F
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
		OUTER APPLY (
			SELECT * FROM dbo.fnFAGetOverrideAccount(F.intAssetId, F.intSalesOffsetAccountId, 6)
		) SalesOffsetAccountOverride
		WHERE @dblDispositionAmount > 0 AND A.totalDepre <> A.dblAssetValue
		AND A.intRowId = @intRowId
		UNION ALL
		SELECT 
			RealizedAccountOverride.intAssetId
			,RealizedAccountOverride.intAccountId
			,RealizedAccountOverride.intTransactionType
			,RealizedAccountOverride.intNewAccountId
			,RealizedAccountOverride.strNewAccountId
			,RealizedAccountOverride.strError
		FROM tblFAFixedAsset F
		JOIN @tblAsset A ON A.intAssetId = F.intAssetId
		OUTER APPLY (
			SELECT * FROM dbo.fnFAGetOverrideAccount(F.intAssetId, @intRealizedGainLossAccountId, 7)
		) RealizedAccountOverride
		WHERE @ysnMultiCurrency = 1 AND @intRealizedGainLossAccountId IS NOT NULL 
			AND @dblRate <> @dblCurrentRate AND ((A.dblAssetValue - A.totalForeignDepre) <> 0)
			AND A.intRowId = @intRowId

		-- Validate override accounts
		IF EXISTS(SELECT TOP 1 1 FROM @tblOverrideAccount WHERE intNewAccountId IS NULL AND strError IS NOT NULL)
		BEGIN
			SELECT TOP 1 @ErrorMessage = strError FROM @tblOverrideAccount WHERE intNewAccountId IS NULL AND strError IS NOT NULL
			RAISERROR(@ErrorMessage, 16, 1)
			GOTO Post_Rollback;
		END
		
		-- Generate Transaction Id
		EXEC uspSMGetStartingNumber 111, @strTransactionId OUTPUT
		UPDATE @tblAsset SET strTransactionId = @strTransactionId FROM @tblAsset WHERE intRowId = @intRowId AND strTransactionId IS NULL

		-- Get Accumulated Depreciation (Functional and Foreign)
		UPDATE A 
		SET totalDepre = G.S, totalForeignDepre = G.dblSumForeign
		FROM  @tblAsset A
		OUTER APPLY(
			SELECT 
			SUM(dblCredit - dblDebit) S,
			SUM(dblCreditForeign - dblDebitForeign) dblSumForeign
			FROM tblGLDetail GL
			JOIN tblFAFixedAsset FA 
				ON FA.intAssetId = A.intAssetId
			JOIN @tblOverrideAccount OverrideAccount 
				ON OverrideAccount.intAssetId = FA.intAssetId AND OverrideAccount.intAccountId = FA.intAccumulatedAccountId
			WHERE GL.intAccountId = OverrideAccount.intNewAccountId
			AND strCode = 'AMDPR'
			AND ysnIsUnposted = 0
			AND A.strAssetId = GL.strReference
			AND (CASE WHEN GL.intLedgerId IS NOT NULL THEN CASE WHEN GL.intLedgerId = A.intLedgerId THEN 1 ELSE 0 END
				ELSE 1 END) = 1
			GROUP BY FA.strAssetId
		) G
		WHERE A.intRowId = @intRowId 

		IF (@strConvention <> 'Full Month' AND @ysnFullyDepreciated = 0)
		BEGIN
			-- Get Depreciation Take per convention
			DECLARE @dtmMonthStartDate DATETIME, @intDays INT

			SELECT 
				@dblDepreciationTake = ISNULL(CASE
					WHEN @strConvention = 'Mid Year' THEN T.dblAnnualBasis/2
					WHEN @strConvention = 'Mid Quarter' THEN (T.dblAnnualBasis/4)/2
					WHEN @strConvention = 'Mid Month' THEN (T.dblAnnualBasis / T.intMonthDivisor) * .50
					WHEN @strConvention = 'Actual Days' THEN (T.dblAnnualBasis / T.intMonthDivisor) * ((MonthPeriod.intDays - (DATEDIFF(DAY, MonthPeriod.dtmStartDate, @dtmDispositionDate) + 1) + 1)/ CAST(MonthPeriod.intDays AS FLOAT))
					END, 0)
			FROM @tblAsset T 
			JOIN tblFADepreciationMethod  M ON  M.intDepreciationMethodId = T.intDepreciationMethodId
			JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId= M.intDepreciationMethodId AND BD.intBookId = 1  and BD.intAssetId = T.intAssetId
			OUTER APPLY (
				SELECT TOP 1 dtmStartDate, intDays FROM [dbo].[fnFAGetMonthPeriodFromDate](@dtmDispositionDate, 1)
			) MonthPeriod
			WHERE T.intRowId = @intRowId
				AND (CASE WHEN BD.intLedgerId IS NOT NULL THEN CASE WHEN BD.intLedgerId = T.intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1

			IF (@strConvention = 'Mid Quarter')
			BEGIN
				-- Get the quarter where the disposition date is into
				DECLARE @intQuarter INT
				SELECT TOP 1 @intQuarter = intQuarter FROM [dbo].[fnFACalendarDatesWithQuarter](@dtmDispositionDate, 1) WHERE @dtmDispositionDate BETWEEN dtmStartDate AND dtmEndDate

				-- Get all the depreciation on the quarter
				SELECT @dblAccumulatedDepreciation = ISNULL(SUM(FAD.dblDepreciation), 0)
				FROM tblFAFixedAssetDepreciation FAD
				JOIN @tblAsset T ON T.intAssetId = FAD.intAssetId
				OUTER APPLY (
					SELECT dtmStartDate, dtmEndDate FROM [dbo].[fnFACalendarDatesWithQuarter](@dtmDispositionDate, 1) WHERE intQuarter = @intQuarter
				) QuarterDate
				WHERE FAD.strTransaction = 'Depreciation'
					AND FAD.dtmDepreciationToDate BETWEEN QuarterDate.dtmStartDate AND QuarterDate.dtmEndDate
					AND T.intRowId = @intRowId
					AND (CASE WHEN FAD.intLedgerId IS NOT NULL THEN CASE WHEN FAD.intLedgerId = T.intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1
			END
			IF (@strConvention = 'Mid Year')
			BEGIN
				-- Get all the depreciation on the year where the disposition date is into
				SELECT @dblAccumulatedDepreciation = ISNULL(SUM(dblDepreciation), 0)
				FROM tblFAFixedAssetDepreciation B
				JOIN @tblAsset T ON T.intAssetId = B.intAssetId
				WHERE B.intAssetId = T.intAssetId and ISNULL(intBookId,1) = 1
				AND (CASE WHEN B.intLedgerId IS NOT NULL 
								THEN CASE WHEN (B.intLedgerId = T.intLedgerId) THEN 1 ELSE 0 END
								ELSE 1 END) = 1
				AND strTransaction = 'Depreciation'
				AND YEAR(B.dtmDepreciationToDate) = YEAR(@dtmDispositionDate)
				AND T.intRowId = @intRowId
				AND (CASE WHEN B.intLedgerId IS NOT NULL THEN CASE WHEN B.intLedgerId = T.intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1
			END

			IF (@strConvention IN ('Mid Year', 'Mid Quarter'))
			BEGIN
				IF (@dblAccumulatedDepreciation = 0) --No depreciation within the period: Do not depreciate and set the depreciation take as the expense adjustment
					SET @dblExpenseAdjustment = @dblDepreciationTake
				ELSE
				BEGIN
					-- Depreciate
					DECLARE @intSuccessfulCount INT = 0 
					EXEC [dbo].[uspFADepreciateMultipleAsset]
						@Id						-- Asset Ids
						,1						-- intBookId
						,@intLedgerId			-- intLedgerId
						,@dtmDispositionDate	-- dtmDepreciationDate
						,1						-- ysnPost
						,0						-- ysnRecap
						,@intEntityId			-- intEntityId
						,0						-- ysnReverseCurrentDate
						,@strBatchId			-- strBatchId
						,@intSuccessfulCount OUTPUT -- successfulCount
				
					IF @intSuccessfulCount = 0
						GOTO Post_Rollback
				
					-- Get again the accumulated depreciation per convention
					IF (@strConvention = 'Mid Quarter')
					BEGIN
						SELECT @dblAccumulatedDepreciation = ISNULL(SUM(FAD.dblDepreciation), 0)
						FROM tblFAFixedAssetDepreciation FAD
						JOIN @tblAsset T ON T.intAssetId = FAD.intAssetId
						OUTER APPLY (
							SELECT dtmStartDate, dtmEndDate FROM [dbo].[fnFACalendarDatesWithQuarter](@dtmDispositionDate, 1) WHERE intQuarter = @intQuarter
						) QuarterDate
						WHERE FAD.strTransaction = 'Depreciation'
							AND FAD.dtmDepreciationToDate BETWEEN QuarterDate.dtmStartDate AND QuarterDate.dtmEndDate
							AND T.intRowId = @intRowId
							AND (CASE WHEN FAD.intLedgerId IS NOT NULL THEN CASE WHEN FAD.intLedgerId = T.intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1
					END
					ELSE
					BEGIN
						SELECT @dblAccumulatedDepreciation = ISNULL(SUM(dblDepreciation), 0)
						FROM tblFAFixedAssetDepreciation B
						JOIN @tblAsset T ON T.intAssetId = B.intAssetId
						WHERE B.intAssetId = T.intAssetId and ISNULL(intBookId,1) = 1
							AND (CASE WHEN B.intLedgerId IS NOT NULL 
											THEN CASE WHEN (B.intLedgerId = T.intLedgerId) THEN 1 ELSE 0 END
											ELSE 1 END) = 1
							AND strTransaction = 'Depreciation'
							AND YEAR(B.dtmDepreciationToDate) = YEAR(@dtmDispositionDate)
							AND T.intRowId = @intRowId
							AND (CASE WHEN B.intLedgerId IS NOT NULL THEN CASE WHEN B.intLedgerId = T.intLedgerId THEN 1 ELSE 0 END ELSE 1 END) = 1
					END
				END

				SET @dblExpenseAdjustment = @dblDepreciationTake - @dblAccumulatedDepreciation
			END
			
			IF (@strConvention IN ('Actual Days', 'Mid Month'))
			BEGIN
				-- Depreciate like the fist month
				EXEC [dbo].[uspFAManualDepreciateSingleAsset]
					@intAssetId,
					@intBookId,
					@intLedgerId,
					@dtmDispositionDate,
					@dblDepreciationTake,
					@strBatchId,
					'Depreciation',
					@intEntityId
			END

			-- Get again Accumulated Depreciation (Functional and Foreign) from GL Entries
			UPDATE A 
			SET totalDepre = G.S, totalForeignDepre = G.dblSumForeign
			FROM  @tblAsset A
			OUTER APPLY(
				SELECT 
					SUM(dblCredit - dblDebit) S,
					SUM(dblCreditForeign - dblDebitForeign) dblSumForeign
				FROM tblGLDetail GL
				JOIN tblFAFixedAsset FA 
					ON FA.intAssetId = A.intAssetId
				JOIN @tblOverrideAccount OverrideAccount 
					ON OverrideAccount.intAssetId = FA.intAssetId AND OverrideAccount.intAccountId = FA.intAccumulatedAccountId
				WHERE GL.intAccountId = OverrideAccount.intNewAccountId
					AND strCode = 'AMDPR'
					AND ysnIsUnposted = 0
					AND A.strAssetId = GL.strReference
					AND (CASE WHEN GL.intLedgerId IS NOT NULL THEN CASE WHEN GL.intLedgerId = A.intLedgerId THEN 1 ELSE 0 END
						ELSE 1 END) = 1
					GROUP BY FA.strAssetId
			) G
			WHERE A.intRowId = @intRowId 
		END

		-- Dispose Fixed Asset
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
			[intLedgerId],
			[intBookDepreciationId]
        )  
        SELECT  
            F.intAssetId,
            1,
            D.intDepreciationMethodId,
            LastDepreciation.dblBasis,  
            LastDepreciation.dblDepreciationBasis,  
            BD.dtmPlacedInService,  
            A.dtmDispose,
			A.dtmDispose,
			CASE WHEN @ysnMultiCurrency = 0 THEN A.totalDepre ELSE A.totalForeignDepre END,  
            LastDepreciation.dblSalvageValue,
            LastDepreciation.dblFunctionalBasis,
            LastDepreciation.dblFunctionalDepreciationBasis,
            ROUND((CASE WHEN @ysnMultiCurrency = 0 THEN A.totalDepre * @dblRate ELSE A.totalDepre END), 2),
            LastDepreciation.dblFunctionalSalvageValue,
            @dblRate,    
            'Dispose',  
            A.strTransactionId,  
            D.strDepreciationType,  
            D.strConvention,
            @strBatchId,
			BD.intCurrencyId,
			BD.intFunctionalCurrencyId,
			BD.intLedgerId,
			BD.intBookDepreciationId
            FROM tblFAFixedAsset F 
			JOIN @tblAsset A ON A.intAssetId = F.intAssetId
            JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
            JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
			OUTER APPLY (
				SELECT TOP 1 dblBasis, dblFunctionalBasis, dblDepreciationBasis, dblFunctionalDepreciationBasis, dblSalvageValue, dblFunctionalSalvageValue 
				FROM tblFAFixedAssetDepreciation 
				WHERE intAssetId = A.intAssetId AND intBookId = 1 AND strTransaction = 'Depreciation'
					AND (CASE WHEN intLedgerId IS NOT NULL THEN CASE WHEN intLedgerId = A.intLedgerId THEN 1 ELSE 0 END
						ELSE 1 END) = 1
				ORDER BY dtmDepreciationToDate DESC
			) LastDepreciation
            WHERE BD.intBookId = 1 AND intRowId = @intRowId AND
				(CASE WHEN BD.intLedgerId IS NOT NULL THEN CASE WHEN BD.intLedgerId = A.intLedgerId THEN 1 ELSE 0 END
					ELSE 1 END) = 1


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
			,[intCompanyLocationId]
			,[intLedgerId]
		)
		-- Accumulated Depreciation Account GL Entry
		SELECT 
				[strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= OverrideAccount.[intNewAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= B.totalDepre
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
			,[intCompanyLocationId] = A.[intCompanyLocationId]
			,[intLedgerId]			= B.[intLedgerId]
		
		FROM tblFAFixedAsset A 
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId
		JOIN @tblOverrideAccount OverrideAccount 
			ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intAccumulatedAccountId
		WHERE B.intRowId = @intRowId

		-- Asset Account GL Entry
		UNION ALL
		SELECT 
				[strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= OverrideAccount.[intNewAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= 0
			,[dblCredit]			= CASE WHEN @ysnMultiCurrency = 0 THEN B.dblAssetValue ELSE ROUND((B.dblAssetValue * @dblRate), 2) END
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE B.dblAssetValue END
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
			,[intCompanyLocationId] = A.[intCompanyLocationId]
			,[intLedgerId]			= B.[intLedgerId]
		
		FROM tblFAFixedAsset A
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId
		JOIN @tblOverrideAccount OverrideAccount 
			ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intAssetAccountId
		WHERE B.intRowId = @intRowId

		-- Expense Adjustment Entry
		UNION ALL
		SELECT 
				[strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= OverrideAccount.[intNewAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN @dblExpenseAdjustment > 0
											THEN CASE WHEN @ysnMultiCurrency = 0 THEN @dblExpenseAdjustment ELSE ROUND(@dblExpenseAdjustment * @dblRate, 2) END
											ELSE 0 END
			,[dblCredit]			= CASE WHEN @dblExpenseAdjustment < 0
											THEN CASE WHEN @ysnMultiCurrency = 0 THEN ABS(@dblExpenseAdjustment) ELSE ROUND(ABS(@dblExpenseAdjustment) * @dblRate, 2) END
											ELSE 0 END
			,[dblDebitForeign]		= CASE WHEN @dblExpenseAdjustment > 0 THEN CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE @dblExpenseAdjustment END END
			,[dblCreditForeign]		= CASE WHEN @dblExpenseAdjustment < 0 THEN CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE ABS(@dblExpenseAdjustment) END END
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
			,[intCompanyLocationId] = A.[intCompanyLocationId]
			,[intLedgerId]			= B.[intLedgerId]
		
		FROM tblFAFixedAsset A
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId
		JOIN @tblOverrideAccount OverrideAccount 
			ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intDepreciationAccountId
		WHERE B.intRowId = @intRowId AND @dblExpenseAdjustment <> 0

		-- Gain or Loss Account GL Entry
		UNION ALL
		SELECT 
				[strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= OverrideAccount.[intNewAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN @ysnMultiCurrency = 0
										THEN
											CASE WHEN (B.dblAssetValue - B.totalDepre - @dblDispositionAmount - @dblExpenseAdjustment) > 0 
											THEN B.dblAssetValue - B.totalDepre - @dblDispositionAmount - @dblExpenseAdjustment ELSE 0 
											END
										ELSE
											CASE WHEN (B.dblAssetValue - (B.totalDepre / @dblRate) - @dblDispositionAmount) > 0
												THEN ROUND(((B.dblAssetValue -(B.totalDepre / @dblRate) - @dblDispositionAmount) * @dblCurrentRate), 2) 
												ELSE 0
										END
										END
			,[dblCredit]			= CASE WHEN @ysnMultiCurrency = 0
										THEN 
											CASE WHEN (B.dblAssetValue - B.totalDepre - @dblDispositionAmount - @dblExpenseAdjustment) < 0 
											THEN ABS(B.dblAssetValue - B.totalDepre - @dblDispositionAmount - @dblExpenseAdjustment) ELSE 0 
											END
										ELSE
											CASE WHEN (B.dblAssetValue - (B.totalDepre / @dblRate) - @dblDispositionAmount) < 0
												THEN ROUND((ABS(B.dblAssetValue - (B.totalDepre / @dblRate) - @dblDispositionAmount) * @dblCurrentRate), 2)
												ELSE 0
										END
										END
			,[dblDebitForeign]		= CASE WHEN @ysnMultiCurrency = 0
										THEN 0
										ELSE
											CASE WHEN (B.dblAssetValue - B.totalForeignDepre - @dblDispositionAmount - @dblExpenseAdjustment) > 0
												THEN (B.dblAssetValue - B.totalForeignDepre - @dblDispositionAmount - @dblExpenseAdjustment) ELSE 0
											END
										END
			,[dblCreditForeign]		= CASE WHEN @ysnMultiCurrency = 0
										THEN 0
										ELSE
											CASE WHEN (B.dblAssetValue - B.totalForeignDepre - @dblDispositionAmount - @dblExpenseAdjustment) < 0
												THEN ABS(B.dblAssetValue - B.totalForeignDepre - @dblDispositionAmount - @dblExpenseAdjustment) ELSE 0
											END
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
			,[dblExchangeRate]		= @dblCurrentRate
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
			,[intCompanyLocationId] = A.[intCompanyLocationId]
			,[intLedgerId]			= B.[intLedgerId]
		
		FROM tblFAFixedAsset A
		JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> B.dblAssetValue
		AND ((B.dblAssetValue - (CASE WHEN @ysnMultiCurrency = 0 THEN B.totalDepre ELSE B.totalForeignDepre END) - @dblDispositionAmount) <> 0) -- debit and credit should not be zero.
		JOIN @tblOverrideAccount OverrideAccount 
			ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intGainLossAccountId
		WHERE B.intRowId = @intRowId

		-- Add Sales Offset Account entry if Disposition Amount has value, else no entry
		UNION ALL
		SELECT 
				[strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= OverrideAccount.[intNewAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN @ysnMultiCurrency = 0
										THEN
											@dblDispositionAmount
										ELSE
											ROUND((@dblDispositionAmount * @dblCurrentRate), 2)
										END
			,[dblCredit]			= 0
			,[dblDebitForeign]		= CASE WHEN @ysnMultiCurrency = 0
										THEN 0
										ELSE @dblDispositionAmount 
										END
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
			,[dblExchangeRate]		= @dblCurrentRate
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
			,[intCompanyLocationId] = A.[intCompanyLocationId]
			,[intLedgerId]			= B.[intLedgerId]
		
			FROM tblFAFixedAsset A
			JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> B.dblAssetValue
			JOIN @tblOverrideAccount OverrideAccount 
				ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intSalesOffsetAccountId
			WHERE @dblDispositionAmount > 0 AND B.intRowId = @intRowId

		-- Realized Gain or Loss GL Entry -> If multi currency, and if history rate and current rate is not equal
		UNION ALL
		SELECT
				[strTransactionId]		= B.strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= OverrideAccount.[intNewAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN ROUND((B.dblAssetValue * (@dblRate - @dblCurrentRate)), 2) - ROUND(((B.totalDepre / @dblRate) * (@dblRate - @dblCurrentRate)), 2) > 0
										THEN 
											ROUND((B.dblAssetValue* (@dblRate - @dblCurrentRate)), 2) - ROUND(((B.totalDepre / @dblRate) * (@dblRate - @dblCurrentRate)), 2)
										ELSE 0
									  END
			,[dblCredit]			= CASE WHEN ROUND((B.dblAssetValue * (@dblRate - @dblCurrentRate)), 2) - ROUND(((B.totalDepre / @dblRate) * (@dblRate - @dblCurrentRate)), 2) < 0
										THEN 
											ABS(ROUND((B.dblAssetValue * (@dblRate - @dblCurrentRate)), 2) - ROUND(((B.totalDepre / @dblRate) * (@dblRate - @dblCurrentRate)), 2))
										ELSE 0
										END
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
			,[intCurrencyExchangeRateTypeId] = NULL
			,[intCompanyLocationId] = A.[intCompanyLocationId]
			,[intLedgerId]			= B.[intLedgerId]
				
			FROM tblFAFixedAsset A
			JOIN @tblAsset B ON B.intAssetId = A.intAssetId AND B.totalDepre <> B.dblAssetValue
			JOIN @tblOverrideAccount OverrideAccount 
				ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = @intRealizedGainLossAccountId
			WHERE @ysnMultiCurrency = 1 AND @intRealizedGainLossAccountId IS NOT NULL 
			AND @dblRate <> @dblCurrentRate AND ((B.dblAssetValue - B.totalForeignDepre) <> 0)
			AND B.intRowId = @intRowId

			-- UPDATE FLAG
			UPDATE @tblAsset SET ysnProcessed = 1 WHERE intRowId = @intRowId
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