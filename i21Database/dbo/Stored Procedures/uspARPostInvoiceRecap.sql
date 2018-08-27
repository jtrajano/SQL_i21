CREATE PROCEDURE [dbo].[uspARPostInvoiceRecap]
     @BatchId           NVARCHAR(40)
    ,@PostDate          DATETIME                
    ,@UserId            INT
	,@raiseError		AS BIT				= 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

--SET @InitTranCount = @@TRANCOUNT
--SET @Savepoint = SUBSTRING(('uspARPostInvoiceRecap' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000

DECLARE @ErrorMerssage NVARCHAR(MAX)

--DECLARE  @totalRecords INT = 0
--		,@totalInvalid INT = 0
DECLARE @DelimitedIds VARCHAR(MAX)

--IF ISNULL(@raiseError,0) = 0	
--BEGIN
--	IF @InitTranCount = 0
--		BEGIN TRANSACTION 
--	ELSE
--		SAVE TRANSACTION @Savepoint
--END

DECLARE @TransactionName AS VARCHAR(500) = 'Invoice Transaction' + CAST(NEWID() AS NVARCHAR(100));
IF @@TRANCOUNT = 0
	BEGIN TRANSACTION @TransactionName
ELSE	 
	SAVE TRAN @TransactionName


BEGIN TRY

    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
			@PostDate        = @PostDate
		   ,@UserId          = @UserId

    EXEC [dbo].[uspARPrePostInvoiceIntegration]

    EXEC dbo.[uspARUpdateTransactionAccountOnPost]  

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
            
			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
			FROM
				#ARPostInvoiceHeader
			WHERE
				[ysnRecap] = 1
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Invoice', @ErrorMerssage, @DelimitedIds

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

BEGIN TRY
    IF(OBJECT_ID('tempdb..#ARInvoiceGLEntries') IS NOT NULL)
    BEGIN
        DROP TABLE #ARInvoiceGLEntries
    END

	CREATE TABLE #ARInvoiceGLEntries
	([dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign]			NUMERIC (18, 9) NULL,
	[dblDebitReport]			NUMERIC (18, 9) NULL,
	[dblCreditForeign]			NUMERIC (18, 9) NULL,
	[dblCreditReport]			NUMERIC (18, 9) NULL,
	[dblReportingRate]			NUMERIC (18, 9) NULL,
	[dblForeignRate]			NUMERIC (18, 9) NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[strRateType]			    NVARCHAR(50)	COLLATE Latin1_General_CI_AS,
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intSourceLocationId]		INT NULL,
	[intSourceUOMId]			INT NULL,
	[dblSourceUnitDebit]		NUMERIC (18, 6)  NULL,
	[dblSourceUnitCredit]		NUMERIC (18, 6)  NULL,
	[intCommodityId]			INT NULL,
	intSourceEntityId INT NULL,
	ysnRebuild BIT NULL)
	
    DECLARE @GLEntries RecapTableType
	INSERT INTO @GLEntries
		([dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[strRateType]
		,[strDocument]
		,[strComments]
		,[strSourceDocumentId]
		,[intSourceLocationId]
		,[intSourceUOMId]
		,[dblSourceUnitDebit]
		,[dblSourceUnitCredit]
		,[intCommodityId]
		,[intSourceEntityId]
		,[ysnRebuild])
	EXEC dbo.uspARGenerateEntriesForAccrual  

    EXEC [dbo].[uspARGenerateGLEntries]

	--IF @recap = 0
	--	BEGIN
	--		BEGIN TRY
	--			DECLARE @FinalGLEntries AS RecapTableType
	--			DELETE FROM @FinalGLEntries

	--			IF EXISTS ( SELECT TOP 1 1 FROM @FinalGLEntries)

	--				DECLARE @InvalidGLEntries AS TABLE
	--				(strTransactionId	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	--				,strText			NVARCHAR(150)  COLLATE Latin1_General_CI_AS NULL
	--				,intErrorCode		INT
	--				,strModuleName		NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL)

	--				INSERT INTO @InvalidGLEntries
	--					(strTransactionId
	--					,strText
	--					,intErrorCode
	--					,strModuleName)
	--				SELECT DISTINCT
	--					strTransactionId
	--					,strText
	--					,intErrorCode
	--					,strModuleName
	--				FROM
	--					[dbo].[fnGetGLEntriesErrors](@GLEntries)

	--				SET @invalidCount = @invalidCount + ISNULL((SELECT COUNT(strTransactionId) FROM @InvalidGLEntries), 0)

	--				INSERT INTO 
	--						tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	--					SELECT DISTINCT
	--							strError				= IGLE.strText
	--						,strTransactionType		= GLE.strTransactionType 
	--						,strTransactionId		= IGLE.strTransactionId
	--						,strBatchNumber			= GLE.strBatchId
	--						,intTransactionId		= GLE.intTransactionId 
	--					FROM
	--						@InvalidGLEntries IGLE
	--					LEFT OUTER JOIN
	--						@GLEntries GLE
	--							ON IGLE.strTransactionId = GLE.strTransactionId
					

	--				DELETE FROM @GLEntries
	--				WHERE
	--					strTransactionId IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

	--				DELETE FROM @PostInvoiceData
	--				WHERE
	--					strInvoiceNumber IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

	--				EXEC	dbo.uspGLBookEntries
	--								@GLEntries		= @FinalGLEntries
	--							,@ysnPost		= @post
	--							,@XACT_ABORT_ON = @raiseError
	--		END TRY
	--		BEGIN CATCH
	--			SELECT @ErrorMerssage = ERROR_MESSAGE()										
	--			GOTO Do_Rollback
	--		END CATCH
	--	END	

	INSERT INTO @GLEntries
		([dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[strRateType]
		,[strDocument]
		,[strComments]
		,[strSourceDocumentId]
		,[intSourceLocationId]
		,[intSourceUOMId]
		,[dblSourceUnitDebit]
		,[dblSourceUnitCredit]
		,[intCommodityId]
		,[intSourceEntityId]
		,[ysnRebuild])
	SELECT
		 [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[strRateType]
		,[strDocument]
		,[strComments]
		,[strSourceDocumentId]
		,[intSourceLocationId]
		,[intSourceUOMId]
		,[dblSourceUnitDebit]
		,[dblSourceUnitCredit]
		,[intCommodityId]
		,[intSourceEntityId]
		,[ysnRebuild]
    FROM
        #ARInvoiceGLEntries

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint

			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
			FROM
				#ARPostInvoiceHeader
			WHERE
				[ysnRecap] = 1
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Invoice', @ErrorMerssage, @DelimitedIds
									
			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

--DECLARE @DefaultCurrencyId                  INT
--        ,@DefaultCurrencyExchangeRateTypeId INT
--SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
--SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)

--IF @recap = 1		
--	BEGIN
--		IF @raiseError = 0
--			ROLLBACK TRAN @TransactionName		

--		DELETE GLDR  
--		FROM 
--			(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID  
--		INNER JOIN 
--			(SELECT intTransactionId, strTransactionId, strCode FROM dbo.tblGLDetailRecap WITH (NOLOCK)) GLDR 
--				ON (PID.strInvoiceNumber = GLDR.strTransactionId OR PID.intInvoiceId = GLDR.intTransactionId)  AND GLDR.strCode = @CODE		   
		   
--		BEGIN TRY		
		 
--			INSERT INTO tblGLPostRecap(
--			 [strTransactionId]
--			,[intTransactionId]
--			,[intAccountId]
--			,[strDescription]
--			,[strJournalLineDescription]
--			,[strReference]	
--			,[dtmTransactionDate]
--			,[dblDebit]
--			,[dblCredit]
--			,[dblDebitUnit]
--			,[dblCreditUnit]
--			,[dblDebitForeign]
--			,[dblCreditForeign]			
--			,[intCurrencyId]
--			,[dtmDate]
--			,[ysnIsUnposted]
--			,[intConcurrencyId]	
--			,[dblExchangeRate]
--			,[intUserId]
--			,[dtmDateEntered]
--			,[strBatchId]
--			,[strCode]
--			,[strModuleName]
--			,[strTransactionForm]
--			,[strTransactionType]
--			,[strAccountId]
--			,[strAccountGroup]
--			,[strRateType]
--		)
--		SELECT
--			[strTransactionId]
--			,A.[intTransactionId]
--			,A.[intAccountId]
--			--,A.[strDescription]
--			, strDescription					= B.strDescription
--			,A.[strJournalLineDescription]
--			,A.[strReference]	
--			,A.[dtmTransactionDate]
--			,Debit.Value
--			,Credit.Value
--			,DebitUnit.Value
--			,CreditUnit.Value
--			,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblDebitForeign] END
--			,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblCreditForeign]	 END 		
--			,A.[intCurrencyId]
--			,A.[dtmDate]
--			,A.[ysnIsUnposted]
--			,A.[intConcurrencyId]	
--			,[dblExchangeRate]					= ISNULL(RATETYPE.dblCurrencyExchangeRate, @OneDecimal)
--			,A.[intUserId]
--			,A.[dtmDateEntered]
--			,A.[strBatchId]
--			,A.[strCode]
--			,A.[strModuleName]
--			,A.[strTransactionForm]
--			,A.[strTransactionType]
--			,B.strAccountId
--			,C.strAccountGroup
--			,[strRateType]						= RATETYPE.strCurrencyExchangeRateType
--		FROM @GLEntries A
--		INNER JOIN dbo.tblGLAccount B 
--			ON A.intAccountId = B.intAccountId
--		INNER JOIN dbo.tblGLAccountGroup C
--			ON B.intAccountGroupId = C.intAccountGroupId			
--		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Debit
--		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Credit
--		CROSS APPLY dbo.fnGetDebitUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) DebitUnit
--		CROSS APPLY dbo.fnGetCreditUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) CreditUnit
--		OUTER APPLY (
--			SELECT SMCERT.strCurrencyExchangeRateType,dblBaseInvoiceTotal,dblInvoiceTotal,dblCurrencyExchangeRate
--			FROM dbo.tblARInvoice I
--			OUTER APPLY (
--				SELECT TOP 1 intCurrencyExchangeRateTypeId
--				FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
--				WHERE intInvoiceId = I.intInvoiceId
--			) ID
--			INNER JOIN (
--				SELECT intCurrencyExchangeRateTypeId
--					 , strCurrencyExchangeRateType
--				FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
--			) SMCERT ON SMCERT.intCurrencyExchangeRateTypeId = ISNULL(ID.intCurrencyExchangeRateTypeId, @DefaultCurrencyExchangeRateTypeId)
--			WHERE I.strInvoiceNumber = A.strTransactionId 
--			  AND I.intInvoiceId = A.intTransactionId
--		) RATETYPE
				
--		--EXEC uspGLPostRecap @GLEntries, @UserEntityID 

--		END TRY
--		BEGIN CATCH
--			SELECT @ErrorMerssage = ERROR_MESSAGE()
--			IF @raiseError = 0
--				BEGIN
--					SET @CurrentTranCount = @@TRANCOUNT
--					SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
--					IF @CurrentTranCount = 0
--						BEGIN TRANSACTION
--					ELSE
--						SAVE TRANSACTION @CurrentSavepoint

--					EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param		
--				IF @CurrentTranCount = 0
--					BEGIN
--						IF (XACT_STATE()) = -1
--							ROLLBACK TRANSACTION
--						IF (XACT_STATE()) = 1
--							COMMIT TRANSACTION
--					END		
--				ELSE
--					BEGIN
--						IF (XACT_STATE()) = -1
--							ROLLBACK TRANSACTION  @CurrentSavepoint
--						--IF (XACT_STATE()) = 1
--						--	COMMIT TRANSACTION  @Savepoint
--					END
--				END			
--			IF @raiseError = 1
--				RAISERROR(@ErrorMerssage, 11, 1)
--			GOTO Post_Exit
--		END CATCH
	
--	END 	

--ELSE 
--BEGIN
--	DECLARE @tmpBatchId NVARCHAR(100)
--	SELECT @tmpBatchId = [strBatchId] 
--	FROM @GLEntries A
--	INNER JOIN dbo.tblGLAccount B 
--		ON A.intAccountId = B.intAccountId
--	INNER JOIN dbo.tblGLAccountGroup C
--		ON B.intAccountGroupId = C.intAccountGroupId
--	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Debit
--	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Credit
--	CROSS APPLY dbo.fnGetDebitUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) DebitUnit
--	CROSS APPLY dbo.fnGetCreditUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) CreditUnit

--	UPDATE tblGLPostRecap 
--	SET 
--		dblCreditForeign = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN @ZeroDecimal ELSE dblDebitForeign END
--		, dblDebitForeign = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN @ZeroDecimal ELSE dblDebitForeign END
--		, dblExchangeRate = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN @ZeroDecimal ELSE dblExchangeRate END
--		, strRateType = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN NULL ELSE strRateType END
--	WHERE 			
--		tblGLPostRecap.strBatchId = @tmpBatchId
--END

DECLARE @DefaultCurrencyId                  INT
        ,@DefaultCurrencyExchangeRateTypeId INT

SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)

ROLLBACK TRAN @TransactionName		

BEGIN TRY	

	DELETE GLDR  
	FROM 
		(SELECT intInvoiceId, strInvoiceNumber FROM #ARPostInvoiceHeader WHERE [ysnRecap] = 1) PID  
	INNER JOIN 
		(SELECT intTransactionId, strTransactionId, strCode FROM dbo.tblGLDetailRecap WITH (NOLOCK)) GLDR 
			ON (PID.strInvoiceNumber = GLDR.strTransactionId OR PID.intInvoiceId = GLDR.intTransactionId)  AND GLDR.strCode = @CODE		   
		   
	
		 
	INSERT INTO tblGLPostRecap(
		 [strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strDescription]
		,[strJournalLineDescription]
		,[strReference]	
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[dblDebitForeign]
		,[dblCreditForeign]			
		,[intCurrencyId]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[dblExchangeRate]
		,[intUserId]
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]
		,[strModuleName]
		,[strTransactionForm]
		,[strTransactionType]
		,[strAccountId]
		,[strAccountGroup]
		,[strRateType]
	)
	SELECT
		[strTransactionId]
		,A.[intTransactionId]
		,A.[intAccountId]
		--,A.[strDescription]
		, strDescription					= B.strDescription
		,A.[strJournalLineDescription]
		,A.[strReference]	
		,A.[dtmTransactionDate]
		,Debit.Value
		,Credit.Value
		,DebitUnit.Value
		,CreditUnit.Value
		,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN @ZeroDecimal ELSE A.[dblDebitForeign] END
		,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN @ZeroDecimal ELSE A.[dblCreditForeign]	 END 		
		,A.[intCurrencyId]
		,A.[dtmDate]
		,A.[ysnIsUnposted]
		,A.[intConcurrencyId]	
		,[dblExchangeRate]					= ISNULL(RATETYPE.dblCurrencyExchangeRate, @OneDecimal)
		,A.[intUserId]
		,A.[dtmDateEntered]
		,A.[strBatchId]
		,A.[strCode]
		,A.[strModuleName]
		,A.[strTransactionForm]
		,A.[strTransactionType]
		,B.strAccountId
		,C.strAccountGroup
		,[strRateType]						= RATETYPE.strCurrencyExchangeRateType
	FROM @GLEntries A
	INNER JOIN dbo.tblGLAccount B 
		ON A.intAccountId = B.intAccountId
	INNER JOIN dbo.tblGLAccountGroup C
		ON B.intAccountGroupId = C.intAccountGroupId			
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Credit
	CROSS APPLY dbo.fnGetDebitUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) DebitUnit
	CROSS APPLY dbo.fnGetCreditUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) CreditUnit
	OUTER APPLY (
		SELECT SMCERT.strCurrencyExchangeRateType,dblBaseInvoiceTotal,dblInvoiceTotal,dblCurrencyExchangeRate
		FROM dbo.tblARInvoice I
		OUTER APPLY (
			SELECT TOP 1 intCurrencyExchangeRateTypeId
			FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
			WHERE intInvoiceId = I.intInvoiceId
		) ID
		INNER JOIN (
			SELECT intCurrencyExchangeRateTypeId
					, strCurrencyExchangeRateType
			FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
		) SMCERT ON SMCERT.intCurrencyExchangeRateTypeId = ISNULL(ID.intCurrencyExchangeRateTypeId, @DefaultCurrencyExchangeRateTypeId)
		WHERE I.strInvoiceNumber = A.strTransactionId 
			AND I.intInvoiceId = A.intTransactionId
	) RATETYPE
				

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()
	IF @raiseError = 0
		BEGIN
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint

	SET @DelimitedIds = ''
	SELECT
		@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		#ARPostInvoiceHeader
	WHERE
		[ysnRecap] = 1

			EXEC dbo.uspARInsertPostResult @BatchId, 'Invoice', @ErrorMerssage, @DelimitedIds		
		IF @CurrentTranCount = 0
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION
				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION
			END		
		ELSE
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION  @CurrentSavepoint
			END
		END			
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
	GOTO Post_Exit
END CATCH

	RETURN 1;

Post_Exit:
	RETURN 0;
