
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
            UPDATE A SET ysnDepreciated = 0, ysnFullyDepreciated = 0, ysnDisposed = 0, ysnAcquired = 0
            FROM tblFAFixedAsset A JOIN @IdGood B ON A.intAssetId = B.intId
            UPDATE A SET ysnFullyDepreciated = 0 FROM tblFABookDepreciation A JOIN @IdGood B ON A.intAssetId = B.intId
            DELETE A FROM tblFAFixedAssetDepreciation A JOIN @IdGood B ON B.intId =  A.intAssetId 
        END
     
END  
ELSE  
BEGIN  
--=====================================================================================================================================  
--  CHECK IF THE PROCESS IS RECAP OR NOT  
---------------------------------------------------------------------------------------------------------------------------------------  
Post_Transaction:  
DECLARE @strTransactionId NVARCHAR(100)  
  
IF ISNULL(@ysnRecap, 0) = 0  
BEGIN     
        
      DECLARE @GLEntries RecapTableType ,
              @IdHasNoPlaceOfService Id,
              @IdHasNoDepreciation Id,
              @IdHasDepreciation Id
      

      DECLARE @tblDepComputation TABLE (
        intAssetId INT ,
        dblBasis NUMERIC(18,6) NULL,
        dblMonth NUMERIC(18,6) NULL,
        dblDepre NUMERIC(18,6) NULL,
        ysnFullyDepreciated BIT NULL,
        strError NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL ,
        strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
        ysnDepreciated BIT NULL,
        dtmDepreciate DATETIME NULL
      )
  
      INSERT INTO @tblDepComputation(intAssetId,dblBasis,dblMonth, dblDepre, ysnFullyDepreciated, strError)
        SELECT intAssetId, dblBasis,dblMonth,dblDepre,ysnFullyDepreciated, strError
        FROM dbo.fnFAComputeMultipleDepreciation(@IdGood, @BookId) 

      DELETE FROM @IdGood

      INSERT INTO @IdGood
        SELECT intAssetId FROM @tblDepComputation WHERE strError IS NULL

      INSERT INTO @tblError(intAssetId, strError)
        SELECT intAssetId,strError FROM @tblDepComputation WHERE strError IS NOT NULL
      
      DELETE FROM @tblDepComputation WHERE strError IS NOT NULL
      
      IF NOT EXISTS(SELECT TOP 1 1 FROM @IdGood)
          GOTO LogError

      INSERT INTO @IdHasNoPlaceOfService 
        select intId from @IdGood 
		    outer apply(	
			    select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  AND ISNULL(intBookId,1) = @BookId
		    )D
        where D.cnt = 0
      
    INSERT INTO @IdHasNoDepreciation 
		select intId from @IdGood 
		outer apply
		(	
			select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  
      AND ISNULL(intBookId,1) = @BookId
      AND strTransaction  in( 'Depreciation', 'Place in service')
		)D
        where D.cnt =1

    INSERT INTO @IdHasDepreciation 
		select intId from @IdGood 
		outer apply
		(	
			select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  
      AND ISNULL(intBookId,1) = @BookId
      AND strTransaction  in( 'Depreciation', 'Place in service')
		)D
        where D.cnt >1

      

  
      DECLARE @IdIterate Id
 
  --for creation of place of service
      IF EXISTS(SELECT TOP 1 1 FROM @IdHasNoPlaceOfService)  
      BEGIN  
          INSERT INTO @IdIterate SELECT intId FROM @IdHasNoPlaceOfService
          DECLARE @i INT 
          WHILE EXISTS(SELECT TOP 1 1 FROM @IdIterate)
          BEGIN
                SELECT TOP 1 @i = intId FROM @IdIterate 
                EXEC uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strTransactionId OUTPUT  

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
                    [strTransaction],  
                    [strTransactionId],  
                    [strType],  
                    [strConvention],
                    [strBatchId]
                  )  
                  SELECT  
                    F.intAssetId,  
                    @BookId,
                    D.[intDepreciationMethodId],  
                    BD.dblCost - BD.dblSalvageValue,  
                    BD.dtmPlacedInService,
                    NULL,  
                    BD.dtmPlacedInService,  
                    0,  
                    BD.dblSalvageValue,  
                    'Place in service',  
                    @strTransactionId,  
                    D.strDepreciationType,  
                    D.strConvention,
                    @strBatchId
                    FROM 
                    tblFAFixedAsset F 
                    JOIN tblFADepreciationMethod D ON D.intAssetId = F.intAssetId
                    JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId = D.intDepreciationMethodId AND BD.intBookId = @BookId
                    WHERE F.intAssetId = @i
                  
                  UPDATE @tblDepComputation SET strTransactionId = @strTransactionId WHERE intAssetId = @i
                  DELETE FROM @IdIterate WHERE intId = @i
              END
      END  
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
                  [dtmDateInService],  
                  [dtmDispositionDate],  
                  [dtmDepreciationToDate],  
                  [dblDepreciationToDate],  
                  [dblSalvageValue],  
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
                  BD.dtmPlacedInService,  
                  NULL,  
				          DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (Depreciation.dtmDepreciationToDate)) + 1, 0)) ,
                  E.dblDepre,  
                  BD.dblSalvageValue,  
                  'Depreciation',  
                  @strTransactionId,  
                  D.strDepreciationType,
                  D.strConvention,
                  @strBatchId
                  FROM tblFAFixedAsset F 
                  JOIN tblFADepreciationMethod D ON D.intAssetId = F.intAssetId
                  JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId = D.intDepreciationMethodId AND BD.intBookId = @BookId
                  OUTER APPLY (
                    SELECT dblDepre,dblBasis FROM @tblDepComputation WHERE intAssetId = @i
                  ) E
                  OUTER APPLY(
                    SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation 
                    WHERE [intAssetId] = @i AND intBookId = @BookId
                    ORDER BY dtmDepreciationToDate DESC
                  )Depreciation
                  WHERE F.intAssetId = @i

                  UPDATE @tblDepComputation SET strTransactionId = @strTransactionId, ysnDepreciated = 1 WHERE intAssetId = @i
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
                [dtmDateInService],  
                [dtmDispositionDate],  
                [dtmDepreciationToDate],  
                [dblDepreciationToDate],  
                [dblSalvageValue],  
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
                BD.dtmPlacedInService,  
                NULL,  
				        DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (Depreciation.dtmDepreciationToDate)) + 2, 0)) ,
                E.dblDepre,  
                BD.dblSalvageValue,  
                'Depreciation',  
                @strTransactionId,  
                D.strDepreciationType,  
                D.strConvention,
                @strBatchId
                FROM tblFAFixedAsset F 
                  JOIN tblFADepreciationMethod D ON D.intAssetId = F.intAssetId
                  JOIN tblFABookDepreciation BD ON BD.intDepreciationMethodId = D.intDepreciationMethodId AND BD.intBookId = @BookId
                  
                  OUTER APPLY (
                    SELECT dblDepre,dblBasis FROM @tblDepComputation WHERE intAssetId = @i
                  ) E
                  OUTER APPLY(
                    SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation WHERE [intAssetId] = @i 
                    AND intBookId = @BookId
                    ORDER BY dtmDepreciationToDate DESC
                  )Depreciation
                  WHERE F.intAssetId = @i

                UPDATE @tblDepComputation SET strTransactionId = @strTransactionId WHERE intAssetId = @i
                UPDATE FA SET ysnFullyDepreciated = 1  FROM tblFAFixedAsset FA JOIN @tblDepComputation D on D.intAssetId = FA.intAssetId
                WHERE D.ysnFullyDepreciated = 1 AND FA.intAssetId = @i

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
            
          )  
          SELECT   
          [strTransactionId]  = B.strTransactionId  
          ,[intTransactionId]  = A.[intAssetId]  
          ,[intAccountId]   = A.[intDepreciationAccountId]  
          ,[strDescription]  = A.[strAssetDescription]  
          ,[strReference]   = A.[strAssetId]  
          ,[dtmTransactionDate] = FAD.dtmDepreciationToDate
          ,[dblDebit]    = ROUND(B.dblMonth,2)  
          ,[dblCredit]   = 0  
          ,[dblDebitForeign]  = 0  
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
          ,[dblExchangeRate]  = 1  
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
          
          UNION ALL  
          SELECT   
          [strTransactionId]  = B.strTransactionId  
          ,[intTransactionId]  = A.[intAssetId]  
          ,[intAccountId]   = A.[intAccumulatedAccountId]  
          ,[strDescription]  = A.[strAssetDescription]  
          ,[strReference]   = A.[strAssetId]  
          ,[dtmTransactionDate] = FAD.dtmDepreciationToDate
          ,[dblDebit]    = 0  
          ,[dblCredit]   = ROUND(B.dblMonth,2)  
          ,[dblDebitForeign]  = 0  
          ,[dblCreditForeign]  = 0  
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
          ,[dblExchangeRate]  = 1  
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
            
          DECLARE @PostResult INT  
          EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = @ysnPost, @SkipICValidation = 1  
          IF @@ERROR <> 0 OR @PostResult <> 0 RETURN --1  
      END
END  
  
  
  
  
--=====================================================================================================================================  
--  UPDATE FIXEDASSETS TABLE  
---------------------------------------------------------------------------------------------------------------------------------------  

-- IF EXISTS(SELECT TOP 1 1 FROM (SELECT TOP 1 A.intAssetDepreciationId FROM tblFAFixedAssetDepreciation A   
--       WHERE A.[intAssetId] IN (SELECT intAssetId From #AssetID)   
--         AND ISNULL([dbo].isOpenAccountingDate(A.[dtmDepreciationToDate]), 0) = 0 ORDER BY A.intAssetDepreciationId DESC ) TBL)  
-- BEGIN  
--  RAISERROR('There is Depreciation Date on a closed period in this asset.', 16,1)  
--  RETURN-1  
-- END  

UPDATE A SET [ysnDepreciated] = 1   
FROM tblFAFixedAsset  A JOIN  @tblDepComputation B ON B.intAssetId = A.intAssetId
WHERE B.ysnDepreciated =1 


UPDATE A  SET A.ysnFullyDepreciated  =1  
  FROM tblFABookDepreciation A  JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId  
  WHERE B.ysnFullyDepreciated = 1  AND A.intBookId = @BookId

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
    SELECT strReference strAssetId, strTransactionId, 'Asset Depreciated' strResult,'GAAP' strBook, dtmDate FROM tblGLDetail C WHERE @strBatchId = strBatchId
    AND ysnIsUnposted = 0  AND @BookId = 1
    GROUP by strReference, strTransactionId, dtmDate
    UNION
    SELECT strAssetId, strTransactionId, 'Tax Depreciated' strResult, 'Tax' strBook, dtmDepreciationToDate FROM  tblFAFixedAssetDepreciation A 
    JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
	  WHERE @strBatchId = strBatchId AND A.intBookId <> 1 AND @BookId <> 1
    UNION
    SELECT strAssetId,'' strTransactionId, strError strResult, 
	  case when @BookId = 1 then 'GAAP' 
		when @BookId = 2 THEN 'Tax'
		end strBook, 
	
	 null dtmDate FROM @tblError A JOIN tblFAFixedAsset B ON B.intAssetId = A.intAssetId
  )
  INSERT INTO tblFADepreciateLogDetail (intLogId, strAssetId ,strTransactionId, strBook, strResult, dtmDate) 
  SELECT @intLogId, strAssetId, strTransactionId, strBook, strResult, dtmDate FROM Q 




-- IF @ysnSingleMode = 1 AND EXISTS (SELECT TOP 1 1 FROM @tblError)
-- BEGIN
--   DECLARE @strError NVARCHAR(200)
--   SELECT TOP 1 @strError = strError FROM @tblError
--   RAISERROR (@strError,16,1)  
--   RETURN -1
-- END

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
  
--RETURN 0;  