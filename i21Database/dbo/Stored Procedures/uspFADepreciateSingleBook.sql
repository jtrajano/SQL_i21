﻿CREATE PROCEDURE [dbo].[uspFADepreciateSingleBook]
    @intBookDepreciationId INT,
    @dtmDepreciationDate DATETIME = NULL,
    @ysnPost   AS BIT    = 0,  
    @ysnRecap   AS BIT    = 0,  
    @intEntityId  AS INT    = 1,  
    @ysnReverseCurrentDate BIT = 0,
    @strBatchId   AS NVARCHAR(100),
    @successfulCount AS INT    = 0 OUTPUT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  

DECLARE @ErrorMsg NVARCHAR(MAX)
DECLARE @Id Id
DECLARE @IdGood FABookDepreciationTypeTable

DECLARE @tblError TABLE (  
  intAssetId INT NOT NULL,
  intBookDepreciationId INT NULL,
  strError NVARCHAR(MAX) NULL
)  

INSERT INTO @Id 
SELECT FA.intAssetId
FROM tblFAFixedAsset FA
JOIN tblFABookDepreciation BD ON BD.intAssetId = FA.intAssetId
WHERE BD.intBookDepreciationId = @intBookDepreciationId

INSERT INTO @tblError 
SELECT intAssetId, intBookDepreciationId, strError FROM [dbo].[fnFAValidateMultipleBooks](@Id, @ysnPost)
WHERE intBookDepreciationId = @intBookDepreciationId

UPDATE BD
    SET ysnFullyDepreciated = 1
FROM tblFABookDepreciation BD 
JOIN @tblError E ON E.intAssetId = BD.intAssetId AND BD.intBookDepreciationId = E.intBookDepreciationId
WHERE strError = 'Asset already fully depreciated.' AND E.intBookDepreciationId = @intBookDepreciationId

UPDATE A
    SET ysnDisposed = 1
FROM tblFAFixedAsset A
JOIN @tblError E ON A.intAssetId = A.intAssetId
WHERE strError = 'Asset was already disposed.'
AND intBookDepreciationId = @intBookDepreciationId

INSERT INTO @IdGood
SELECT A.intId, BD.intBookDepreciationId, BD.intBookId
FROM @Id A 
JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intId
LEFT JOIN @tblError B ON A.intId = B.intAssetId AND B.intBookDepreciationId = BD.intBookDepreciationId
WHERE B.strError IS NULL AND B.intAssetId IS NULL
AND B.intBookDepreciationId = @intBookDepreciationId

IF NOT EXISTS (SELECT TOP 1 1 FROM @IdGood)
  GOTO LogError
   
--=====================================================================================================================================  
--  UNPOSTING FIXEDASSETS TRANSACTIONS ysnPost = 0  
---------------------------------------------------------------------------------------------------------------------------------------  
IF ISNULL(@ysnPost, 0) = 0  
BEGIN  
 DECLARE @intCount AS INT   
 DECLARE @IdGLDetail Id
 
 INSERT INTO @IdGLDetail
    SELECT intGLDetailId FROM tblGLDetail GL JOIN tblFAFixedAsset A on GL.strReference = A.strAssetId
    JOIN @IdGood C on C.intId = A.intAssetId
    WHERE ysnIsUnposted = 0
    
    DECLARE @ReverseResult INT  
	  DECLARE @dtmReverse DATETIME = NULL
    BEGIN TRY
      IF @ysnReverseCurrentDate = 1
        SET @dtmReverse =  CAST(CONVERT(NVARCHAR(10), GETDATE(), 101) AS DATETIME)
      IF EXISTS(SELECT TOP 1 1 FROM tblGLFiscalYearPeriod where @dtmReverse BETWEEN dtmStartDate AND dtmEndDate 
      AND (ysnFAOpen = 0 OR ysnOpen = 0))
      BEGIN
        RAISERROR('Current fiscal period is closed.', 16,1)
        ROLLBACK TRANSACTION
      END
          IF EXISTS(SELECT 1 FROM @IdGLDetail)
            EXEC @ReverseResult  = [dbo].[uspFAReverseMultipleAsset] @strBatchId,@IdGLDetail, @ysnRecap,
            @dtmReverse, @intEntityId,@intCount OUT  
    END TRY
    BEGIN CATCH
          SELECT @ErrorMsg = ERROR_MESSAGE()
          RAISERROR(@ErrorMsg, 16,1)
          ROLLBACK TRANSACTION
    END CATCH

      IF @ReverseResult <> 0 RETURN --1  
      SET @successfulCount = @intCount  
        IF ISNULL(@ysnRecap,0) = 0
        BEGIN
            UPDATE A SET ysnDepreciated = 0, ysnTaxDepreciated = 0,
            ysnDisposed = 0, ysnAcquired = 0, dtmDispositionDate = NULL, intDispositionNumber = null, strDispositionNumber = ''
            FROM tblFAFixedAsset A JOIN @IdGood B ON A.intAssetId = B.intId
            DELETE A FROM tblFAFixedAssetDepreciation A JOIN @IdGood B ON B.intId =  A.intAssetId 

            -- Delete Adjustments (Basis and Depreciation)
            DELETE A FROM tblFABasisAdjustment A JOIN @IdGood B ON B.intId = A.intAssetId 

            UPDATE BD SET ysnFullyDepreciated = 0
            FROM tblFABookDepreciation BD  JOIN @IdGood B ON intAssetId = intId 
            
            --remove from undepreciated
            DELETE A FROM tblFAFiscalAsset A JOIN
            @IdGood B on B.intId = A.intAssetId
        END
     
END  
ELSE  
BEGIN  
--=====================================================================================================================================  
--  CHECK IF THE PROCESS IS RECAP OR NOT  
---------------------------------------------------------------------------------------------------------------------------------------  
Post_Transaction:  
DECLARE @strTransactionId NVARCHAR(100), @strAdjustmentTransactionId NVARCHAR(100), @strDepAdjustmentTransactionId NVARCHAR(100)  
  
IF ISNULL(@ysnRecap, 0) = 0  
BEGIN     
        
      DECLARE @GLEntries RecapTableType ,
              @IdHasNoDepreciation FABookDepreciationTypeTable,
              @IdHasDepreciation FABookDepreciationTypeTable,
              @IdHasBasisAdjustment FABookDepreciationTypeTable,
              @IdHasDepreciationAdjustment FABookDepreciationTypeTable
      
      -- Adjustment to Basis and Depreciation should be different/separated
	   DECLARE @tblBasisAdjustment TABLE (
        intAssetId INT,
	    intBookId INT,
	    intCurrencyId INT,
	    intFunctionalCurrencyId INT,
	    intCurrencyExchangeRateTypeId INT,
	    dblRate NUMERIC(18, 6),
	    dblAdjustment NUMERIC(18, 6),
	    dblFunctionalAdjustment NUMERIC(18, 6),
	    dtmDate DATETIME,
	    ysnAddToBasis BIT,
		strTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
      )

      DECLARE @tblDepreciationAdjustment TABLE (
        intAssetId INT,
	    intBookId INT,
	    intCurrencyId INT,
	    intFunctionalCurrencyId INT,
	    intCurrencyExchangeRateTypeId INT,
	    dblRate NUMERIC(18, 6),
	    dblAdjustment NUMERIC(18, 6),
	    dblFunctionalAdjustment NUMERIC(18, 6),
	    dtmDate DATETIME,
	    ysnAddToBasis BIT,
		strTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
      )

      DECLARE @tblDepComputation TABLE (
        intAssetId INT,
        intBookId INT NULL,
        dblBasis NUMERIC(18,6) NULL,
        dblDepreciationBasis NUMERIC(18,6) NULL,
        dblMonth NUMERIC(18,6) NULL,
        dblDepre NUMERIC(18,6) NULL,
        dblFunctionalBasis NUMERIC(18,6) NULL,
        dblFunctionalDepreciationBasis NUMERIC(18,6) NULL,
        dblFunctionalMonth NUMERIC(18,6) NULL,
        dblFunctionalDepre NUMERIC(18,6) NULL,
        dblRate NUMERIC(18,6) NULL,
        ysnFullyDepreciated BIT NULL,
        strError NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL ,
        strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
        ysnMultiCurrency BIT NULL,
        ysnDepreciated BIT NULL,
        dtmDepreciate DATETIME NULL,
        strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
        intBookDepreciationId INT NULL
      )
  
      INSERT INTO @tblDepComputation(intAssetId, intBookId, dblBasis, dblDepreciationBasis,dblMonth, dblDepre, dblFunctionalBasis, dblFunctionalDepreciationBasis, dblFunctionalDepre, dblFunctionalMonth, dblRate, ysnMultiCurrency, ysnFullyDepreciated, strError, strTransaction, intBookDepreciationId)
        SELECT intAssetId, intBookId, dblBasis, dblDepreciationBasis,dblMonth,dblDepre, dblFunctionalBasis,dblFunctionalDepreciationBasis, dblFunctionalDepre, dblFunctionalMonth, dblRate, ysnMultiCurrency, ysnFullyDepreciated, strError, strTransaction, intBookDepreciationId
        FROM dbo.fnFAComputeMultipleBookDepreciation(@IdGood) 
        WHERE intBookDepreciationId = @intBookDepreciationId
      
      DELETE FROM @IdGood

      INSERT INTO @IdGood
        SELECT intAssetId, intBookDepreciationId, intBookId FROM @tblDepComputation WHERE strError IS NULL

      INSERT INTO @tblError(intAssetId, strError, intBookDepreciationId)
        SELECT intAssetId, strError, intBookDepreciationId FROM @tblDepComputation WHERE strError IS NOT NULL
      
      DELETE FROM @tblDepComputation WHERE strError IS NOT NULL
      
      IF NOT EXISTS(SELECT TOP 1 1 FROM @IdGood)
          GOTO LogError
      
    INSERT INTO @IdHasNoDepreciation 
		SELECT G.intId, G.intBookDepreciationId, G.intBookId FROM @IdGood G
		OUTER APPLY (	
            SELECT COUNT(*) cnt FROM tblFAFixedAssetDepreciation 
            WHERE intAssetId = G.intId
            AND intBookDepreciationId = G.intBookDepreciationId
            AND strTransaction IN ('Depreciation', 'Imported')
		)D
        WHERE D.cnt = 0

    INSERT INTO @IdHasDepreciation 
		SELECT G.intId, G.intBookDepreciationId, G.intBookId FROM @IdGood G
		OUTER APPLY (	
			SELECT count(*) cnt FROM tblFAFixedAssetDepreciation WHERE intAssetId = G.intId
            AND intBookDepreciationId = G.intBookDepreciationId
            AND strTransaction IN ('Depreciation', 'Imported')
		)D
        WHERE D.cnt > 0

	-- GL Entry for Adjustment is for GAAP only
	INSERT INTO @IdHasBasisAdjustment
        SELECT G.intId, G.intBookDepreciationId, G.intBookId FROM @IdGood G
        JOIN tblFABookDepreciation BD ON BD.intBookDepreciationId = G.intBookDepreciationId
        OUTER APPLY (
            SELECT COUNT(1) cnt FROM dbo.fnFAGetBasisAdjustment(intId, BD.intBookId, @dtmDepreciationDate) 
            WHERE intAssetId = intId AND intBookdId = BD.intBookId AND strAdjustmentType = 'Basis'
        ) Adjustment
        WHERE Adjustment.cnt > 0 AND BD.intBookId = 1

    IF EXISTS(SELECT TOP 1 1 FROM @IdHasBasisAdjustment)
    BEGIN
        DECLARE @idx INT
        SELECT TOP 1 @idx = intId FROM @IdHasBasisAdjustment
        INSERT INTO @tblBasisAdjustment
        SELECT TOP 1 
			intAssetId, 
			intBookdId, 
			intCurrencyId,
			intFunctionalCurrencyId,
			intCurrencyExchangeRateTypeId,
			dblRate,
			dblAdjustment,
			dblFunctionalAdjustment,
			dtmDate,
			ysnAddToBasis,
			NULL
		FROM dbo.fnFAGetBasisAdjustment(@idx, 1, @dtmDepreciationDate) WHERE intBookdId = 1 AND intAssetId = @idx
    END 

    INSERT INTO @IdHasDepreciationAdjustment
        SELECT G.intId, G.intBookDepreciationId, G.intBookId FROM @IdGood G
        LEFT JOIN tblFABookDepreciation BD ON BD.intAssetId = intId AND BD.intBookDepreciationId = G.intBookDepreciationId
        OUTER APPLY (
            SELECT COUNT(1) cnt FROM dbo.fnFAGetBasisAdjustment(intId, BD.intBookId, @dtmDepreciationDate)
            WHERE intAssetId = intId AND intBookdId = BD.intBookId AND strAdjustmentType = 'Depreciation'
        ) Adjustment
        WHERE Adjustment.cnt > 0

    IF EXISTS(SELECT TOP 1 1 FROM @IdHasDepreciationAdjustment)
    BEGIN
        DECLARE @idx2 INT
        SELECT TOP 1 @idx2 = intId FROM @IdHasDepreciationAdjustment
        INSERT INTO @tblDepreciationAdjustment
        SELECT TOP 1 
			B.intAssetId, 
			B.intBookdId, 
			B.intCurrencyId,
			B.intFunctionalCurrencyId,
			B.intCurrencyExchangeRateTypeId,
			B.dblRate,
			B.dblAdjustment,
			B.dblFunctionalAdjustment,
			B.dtmDate,
			B.ysnAddToBasis,
			NULL
		FROM @IdHasDepreciationAdjustment G
        OUTER APPLY (
            SELECT * FROM dbo.fnFAGetBasisAdjustment(@idx2, G.intBookId, @dtmDepreciationDate) WHERE intBookdId = G.intBookId AND intAssetId = @idx2
        ) B
        WHERE intAssetId = @idx2
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
	INSERT INTO @tblOverrideAccount (
		intAssetId
		,intAccountId
		,intTransactionType
		,intNewAccountId
		,strNewAccountId
		,strError
	)
	SELECT 
		AssetAccountOverride.intAssetId
		,AssetAccountOverride.intAccountId
		,AssetAccountOverride.intTransactionType
		,AssetAccountOverride.intNewAccountId
		,AssetAccountOverride.strNewAccountId
		,AssetAccountOverride.strError
	FROM tblFAFixedAsset A
    JOIN @tblDepComputation B 
    ON A.intAssetId = B.intAssetId
    OUTER APPLY (
		SELECT TOP 1 dblAdjustment FROM @tblBasisAdjustment WHERE intAssetId = A.intAssetId AND intBookId = 1
	) Adjustment
    OUTER APPLY (
		SELECT * FROM dbo.fnFAGetOverrideAccount(A.intAssetId, A.intAssetAccountId, 1)
	) AssetAccountOverride
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL
	AND ISNULL(Adjustment.dblAdjustment, 0) <> 0
    UNION ALL
    SELECT 
		OffsetAccount.intAssetId
		,OffsetAccount.intAccountId
		,OffsetAccount.intTransactionType
		,OffsetAccount.intNewAccountId
		,OffsetAccount.strNewAccountId
		,OffsetAccount.strError
	FROM tblFAFixedAsset A
    JOIN @tblDepComputation B 
    ON A.intAssetId = B.intAssetId
    OUTER APPLY (
		SELECT TOP 1 dblAdjustment FROM @tblBasisAdjustment WHERE intAssetId = A.intAssetId AND intBookId = 1
	) Adjustment
    OUTER APPLY (
		SELECT * FROM dbo.fnFAGetOverrideAccount(A.intAssetId, A.intExpenseAccountId, 2)
	) OffsetAccount
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL 
	AND ISNULL(Adjustment.dblAdjustment, 0) <> 0
    UNION ALL
    SELECT 
		DepreciationAccount.intAssetId
		,DepreciationAccount.intAccountId
		,DepreciationAccount.intTransactionType
		,DepreciationAccount.intNewAccountId
		,DepreciationAccount.strNewAccountId
		,DepreciationAccount.strError
	FROM tblFAFixedAsset A
    JOIN @tblDepComputation B 
    ON A.intAssetId = B.intAssetId
    OUTER APPLY (
		SELECT * FROM dbo.fnFAGetOverrideAccount(A.intAssetId, CASE WHEN B.strTransaction = 'Imported' THEN A.[intExpenseAccountId] ELSE A.[intDepreciationAccountId] END, CASE WHEN B.strTransaction = 'Imported' THEN 2 ELSE 3 END)
	) DepreciationAccount
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL
    UNION ALL
    SELECT 
		AccumulatedDepreciationAccount.intAssetId
		,AccumulatedDepreciationAccount.intAccountId
		,AccumulatedDepreciationAccount.intTransactionType
		,AccumulatedDepreciationAccount.intNewAccountId
		,AccumulatedDepreciationAccount.strNewAccountId
		,AccumulatedDepreciationAccount.strError
	FROM tblFAFixedAsset A
    JOIN @tblDepComputation B 
    ON A.intAssetId = B.intAssetId
    OUTER APPLY (
		SELECT * FROM dbo.fnFAGetOverrideAccount(A.intAssetId, A.[intAccumulatedAccountId], 4)
	) AccumulatedDepreciationAccount
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL

    -- Validate override accounts
	IF EXISTS(SELECT TOP 1 1 FROM @tblOverrideAccount WHERE intNewAccountId IS NULL AND strError IS NOT NULL)
	BEGIN
        INSERT INTO @tblError
        SELECT A.intAssetId, B.intBookDepreciationId, O.strError
        FROM tblFAFixedAsset A  
        JOIN @tblDepComputation B 
            ON A.intAssetId = B.intAssetId
        JOIN @tblOverrideAccount O
            ON O.intAssetId = B.intAssetId
        WHERE O.intNewAccountId IS NULL AND O.strError IS NOT NULL

        GOTO LogError
	END
  
    DECLARE @IdIterate Id
    DECLARE @i INT 
 
    -- First Depreciation
    IF EXISTS(SELECT TOP 1 1 FROM @IdHasNoDepreciation)  
    BEGIN  
        DELETE FROM @IdIterate
        INSERT INTO @IdIterate SELECT DISTINCT intId FROM @IdHasNoDepreciation
        WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
        BEGIN
            SELECT TOP 1 @i = intId FROM @IdIterate 
            EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strTransactionId OUTPUT  

            INSERT INTO tblFAFixedAssetDepreciation (  
                  [intAssetId]
                , [intBookId]
                , [intDepreciationMethodId]
                , [dblBasis]
                , [dblDepreciationBasis]
                , [dtmDateInService]
                , [dtmDepreciationToDate]
                , [dblDepreciationToDate]
                , [dblDepreciation]
                , [dblFunctionalDepreciation]
                , [dblSalvageValue]
                , [dblFunctionalBasis]
                , [dblFunctionalDepreciationBasis]
                , [dblFunctionalDepreciationToDate]
                , [dblFunctionalSalvageValue]
                , [dblRate]
                , [strTransaction]
                , [strTransactionId]
                , [strType]
                , [strConvention]
                , [strBatchId]
                , [intCurrencyId]
                , [intFunctionalCurrencyId]
                , [intLedgerId]
            )  
            SELECT DISTINCT
                  @i
                , BD.intBookId
                , D.intDepreciationMethodId
                , E.dblBasis
                , E.dblDepreciationBasis
                , BD.dtmPlacedInService
				, [dbo].[fnFAGetNextBookDepreciationDate](@i, BD.intBookDepreciationId)
                , E.dblDepre
                , E.dblMonth
                , E.dblFunctionalMonth
                , BD.dblSalvageValue
                , CASE WHEN ISNULL(E.dblFunctionalBasis, 0) > 0 THEN E.dblFunctionalBasis ELSE E.dblBasis END
                , CASE WHEN ISNULL(E.dblFunctionalDepreciationBasis, 0) > 0 THEN E.dblFunctionalDepreciationBasis ELSE E.dblDepreciationBasis END
                , CASE WHEN ISNULL(E.dblFunctionalDepre, 0) > 0 THEN E.dblFunctionalDepre ELSE E.dblDepre END
                , CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END
                , CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE 1 END
                , ISNULL(E.strTransaction, 'Depreciation')
                , @strTransactionId
                , D.strDepreciationType
                , D.strConvention
                , @strBatchId
                , BD.intCurrencyId
                , BD.intFunctionalCurrencyId
                , BD.intLedgerId
            FROM tblFAFixedAsset F 
            JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
            JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
            JOIN @tblDepComputation E ON E.intAssetId = F.intAssetId AND E.intBookDepreciationId = BD.intBookDepreciationId
            WHERE F.intAssetId = @i

            UPDATE @tblDepComputation SET strTransactionId = @strTransactionId, ysnDepreciated = 1 WHERE intAssetId = @i
            DELETE FROM @IdIterate WHERE intId = @i
        END
    END  
	
    -- Basis Adjustment
	IF EXISTS(SELECT TOP 1 1 FROM @IdHasBasisAdjustment)
    BEGIN  
        DELETE FROM @IdIterate
        INSERT INTO @IdIterate SELECT DISTINCT intId FROM @IdHasBasisAdjustment
 
        WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
        BEGIN
            SELECT TOP 1 @i = intId FROM @IdIterate 
            EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strAdjustmentTransactionId OUTPUT  
            INSERT INTO tblFAFixedAssetDepreciation (  
                  [intAssetId]
                , [intBookId]
                , [intDepreciationMethodId]
                , [dblBasis]
                , [dblDepreciationBasis]
                , [dtmDateInService]
                , [dtmDepreciationToDate]
                , [dblDepreciationToDate]
                , [dblDepreciation]
                , [dblFunctionalDepreciation]
                , [dblSalvageValue]
                , [dblFunctionalBasis]
                , [dblFunctionalDepreciationBasis]
                , [dblFunctionalDepreciationToDate]
                , [dblFunctionalSalvageValue]
                , [dblRate]
                , [strTransaction]
                , [strTransactionId]
                , [strType]
                , [strConvention]
                , [strBatchId]
                , [ysnAddToBasis]
                , [intCurrencyId]
                , [intFunctionalCurrencyId]
            )  
            SELECT  
                 @i
                , BD.intBookId
                , D.intDepreciationMethodId
                , Adjustment.dblAdjustment
                , CASE WHEN Adjustment.ysnAddToBasis = 1 THEN Adjustment.dblAdjustment ELSE 0 END
                , BD.dtmPlacedInService
                , Adjustment.dtmDate
                , 0
                , 0
                , 0
                , 0
                , Adjustment.dblFunctionalAdjustment
                , CASE WHEN Adjustment.ysnAddToBasis = 1 THEN Adjustment.dblFunctionalAdjustment ELSE 0 END
                , 0
                , 0
                , Adjustment.dblRate
                , 'Basis Adjustment'
                , 'Basis Adjustment' -- to be updated by actual Asset Depreciation Transaction ID
                , D.strDepreciationType
                , D.strConvention
                , @strBatchId
                , ysnAddToBasis
                , BD.intCurrencyId
                , BD.intFunctionalCurrencyId
            FROM tblFAFixedAsset F 
            JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
            JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
            JOIN @tblBasisAdjustment Adjustment ON Adjustment.intAssetId = @i AND Adjustment.intBookId = BD.intBookId
            WHERE F.intAssetId = @i

			UPDATE @tblBasisAdjustment SET strTransactionId = @strAdjustmentTransactionId WHERE intAssetId = @i
            UPDATE @tblDepComputation SET strTransactionId = @strAdjustmentTransactionId WHERE intAssetId = @i
            DELETE FROM @IdIterate WHERE intId = @i
        END
    END

    -- Depreciation Adjustment
    IF EXISTS(SELECT TOP 1 1 FROM @IdHasDepreciationAdjustment)
    BEGIN  
        DELETE FROM @IdIterate
        INSERT INTO @IdIterate SELECT DISTINCT intId FROM @IdHasDepreciationAdjustment
 
        WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
        BEGIN
            SELECT TOP 1 @i = intId FROM @IdIterate 
            --EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strDepAdjustmentTransactionId OUTPUT
            INSERT INTO tblFAFixedAssetDepreciation (  
                  [intAssetId]
                , [intBookId]
                , [intDepreciationMethodId]
                , [dblBasis]
                , [dblDepreciationBasis]
                , [dtmDateInService]
                , [dtmDepreciationToDate]
                , [dblDepreciationToDate]
                , [dblDepreciation]
                , [dblFunctionalDepreciation]
                , [dblSalvageValue]
                , [dblFunctionalBasis]
                , [dblFunctionalDepreciationBasis]
                , [dblFunctionalDepreciationToDate]
                , [dblFunctionalSalvageValue]
                , [dblRate]
                , [strTransaction]
                , [strTransactionId]
                , [strType]
                , [strConvention]
                , [strBatchId]
                , [ysnAddToBasis]
                , [intCurrencyId]
                , [intFunctionalCurrencyId]
            )  
            SELECT  
                  @i
                , BD.intBookId
                , D.intDepreciationMethodId
                , 0
                , CASE WHEN Adjustment.ysnAddToBasis = 0 THEN 0 ELSE Adjustment.dblAdjustment END
                , BD.dtmPlacedInService
                , Adjustment.dtmDate
                , CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblAdjustment ELSE 0 END
                , CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblAdjustment ELSE 0 END
                , CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblFunctionalAdjustment ELSE 0 END
                , BD.dblSalvageValue
			    , 0
			    , CASE WHEN Adjustment.ysnAddToBasis = 0 THEN 0 ELSE ISNULL(Adjustment.dblFunctionalAdjustment, Adjustment.dblAdjustment) END
                , CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblFunctionalAdjustment ELSE 0 END
                , CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END
                , Adjustment.dblRate
                , 'Depreciation Adjustment'
                , 'Depreciation Adjustment'
                , D.strDepreciationType
                , D.strConvention
                , @strBatchId
                , ysnAddToBasis
                , BD.intCurrencyId
                , BD.intFunctionalCurrencyId
            FROM tblFAFixedAsset F 
            JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
            JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
            JOIN @tblDepreciationAdjustment Adjustment ON Adjustment.intAssetId = @i AND Adjustment.intBookId = BD.intBookId
            WHERE F.intAssetId = @i

			UPDATE @tblDepreciationAdjustment SET strTransactionId = 'Depreciation Adjustment' WHERE intAssetId = @i
            UPDATE @tblDepComputation SET strTransactionId = 'Depreciation Adjustment' WHERE intAssetId = @i
            DELETE FROM @IdIterate WHERE intId = @i
        END
    END
	
    -- Succeeding Depreciations
    IF EXISTS(SELECT TOP 1 1 FROM @IdHasDepreciation)
    BEGIN  
        DELETE FROM @IdIterate
        INSERT INTO @IdIterate SELECT DISTINCT intId FROM @IdHasDepreciation
 
        WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
        BEGIN
            SELECT TOP 1 @i = intId FROM @IdIterate 
            EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strTransactionId OUTPUT  
            INSERT INTO tblFAFixedAssetDepreciation (  
                  [intAssetId]
                , [intBookId]
                , [intDepreciationMethodId]
                , [dblBasis]
                , [dblDepreciationBasis]
                , [dtmDateInService]
                , [dtmDepreciationToDate]
                , [dblDepreciationToDate]
                , [dblDepreciation]
                , [dblFunctionalDepreciation]
                , [dblSalvageValue]
                , [dblFunctionalBasis]
                , [dblFunctionalDepreciationBasis]
                , [dblFunctionalDepreciationToDate]
                , [dblFunctionalSalvageValue]
                , [dblRate]
                , [strTransaction]
                , [strTransactionId]
                , [strType]
                , [strConvention]
                , [strBatchId]
                , [intCurrencyId]
                , [intFunctionalCurrencyId]
                , [intLedgerId]
            )  
            SELECT DISTINCT
                  @i
                , BD.intBookId
                , D.intDepreciationMethodId
                , E.dblBasis
                , E.dblDepreciationBasis
                , BD.dtmPlacedInService
				, ISNULL(@dtmDepreciationDate, [dbo].[fnFAGetNextBookDepreciationDate](@i, BD.intBookDepreciationId))
                , E.dblDepre
                , E.dblMonth
                , E.dblFunctionalMonth
                , BD.dblSalvageValue
                , CASE WHEN ISNULL(E.dblFunctionalBasis, 0) > 0 THEN E.dblFunctionalBasis ELSE E.dblBasis END
                , CASE WHEN ISNULL(E.dblFunctionalDepreciationBasis, 0) > 0 THEN E.dblFunctionalDepreciationBasis ELSE E.dblDepreciationBasis END
                , CASE WHEN ISNULL(E.dblFunctionalDepre, 0) > 0 THEN E.dblFunctionalDepre ELSE E.dblDepre END
                , CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END
                , CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE 1 END
                , ISNULL(E.strTransaction, 'Depreciation')
                , @strTransactionId
                , D.strDepreciationType
                , D.strConvention
                , @strBatchId
                , BD.intCurrencyId
                , BD.intFunctionalCurrencyId
                , BD.intLedgerId
            FROM tblFAFixedAsset F 
            JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
            JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
            JOIN @tblDepComputation E ON E.intAssetId = F.intAssetId AND E.intBookDepreciationId = BD.intBookDepreciationId
            WHERE F.intAssetId = @i

            UPDATE @tblDepComputation SET strTransactionId = @strTransactionId WHERE intAssetId = @i
            DELETE FROM @IdIterate WHERE intId = @i
        END
    END

    IF NOT EXISTS(SELECT TOP 1 1 FROM @tblDepComputation)
        GOTO LogError
    
    DELETE FROM @GLEntries  
    INSERT INTO @GLEntries (
          [strTransactionId]  
        , [intTransactionId]  
        , [intAccountId]  
        , [strDescription]  
        , [strReference]   
        , [dtmTransactionDate]  
        , [dblDebit]  
        , [dblCredit]  
        , [dblDebitForeign]     
        , [dblCreditForeign]  
        , [dblDebitReport]  
        , [dblCreditReport]  
        , [dblReportingRate]  
        , [dblForeignRate]  
        , [dblDebitUnit]  
        , [dblCreditUnit]  
        , [dtmDate]  
        , [ysnIsUnposted]  
        , [intConcurrencyId]   
        , [intCurrencyId]  
        , [dblExchangeRate]  
        , [intUserId]  
        , [intEntityId]     
        , [dtmDateEntered]  
        , [strBatchId]  
        , [strCode]     
        , [strJournalLineDescription]  
        , [intJournalLineNo]  
        , [strTransactionType]  
        , [strTransactionForm]  
        , [strModuleName]     
        , [intCurrencyExchangeRateTypeId]
        , [intLedgerId]
        , [intCompanyLocationId]
    )
	-- Basis Adjustment Entries
	SELECT   
          [strTransactionId]  = Adjustment.strTransactionId  
        , [intTransactionId]  = A.[intAssetId]  
        , [intAccountId]   = OverrideAccount.[intNewAccountId]  
        , [strDescription]  = A.[strAssetDescription]  
        , [strReference]   = A.[strAssetId]  
        , [dtmTransactionDate] = Adjustment.dtmDate
        , [dblDebit]    = CASE WHEN Adjustment.dblFunctionalAdjustment > 0
                            THEN ROUND(Adjustment.dblFunctionalAdjustment, 2)
                            ELSE 0
                        END
        , [dblCredit]   = CASE WHEN Adjustment.dblFunctionalAdjustment < 0
                            THEN ROUND(ABS(Adjustment.dblFunctionalAdjustment), 2)
                            ELSE 0
                        END  
        , [dblDebitForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                THEN 0 
                                ELSE 
                                    CASE WHEN Adjustment.dblAdjustment > 0 
                                        THEN ROUND(Adjustment.dblAdjustment, 2) 
                                        ELSE 0
                                    END
                            END 
        , [dblCreditForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                THEN 0 
                                ELSE 
                                    CASE WHEN Adjustment.dblAdjustment < 0 
                                        THEN ROUND(ABS(Adjustment.dblAdjustment), 2) 
                                        ELSE 0
                                    END
                            END   
        , [dblDebitReport]  = 0  
        , [dblCreditReport]  = 0  
        , [dblReportingRate]  = 0  
        , [dblForeignRate]  = 0  
        , [dblDebitUnit]   = 0  
        , [dblCreditUnit]  = 0  
        , [dtmDate]    =  Adjustment.dtmDate 
        , [ysnIsUnposted]  = 0   
        , [intConcurrencyId]  = 1  
        , [intCurrencyId]  = ISNULL(Adjustment.intCurrencyId, A.intCurrencyId)
        , [dblExchangeRate] = ISNULL(Adjustment.dblRate, 1)
        , [intUserId]   = 0  
        , [intEntityId]   = @intEntityId     
        , [dtmDateEntered]  = GETDATE()  
        , [strBatchId]   = @strBatchId  
        , [strCode]    = 'AMDPR'            
        , [strJournalLineDescription] = ''  
        , [intJournalLineNo]  = A.[intAssetId]     
        , [strTransactionType] = 'Depreciation'  
        , [strTransactionForm] = 'Fixed Assets'  
        , [strModuleName]  = 'Fixed Assets'
        , [intCurrencyExchangeRateTypeId] = Adjustment.intCurrencyExchangeRateTypeId
        , [intLedgerId] = BD.intLedgerId
        , [intCompanyLocationId] = A.intCompanyLocationId
    FROM tblFAFixedAsset A  
    JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId AND BD.intBookDepreciationId = B.intBookDepreciationId
    JOIN @tblOverrideAccount OverrideAccount ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intAssetAccountId
	OUTER APPLY (
	    SELECT TOP 1 strTransactionId, dblAdjustment, dblFunctionalAdjustment,dblRate, dtmDate, intCurrencyId,
		    intFunctionalCurrencyId, intCurrencyExchangeRateTypeId, ysnAddToBasis
	    FROM @tblBasisAdjustment WHERE intAssetId = A.intAssetId AND intBookId = 1
	) Adjustment
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL
	AND ISNULL(Adjustment.dblAdjustment, 0) <> 0
	UNION ALL
	SELECT   
          [strTransactionId]  = Adjustment.strTransactionId  
        , [intTransactionId]  = A.[intAssetId]  
        , [intAccountId]   = OverrideAccount.[intNewAccountId] 
        , [strDescription]  = A.[strAssetDescription]  
        , [strReference]   = A.[strAssetId]  
        , [dtmTransactionDate] = Adjustment.dtmDate
        , [dblDebit]    = CASE WHEN Adjustment.dblFunctionalAdjustment < 0
                            THEN ROUND(ABS(Adjustment.dblFunctionalAdjustment), 2)
                            ELSE 0
                        END   
        , [dblCredit]   = CASE WHEN Adjustment.dblFunctionalAdjustment > 0
                            THEN ROUND(Adjustment.dblFunctionalAdjustment, 2)
                            ELSE 0
                        END  
        , [dblDebitForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                THEN 0 
                                ELSE 
                                    CASE WHEN Adjustment.dblAdjustment < 0 
                                        THEN ROUND(ABS(Adjustment.dblAdjustment), 2) 
                                        ELSE 0
                                    END
                            END
        , [dblCreditForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                THEN 0 
                                ELSE 
                                    CASE WHEN Adjustment.dblAdjustment > 0 
                                        THEN ROUND(Adjustment.dblAdjustment, 2) 
                                        ELSE 0
                                    END
                            END
        , [dblDebitReport]  = 0  
        , [dblCreditReport]  = 0  
        , [dblReportingRate]  = 0  
        , [dblForeignRate]  = 0  
        , [dblDebitUnit]   = 0  
        , [dblCreditUnit]  = 0  
        , [dtmDate]    =  Adjustment.dtmDate 
        , [ysnIsUnposted]  = 0   
        , [intConcurrencyId]  = 1  
        , [intCurrencyId]  = ISNULL(Adjustment.intCurrencyId, A.intCurrencyId)
        , [dblExchangeRate] = ISNULL(Adjustment.dblRate, 1)
        , [intUserId]   = 0  
        , [intEntityId]   = @intEntityId     
        , [dtmDateEntered]  = GETDATE()  
        , [strBatchId]   = @strBatchId  
        , [strCode]    = 'AMDPR'            
        , [strJournalLineDescription] = ''  
        , [intJournalLineNo]  = A.[intAssetId]     
        , [strTransactionType] = 'Depreciation'  
        , [strTransactionForm] = 'Fixed Assets'  
        , [strModuleName]  = 'Fixed Assets'
        , [intCurrencyExchangeRateTypeId] = Adjustment.intCurrencyExchangeRateTypeId
        , [intLedgerId] = BD.intLedgerId
        , [intCompanyLocationId] = A.intCompanyLocationId
    FROM tblFAFixedAsset A  
    JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId AND BD.intBookDepreciationId = B.intBookDepreciationId
    JOIN @tblOverrideAccount OverrideAccount ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.intExpenseAccountId
	OUTER APPLY (
	    SELECT TOP 1 strTransactionId, dblAdjustment, dblFunctionalAdjustment,dblRate, dtmDate, intCurrencyId,
		    intFunctionalCurrencyId, intCurrencyExchangeRateTypeId, ysnAddToBasis
	    FROM @tblBasisAdjustment WHERE intAssetId = A.intAssetId AND intBookId = 1
	) Adjustment
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL
	AND ISNULL(Adjustment.dblAdjustment, 0) <> 0
    AND B.intBookId = 1
		
	-- Depreciation Entries
	UNION ALL
    SELECT   
          [strTransactionId]  = B.strTransactionId  
        , [intTransactionId]  = A.[intAssetId]  
        , [intAccountId]   = OverrideAccount.[intNewAccountId]
        , [strDescription]  = A.[strAssetDescription]  
        , [strReference]   = A.[strAssetId]  
        , [dtmTransactionDate] = FAD.dtmDepreciationToDate
        , [dblDebit]    = ROUND(ISNULL(B.dblFunctionalMonth, B.dblMonth), 2)  
        , [dblCredit]   = 0  
        , [dblDebitForeign]  = ROUND(B.dblMonth, 2) 
        , [dblCreditForeign]  = 0  
        , [dblDebitReport]  = 0  
        , [dblCreditReport]  = 0  
        , [dblReportingRate]  = 0  
        , [dblForeignRate]  = 0  
        , [dblDebitUnit]   = 0  
        , [dblCreditUnit]  = 0  
        , [dtmDate]    =  FAD.dtmDepreciationToDate 
        , [ysnIsUnposted]  = 0   
        , [intConcurrencyId]  = 1  
        , [intCurrencyId]  = A.intCurrencyId
        , [dblExchangeRate] = ISNULL(B.dblRate, 1)
        , [intUserId]   = 0  
        , [intEntityId]   = @intEntityId     
        , [dtmDateEntered]  = GETDATE()  
        , [strBatchId]   = @strBatchId  
        , [strCode]    = 'AMDPR'            
        , [strJournalLineDescription] = ''  
        , [intJournalLineNo]  = A.[intAssetId]     
        , [strTransactionType] = 'Depreciation'  
        , [strTransactionForm] = 'Fixed Assets'  
        , [strModuleName]  = 'Fixed Assets'
        , [intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
        , [intLedgerId] = BD.intLedgerId
        , [intCompanyLocationId] = A.intCompanyLocationId
    FROM tblFAFixedAsset A  
    JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId AND BD.intBookDepreciationId = B.intBookDepreciationId
    JOIN @tblOverrideAccount OverrideAccount ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = CASE WHEN B.strTransaction = 'Imported' THEN A.[intExpenseAccountId] ELSE A.[intDepreciationAccountId] END
    OUTER APPLY(
        SELECT TOP 1 B.[dtmDepreciationToDate] 
        FROM tblFAFixedAssetDepreciation B 
        WHERE B.intAssetId = A.[intAssetId] 
            AND ISNULL(intBookId, 1) = 1
        ORDER BY B.intAssetDepreciationId DESC
    ) FAD
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL
        AND B.intBookId = 1
    
    UNION ALL  
    SELECT   
          [strTransactionId]  = B.strTransactionId  
        , [intTransactionId]  = A.[intAssetId]  
        , [intAccountId]   = OverrideAccount.[intNewAccountId]
        , [strDescription]  = A.[strAssetDescription]  
        , [strReference]   = A.[strAssetId]  
        , [dtmTransactionDate] = FAD.dtmDepreciationToDate
        , [dblDebit]    = 0  
        , [dblCredit]   = ROUND(ISNULL(B.dblFunctionalMonth, B.dblMonth), 2)  
        , [dblDebitForeign]  = 0  
        , [dblCreditForeign]  = ROUND(B.dblMonth, 2)
        , [dblDebitReport]  = 0  
        , [dblCreditReport]  = 0  
        , [dblReportingRate]  = 0  
        , [dblForeignRate]  = 0  
        , [dblDebitUnit]   = 0  
        , [dblCreditUnit]  = 0  
        , [dtmDate]    = FAD.dtmDepreciationToDate
        , [ysnIsUnposted]  = 0   
        , [intConcurrencyId]  = 1  
        , [intCurrencyId]  = A.intCurrencyId  
        , [dblExchangeRate]  = ISNULL(B.dblRate, 1)  
        , [intUserId]   = 0  
        , [intEntityId]   = @intEntityId     
        , [dtmDateEntered]  = GETDATE()  
        , [strBatchId]   = @strBatchId  
        , [strCode]    = 'AMDPR'  
        , [strJournalLineDescription] = ''  
        , [intJournalLineNo]  = A.[intAssetId]     
        , [strTransactionType] = 'Depreciation'  
        , [strTransactionForm] = 'Fixed Assets'  
        , [strModuleName]  = 'Fixed Assets'  
        , [intCurrencyExchangeRateTypeId] = A.intCurrencyExchangeRateTypeId
        , [intLedgerId] = BD.intLedgerId
        , [intCompanyLocationId] = A.intCompanyLocationId
    FROM tblFAFixedAsset A  
    JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId AND BD.intBookDepreciationId = B.intBookDepreciationId
    JOIN @tblOverrideAccount OverrideAccount ON OverrideAccount.intAssetId = B.intAssetId AND OverrideAccount.intAccountId = A.[intAccumulatedAccountId]
    OUTER APPLY(
        SELECT TOP 1 B.[dtmDepreciationToDate] 
        FROM tblFAFixedAssetDepreciation B 
        WHERE B.intAssetId = A.[intAssetId] 
            AND ISNULL(intBookId, 1) = 1
        ORDER BY B.intAssetDepreciationId DESC
    ) FAD
    WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL
    AND B.intBookId = 1

	DECLARE @GLEntries2 RecapTableType
	INSERT INTO @GLEntries2 SELECT * FROM @GLEntries 
	DELETE FROM @GLEntries2 WHERE dblDebit = 0 AND dblCredit = 0

    IF EXISTS(SELECT TOP 1 1 FROM @GLEntries2)  
    BEGIN
        DECLARE @PostResult INT  
        EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries2, @ysnPost = @ysnPost, @SkipICValidation = 1  
        IF @@ERROR <> 0 OR @PostResult <> 0 RETURN --1  
    END
END

-- THIS WILL REFLECT IN THE ASSET SCREEN ysnFullyDepreciated FLAG
UPDATE BD  SET BD.ysnFullyDepreciated  =1  
  FROM tblFABookDepreciation BD JOIN @tblDepComputation B ON BD.intAssetId = B.intAssetId  
  WHERE B.ysnFullyDepreciated = 1
  AND BD.intBookDepreciationId  = B.intBookDepreciationId
  
UPDATE A  SET A.ysnDepreciated  =1  
  FROM tblFAFixedAsset A  JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId  
  WHERE B.ysnDepreciated = 1  AND B.intBookId = 1

UPDATE A  SET A.ysnTaxDepreciated = 1  
  FROM tblFAFixedAsset A  JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId  
  WHERE B.ysnDepreciated = 1  AND B.intBookId = 2

-- Check the fiscal asset if fiscal period of depreciation exists
-- Fiscal periods of assets in the tblFAFiscalAsset might be remove/deleted due to reversing of previous depreciation transactions
-- If previous depreciation transaction is reversed, it also removes the entry on fiscal asset - then upon depreciating the asset again,
-- we should recreate the removed fiscal asset.
DECLARE @IdAsset FABookDepreciationTypeTable
INSERT INTO @IdAsset
SELECT DISTINCT intAssetId, intBookDepreciationId, intBookId FROM @tblDepComputation

WHILE EXISTS (SELECT TOP 1 1 FROM @IdAsset)
BEGIN
    DECLARE 
        @intAssetId INT,
        @intBookId INT,
        @dtmDepreciationToDate DATETIME,
        @intFiscalPeriodId INT,
        @intFiscalYearId INT

    SELECT TOP 1 @intAssetId = intId FROM @IdAsset
    
    SELECT TOP 1 @dtmDepreciationToDate = dtmDepreciationToDate, @intBookId = intBookId
    FROM tblFAFixedAssetDepreciation
    WHERE intAssetId = @intAssetId AND strTransaction IN ('Depreciation', 'Imported') AND intBookDepreciationId = @intBookDepreciationId
    ORDER BY dtmDepreciationToDate DESC, intAssetDepreciationId DESC

    SELECT @intFiscalYearId = intFiscalYearId, @intFiscalPeriodId = intGLFiscalYearPeriodId
	FROM tblGLFiscalYearPeriod WHERE @dtmDepreciationToDate BETWEEN dtmStartDate AND dtmEndDate

    IF NOT EXISTS(SELECT TOP 1 1 FROM tblFAFiscalAsset 
        WHERE intAssetId = @intAssetId AND intBookDepreciationId = @intBookDepreciationId 
            AND intFiscalPeriodId = @intFiscalPeriodId AND intFiscalYearId = @intFiscalYearId
    )
        INSERT INTO tblFAFiscalAsset (
              [intAssetId]
            , [intBookId]
            , [intBookDepreciationId]
            , [intFiscalPeriodId]
            , [intFiscalYearId]
        ) VALUES (
              @intAssetId
            , @intBookId
            , @intBookDepreciationId
            , @intFiscalPeriodId
            , @intFiscalYearId
        )

    DELETE @IdAsset WHERE intId = @intAssetId
END

--=====================================================================================================================================  
--  RETURN TOTAL NUMBER OF VALID FIXEDASSETS  
---------------------------------------------------------------------------------------------------------------------------------------  
LogError:
DECLARE @intLogId INT

IF EXISTS(SELECT 1 FROM tblFADepreciateLog where strBatchId = @strBatchId )
BEGIN
  SELECT @intLogId = intLogId  FROM tblFADepreciateLog WHERE strBatchId = @strBatchId
END
ELSE
BEGIN
  INSERT INTO tblFADepreciateLog(strBatchId, dtmDate, intEntityId)
  SELECT @strBatchId, GETDATE(), @intEntityId
  SELECT @intLogId = SCOPE_IDENTITY()
END

;WITH Q AS (
    SELECT FA.strAssetId, FAD.strTransactionId, CASE WHEN B.intBookId = 1 THEN 'Asset Depreciated' ELSE 'Tax Depreciated' END strResult, B.strBook, FAD.dtmDepreciationToDate, CAST(0 AS BIT) ysnError, L.strLedgerName
	FROM  tblFAFixedAssetDepreciation FAD
    JOIN tblFAFixedAsset FA on FA.intAssetId = FAD.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intBookDepreciationId = FAD.intBookDepreciationId
    LEFT JOIN tblFABook B ON B.intBookId = BD.intBookId
    LEFT JOIN tblGLLedger L ON L.intLedgerId = BD.intLedgerId
    WHERE FAD.strBatchId = @strBatchId AND FAD.strTransaction = 'Depreciation'
UNION
	SELECT FA.strAssetId, FAD.strTransactionId, CASE WHEN B.intBookId = 1 THEN 'Asset Basis Adjusted' ELSE 'Tax Basis Adjusted' END strResult, B.strBook, FAD.dtmDepreciationToDate, CAST(0 AS BIT) ysnError, L.strLedgerName
	FROM  tblFAFixedAssetDepreciation FAD
    JOIN tblFAFixedAsset FA on FA.intAssetId = FAD.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intBookDepreciationId = FAD.intBookDepreciationId
    LEFT JOIN tblFABook B ON B.intBookId = BD.intBookId
    LEFT JOIN tblGLLedger L ON L.intLedgerId = BD.intLedgerId
    WHERE FAD.strBatchId = @strBatchId
	AND FAD.strTransaction = 'Basis Adjustment'
UNION
    SELECT FA.strAssetId, FAD.strTransactionId, CASE WHEN B.intBookId = 1 THEN 'Asset Depreciation Adjusted' ELSE 'Tax Depreciation Adjusted' END strResult, B.strBook, FAD.dtmDepreciationToDate, CAST(0 AS BIT) ysnError, L.strLedgerName
	FROM  tblFAFixedAssetDepreciation FAD
    JOIN tblFAFixedAsset FA on FA.intAssetId = FAD.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intBookDepreciationId = FAD.intBookDepreciationId
    LEFT JOIN tblFABook B ON B.intBookId = BD.intBookId
    LEFT JOIN tblGLLedger L ON L.intLedgerId = BD.intLedgerId
    WHERE FAD.strBatchId = @strBatchId
	AND FAD.strTransaction = 'Depreciation Adjustment'
UNION
    SELECT FA.strAssetId,'' strTransactionId, E.strError strResult, B.strBook, NULL dtmDate, CAST(1 AS BIT) ysnError, L.strLedgerName
    FROM @tblError E 
    JOIN tblFAFixedAsset FA ON FA.intAssetId = E.intAssetId
    JOIN tblFABookDepreciation BD ON BD.intBookDepreciationId = E.intBookDepreciationId
    JOIN tblFABook B ON B.intBookId = BD.intBookId
    LEFT JOIN tblGLLedger L ON L.intLedgerId = BD.intLedgerId
)
INSERT INTO tblFADepreciateLogDetail (intLogId, strAssetId ,strTransactionId, strBook, strResult, dtmDate, ysnError, strLedgerName) 
SELECT @intLogId, strAssetId, strTransactionId, strBook, strResult, dtmDepreciationToDate, ysnError, strLedgerName FROM Q ORDER BY strAssetId

DECLARE @intGLEntry INT

SELECT @intGLEntry = COUNT(*) FROM tblGLDetail GL WHERE GL.strBatchId = @strBatchId AND GL.ysnIsUnposted  = 0
SET @successfulCount =  CASE WHEN @intGLEntry > 0 THEN @intGLEntry/2 ELSE 0 END  

SELECT @successfulCount += COUNT(*) 
FROM  tblFAFixedAssetDepreciation A 
JOIN tblFAFixedAsset B ON A.intAssetId = B.intAssetId 
WHERE strBatchId = @strBatchId AND intBookId <> 1

END