CREATE PROCEDURE [dbo].[uspARPostInvoice]
	 @batchId			AS NVARCHAR(40)		= NULL
	,@post				AS BIT				= 0
	,@recap				AS BIT				= 0
	,@param				AS NVARCHAR(MAX)	= NULL
	,@userId			AS INT				= 1
	,@beginDate			AS DATE				= NULL
	,@endDate			AS DATE				= NULL
	,@beginTransaction	AS NVARCHAR(50)		= NULL
	,@endTransaction	AS NVARCHAR(50)		= NULL
	,@exclude			AS NVARCHAR(MAX)	= NULL
	,@successfulCount	AS INT				= 0 OUTPUT
	,@invalidCount		AS INT				= 0 OUTPUT
	,@success			AS BIT				= 0 OUTPUT
	,@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	,@transType			AS NVARCHAR(25)		= 'all'
	,@accrueLicense		AS BIT				= 0
	,@raiseError		AS BIT				= 0

 WITH RECOMPILE
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS ON
SET XACT_ABORT ON
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000
DECLARE @OneHundredDecimal DECIMAL(18,6)
SET @OneHundredDecimal = 100.000000

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

DECLARE  @totalRecords INT = 0
		,@totalInvalid INT = 0
 
SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

DECLARE @ErrorMerssage NVARCHAR(MAX)

SET @recapId = '1'
SET @success = 1

-- Ensure @post and @recap is not NULL  
SET @post = ISNULL(@post, 0)
SET @recap = ISNULL(@recap, 0)
SET @accrueLicense = ISNULL(@accrueLicense, 0)

DECLARE @StartingNumberId INT
SET @StartingNumberId = 3
IF(LEN(RTRIM(LTRIM(ISNULL(@batchId,'')))) = 0) AND @recap = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @batchId OUT
END
SET @batchIdUsed = @batchId
 
-- Get Transaction to Post
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

DECLARE @dtmStartWait	DATETIME
SET @dtmStartWait = GETDATE()

DELETE PQ
FROM tblARPostingQueue PQ
WHERE DATEDIFF(SECOND, dtmPostingdate, @dtmStartWait) >= 60

--CHECK IF THERE'S ON GOING POSTING IN QUEUE
IF EXISTS (SELECT TOP 1 NULL FROM tblARPostingQueue WHERE DATEDIFF(SECOND, dtmPostingdate, @dtmStartWait) <= 60)
	--IF HAS QUEUE TRY TO WAIT FOR 1 MINUTE
	BEGIN
		DECLARE @intQueueCount INT = 0

		--CHECK EVERY 5 SECS.
		WHILE @intQueueCount <= 12
			BEGIN
				--IF WAITING TIME IS > 1 MINUTE, THROW TIME OUT ERROR
				IF @intQueueCount >= 12
					BEGIN
						SET @intQueueCount = 13

						IF @raiseError = 0
							BEGIN
								IF @InitTranCount = 0
									BEGIN
										IF (XACT_STATE()) = -1
											ROLLBACK TRANSACTION
										IF (XACT_STATE()) = 1
											COMMIT TRANSACTION
									END		
								ELSE
									BEGIN
										IF (XACT_STATE()) = -1
											ROLLBACK TRANSACTION  @Savepoint
									END	

								INSERT INTO tblARPostResult (
										strMessage
									  , strTransactionType
									  , strTransactionId
									  , strBatchNumber
									  , intTransactionId
								)
								SELECT strMessage	= 'There''s an on-going posting for other transactions. Please try again later.'
									, [strTransactionType]
									, [strInvoiceNumber]
									, [strBatchId]
									, [intInvoiceId]
								FROM tblARInvoice ARI
								INNER JOIN dbo.fnGetRowsFromDelimitedValues(@param) DV ON DV.[intID] = ARI.[intInvoiceId]
							END

							IF @raiseError = 1
								BEGIN
									RAISERROR('There''s an on-going posting for other transactions. Please try again later.', 11, 1)							
								END
							GOTO Post_Exit
					END
				
				IF EXISTS (SELECT TOP 1 NULL FROM tblARPostingQueue WHERE DATEDIFF(SECOND, dtmPostingdate, @dtmStartWait) <= 60) AND @intQueueCount < 12
					BEGIN
						SET @intQueueCount += 1
						WAITFOR DELAY '00:00:05'
					END
				ELSE IF @intQueueCount < 12
					BEGIN
						SET @intQueueCount = 13

						INSERT INTO tblARPostingQueue (
							intTransactionId
							, strTransactionNumber
							, strBatchId
							, dtmPostingdate
							, intEntityId
							, strTransactionType
						)
						SELECT DISTINCT 
							intTransactionId		= ARI.intInvoiceId
							, strTransactionNumber	= ARI.strInvoiceNumber
							, strBatchId			= @batchIdUsed
							, dtmPostingdate		= @dtmStartWait
							, intEntityId			= ARI.intEntityId
							, strTransactionType	= 'Invoice'
						FROM tblARInvoice ARI
						INNER JOIN dbo.fnGetRowsFromDelimitedValues(@param) DV ON DV.[intID] = ARI.[intInvoiceId]
						WHERE ISNULL(ARI.intLoadId, 0) = 0
					END
			END		
	END
ELSE 
	--IF NONE
	BEGIN	
		--INSERT INVOICES TO POSTING QUEUE
		INSERT INTO tblARPostingQueue (
			intTransactionId
			, strTransactionNumber
			, strBatchId
			, dtmPostingdate
			, intEntityId
			, strTransactionType
		)
		SELECT DISTINCT 
			intTransactionId		= ARI.intInvoiceId
			, strTransactionNumber	= ARI.strInvoiceNumber
			, strBatchId			= @batchIdUsed
			, dtmPostingdate		= @dtmStartWait
			, intEntityId			= ARI.intEntityId
			, strTransactionType	= 'Invoice'
		FROM tblARInvoice ARI
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@param) DV ON DV.[intID] = ARI.[intInvoiceId]
		WHERE ISNULL(ARI.intLoadId, 0) = 0
	END

DECLARE @InvoiceIds AS [InvoiceId]

EXEC [dbo].[uspARInitializeTempTableForPosting]
EXEC [dbo].[uspARPopulateInvoiceDetailForPosting]
     @Param             = @param
    ,@BeginDate         = @beginDate
    ,@EndDate           = @endDate
    ,@BeginTransaction  = @beginTransaction
    ,@EndTransaction    = @endTransaction
    ,@IntegrationLogId  = NULL
    ,@InvoiceIds        = @InvoiceIds
    ,@Post              = @post
    ,@Recap             = @recap
    ,@PostDate          = @PostDate
    ,@BatchId           = @batchIdUsed
    ,@AccrueLicense     = @accrueLicense
    ,@TransType         = @transType
    ,@UserId            = @userId

IF @post = 1 AND @recap = 0
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
         @PostDate    = @PostDate
        ,@UserId      = @userId

--Removed excluded Invoices to post/unpost
IF(@exclude IS NOT NULL)
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT
		);

		INSERT INTO @InvoicesExclude
		SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@exclude)

		DELETE FROM A
		FROM ##ARPostInvoiceHeader A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])

		DELETE FROM A
		FROM ##ARPostInvoiceDetail A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])
	END

--------------------------------------------------------------------------------------------  
-- Validations  
----------------------------------------------------------------------------------------------
EXEC [dbo].[uspARPopulateInvoiceAccountForPosting]
     @Post     = @post

IF @post = 1
    EXEC dbo.[uspARUpdateTransactionAccountOnPost]

EXEC [dbo].[uspARPopulateInvalidPostInvoiceData]
         @Post     = @post
        ,@Recap    = @recap
        ,@PostDate = @PostDate
        ,@BatchId  = @batchIdUsed
		
SELECT @totalInvalid = COUNT(DISTINCT [intInvoiceId]) FROM ##ARInvalidInvoiceData

IF(@totalInvalid > 0)
	BEGIN
		IF @raiseError = 1 AND @recap = 1
			SELECT TOP 1 @ErrorMerssage = strPostingError FROM ##ARInvalidInvoiceData

		--Insert Invalid Post transaction result
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT [strPostingError]
			 , [strTransactionType]
			 , [strInvoiceNumber]
			 , [strBatchId]
			 , [intInvoiceId]
		FROM ##ARInvalidInvoiceData

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE A
		FROM ##ARPostInvoiceHeader A
		INNER JOIN ##ARInvalidInvoiceData B ON A.intInvoiceId = B.intInvoiceId

		DELETE A
		FROM ##ARPostInvoiceDetail A
		INNER JOIN ##ARInvalidInvoiceData B ON A.intInvoiceId = B.intInvoiceId

		DELETE A
		FROM ##ARItemsForCosting A
		INNER JOIN ##ARInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]

		DELETE A
		FROM ##ARItemsForInTransitCosting A
		INNER JOIN ##ARInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]

		DELETE A
		FROM ##ARItemsForStorageCosting A
		INNER JOIN ##ARInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]

		DELETE A
		FROM ##ARItemsForContracts A
		INNER JOIN ##ARInvalidInvoiceData B ON A.[intInvoiceId] = B.[intInvoiceId]		

		DELETE GL
  		FROM ##ARInvoiceGLEntries GL
  		INNER JOIN ##ARInvalidInvoiceData B ON GL.[intTransactionId] = B.[intInvoiceId] AND GL.[strTransactionId] = B.[strInvoiceNumber]

        DELETE FROM ##ARInvalidInvoiceData
	END

SELECT @totalRecords = COUNT([intInvoiceId]) FROM ##ARPostInvoiceHeader
			
IF(@totalInvalid >= 1 AND @totalRecords <= 0)
	BEGIN
		IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @Savepoint
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	

			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT [strPostingError]
				 , [strTransactionType]
				 , [strInvoiceNumber]
				 , [strBatchId]
				 , [intInvoiceId]
			FROM ##ARInvalidInvoiceData
		END

		IF @raiseError = 1
			BEGIN
				IF ISNULL(@ErrorMerssage, '') = ''
					SELECT TOP 1 @ErrorMerssage = [strMessage] FROM tblARPostResult WHERE [strBatchNumber] = @batchIdUsed ORDER BY intId DESC

				RAISERROR(@ErrorMerssage, 11, 1)							
			END				
		GOTO Post_Exit	
	END

BEGIN TRY

	IF @recap = 0
		EXEC [dbo].[uspARPostItemResevation]

	IF @recap = 1
    BEGIN
        EXEC [dbo].[uspARPostInvoiceRecap]
                @Post            = @post
		       ,@Recap           = @recap
		       ,@BatchId         = @batchId
		       ,@PostDate        = @PostDate
		       ,@UserId          = @userId
		       ,@BatchIdUsed     = @batchIdUsed OUT

		DELETE 
		FROM tblARPostingQueue
		WHERE intTransactionId IN (SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@param))

        GOTO Do_Commit
    END

	IF @post = 1 AND @recap = 1
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
			@PostDate        = @PostDate
		   ,@UserId          = @userId

	IF @recap = 0
	BEGIN
		-- Log to inventory sub-ledger	
		EXEC [dbo].[uspARLogInventorySubLedger] @post, @userId
	END

	IF @post = 1
    EXEC [dbo].[uspARPrePostInvoiceIntegration]	

	DECLARE @InvoicesForIntegration Id

	INSERT INTO @InvoicesForIntegration
	SELECT intValue FROM fnCreateTableFromDelimitedValues(@param, ',')

	WHILE EXISTS(SELECT 1 FROM @InvoicesForIntegration)
	BEGIN
		DECLARE @intInvoiceForIntegration INT

		SELECT @intInvoiceForIntegration = intId FROM @InvoicesForIntegration

		EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @intInvoiceForIntegration, @ForDelete = 0, @UserId = @userId, @Post = @post, @Recap = @recap, @FromPosting = 1

		DELETE FROM @InvoicesForIntegration WHERE intId = @intInvoiceForIntegration
	END
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
									
			EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

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
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	
		END						
	IF @raiseError = 1
        RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH
--------------------------------------------------------------------------------------------  
-- GL ENTRIES START
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------
BEGIN TRY
    DECLARE @GLEntries RecapTableType	 

    EXEC [dbo].[uspARGenerateGLEntries]
         @Post     		= @post
	    ,@Recap    		= @recap
        ,@PostDate 		= @PostDate
        ,@BatchId  		= @batchIdUsed
        ,@UserId   		= @userId
	
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
    FROM ##ARInvoiceGLEntries
	WHERE strCode = 'IC'

    DECLARE @InvalidGLEntries AS TABLE
        ([strTransactionId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
        ,[strText]          NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
        ,[intErrorCode]     INT
        ,[strModuleName]    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL)

    INSERT INTO @InvalidGLEntries (
		  [strTransactionId]
        , [strText]
        , [intErrorCode]
        , [strModuleName]
	)
    SELECT DISTINCT
          [strTransactionId]
        , [strText]
        , [intErrorCode]
        , [strModuleName]
    FROM [dbo].[fnGetGLEntriesErrors](@GLEntries, @post)

    DECLARE @invalidGLCount INT
	SET @invalidGLCount = ISNULL((SELECT COUNT(DISTINCT[strTransactionId]) FROM @InvalidGLEntries), 0)
    SET @invalidCount = @invalidCount + @invalidGLCount
	SET @totalRecords = @totalRecords - @invalidGLCount

    INSERT INTO tblARPostResult
		([strMessage]
        ,[strTransactionType]
        ,[strTransactionId]
        ,[strBatchNumber]
        ,[intTransactionId])
    SELECT DISTINCT
         [strError]             = IGLE.[strText]
        ,[strTransactionType]   = GLE.[strTransactionType] 
        ,[strTransactionId]     = IGLE.[strTransactionId]
        ,[strBatchNumber]       = GLE.[strBatchId]
        ,[intTransactionId]     = GLE.[intTransactionId] 
    FROM @InvalidGLEntries IGLE
    LEFT OUTER JOIN @GLEntries GLE ON IGLE.[strTransactionId] = GLE.[strTransactionId]	
	WHERE IGLE.strTransactionId IS NOT NULL

	IF @raiseError = 1 AND ISNULL(@invalidGLCount, 0) > 0
	BEGIN
		SELECT TOP 1 @ErrorMerssage = [strText] FROM @InvalidGLEntries
		RAISERROR(@ErrorMerssage, 11, 1)
	END

    DELETE FROM ##ARInvoiceGLEntries
    WHERE [strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM ##ARPostInvoiceHeader
    WHERE [strInvoiceNumber] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM ##ARPostInvoiceDetail
    WHERE [strInvoiceNumber] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    EXEC [dbo].[uspARBookInvoiceGLEntries]
            @Post    = @post
           ,@BatchId = @batchIdUsed
		   ,@UserId  = @userId
		   ,@raiseError = @raiseError

    EXEC [dbo].[uspARPostInvoiceIntegrations]
            @Post    = @post
           ,@BatchId = @batchIdUsed
		   ,@UserId  = @userId
		   ,@raiseError = @raiseError

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
									
			EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

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
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	
		END						
	IF @raiseError = 1
        RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

SET @successfulCount = @totalRecords
SET @invalidCount = @totalInvalid	

Do_Commit:
IF ISNULL(@raiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END

	RETURN 1;

Do_Rollback:
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

			EXEC uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param								

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
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;