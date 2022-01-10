CREATE PROCEDURE [dbo].[uspFADepreciateMultipleAsset]  
 @Id    AS Id READONLY, 
 @BookId INT = 1,
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
DECLARE @IdGood Id
--DECLARE @ysnSingleMode BIT = 0
DECLARE @tblError TABLE (  
  [intAssetId] [int] NOT NULL,  
  strError NVARCHAR(400) NULL
)  


--IF(SELECT COUNT(*) FROM @Id) = 1 SET @ysnSingleMode = 1

INSERT INTO @tblError 
      SELECT intAssetId , strError FROM fnFAValidateAssetDepreciation(@ysnPost, @BookId, @Id)


  UPDATE BD
  SET ysnFullyDepreciated = 1
  FROM
  tblFABookDepreciation BD JOIN @tblError E
  ON E.intAssetId = BD.intAssetId
  WHERE intBookId = @BookId
  AND strError = 'Asset already fully depreciated.'

  UPDATE A
  SET ysnDisposed = 1
  FROM
  tblFAFixedAsset A JOIN @tblError E
  ON A.intAssetId = A.intAssetId
  WHERE strError = 'Asset was already disposed.'


INSERT INTO @IdGood
    SELECT A.intId FROM @Id A LEFT JOIN @tblError B
    ON A.intId = B.intAssetId WHERE B.intAssetId IS NULL
    
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

            UPDATE BD SET ysnFullyDepreciated  =0
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
              @IdHasNoDepreciation Id,
              @IdHasDepreciation Id,
              @IdHasBasisAdjustment Id,
              @IdHasDepreciationAdjustment Id
      
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
        intAssetId INT ,
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
        strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
      )
  
      INSERT INTO @tblDepComputation(intAssetId,dblBasis, dblDepreciationBasis,dblMonth, dblDepre, dblFunctionalBasis, dblFunctionalDepreciationBasis, dblFunctionalDepre, dblFunctionalMonth, dblRate, ysnMultiCurrency, ysnFullyDepreciated, strError, strTransaction)
        SELECT intAssetId, dblBasis,dblDepreciationBasis,dblMonth,dblDepre, dblFunctionalBasis,dblFunctionalDepreciationBasis, dblFunctionalDepre, dblFunctionalMonth, dblRate, ysnMultiCurrency, ysnFullyDepreciated, strError, strTransaction
        FROM dbo.fnFAComputeMultipleDepreciation(@IdGood, @BookId) 

      DELETE FROM @IdGood

      INSERT INTO @IdGood
        SELECT intAssetId FROM @tblDepComputation WHERE strError IS NULL

      INSERT INTO @tblError(intAssetId, strError)
        SELECT intAssetId,strError FROM @tblDepComputation WHERE strError IS NOT NULL
      
      DELETE FROM @tblDepComputation WHERE strError IS NOT NULL
      
      IF NOT EXISTS(SELECT TOP 1 1 FROM @IdGood)
          GOTO LogError
      
    INSERT INTO @IdHasNoDepreciation 
		select intId from @IdGood 
		outer apply
		(	
			select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  
      AND ISNULL(intBookId,1) = @BookId
      AND strTransaction  in( 'Depreciation','Imported')
		)D
        where D.cnt = 0

    INSERT INTO @IdHasDepreciation 
		select intId from @IdGood 
		outer apply
		(	
			select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  
      AND ISNULL(intBookId,1) = @BookId
      AND strTransaction  in( 'Depreciation','Imported')
		)D
        where D.cnt > 0

	-- GL Entry for Adjustment is for GAAP only
	INSERT INTO @IdHasBasisAdjustment
        SELECT intId FROM @IdGood
        OUTER APPLY (
            SELECT COUNT(1) cnt FROM dbo.fnFAGetBasisAdjustment(intId, @BookId) WHERE intAssetId = intId AND intBookdId = @BookId AND (strAdjustmentType IS NULL OR strAdjustmentType = 'Basis')
        ) Adjustment
        WHERE Adjustment.cnt > 0

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
		FROM dbo.fnFAGetBasisAdjustment(@idx, @BookId) WHERE intBookdId = @BookId AND intAssetId = @idx
    END 

    INSERT INTO @IdHasDepreciationAdjustment
        SELECT intId FROM @IdGood
        OUTER APPLY (
            SELECT COUNT(1) cnt FROM dbo.fnFAGetBasisAdjustment(intId, @BookId) WHERE intAssetId = intId AND intBookdId = @BookId AND strAdjustmentType = 'Depreciation'
        ) Adjustment
        WHERE Adjustment.cnt > 0

    IF EXISTS(SELECT TOP 1 1 FROM @IdHasDepreciationAdjustment)
    BEGIN
        DECLARE @idx2 INT
        SELECT TOP 1 @idx2 = intId FROM @IdHasDepreciationAdjustment
        INSERT INTO @tblDepreciationAdjustment
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
		FROM dbo.fnFAGetBasisAdjustment(@idx2, @BookId) WHERE intBookdId = @BookId AND intAssetId = @idx2
    END
  
      DECLARE @IdIterate Id
      DECLARE @i INT 
 
      -- First Depreciation
      IF EXISTS(SELECT TOP 1 1 FROM @IdHasNoDepreciation)  
      BEGIN  
          DELETE FROM @IdIterate
          INSERT INTO @IdIterate SELECT intId FROM @IdHasNoDepreciation
          WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
          BEGIN
              SELECT TOP 1 @i = intId FROM @IdIterate 
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
                  [strBatchId]
                )  
                  SELECT  
                  @i,  
                  @BookId,
                  D.intDepreciationMethodId,  
                  E.dblBasis,
                  E.dblDepreciationBasis,
                  BD.dtmPlacedInService,  
                  NULL,  
				  [dbo].[fnFAGetNextDepreciationDate](@i, CASE WHEN @BookId = 1 THEN 1 ELSE 0 END),--DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (Depreciation.dtmDepreciationToDate)) + 1, 0)) ,
                  E.dblDepre,
                  E.dblMonth,
                  E.dblFunctionalMonth,
                  BD.dblSalvageValue,
                  CASE WHEN ISNULL(E.dblFunctionalBasis, 0) > 0 THEN E.dblFunctionalBasis ELSE E.dblBasis END,
                  CASE WHEN ISNULL(E.dblFunctionalDepreciationBasis, 0) > 0 THEN E.dblFunctionalDepreciationBasis ELSE E.dblDepreciationBasis END,
                  CASE WHEN ISNULL(E.dblFunctionalDepre, 0) > 0 THEN E.dblFunctionalDepre ELSE E.dblDepre END,
                  CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END,
                  CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE 1 END,
                  ISNULL(E.strTransaction, 'Depreciation'),  
                  @strTransactionId,  
                  D.strDepreciationType,
                  D.strConvention,
                  @strBatchId
                  FROM tblFAFixedAsset F 
                  JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId 
                  JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
                  OUTER APPLY (
                    SELECT dblDepre,dblBasis, dblDepreciationBasis, dblRate, dblFunctionalBasis, dblFunctionalDepreciationBasis, dblFunctionalDepre, dblMonth, dblFunctionalMonth, strTransaction 
                    FROM @tblDepComputation WHERE intAssetId = @i
                  ) E
                  OUTER APPLY(
                    SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation 
                    WHERE [intAssetId] = @i AND intBookId = @BookId
                    ORDER BY dtmDepreciationToDate DESC
                  )Depreciation
                  WHERE F.intAssetId = @i
                  AND BD.intBookId = @BookId
                  UPDATE @tblDepComputation SET strTransactionId = @strTransactionId, ysnDepreciated = 1 WHERE intAssetId = @i
                  DELETE FROM @IdIterate WHERE intId = @i
          END
        END  
	
	  IF EXISTS(SELECT TOP 1 1 FROM @IdHasBasisAdjustment)
      BEGIN  
          DELETE FROM @IdIterate
          INSERT INTO @IdIterate SELECT intId FROM @IdHasBasisAdjustment
 
          WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
          BEGIN
              SELECT TOP 1 @i = intId FROM @IdIterate 
              EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strAdjustmentTransactionId OUTPUT  
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
                @i,
                @BookId,
                D.intDepreciationMethodId,
                Adjustment.dblAdjustment,
                CASE WHEN Adjustment.ysnAddToBasis = 1 THEN Adjustment.dblAdjustment ELSE 0 END,
                BD.dtmPlacedInService,  
                NULL,  
                Adjustment.dtmDate,
                0,
                0,
                0,
                0,
                Adjustment.dblFunctionalAdjustment,
                CASE WHEN Adjustment.ysnAddToBasis = 1 THEN Adjustment.dblFunctionalAdjustment ELSE 0 END,
                0,
                0,
                Adjustment.dblRate,
                'Basis Adjustment',  
                @strAdjustmentTransactionId,  
                D.strDepreciationType,  
                D.strConvention,
                @strBatchId
                FROM tblFAFixedAsset F 
                JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
                JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
                OUTER APPLY (
                  SELECT dblDepre,dblBasis, dblRate, dblFunctionalBasis, dblFunctionalDepre, strTransaction FROM @tblDepComputation WHERE intAssetId = @i
                ) E
                OUTER APPLY (
                    SELECT TOP 1 dblAdjustment, dblFunctionalAdjustment, dtmDate, dblRate, ysnAddToBasis FROM @tblBasisAdjustment
                    WHERE intAssetId = @i AND intBookId = @BookId
                ) Adjustment
                WHERE F.intAssetId = @i
                AND BD.intBookId = @BookId

				UPDATE @tblBasisAdjustment SET strTransactionId = @strAdjustmentTransactionId WHERE intAssetId = @i
                UPDATE @tblDepComputation SET strTransactionId = @strAdjustmentTransactionId WHERE intAssetId = @i
                DELETE FROM @IdIterate WHERE intId = @i
          END
      END

      -- Depreciation Adjustment
      IF EXISTS(SELECT TOP 1 1 FROM @IdHasDepreciationAdjustment)
      BEGIN  
          DELETE FROM @IdIterate
          INSERT INTO @IdIterate SELECT intId FROM @IdHasDepreciationAdjustment
 
          WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
          BEGIN
              SELECT TOP 1 @i = intId FROM @IdIterate 
              EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strDepAdjustmentTransactionId OUTPUT  
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
                @i,
                @BookId,
                D.intDepreciationMethodId,
                0,
                CASE WHEN Adjustment.ysnAddToBasis = 0 THEN 0 ELSE Adjustment.dblAdjustment END,
                BD.dtmPlacedInService,  
                NULL,  
                Adjustment.dtmDate,
                CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblAdjustment ELSE 0 END,
                CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblAdjustment ELSE 0 END,
                CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblFunctionalAdjustment ELSE 0 END,
                BD.dblSalvageValue,
				0,
				CASE WHEN Adjustment.ysnAddToBasis = 0 THEN 0 ELSE ISNULL(Adjustment.dblFunctionalAdjustment, Adjustment.dblAdjustment) END,
                CASE WHEN Adjustment.ysnAddToBasis = 0 THEN Adjustment.dblFunctionalAdjustment ELSE 0 END,
                CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END,
                Adjustment.dblRate,  
                'Depreciation Adjustment',  
                @strDepAdjustmentTransactionId,  
                D.strDepreciationType,  
                D.strConvention,
                @strBatchId
                FROM tblFAFixedAsset F 
                JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
                JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
                OUTER APPLY (
                  SELECT dblDepre,dblBasis, dblDepreciationBasis, dblRate, dblFunctionalBasis, dblFunctionalDepreciationBasis, dblFunctionalDepre, strTransaction FROM @tblDepComputation WHERE intAssetId = @i
                ) E
                OUTER APPLY (
                    SELECT TOP 1 dblAdjustment, dblFunctionalAdjustment, dtmDate, dblRate, ysnAddToBasis FROM @tblDepreciationAdjustment
                    WHERE intAssetId = @i AND intBookId = @BookId
                ) Adjustment
                WHERE F.intAssetId = @i
                AND BD.intBookId = @BookId

				UPDATE @tblDepreciationAdjustment SET strTransactionId = @strDepAdjustmentTransactionId WHERE intAssetId = @i
                UPDATE @tblDepComputation SET strTransactionId = @strDepAdjustmentTransactionId WHERE intAssetId = @i
                DELETE FROM @IdIterate WHERE intId = @i
          END
      END
			
      IF EXISTS(SELECT TOP 1 1 FROM @IdHasDepreciation)
      BEGIN  
          DELETE FROM @IdIterate
          INSERT INTO @IdIterate SELECT intId FROM @IdHasDepreciation
 
          WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
          BEGIN
              SELECT TOP 1 @i = intId FROM @IdIterate 
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
                [strBatchId]
              )  
              SELECT  
                @i,
                @BookId,
                D.intDepreciationMethodId,
                E.dblBasis,  
                E.dblDepreciationBasis,
                BD.dtmPlacedInService,  
                NULL,  
				        dbo.fnFAGetNextDepreciationDate(@i, @BookId),--DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (Depreciation.dtmDepreciationToDate)) + 2, 0)) ,
                E.dblDepre,  
                E.dblMonth,
                E.dblFunctionalMonth,
                BD.dblSalvageValue,
                CASE WHEN ISNULL(E.dblFunctionalBasis, 0) > 0 THEN E.dblFunctionalBasis ELSE E.dblBasis END,
                CASE WHEN ISNULL(E.dblFunctionalDepreciationBasis, 0) > 0 THEN E.dblFunctionalDepreciationBasis ELSE E.dblDepreciationBasis END,
                CASE WHEN ISNULL(E.dblFunctionalDepre, 0) > 0 THEN E.dblFunctionalDepre ELSE E.dblDepre END,
                CASE WHEN ISNULL(BD.dblFunctionalSalvageValue, 0) > 0 THEN BD.dblFunctionalSalvageValue ELSE BD.dblSalvageValue END,
                CASE WHEN ISNULL(BD.dblRate, 0) > 0 THEN BD.dblRate ELSE 1 END,  
                ISNULL(E.strTransaction, 'Depreciation'),  
                @strTransactionId,  
                D.strDepreciationType,  
                D.strConvention,
                @strBatchId
                FROM tblFAFixedAsset F 
                JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
                JOIN tblFADepreciationMethod D ON D.intDepreciationMethodId = BD.intDepreciationMethodId
                OUTER APPLY (
                  SELECT dblDepre,dblBasis, dblDepreciationBasis, dblRate, dblFunctionalBasis, dblFunctionalDepreciationBasis, dblFunctionalDepre, dblMonth, dblFunctionalMonth, strTransaction FROM @tblDepComputation WHERE intAssetId = @i
                ) E
                WHERE F.intAssetId = @i
                AND BD.intBookId = @BookId

                UPDATE @tblDepComputation SET strTransactionId = @strTransactionId WHERE intAssetId = @i
                DELETE FROM @IdIterate WHERE intId = @i
          END
      END

      IF NOT EXISTS(SELECT TOP 1 1 FROM @tblDepComputation)
        GOTO LogError
    
      IF @BookId = 1
      BEGIN

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
		  -- Adjustment Entries
		  SELECT   
          [strTransactionId]  = Adjustment.strTransactionId  
          ,[intTransactionId]  = A.[intAssetId]  
          ,[intAccountId]   = A.[intAssetAccountId]  
          ,[strDescription]  = A.[strAssetDescription]  
          ,[strReference]   = A.[strAssetId]  
          ,[dtmTransactionDate] = Adjustment.dtmDate
          ,[dblDebit]    = CASE WHEN Adjustment.dblFunctionalAdjustment > 0
                                THEN ROUND(Adjustment.dblFunctionalAdjustment, 2)
                                ELSE 0
                           END
          ,[dblCredit]   = CASE WHEN Adjustment.dblFunctionalAdjustment < 0
                                THEN ROUND(ABS(Adjustment.dblFunctionalAdjustment), 2)
                                ELSE 0
                           END  
          ,[dblDebitForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                    THEN 0 
                                    ELSE 
                                        CASE WHEN Adjustment.dblAdjustment > 0 
                                            THEN ROUND(Adjustment.dblAdjustment, 2) 
                                            ELSE 0
                                        END
                                END 
          ,[dblCreditForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                    THEN 0 
                                    ELSE 
                                        CASE WHEN Adjustment.dblAdjustment < 0 
                                            THEN ROUND(ABS(Adjustment.dblAdjustment), 2) 
                                            ELSE 0
                                        END
                                END   
          ,[dblDebitReport]  = 0  
          ,[dblCreditReport]  = 0  
          ,[dblReportingRate]  = 0  
          ,[dblForeignRate]  = 0  
          ,[dblDebitUnit]   = 0  
          ,[dblCreditUnit]  = 0  
          ,[dtmDate]    =  Adjustment.dtmDate 
          ,[ysnIsUnposted]  = 0   
          ,[intConcurrencyId]  = 1  
          ,[intCurrencyId]  = ISNULL(Adjustment.intCurrencyId, A.intCurrencyId)
          ,[dblExchangeRate] = ISNULL(Adjustment.dblRate, 1)
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
          ,[intCurrencyExchangeRateTypeId] = Adjustment.intCurrencyExchangeRateTypeId
          FROM tblFAFixedAsset A  
          JOIN @tblDepComputation B 
          ON A.intAssetId = B.intAssetId
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
          ,[intTransactionId]  = A.[intAssetId]  
          ,[intAccountId]   = A.[intExpenseAccountId]  
          ,[strDescription]  = A.[strAssetDescription]  
          ,[strReference]   = A.[strAssetId]  
          ,[dtmTransactionDate] = Adjustment.dtmDate
          ,[dblDebit]    = CASE WHEN Adjustment.dblFunctionalAdjustment < 0
                                THEN ROUND(ABS(Adjustment.dblFunctionalAdjustment), 2)
                                ELSE 0
                           END   
          ,[dblCredit]   = CASE WHEN Adjustment.dblFunctionalAdjustment > 0
                                THEN ROUND(Adjustment.dblFunctionalAdjustment, 2)
                                ELSE 0
                           END  
          ,[dblDebitForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                    THEN 0 
                                    ELSE 
                                        CASE WHEN Adjustment.dblAdjustment < 0 
                                            THEN ROUND(ABS(Adjustment.dblAdjustment), 2) 
                                            ELSE 0
                                        END
                                END
          ,[dblCreditForeign]  = CASE WHEN Adjustment.intCurrencyId = Adjustment.intFunctionalCurrencyId 
                                    THEN 0 
                                    ELSE 
                                        CASE WHEN Adjustment.dblAdjustment > 0 
                                            THEN ROUND(Adjustment.dblAdjustment, 2) 
                                            ELSE 0
                                        END
                                END
          ,[dblDebitReport]  = 0  
          ,[dblCreditReport]  = 0  
          ,[dblReportingRate]  = 0  
          ,[dblForeignRate]  = 0  
          ,[dblDebitUnit]   = 0  
          ,[dblCreditUnit]  = 0  
          ,[dtmDate]    =  Adjustment.dtmDate 
          ,[ysnIsUnposted]  = 0   
          ,[intConcurrencyId]  = 1  
          ,[intCurrencyId]  = ISNULL(Adjustment.intCurrencyId, A.intCurrencyId)
          ,[dblExchangeRate] = ISNULL(Adjustment.dblRate, 1)
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
          ,[intCurrencyExchangeRateTypeId] = Adjustment.intCurrencyExchangeRateTypeId
          FROM tblFAFixedAsset A  
          JOIN @tblDepComputation B 
          ON A.intAssetId = B.intAssetId
		  OUTER APPLY (
			SELECT TOP 1 strTransactionId, dblAdjustment, dblFunctionalAdjustment,dblRate, dtmDate, intCurrencyId,
				intFunctionalCurrencyId, intCurrencyExchangeRateTypeId, ysnAddToBasis
			FROM @tblBasisAdjustment WHERE intAssetId = A.intAssetId AND intBookId = 1
		  ) Adjustment
          WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL
			AND ISNULL(Adjustment.dblAdjustment, 0) <> 0
		
		  -- Depreciation Entries
		  UNION ALL
          SELECT   
          [strTransactionId]  = B.strTransactionId  
          ,[intTransactionId]  = A.[intAssetId]  
          ,[intAccountId]   = A.[intDepreciationAccountId]  
          ,[strDescription]  = A.[strAssetDescription]  
          ,[strReference]   = A.[strAssetId]  
          ,[dtmTransactionDate] = FAD.dtmDepreciationToDate
          ,[dblDebit]    = ROUND(ISNULL(B.dblFunctionalMonth, B.dblMonth), 2)  
          ,[dblCredit]   = 0  
          ,[dblDebitForeign]  = CASE WHEN ISNULL(ysnMultiCurrency, 0) = 0 THEN 0 ELSE ROUND(B.dblMonth, 2) END 
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
          ,[dblExchangeRate] = ISNULL(B.dblRate, 1)
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
          FROM tblFAFixedAsset A  
          JOIN @tblDepComputation B 
          ON A.intAssetId = B.intAssetId
          OUTER APPLY(
              SELECT TOP 1 B.[dtmDepreciationToDate] 
              FROM tblFAFixedAssetDepreciation B 
              WHERE B.intAssetId = A.[intAssetId] 
              AND ISNULL(intBookId,1) = @BookId
              ORDER BY B.intAssetDepreciationId DESC
          )FAD
          WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL

          UNION ALL  
          SELECT   
          [strTransactionId]  = B.strTransactionId  
          ,[intTransactionId]  = A.[intAssetId]  
          ,[intAccountId]   = A.[intAccumulatedAccountId]  
          ,[strDescription]  = A.[strAssetDescription]  
          ,[strReference]   = A.[strAssetId]  
          ,[dtmTransactionDate] = FAD.dtmDepreciationToDate
          ,[dblDebit]    = 0  
          ,[dblCredit]   = ROUND(ISNULL(B.dblFunctionalMonth, B.dblMonth), 2)  
          ,[dblDebitForeign]  = 0  
          ,[dblCreditForeign]  = CASE WHEN ISNULL(ysnMultiCurrency, 0) = 0 THEN 0 ELSE ROUND(B.dblMonth, 2) END  
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
          ,[dblExchangeRate]  = ISNULL(B.dblRate, 1)  
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
          FROM tblFAFixedAsset A  
          JOIN @tblDepComputation B 
          ON A.intAssetId = B.intAssetId
          OUTER APPLY(
              SELECT TOP 1 B.[dtmDepreciationToDate] 
              FROM tblFAFixedAssetDepreciation B 
              WHERE B.intAssetId = A.[intAssetId] 
              AND ISNULL(intBookId,1) = @BookId
              ORDER BY B.intAssetDepreciationId DESC
          )FAD
          WHERE B.dblBasis IS NOT NULL AND B.dblDepre IS NOT NULL AND B.dblMonth IS NOT NULL -- Do not include in posting if NULL

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
END  

-- THIS WILL REFLECT IN THE ASSET SCREEN ysnFullyDepreciated FLAG

UPDATE BD  SET BD.ysnFullyDepreciated  =1  
  FROM tblFABookDepreciation BD  JOIN @tblDepComputation B ON BD.intAssetId = B.intAssetId  
  WHERE B.ysnFullyDepreciated = 1
  AND BD.intBookId  = @BookId
  
UPDATE A  SET A.ysnDepreciated  =1  
  FROM tblFAFixedAsset A  JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId  
  WHERE B.ysnDepreciated = 1  AND @BookId = 1

UPDATE A  SET A.ysnTaxDepreciated = 1  
  FROM tblFAFixedAsset A  JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId  
  WHERE B.ysnDepreciated = 1  AND @BookId = 2

-- Check the fiscal asset if fiscal period of depreciation exists
-- Fiscal periods of assets in the tblFAFiscalAsset might be remove/deleted due to reversing of previous depreciation transactions
-- If previous depreciation transaction is reversed, it also removes the entry on fiscal asset - then upon depreciating the asset again,
-- we should recreate the removed fiscal asset.
DECLARE @IdAsset Id
INSERT INTO @IdAsset
SELECT intAssetId FROM @tblDepComputation

WHILE EXISTS (SELECT TOP 1 1 FROM @IdAsset)
BEGIN
    DECLARE 
        @intAssetId INT,
        @dtmDepreciationToDate DATETIME,
        @intFiscalPeriodId INT,
        @intFiscalYearId INT

    SELECT TOP 1 @intAssetId = intId FROM @IdAsset
    
    SELECT TOP 1 @dtmDepreciationToDate = dtmDepreciationToDate
    FROM tblFAFixedAssetDepreciation
    WHERE intAssetId = @intAssetId AND intBookId = @BookId AND strTransaction IN ('Depreciation', 'Imported')
    ORDER BY intAssetDepreciationId DESC

    SELECT @intFiscalYearId = intFiscalYearId, @intFiscalPeriodId = intGLFiscalYearPeriodId
	FROM tblGLFiscalYearPeriod WHERE @dtmDepreciationToDate BETWEEN dtmStartDate AND dtmEndDate

    IF NOT EXISTS(SELECT TOP 1 1 FROM tblFAFiscalAsset WHERE intAssetId = @intAssetId AND intBookId = @BookId AND intFiscalPeriodId = @intFiscalPeriodId AND intFiscalYearId = @intFiscalYearId)
        INSERT INTO tblFAFiscalAsset(
            [intAssetId]
            ,[intBookId]
            ,[intFiscalPeriodId]
            ,[intFiscalYearId]
        ) VALUES (
            @intAssetId
            ,@BookId
            ,@intFiscalPeriodId
            ,@intFiscalYearId
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

  ;WITH Q as(
     SELECT strReference strAssetId, strTransactionId, 'Asset Depreciated' strResult, 'GAAP' strBook, dtmDate, cast(0 as BIT) ysnError 
      FROM @GLEntries C WHERE @strBatchId = strBatchId
      AND ysnIsUnposted = 0  AND @BookId = 1
      AND strModuleName ='Fixed Assets'
      GROUP by strReference, strTransactionId, dtmDate
    UNION
	  SELECT strAssetId, strTransactionId, 'Asset Basis Adjusted' strResult, 'GAAP' strBook, dtmDepreciationToDate, cast(0 as BIT) 
	  FROM  tblFAFixedAssetDepreciation A 
      JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
      WHERE @strBatchId = strBatchId AND A.intBookId = 1 AND @BookId = 1
	  AND strTransaction = 'Basis Adjustment'
	UNION
      SELECT strAssetId, strTransactionId, 'Asset Depreciation Adjusted' strResult, 'GAAP' strBook, dtmDepreciationToDate, cast(0 as BIT) 
	  FROM  tblFAFixedAssetDepreciation A 
      JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
      WHERE @strBatchId = strBatchId AND A.intBookId = 1 AND @BookId = 1 
	  AND strTransaction = 'Depreciation Adjustment'
	UNION
      SELECT strAssetId, strTransactionId, 'Tax Depreciated' strResult, 'Tax' strBook, dtmDepreciationToDate, cast(0 as BIT) 
	  FROM  tblFAFixedAssetDepreciation A 
      JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
      WHERE @strBatchId = strBatchId AND A.intBookId <> 1 AND @BookId <> 1
	UNION
      SELECT strAssetId, strTransactionId, 'Tax Basis Adjusted' strResult, 'Tax' strBook, dtmDepreciationToDate, cast(0 as BIT) 
	  FROM  tblFAFixedAssetDepreciation A 
      JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
      WHERE @strBatchId = strBatchId AND A.intBookId <> 1 AND @BookId <> 1
	  AND strTransaction = 'Basis Adjustment'
	UNION
      SELECT strAssetId, strTransactionId, 'Tax Depreciation Adjusted' strResult, 'Tax' strBook, dtmDepreciationToDate, cast(0 as BIT) 
	  FROM  tblFAFixedAssetDepreciation A 
      JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
      WHERE @strBatchId = strBatchId AND A.intBookId <> 1 AND @BookId <> 1
	  AND strTransaction = 'Depreciation Adjustment'
    UNION
      SELECT strAssetId,'' strTransactionId, strError strResult, 
      CASE WHEN @BookId = 1 THEN 'GAAP' 
      WHEN @BookId = 2 THEN 'Tax'
      END strBook, 
      NULL dtmDate ,
      CAST(1 AS BIT)
      FROM @tblError A JOIN tblFAFixedAsset B ON B.intAssetId = A.intAssetId
  )
  INSERT INTO tblFADepreciateLogDetail (intLogId, strAssetId ,strTransactionId, strBook, strResult, dtmDate,ysnError) 
  SELECT @intLogId, strAssetId, strTransactionId, strBook, strResult, dtmDate, ysnError FROM Q ORDER BY strAssetId

DECLARE @intGLEntry INT

IF @BookId = 1
BEGIN
  SELECT @intGLEntry = COUNT(*) FROM tblGLDetail WHERE @strBatchId = strBatchId AND ysnIsUnposted  = 0
  SET @successfulCount =  CASE WHEN @intGLEntry > 0 THEN @intGLEntry/2 ELSE 0 END  
END
ELSE
BEGIN
  SELECT @successfulCount = COUNT(*) FROM  tblFAFixedAssetDepreciation A 
  JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId WHERE @strBatchId = strBatchId AND intBookId <> 1
END

END