CREATE PROCEDURE [dbo].[uspFADepreciateAsset]
	@Param				AS NVARCHAR(MAX)	= '',	
	@ysnPost			AS BIT				= 0,
	@ysnRecap			AS BIT				= 0,
	@intEntityId		AS INT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT,
	@strBatchId			AS NVARCHAR(100)	= '' OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON


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


Exec uspSMGetStartingNumber @intStartingNumberId= 3, @strID = @strBatchId OUTPUT

	
--=====================================================================================================================================
-- 	UNPOSTING FIXEDASSETS TRANSACTIONS ysnPost = 0
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@ysnPost, 0) = 0
BEGIN
	DECLARE @intCount AS INT	
	DECLARE @strAssetId NVARCHAR(20)
	SELECT TOP 1 @strAssetId= strAssetId FROM tblFAFixedAsset A JOIN #AssetID B on A.intAssetId = B.intAssetId
	SET @Param = 'SELECT intGLDetailId FROM tblGLDetail WHERE strReference = ''' + @strAssetId + ''' AND strCode = ''AMDPR'' AND ysnIsUnposted=0'

	IF (NOT EXISTS(SELECT TOP 1 1 FROM tblGLDetail WHERE strBatchId = @strBatchId))
	BEGIN
		DECLARE @ReverseResult INT
		EXEC @ReverseResult  = [dbo].[uspFAReverseGLEntries] @strBatchId,@Param, @ysnRecap, NULL, @intEntityId, @intCount	OUT
		IF @ReverseResult <> 0 RETURN -1
		SET @successfulCount = @intCount
		IF ISNULL(@ysnRecap,0) = 0
			BEGIN
			IF(@intCount > 0)
			BEGIN
				UPDATE tblFAFixedAsset SET ysnDepreciated = 0, ysnDisposed = 0 WHERE intAssetId IN (SELECT intAssetId FROM #AssetID)				
				DELETE A FROM tblFAFixedAssetDepreciation A JOIN #AssetID B ON B.intAssetId =  A.intAssetId AND strTransaction = 'Depreciation'
			END		
		END							
	END
END
ELSE
BEGIN
--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
Post_Transaction:

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @intDefaultCurrencyId	INT, @ysnForeignCurrency BIT = 0
DECLARE @strTransactionId NVARCHAR(100)

Exec uspSMGetStartingNumber  @intStartingNumberId = 113 , @strID= @strTransactionId OUTPUT

SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

-- Entire record
SELECT * INTO #FAAsset FROM tblFAFixedAsset where intAssetId IN (SELECT [intAssetId] FROM #AssetID)

-- Service Year
DECLARE @intYear		INT = (SELECT (COUNT(*)/12)+1 as intYear FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID))

-- Service Year Percentage
DECLARE @dblPercentage	INT = (SELECT ISNULL(dblPercentage,1) as dblPercentage FROM tblFADepreciationMethodDetail A 
										WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset) and intYear = @intYear)

-- Running Balance
DECLARE @dblYear		NUMERIC (18,6) = (SELECT TOP 1 dblDepreciationToDate FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID) ORDER BY intAssetDepreciationId DESC)

-- Computation
DECLARE @dblBasis		NUMERIC (18,6)	= (SELECT TOP 1 dblCost - dblSalvageValue FROM #FAAsset)
DECLARE @dblAnnualDep	NUMERIC (18,6)	= (@dblBasis * (@dblPercentage * .01))
DECLARE @dblMonth		NUMERIC (18,6)	= (@dblAnnualDep / 12)								--NEED TO VERIFY IF ITS REALLY 12
DECLARE @dblDepre		NUMERIC (18,6)	= (@dblMonth / 2) + ISNULL(@dblYear,0)				--NEED TO VERIFY IF ITS REALLY 2


IF ISNULL(@ysnRecap, 0) = 0
	BEGIN							
		
		DECLARE @GLEntries RecapTableType				
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID))
		BEGIN
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
						[strType],
						[strConvention]
					)
				SELECT
						(SELECT TOP 1 [intAssetId] FROM #AssetID),
						(SELECT TOP 1 [intDepreciationMethodId] FROM #FAAsset),
						@dblBasis,
						(SELECT TOP 1 dtmDateInService FROM #FAAsset),
						NULL,
						(SELECT TOP 1 dtmDateInService FROM #FAAsset),
						0,
						(SELECT TOP 1 dblSalvageValue FROM #FAAsset),
						'Place in service',
						(SELECT TOP 1 strDepreciationType FROM tblFADepreciationMethod A WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset)),
						(SELECT TOP 1 strConvention FROM tblFADepreciationMethod A WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset))

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
					[strType],
					[strConvention]
				)
			SELECT
					(SELECT TOP 1 [intAssetId] FROM #AssetID),
					(SELECT TOP 1 [intDepreciationMethodId] FROM #FAAsset),
					@dblBasis,
					(SELECT TOP 1 dtmDateInService FROM #FAAsset),
					NULL,
					(SELECT DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID))) + 1, 0))),
					@dblDepre,
					(SELECT TOP 1 dblSalvageValue FROM #FAAsset),
					'Depreciation',
					(SELECT TOP 1 strDepreciationType FROM tblFADepreciationMethod A WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset)),
					(SELECT TOP 1 strConvention FROM tblFADepreciationMethod A WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset))

		END
		ELSE
		BEGIN
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
					[strType],
					[strConvention]
				)
			SELECT
					(SELECT TOP 1 [intAssetId] FROM #AssetID),
					(SELECT TOP 1 [intDepreciationMethodId] FROM #FAAsset),
					@dblBasis,
					(SELECT TOP 1 dtmDateInService FROM #FAAsset),
					NULL,
					(SELECT DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (SELECT TOP 1 dtmDepreciationToDate FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID) ORDER BY intAssetDepreciationId DESC)) + 2, 0))),
					(SELECT (SELECT TOP 1 dblDepreciationToDate FROM tblFAFixedAssetDepreciation A WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID) ORDER BY intAssetDepreciationId DESC) + @dblMonth),
					(SELECT TOP 1 dblSalvageValue FROM #FAAsset),
					'Depreciation',
					(SELECT TOP 1 strDepreciationType FROM tblFADepreciationMethod A WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset)),
					(SELECT TOP 1 strConvention FROM tblFADepreciationMethod A WHERE A.[intDepreciationMethodId] = (SELECT TOP 1 intDepreciationMethodId FROM #FAAsset))
		END
		
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
			,[intAccountId]			= A.[intDepreciationAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.[strAssetId]
			,[dtmTransactionDate]	= (SELECT TOP 1 B.[dtmDepreciationToDate] FROM tblFAFixedAssetDepreciation B WHERE B.intAssetId = A.[intAssetId] ORDER BY B.intAssetDepreciationId DESC)
			,[dblDebit]				= ISNULL(A.[dblCost], 0) - ISNULL(A.[dblSalvageValue], 0)
			,[dblCredit]			= 0
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= (SELECT TOP 1 B.[dtmDepreciationToDate] FROM tblFAFixedAssetDepreciation B WHERE B.intAssetId = A.[intAssetId] ORDER BY B.intAssetDepreciationId DESC)
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AMDPR'
								
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Depreciation'
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
			,[intAccountId]			= A.[intDepreciationAccountId]
			,[strDescription]		= A.[strAssetDescription]
			,[strReference]			= A.[strAssetId]
			,[dtmTransactionDate]	= (SELECT TOP 1 B.[dtmDepreciationToDate] FROM tblFAFixedAssetDepreciation B WHERE B.intAssetId = A.[intAssetId] ORDER BY B.intAssetDepreciationId DESC)
			,[dblDebit]				= 0
			,[dblCredit]			= ISNULL(A.[dblCost], 0) - ISNULL(A.[dblSalvageValue], 0)
			,[dblDebitForeign]		= 0
			,[dblCreditForeign]		= 0
			,[dblDebitReport]		= 0
			,[dblCreditReport]		= 0
			,[dblReportingRate]		= 0
			,[dblForeignRate]		= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[dtmDate]				= (SELECT TOP 1 B.[dtmDepreciationToDate] FROM tblFAFixedAssetDepreciation B WHERE B.intAssetId = A.[intAssetId] ORDER BY B.intAssetDepreciationId DESC)
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[intUserId]			= 0
			,[intEntityId]			= @intEntityId			
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @strBatchId
			,[strCode]				= 'AMDPR'
			,[strJournalLineDescription] = ''
			,[intJournalLineNo]		= A.[intAssetId]			
			,[strTransactionType]	= 'Depreciation'
			,[strTransactionForm]	= 'Fixed Assets'
			,[strModuleName]		= 'Fixed Assets'
		FROM tblFAFixedAsset A
		WHERE A.[intAssetId] IN (SELECT [intAssetId] FROM #AssetID)
		
		DECLARE @PostResult INT
		EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = @ysnPost, @SkipICValidation = 1
		IF @@ERROR <> 0	OR @PostResult <> 0 RETURN -1
		DELETE #FAAsset
		DROP TABLE #FAAsset
	END




--=====================================================================================================================================
-- 	UPDATE FIXEDASSETS TABLE
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblFAFixedAsset
	SET [ysnDepreciated] = 1
	WHERE [intAssetId] IN (SELECT intAssetId From #AssetID)


IF EXISTS(SELECT TOP 1 1 FROM (SELECT TOP 1 A.intAssetDepreciationId FROM tblFAFixedAssetDepreciation A 
						WHERE A.[intAssetId] IN (SELECT intAssetId From #AssetID) 
								AND ISNULL([dbo].isOpenAccountingDate(A.[dtmDepreciationToDate]), 0) = 0 ORDER BY A.intAssetDepreciationId DESC ) TBL)
BEGIN
	RAISERROR('There is Depreciation Date on a closed period in this asset.', 16,1)
	RETURN-1
END
--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID FIXEDASSETS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM #AssetID)

END

RETURN 0;