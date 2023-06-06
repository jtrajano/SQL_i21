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
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL	OUTPUT
	,@Success			AS BIT				= 0		OUTPUT
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
DECLARE @strRequestId NVARCHAR(200) = NEWID()

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
IF(LEN(RTRIM(LTRIM(ISNULL(@BatchId,'')))) = 0)
BEGIN
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @BatchId OUT
END
SET @BatchIdUsed = @BatchId
 
-- Get Transaction to Post
IF (@TransType IS NULL OR RTRIM(LTRIM(@TransType)) = '')
	SET @TransType = 'all'

DECLARE @dtmStartWait    DATETIME
SET @dtmStartWait = GETDATE()

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
	,@strSessionId		= @strRequestId

IF @Post = 1 AND @Recap = 0
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
		  @ysnPost	  	= 1
		, @ysnRecap	  	= 0
		, @dtmDatePost	= @PostDate
		, @strBatchId	= @BatchIdUsed
		, @intUserId	= @UserId
		, @strSessionId	= @strRequestId

--Removed excluded Invoices to post/unpost
IF ISNULL(@Exclude, '') <> ''
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT PRIMARY KEY
		);

		INSERT INTO @InvoicesExclude
		SELECT DISTINCT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@Exclude)

		IF EXISTS (SELECT TOP 1 1 FROM @InvoicesExclude)
			BEGIN
				DELETE FROM A
				FROM tblARPostInvoiceHeader A
				INNER JOIN @InvoicesExclude B ON A.[intInvoiceId] = B.[intInvoiceId]
				WHERE A.strSessionId = @strRequestId

				DELETE FROM A
				FROM tblARPostInvoiceDetail A
				INNER JOIN @InvoicesExclude B ON A.[intInvoiceId] = B.[intInvoiceId]
				WHERE A.strSessionId = @strRequestId
			END
	END

--------------------------------------------------------------------------------------------  
-- Validations  
----------------------------------------------------------------------------------------------
EXEC [dbo].[uspARPopulateInvoiceAccountForPosting]
	 @Post			= @Post
	,@strSessionId	= @strRequestId


IF @Post = 1
    EXEC dbo.[uspARUpdateTransactionAccountOnPost] @strSessionId = @strRequestId

EXEC [dbo].[uspARPopulateInvalidPostInvoiceData]
	 @Post     = @Post
	,@Recap    = @Recap
	,@PostDate = @PostDate
	,@BatchId  = @BatchIdUsed
	,@strSessionId 	= @strRequestId
		
SELECT @totalInvalid = COUNT(DISTINCT [intInvoiceId]) FROM tblARPostInvalidInvoiceData WHERE strSessionId = @strRequestId

IF(@totalInvalid > 0)
	BEGIN
		IF @RaiseError = 1
			SELECT TOP 1 @ErrorMerssage = strPostingError FROM tblARPostInvalidInvoiceData WHERE strSessionId = @strRequestId

        UPDATE ILD
		SET  ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
			,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
			,ILD.[strPostingMessage]		= PID.[strPostingError]
			,ILD.[strMessage]				= PID.[strPostingError]
			,ILD.[strBatchId]				= PID.[strBatchId]
			,ILD.[strPostedTransactionId] = PID.[strInvoiceNumber] 
			,ILD.[ysnSuccess] = 0
		FROM tblARInvoiceIntegrationLogDetail ILD
		INNER JOIN tblARPostInvalidInvoiceData PID ON ILD.[intInvoiceId] = PID.[intInvoiceId]
		WHERE ILD.[intIntegrationLogId] = @IntegrationLogId
		  AND ILD.[ysnPost] IS NOT NULL
	      AND PID.strSessionId = @strRequestId

		--DELETE Invalid Transaction From temp table
		DELETE A
		FROM tblARPostInvoiceHeader A
		INNER JOIN tblARPostInvalidInvoiceData B ON A.intInvoiceId = B.intInvoiceId
		WHERE A.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

		DELETE A
		FROM tblARPostInvoiceDetail A
		INNER JOIN tblARPostInvalidInvoiceData B ON A.intInvoiceId = B.intInvoiceId
		WHERE A.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

		DELETE A
		FROM tblARPostItemsForCosting A
		INNER JOIN tblARPostInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]
		WHERE A.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

		DELETE A
		FROM tblARPostItemsForInTransitCosting A
		INNER JOIN tblARPostInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]
		WHERE A.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

		DELETE A
		FROM tblARPostItemsForStorageCosting A
		INNER JOIN tblARPostInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]
		WHERE A.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

		DELETE A
		FROM tblARPostItemsForContracts A
		INNER JOIN tblARPostInvalidInvoiceData B ON A.[intInvoiceId] = B.[intInvoiceId]	
		WHERE A.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

		DELETE GL
  		FROM tblARPostInvoiceGLEntries GL
  		INNER JOIN tblARPostInvalidInvoiceData B ON GL.[intTransactionId] = B.[intInvoiceId] AND GL.[strTransactionId] = B.[strInvoiceNumber]
		WHERE GL.strSessionId = @strRequestId
		AND B.strSessionId = @strRequestId

        DELETE FROM tblARPostInvalidInvoiceData
		WHERE strSessionId = @strRequestId
					
	END

SELECT @totalRecords = COUNT([intInvoiceId]) FROM tblARPostInvoiceHeader WHERE strSessionId = @strRequestId
			
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
				tblARPostInvalidInvoiceData PID
					ON ILD.[intInvoiceId] = PID.[intInvoiceId]
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL
		END

		IF @RaiseError = 1
			BEGIN
				IF ISNULL(@ErrorMerssage, '') = ''
					SELECT TOP 1 @ErrorMerssage = [strPostingMessage] FROM tblARInvoiceIntegrationLogDetail WHERE [intIntegrationLogId] = @IntegrationLogId AND [ysnPost] IS NOT NULL

				RAISERROR(@ErrorMerssage, 11, 1)
			END				
		GOTO Post_Exit	
	END

BEGIN TRY
	IF @Recap = 1
    BEGIN
        EXEC [dbo].[uspARPostInvoiceRecap]
                @Post            = @Post
		       ,@Recap           = @Recap
		       ,@BatchId         = @BatchId
		       ,@PostDate        = @PostDate
		       ,@UserId          = @UserId
		       ,@BatchIdUsed     = @BatchIdUsed OUT
			   ,@strSessionId	 = @strRequestId

		EXEC [dbo].[uspARPostItemReservation] @strSessionId = @strRequestId, @ysnReversePost = 1

        GOTO Do_Commit
    END

	IF @Post = 1 AND @Recap = 1
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
		 @ysnPost	  	= 1
		,@ysnRecap	  	= 1
		,@dtmDatePost	= @PostDate
		,@strBatchId	= @BatchIdUsed
		,@intUserId		= @UserId
		,@strSessionId	= @strRequestId
	
	IF @Post = 1
    EXEC [dbo].[uspARPrePostInvoiceIntegration]	@strSessionId = @strRequestId
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
		,@strSessionId	= @strRequestId

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
    FROM tblARPostInvoiceGLEntries
	WHERE strCode = 'IC'
	AND strSessionId = @strRequestId

    DECLARE @InvalidGLEntries AS TABLE (
         [strTransactionId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
        ,[strText]          NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
        ,[intErrorCode]     INT
        ,[strModuleName]    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	)

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
					
    DELETE PGE
	FROM tblARPostInvoiceGLEntries PGE
	INNER JOIN @InvalidGLEntries GL ON PGE.strTransactionId = GL.strTransactionId
	WHERE strSessionId = @strRequestId

    DELETE PIH 
	FROM tblARPostInvoiceHeader PIH
	INNER JOIN @InvalidGLEntries GL ON PIH.strInvoiceNumber = GL.strTransactionId
	WHERE strSessionId = @strRequestId

    DELETE PID
	FROM tblARPostInvoiceDetail PID
	INNER JOIN @InvalidGLEntries GL ON PID.strInvoiceNumber = GL.strTransactionId
	WHERE strSessionId = @strRequestId

    EXEC [dbo].[uspARBookInvoiceGLEntries]
            @Post			= @Post
           ,@BatchId		= @BatchIdUsed
		   ,@UserId			= @UserId
		   ,@raiseError		= @RaiseError
		   ,@strSessionId 	= @strRequestId

    EXEC [dbo].[uspARPostInvoiceIntegrations]
	        @Post				= @Post
           ,@BatchId			= @BatchIdUsed
		   ,@UserId				= @UserId
		   ,@IntegrationLogId	= @IntegrationLogId
		   ,@raiseError			= @RaiseError
		   ,@strSessionId		= @strRequestId

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
		tblARPostInvoiceHeader PID
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