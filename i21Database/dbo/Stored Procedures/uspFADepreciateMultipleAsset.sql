  
CREATE PROCEDURE [dbo].[uspFADepreciateMultipleAsset]  
 @Id    AS Id READONLY,   
 @ysnPost   AS BIT    = 0,  
 @ysnRecap   AS BIT    = 0,  
 @intEntityId  AS INT    = 1,  
 @successfulCount AS INT    = 0 OUTPUT,  
 @strBatchId   AS NVARCHAR(100) = '' OUTPUT  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
  
  
--=====================================================================================================================================  
--  POPULATE FIXEDASSETS TO POST TEMPORARY TABLE  
---------------------------------------------------------------------------------------------------------------------------------------  
-- CREATE TABLE #AssetID(  
--    [intAssetId] [int] NOT NULL,  
  
--   )  
-- IF (ISNULL(@Param, '') <> '')   
--  INSERT INTO #AssetID EXEC (@Param)  
-- ELSE  
--  INSERT INTO #AssetID SELECT [intAssetId] FROM tblFAFixedAsset  

-- DECLARE @Id Id
DECLARE @IdGood Id
DECLARE @ysnSingleMode BIT = 0
DECLARE @tblError TABLE (  
   [intAssetId] [int] NOT NULL,  
   strError NVARCHAR(400) NULL
)  

IF(SELECT COUNT(*) FROM @Id) = 1 SET @ysnSingleMode = 1

EXEC uspSMGetStartingNumber @intStartingNumberId= 3, @strID = @strBatchId OUTPUT  

INSERT INTO @tblError 
    SELECT intAssetId , strError FROM fnFAValidateAssetDepreciation(@ysnPost, @Id)

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
 DECLARE @strAssetId NVARCHAR(20)  
 DECLARE @IdGLDetail Id
 SELECT TOP 1 @strAssetId= strAssetId FROM tblFAFixedAsset A JOIN @IdGood B on A.intAssetId = B.intId  

 INSERT INTO @IdGLDetail
    SELECT intGLDetailId FROM tblGLDetail GL JOIN tblFAFixedAsset A on GL.strReference = A.strAssetId
    JOIN @IdGood C on C.intId = A.intAssetId
    WHERE ysnIsUnposted = 0 AND strCode ='AMDPR'

  
 IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLDetail WHERE strBatchId = @strBatchId))  
 BEGIN  
      DECLARE @ReverseResult INT  
      EXEC @ReverseResult  = [dbo].[uspFAReverseMultipleAsset] @strBatchId,@IdGLDetail, @ysnRecap,
      NULL, @intEntityId, @intCount OUT  
      IF @ReverseResult <> 0 RETURN -1  
      SET @successfulCount = @intCount  
      IF ISNULL(@ysnRecap,0) = 0  
      BEGIN  
        IF(@intCount > 0)  
          BEGIN  
            UPDATE A SET ysnDepreciated = 0, ysnFullyDepreciated = 0, ysnDisposed = 0 
            FROM tblFAFixedAsset A JOIN @IdGood B ON A.intAssetId = B.intId
            DELETE A FROM tblFAFixedAssetDepreciation A JOIN @IdGood B ON B.intId =  A.intAssetId 
            AND strTransaction = 'Depreciation'  
          END    
        END         
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
        FROM dbo.fnFAComputeMultipleDepreciation(@IdGood) 

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
			    select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId 
		    )D
        where D.cnt = 0
      
    INSERT INTO @IdHasNoDepreciation 
		select intId from @Id 
		outer apply
		(	
			select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  and strTransaction  in( 'Depreciation', 'Place in service')
		)D
        where D.cnt =1

    INSERT INTO @IdHasDepreciation 
		select intId from @Id 
		outer apply
		(	
			select count(*) cnt from tblFAFixedAssetDepreciation WHERE  intAssetId = intId  and strTransaction  in( 'Depreciation', 'Place in service')
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
                    [strConvention]  
                  )  
                  SELECT  
                    F.intAssetId,  
                    D.[intDepreciationMethodId],  
                    dblCost - F.dblSalvageValue,  
                    F.dtmDateInService,
                    NULL,  
                    F.dtmDateInService,  
                    0,  
                    F.dblSalvageValue,  
                    'Place in service',  
                    @strTransactionId,  
                    D.strDepreciationType,  
                    D.strConvention  
                    FROM 
                    tblFAFixedAsset F 
                    JOIN tblFADepreciationMethod D ON D.intAssetId = F.intAssetId
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
                  [strConvention]  
                )  
                  SELECT  
                  @i,  
                  D.intDepreciationMethodId,  
                  E.dblBasis,  
                  F.dtmDateInService,  
                  NULL,  
				          DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (Depreciation.dtmDepreciationToDate)) + 1, 0)) ,
                  E.dblDepre,  
                  F.dblSalvageValue,  
                  'Depreciation',  
                  @strTransactionId,  
                  D.strDepreciationType,
                  D.strConvention
                  FROM tblFAFixedAsset F 
                  JOIN tblFADepreciationMethod D ON D.intAssetId = F.intAssetId
                  OUTER APPLY (
                    SELECT dblDepre,dblBasis FROM @tblDepComputation WHERE intAssetId = @i
                  ) E
                  OUTER APPLY(
                    SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation WHERE [intAssetId] = @i 
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
                [strConvention]  
              )  
              SELECT  
                @i,
                D.intDepreciationMethodId,
                E.dblBasis,  
                F.dtmDateInService,  
                NULL,  
				        DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (Depreciation.dtmDepreciationToDate)) + 2, 0)) ,
                E.dblDepre,  
                F.dblSalvageValue,  
                'Depreciation',  
                @strTransactionId,  
                D.strDepreciationType,  
                D.strConvention
                FROM tblFAFixedAsset F 
                  JOIN tblFADepreciationMethod D ON D.intAssetId = F.intAssetId
                  OUTER APPLY (
                    SELECT dblDepre,dblBasis FROM @tblDepComputation WHERE intAssetId = @i
                  ) E
                  OUTER APPLY(
                    SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation WHERE [intAssetId] = @i 
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
          WHERE B.intAssetId = A.[intAssetId] ORDER BY B.intAssetDepreciationId DESC
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
          WHERE B.intAssetId = A.[intAssetId] ORDER BY B.intAssetDepreciationId DESC
      )FAD
        
  DECLARE @PostResult INT  
  EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = @ysnPost, @SkipICValidation = 1  
  IF @@ERROR <> 0 OR @PostResult <> 0 RETURN -1  



  
  
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


UPDATE A  SET ysnFullyDepreciated  =1  
  FROM tblFAFixedAsset A  JOIN @tblDepComputation B ON A.intAssetId = B.intAssetId  
  WHERE B.ysnFullyDepreciated = 1  

--=====================================================================================================================================  
--  RETURN TOTAL NUMBER OF VALID FIXEDASSETS  
---------------------------------------------------------------------------------------------------------------------------------------  
LogError:
DECLARE @intLogId INT

INSERT INTO tblFADepreciateLog(strBatchId, dtmDate, intEntityId)
SELECT @strBatchId, GETDATE(), @intEntityId

SELECT @intLogId = SCOPE_IDENTITY()

;WITH Q as(
  SELECT strReference strAssetId, strTransactionId, 'Depreciated' strResult FROM tblGLDetail C WHERE @strBatchId = strBatchId
  AND ysnIsUnposted = 0   GROUP by strReference, strTransactionId
  UNION
  SELECT strAssetId,'' strTransactionId, strError strResult FROM @tblError A JOIN tblFAFixedAsset B ON B.intAssetId = A.intAssetId
)
INSERT INTO tblFADepreciateLogDetail (intLogId, strAssetId ,strTransactionId, strResult) 
SELECT @intLogId, strAssetId, strTransactionId, strResult FROM Q 

IF @ysnSingleMode = 1 AND EXISTS (SELECT TOP 1 1 FROM @tblError)
BEGIN
  DECLARE @strError NVARCHAR(200)
  SELECT TOP 1 @strError = strError FROM @tblError
  RAISERROR (@strError,16,1)  
  RETURN -1
END

DECLARE @intGLEntry INT
SELECT @intGLEntry = COUNT(*) FROM tblGLDetail WHERE @strBatchId = strBatchId AND ysnIsUnposted  = 0
SET @successfulCount =  CASE WHEN @intGLEntry > 0 THEN @intGLEntry/2 ELSE 0 END
  
END  
  
RETURN 0;  