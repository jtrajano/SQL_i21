CREATE PROCEDURE [dbo].[uspFADisposeAsset]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@strBatchId			AS NVARCHAR(100)	= '',
	@strTransactionId	AS NVARCHAR(100)	= '',
	@intEntityId		AS INT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION;


--=====================================================================================================================================
-- 	POPULATE FIXEDASSETS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #AssetID(
			[intAssetId] [int] NOT NULL,
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
NULL
FROM #AssetID A 
JOIN tblFAFixedAsset B on A.intAssetId = B.intAssetId 
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
		DECLARE @strAssetId NVARCHAR(20)
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

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @intDefaultCurrencyId	INT, @ysnForeignCurrency BIT = 0
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

DECLARE @dblDailyRate	NUMERIC (18,6)

IF ISNULL(@ysnRecap, 0) = 0
	BEGIN				
		DECLARE @totalDepre NUMERIC(18,6)			

		SELECT @totalDepre = SUM(dblCredit-dblDebit) 
			FROM tblGLDetail GL
			JOIN tblFAFixedAsset FA ON FA.strAssetId = GL.strReference
			JOIN #AssetID A ON A.intAssetId = FA.intAssetId
			WHERE FA.intAccumulatedAccountId = GL.intAccountId
			AND strCode = 'AMDPR'
			AND ysnIsUnposted = 0


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
			
		)
		SELECT 
			 [strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAccumulatedAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= @totalDepre
			,[dblCredit]			= 0
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= ISNULL(A.[dtmDateAcquired], GETDATE())
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
		
		FROM tblFAFixedAsset A 
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)
		UNION ALL
		SELECT 
			 [strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAccumulatedAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= 0
			,[dblCredit]			= A.[dblCost]
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= ISNULL(A.[dtmDateAcquired], GETDATE())
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
		
		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)
		UNION ALL
		SELECT 
			 [strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intGainLossAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.strAssetId
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN A.dblCost > @totalDepre THEN A.dblCost - @totalDepre ELSE 0 END
			,[dblCredit]			= CASE WHEN @totalDepre > A.dblCost THEN @totalDepre - A.dblCost ELSE 0 END
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= ISNULL(A.[dtmDateAcquired], GETDATE())
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
		
		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)
		AND @totalDepre <> A.dblCost


		
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
UPDATE tblFAFixedAsset
	SET [ysnDisposed] = 1
	WHERE [intAssetId] IN (SELECT intAssetId From #AssetID)


IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID FIXEDASSETS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM #AssetID)


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