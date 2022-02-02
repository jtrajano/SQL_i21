CREATE PROCEDURE [dbo].[uspARPostInvoiceNew] 
     @BatchId			AS NVARCHAR(40)		= NULL
	,@Post				AS BIT				= 0
	,@Recap				AS BIT				= 0
	,@UserId			AS INT				= NULL
	,@InvoiceIds		AS InvoiceId		READONLY
	,@IntegrationLogId	AS INT
	,@BeginDate			AS DATE				= NULL
	,@EndDate			AS DATE				= NULL
	,@BeginTransaction	AS NVARCHAR(50)		= NULL
	,@EndTransaction	AS NVARCHAR(50)		= NULL
	,@Exclude			AS NVARCHAR(MAX)	= NULL
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@Success			AS BIT				= 0 OUTPUT
	,@TransType			AS NVARCHAR(25)		= 'all'
	,@RaiseError		AS BIT				= 0

 WITH RECOMPILE
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @PostDESC NVARCHAR(10) = 'Posted '

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

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

DECLARE @ErrorMerssage NVARCHAR(MAX)
SET @Success = 1

-- Ensure @Post and @Recap is not NULL  
SET @Post = ISNULL(@Post, 0)
SET @Recap = ISNULL(@Recap, 0)


DECLARE @StartingNumberId INT
SET @StartingNumberId = 3
IF(LEN(RTRIM(LTRIM(ISNULL(@BatchId,'')))) = 0) AND @Recap = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @BatchId OUT
END
SET @BatchIdUsed = @BatchId
 
-- Get Transaction to Post
IF (@TransType IS NULL OR RTRIM(LTRIM(@TransType)) = '')
	SET @TransType = 'all'

DECLARE @dtmStartWait    DATETIME
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

                        IF @RaiseError = 0
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
                                SELECT strMessage    		= 'There''s an on-going posting for other transactions. Please try again later.'
                                    , strTransactionType	= ARI.strTransactionType
                                    , strInvoiceNumber		= ARI.strInvoiceNumber
                                    , strBatchId			= @BatchIdUsed
                                    , intInvoiceId			= ARI.intInvoiceId
                                FROM tblARInvoice ARI
                                INNER JOIN tblARInvoiceIntegrationLogDetail ILD ON ARI.intInvoiceId = ILD.intInvoiceId
								WHERE ILD.intIntegrationLogId = @IntegrationLogId

								UNION ALL

								SELECT strMessage    		= 'There''s an on-going posting for other transactions. Please try again later.'
                                    , strTransactionType	= ARI.strTransactionType
                                    , strInvoiceNumber		= ARI.strInvoiceNumber
                                    , strBatchId			= @BatchIdUsed
                                    , intInvoiceId			= ARI.intInvoiceId
                                FROM tblARInvoice ARI
								INNER JOIN @InvoiceIds ILD ON ARI.intInvoiceId = ILD.intHeaderId
                            END

                            IF @RaiseError = 1
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
                              intTransactionId      = ARI.intInvoiceId
                            , strTransactionNumber  = ARI.strInvoiceNumber
                            , strBatchId            = @BatchIdUsed
                            , dtmPostingdate        = @dtmStartWait
                            , intEntityId           = ARI.intEntityId
                            , strTransactionType    = 'Invoice'
                        FROM tblARInvoice ARI
                        INNER JOIN tblARInvoiceIntegrationLogDetail ILD ON ARI.intInvoiceId = ILD.intInvoiceId
						WHERE ILD.intIntegrationLogId = @IntegrationLogId
						  AND ISNULL(ARI.intLoadId, 0) = 0

						UNION ALL

						SELECT DISTINCT 
                              intTransactionId      = ARI.intInvoiceId
                            , strTransactionNumber  = ARI.strInvoiceNumber
                            , strBatchId            = @BatchIdUsed
                            , dtmPostingdate        = @dtmStartWait
                            , intEntityId           = ARI.intEntityId
                            , strTransactionType    = 'Invoice'
                        FROM tblARInvoice ARI
                        INNER JOIN @InvoiceIds ILD ON ARI.intInvoiceId = ILD.intHeaderId
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
              intTransactionId      = ARI.intInvoiceId
            , strTransactionNumber  = ARI.strInvoiceNumber
            , strBatchId           	= @BatchIdUsed
            , dtmPostingdate        = @dtmStartWait
            , intEntityId           = ARI.intEntityId
            , strTransactionType    = 'Invoice'
        FROM tblARInvoice ARI
		INNER JOIN tblARInvoiceIntegrationLogDetail ILD ON ARI.intInvoiceId = ILD.intInvoiceId
		WHERE ILD.intIntegrationLogId = @IntegrationLogId
		  AND ISNULL(ARI.intLoadId, 0) = 0

		UNION ALL

		SELECT DISTINCT 
			  intTransactionId      = ARI.intInvoiceId
			, strTransactionNumber  = ARI.strInvoiceNumber
			, strBatchId            = @BatchIdUsed
			, dtmPostingdate        = @dtmStartWait
			, intEntityId           = ARI.intEntityId
			, strTransactionType    = 'Invoice'
		FROM tblARInvoice ARI
		INNER JOIN @InvoiceIds ILD ON ARI.intInvoiceId = ILD.intHeaderId
		WHERE ISNULL(ARI.intLoadId, 0) = 0	
    END


EXEC [dbo].[uspARInitializeTempTableForPosting]
EXEC [dbo].[uspARPopulateInvoiceDetailForPosting]
     @Param             = NULL
    ,@BeginDate         = @BeginDate
    ,@EndDate           = @EndDate
    ,@BeginTransaction  = @BeginTransaction
    ,@EndTransaction    = @EndTransaction
    ,@IntegrationLogId  = @IntegrationLogId
    ,@InvoiceIds        = @InvoiceIds
    ,@Post              = @Post
    ,@Recap             = @Recap
    ,@PostDate          = @PostDate
    ,@BatchId           = @BatchIdUsed
    ,@AccrueLicense     = NULL
    ,@TransType         = @TransType
    ,@UserId            = @UserId


IF @Post = 1 AND @Recap = 0
	EXEC [dbo].[uspARProcessSplitOnInvoicePost]
		  @ysnPost	  	= 1
		, @ysnRecap	  	= 0
		, @dtmDatePost	= @PostDate
		, @strBatchId	= @BatchIdUsed
		, @intUserId	= @UserId		

IF @Recap = 0
	EXEC [dbo].[uspARLogInventorySubLedger] 1, @UserId

--Removed excluded Invoices to post/unpost
IF(@Exclude IS NOT NULL)
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT
		);

		INSERT INTO @InvoicesExclude
		SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@Exclude)

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
     @Post     = @Post

IF @Post = 1
    EXEC dbo.[uspARUpdateTransactionAccountOnPost]  	

EXEC [dbo].[uspARPopulateInvalidPostInvoiceData]
	 @Post     = @Post
	,@Recap    = @Recap
	,@PostDate = @PostDate
	,@BatchId  = @BatchIdUsed
		
SELECT @totalInvalid = COUNT(DISTINCT [intInvoiceId]) FROM ##ARInvalidInvoiceData

IF(@totalInvalid > 0)
	BEGIN

        UPDATE ILD
		SET
			 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
			,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
			,ILD.[strPostingMessage]		= PID.[strPostingError]
			,ILD.[strBatchId]				= PID.[strBatchId]
			,ILD.[strPostedTransactionId] = PID.[strInvoiceNumber] 
			,ILD.[ysnSuccess] = 0
		FROM
			tblARInvoiceIntegrationLogDetail ILD
		INNER JOIN
			##ARInvalidInvoiceData PID
				ON ILD.[intInvoiceId] = PID.[intInvoiceId]
		WHERE
			ILD.[intIntegrationLogId] = @IntegrationLogId
			AND ILD.[ysnPost] IS NOT NULL

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
		IF @RaiseError = 0
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

			UPDATE ILD
			SET
				 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
				,ILD.[strPostingMessage]		= PID.[strPostingError]
				,ILD.[strBatchId]				= PID.[strBatchId]
				,ILD.[strPostedTransactionId]   = PID.[strInvoiceNumber] 
			FROM
				tblARInvoiceIntegrationLogDetail ILD
			INNER JOIN
				##ARInvalidInvoiceData PID
					ON ILD.[intInvoiceId] = PID.[intInvoiceId]
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL
		END

		IF @RaiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingMessage] FROM tblARInvoiceIntegrationLogDetail WHERE [intIntegrationLogId] = @IntegrationLogId AND [ysnPost] IS NOT NULL
				RAISERROR(@ErrorMerssage, 11, 1)							
			END				
		GOTO Post_Exit	
	END

	

BEGIN TRY

	IF @Recap = 0
		EXEC [dbo].[uspARPostItemResevation]

	IF @Recap = 1
    BEGIN
        EXEC [dbo].[uspARPostInvoiceRecap]
                @Post            = @Post
		       ,@Recap           = @Recap
		       ,@BatchId         = @BatchId
		       ,@PostDate        = @PostDate
		       ,@UserId          = @UserId
		       ,@BatchIdUsed     = @BatchIdUsed OUT
		
		DELETE 
		FROM tblARPostingQueue
		WHERE intTransactionId IN (SELECT intInvoiceId FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @IntegrationLogId)

        GOTO Do_Commit
    END

	IF @Post = 1 AND @Recap = 1
		EXEC [dbo].[uspARProcessSplitOnInvoicePost]
			  @ysnPost	  	= 1
			, @ysnRecap	  	= 1
			, @dtmDatePost	= @PostDate
			, @strBatchId	= @BatchIdUsed
			, @intUserId	= @UserId
	
	IF @Post = 1
    	EXEC [dbo].[uspARPrePostInvoiceIntegration]	
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @RaiseError = 0
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
									
			UPDATE ILD
			SET
				 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
				,ILD.[strPostingMessage]		= @ErrorMerssage
				,ILD.[strBatchId]				= @BatchId
				,ILD.[strPostedTransactionId]	= ''
			FROM
				tblARInvoiceIntegrationLogDetail ILD
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL

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
	IF @RaiseError = 1
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
         @Post     		= @Post
	    ,@Recap    		= @Recap
        ,@PostDate 		= @PostDate
        ,@BatchId  		= @BatchIdUsed
        ,@UserId   		= @UserId

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

	IF  EXISTS (SELECT TOP  1 NULL FROM @GLEntries)
	BEGIN
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
    FROM [dbo].[fnGetGLEntriesErrors](@GLEntries, @Post)
	END

    DECLARE @invalidGLCount INT
	SET @invalidGLCount = ISNULL((SELECT COUNT(DISTINCT[strTransactionId]) FROM @InvalidGLEntries WHERE [strTransactionId] IS NOT NULL), 0)
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
    FROM
        @InvalidGLEntries IGLE
    LEFT OUTER JOIN
        @GLEntries GLE
        ON IGLE.[strTransactionId] = GLE.[strTransactionId]
					

    DELETE FROM ##ARInvoiceGLEntries
    WHERE
		[strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM ##ARPostInvoiceHeader
    WHERE
		[strInvoiceNumber] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM ##ARPostInvoiceDetail
    WHERE
		[strInvoiceNumber] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    EXEC [dbo].[uspARBookInvoiceGLEntries]
            @Post    = @Post
           ,@BatchId = @BatchIdUsed
		   ,@UserId  = @UserId
		   ,@raiseError = @RaiseError

    EXEC [dbo].[uspARPostInvoiceIntegrations]
	        @Post             = @Post
           ,@BatchId          = @BatchIdUsed
		   ,@UserId           = @UserId
		   ,@IntegrationLogId = @IntegrationLogId
		   ,@raiseError		  = @RaiseError

	UPDATE ILD
	SET
		 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
		,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
		,ILD.[strPostingMessage]		= CASE WHEN ILD.[ysnPost] = 1 THEN 'Transaction successfully posted.' ELSE 'Transaction successfully unposted.' END
		,ILD.[strBatchId]				= @BatchId
		,ILD.[strPostedTransactionId]	= PID.[strInvoiceNumber] 
	FROM
		tblARInvoiceIntegrationLogDetail ILD
	INNER JOIN
		##ARPostInvoiceHeader PID
			ON ILD.[intInvoiceId] = PID.[intInvoiceId]
	WHERE
		ILD.[intIntegrationLogId] = @IntegrationLogId
		AND ILD.[ysnPost] IS NOT NULL

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @RaiseError = 0
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
									
			UPDATE ILD
			SET
				 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
				,ILD.[strPostingMessage]		= @ErrorMerssage
				,ILD.[strBatchId]				= @BatchId
				,ILD.[strPostedTransactionId]	= ''
			FROM
				tblARInvoiceIntegrationLogDetail ILD
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL

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
	IF @RaiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH


Do_Commit:
IF ISNULL(@RaiseError,0) = 0
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
	IF @RaiseError = 0
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

			UPDATE ILD
			SET
				 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
				,ILD.[strPostingMessage]	= @ErrorMerssage
				,ILD.[strBatchId]			= @BatchId
				,ILD.[strPostedTransactionId] = ''
			FROM
				tblARInvoiceIntegrationLogDetail ILD
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL							

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
	IF @RaiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)	
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @Success = 0	
	RETURN 0;