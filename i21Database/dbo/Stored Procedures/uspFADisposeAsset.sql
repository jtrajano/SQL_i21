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
	INSERT INTO #AssetID SELECT [intAssetId] FROM tblFAFixedAsset
	
--=====================================================================================================================================
-- 	UNPOSTING FIXEDASSETS TRANSACTIONS ysnPost = 0
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
	BEGIN
		DECLARE @intCount AS INT	

		IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLDetail WHERE strBatchId = @strBatchId))
			BEGIN
				SET @Param = (SELECT strAssetId FROM tblFAFixedAsset WHERE intAssetId IN (SELECT intAssetId FROM #AssetID))
				EXEC [dbo].[uspGLReverseGLEntries] @strBatchId,@Param, 0, 'AMDIS', NULL, @intEntityId, @intCount	OUT
				SET @successfulCount = @intCount
				
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

DECLARE @intDefaultCurrencyId	INT, @ysnForeignCurrency BIT = 0
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

DECLARE @dblDailyRate	NUMERIC (18,6)

IF ISNULL(@ysnRecap, 0) = 0
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
			
		)
		SELECT 
			 [strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAccumulatedAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.[strAssetId]
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= A.[dblCost]
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
			,[strCode]				= 'AMDIS'
								
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Disposition'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
		
		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)


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
			,[strReference]			= A.[strAssetId]
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
			,[strCode]				= 'AMDIS'
								
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Disposition'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
		
		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)

		
		EXEC uspGLBookEntries @GLEntries, @ysnPost
		

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