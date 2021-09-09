CREATE PROCEDURE [dbo].[uspFACreateAsset]
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
				EXEC [dbo].[uspGLReverseGLEntries] @strBatchId,@Param, 0, 'AMPUR', NULL, @intEntityId, @intCount	OUT
				SET @successfulCount = @intCount
				
				IF(@intCount > 0)
				BEGIN
					UPDATE tblFAFixedAsset SET ysnAcquired = 0 WHERE intAssetId IN (SELECT intAssetId FROM #AssetID)				
				END									
			END
		
		GOTO Post_Commit;
	END


--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
Post_Transaction:

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @intDefaultCurrencyId	INT, @ysnMultiCurrency BIT = 0, @intDefaultCurrencyExchangeRateTypeId INT
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 
SELECT @intDefaultCurrencyExchangeRateTypeId = dbo.fnFAGetDefaultCurrencyExchangeRateTypeId()

DECLARE @dblRate NUMERIC (18,6)

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
				@ysnMultiCurrency = CASE WHEN ISNULL(BD.intFunctionalCurrencyId, ISNULL(F.intFunctionalCurrencyId, @intDefaultCurrencyId)) = ISNULL(BD.intCurrencyId, F.intCurrencyId) THEN 0 ELSE 1 END
		FROM tblFAFixedAsset F 
        JOIN tblFABookDepreciation BD ON BD.intAssetId = F.intAssetId
        WHERE F.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID) AND BD.intBookId = 1 

		DECLARE @GLEntries RecapTableType				
		
		-- ASSET ACCOUNT
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
			 [strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intAssetAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.[strAssetId]
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= CASE WHEN @ysnMultiCurrency = 0 THEN A.[dblCost] ELSE (A.[dblCost] * @dblRate) END
			,[dblCredit]			= 0
			,[dblDebitForeign]		= CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE A.[dblCost] END
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
			,[dblExchangeRate]		= @dblRate
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
			,[intCurrencyExchangeRateTypeId] = @intDefaultCurrencyExchangeRateTypeId

		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)

		-- EXPENSE ACCOUNT
		UNION ALL
		SELECT 
			 [strTransactionId]		= @strTransactionId
			,[intTransactionId]		= A.[intAssetId]
			,[intAccountId]			= A.[intExpenseAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.[strAssetId]
			,[dtmTransactionDate]	= A.[dtmDateAcquired]
			,[dblDebit]				= 0
			,[dblCredit]			= CASE WHEN @ysnMultiCurrency = 0 THEN A.[dblCost] ELSE (A.[dblCost] * @dblRate) END
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= CASE WHEN @ysnMultiCurrency = 0 THEN 0 ELSE A.[dblCost] END
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
			,[dblExchangeRate]		= @dblRate
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
			,[intCurrencyExchangeRateTypeId] = @intDefaultCurrencyExchangeRateTypeId

		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)
					
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
	SET [ysnAcquired] = 1
	WHERE [intAssetId] IN (SELECT intAssetId From #AssetID)


IF @@ERROR <> 0	GOTO Post_Rollback;

IF EXISTS(SELECT TOP 1 1 FROM (SELECT TOP 1 A.intAssetId FROM tblFAFixedAsset A 
						WHERE A.[intAssetId] IN (SELECT intAssetId From #AssetID) 
								AND ISNULL([dbo].isOpenAccountingDate(A.dtmDateAcquired), 0) = 0) TBL)
BEGIN
	GOTO Post_Rollback
END

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