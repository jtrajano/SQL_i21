CREATE PROCEDURE [dbo].[uspARPostPayment]
	@batchId			AS NVARCHAR(40)		= NULL
	,@post				AS BIT				= 0
	,@recap				AS BIT				= 0
	,@param				AS NVARCHAR(MAX)	= NULL
	,@userId				AS INT				= 1
	,@beginDate			AS DATE				= NULL
	,@endDate			AS DATE				= NULL
	,@beginTransaction	AS NVARCHAR(50)		= NULL
	,@endTransaction		AS NVARCHAR(50)		= NULL
	,@exclude			AS NVARCHAR(MAX)	= NULL
	,@successfulCount	AS INT				= 0 OUTPUT
	,@invalidCount		AS INT				= 0 OUTPUT
	,@success			AS BIT				= 0 OUTPUT
	,@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	,@transType			AS NVARCHAR(25)		= 'all'
	,@raiseError		AS BIT				= 0
	,@bankAccountId	AS INT				= NULL
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

IF @raiseError = 1
	SET XACT_ABORT ON
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   

DECLARE @ZeroDecimal		DECIMAL(18,6)
		,@InitTranCount		INT
		,@CurrentTranCount	INT
		,@Savepoint			NVARCHAR(32)
		,@CurrentSavepoint	NVARCHAR(32)

SET @ZeroDecimal = 0.000000
SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostPayment' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
DECLARE @CODE NVARCHAR(25) = 'AR', @DiscountAccount        INT
SET @DiscountAccount = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '


IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
 
DECLARE @ARReceivablePostData AS [dbo].[ReceivePaymentPostingTable]
DECLARE @PaymentIds AS [dbo].[Id]

DECLARE @ARReceivableInvalidData TABLE (
     [intTransactionId]         INT             NOT NULL
    ,[strTransactionId]         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]       NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[intTransactionDetailId]   INT             NULL
    ,[strBatchId]               NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[strError]                 NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
);

DECLARE @AROverpayment AS [dbo].[Id]
DECLARE @ARPrepayment  AS [dbo].[Id]

DECLARE @ZeroPayment AS [dbo].[ReceivePaymentPostingTable]

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'


DECLARE  @DefaultCurrencyId		INT		
DECLARE @totalInvalid INT
DECLARE @totalRecords INT
DECLARE @ErrorMerssage NVARCHAR(MAX)
		
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)

DECLARE @UserEntityID			INT
	,@AllowOtherUserToPost		BIT

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @userId),@userId)

IF(@batchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @batchId OUT
	END

SET @batchIdUsed = @batchId	

SET @recapId = '1'
SET @success = 1

-- Ensure @post and @recap is not NULL  
SET @post = ISNULL(@post, 0)
SET @recap = ISNULL(@recap, 0)  
 
-- Get Transaction to Post
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

IF (@param IS NOT NULL) 
	BEGIN
		IF(@param = 'all')
			BEGIN
				DELETE FROM @PaymentIds
				INSERT INTO @PaymentIds
				SELECT [intPaymentId] FROM tblARPayment WHERE ysnPosted = 0
				
				INSERT INTO @ARReceivablePostData 
				SELECT *
				FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId)
			END
		ELSE
			BEGIN
				DELETE FROM @PaymentIds
				INSERT INTO @PaymentIds
				SELECT intID FROM fnGetRowsFromDelimitedValues(@param)
				
				INSERT INTO @ARReceivablePostData 
				SELECT *
				FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId)				
			END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		DELETE FROM @PaymentIds
		INSERT INTO @PaymentIds
		SELECT [intPaymentId] FROM tblARPayment WHERE dtmDatePaid BETWEEN @beginDate AND @endDate AND ysnPosted = 0
				
		INSERT INTO @ARReceivablePostData 
		SELECT *
		FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId)
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		DELETE FROM @PaymentIds
		INSERT INTO @PaymentIds
		SELECT [intPaymentId] FROM tblARPayment WHERE intPaymentId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
				
		INSERT INTO @ARReceivablePostData 
		SELECT *
		FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId)
	END

--Removed excluded payments to post/unpost
IF(@exclude IS NOT NULL)
	BEGIN
		DECLARE @PaymentsExclude TABLE  (
			intPaymentId INT
		);

		INSERT INTO @PaymentsExclude
		SELECT intID FROM fnGetRowsFromDelimitedValues(@exclude)


		DELETE FROM A
		FROM @ARReceivablePostData A
		WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.[intTransactionId] = B.intPaymentId)
	END
	
	
---- Get the next batch number
--IF(@batchId IS NULL AND @param IS NOT NULL AND @param <> 'all')
--	BEGIN
--		SELECT TOP 1
--			@batchId = GL.strBatchId
--		FROM
--			tblGLDetailRecap GL
--		INNER JOIN 
--			@ARReceivablePostData I
--				ON GL.intTransactionId = I.intPaymentId
--				AND GL.strTransactionId = I.strTransactionId
--		WHERE
--			GL.strTransactionType = @SCREEN_NAME
--			AND	GL.strModuleName = @MODULE_NAME
--	END
	


--------------------------------------------------------------------------------------------  
-- Validations  
--------------------------------------------------------------------------------------------  
--IF @recap = 0
	BEGIN
	
		-- Zero Payment
		INSERT INTO @ZeroPayment
		SELECT * 
		FROM @ARReceivablePostData
		WHERE
			[intTransactionDetailId] IN (
										SELECT
											MIN(P.[intTransactionDetailId])
										FROM
											@ARReceivablePostData P
										WHERE
											P.[dblAmountPaid] = 0
											AND P.[intTransactionDetailId] IS NOT NULL			
										GROUP BY
											P.[intTransactionId], P.[strTransactionId], P.[intWriteOffAccountId], P.[intEntityId], P.[intInterestAccount], P.[intDiscountAccount]
										HAVING
											SUM(P.[dblPayment]) = 0
											AND SUM(P.[dblDiscount]) = 0			
										)
		
		
		
		--Validation
		INSERT INTO @ARReceivableInvalidData
		SELECT * FROM [dbo].[fnARGetInvalidPaymentsForPosting](@ARReceivablePostData, @post, @recap)

		--POST VALIDATIONS
		IF @post = 1
			BEGIN

				DELETE FROM @PaymentIds
				INSERT INTO @PaymentIds
				SELECT DISTINCT  [intTransactionId]
				 FROM @ARReceivablePostData

				--+overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.[intTransactionId]				
				WHERE
					(A.dblAmountPaid) > (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
					AND EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)	
					
				--+prepayment
				INSERT INTO
					@ARPrepayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.[intTransactionId]				
				WHERE
					(A.dblAmountPaid) <> 0
					AND ISNULL((SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId), 0) = 0	
					AND NOT EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)											

			END

		--UNPOSTING VALIDATIONS
		IF @post = 0 And @recap = 0
			BEGIN							
								
				---overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.[intTransactionId]
				INNER JOIN
					tblARInvoice I
						ON A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId 				
				WHERE
					I.strTransactionType = 'Overpayment'
					
				---prepayment
				INSERT INTO
					@ARPrepayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.[intTransactionId]
				INNER JOIN
					tblARInvoice I
						ON A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId 				
				WHERE
					I.strTransactionType = 'Customer Prepayment'					
					
			END
		
	--Get all invalid		
		SET @totalInvalid = (SELECT COUNT(DISTINCT [intTransactionId]) FROM @ARReceivableInvalidData)

		IF(@totalInvalid > 0)
			BEGIN

				INSERT INTO 
					tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					 [strError]
					,[strTransactionType]
					,[strTransactionId]
					,[strBatchId]
					,[intTransactionId]
				FROM
					@ARReceivableInvalidData

				SET @invalidCount = @totalInvalid

				--DELETE Invalid Transaction From temp table
				DELETE 
					@ARReceivablePostData
				FROM
					@ARReceivablePostData A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.[intTransactionId] = I.[intTransactionId]
												
						
				DELETE 
					A
				FROM
					@AROverpayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.[intId] = I.intTransactionId	
						
				DELETE 
					A
				FROM
					@ARPrepayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.[intId] = I.intTransactionId
						
			IF @raiseError = 1
				BEGIN
					SELECT TOP 1 @ErrorMerssage = strError FROM @ARReceivableInvalidData
					RAISERROR(@ErrorMerssage, 11, 1)							
					GOTO Post_Exit
				END													

			END

	--Get all to be post record
		SET @totalRecords = (SELECT COUNT(DISTINCT [intTransactionId]) FROM @ARReceivablePostData)

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
				END

				IF @raiseError = 1
					BEGIN
						SELECT TOP 1 @ErrorMerssage = strError FROM @ARReceivableInvalidData
						RAISERROR(@ErrorMerssage, 11, 1)							
						GOTO Post_Exit
					END	
				GOTO Post_Exit
			END			

	END
	
	IF (SELECT COUNT(1) FROM @ARReceivablePostData) > 1 AND @post = 1
	BEGIN
		DECLARE @DiscouuntedInvoices TABLE (
				intInvoiceId int PRIMARY KEY,
				UNIQUE (intInvoiceId)
			);

		INSERT INTO @DiscouuntedInvoices(intInvoiceId)
		SELECT DISTINCT
			PD.intInvoiceId 
		FROM
			tblARPaymentDetail PD 
		INNER JOIN
			@ARReceivablePostData P
				ON PD.intPaymentId = P.[intTransactionId]
		WHERE
			PD.dblPayment <> 0
			AND (ISNULL(PD.dblDiscount,0) <> 0 OR ISNULL(PD.dblInterest,0) <> 0)
		GROUP BY
			PD.intInvoiceId
		HAVING
			COUNT(PD.intInvoiceId) > 1
			
		WHILE(EXISTS(SELECT TOP 1 NULL FROM @DiscouuntedInvoices))
		BEGIN
			DECLARE @DiscountedInvID INT
					,@InvoiceDiscount NUMERIC(18,6) = 0
					,@InvoiceInterest NUMERIC(18,6) = 0
					,@DicountedInvoiceAmountDue NUMERIC(18,6) = 0
					,@DicountedInvoicePayment NUMERIC(18,6) = 0	
					
			SELECT TOP 1 @DiscountedInvID = intInvoiceId FROM @DiscouuntedInvoices
			
			DECLARE @PaymentsWithDiscount TABLE(
						intPaymentId INT,
						intPaymentDetailId INT,
						intInvoiceId INT,
						dblInvoiceTotal NUMERIC(18,6),
						dblAmountDue NUMERIC(18,6),
						dblPayment NUMERIC(18,6),
						dblDiscount  NUMERIC(18,6),
						dblInterest NUMERIC(18,6)
					);
					
			INSERT INTO @PaymentsWithDiscount(intPaymentId, intPaymentDetailId, intInvoiceId, dblInvoiceTotal, dblAmountDue, dblPayment, dblDiscount, dblInterest)
			SELECT
				 A.intPaymentId
				,B.intPaymentDetailId
				,C.intInvoiceId
				,C.dblInvoiceTotal
				,C.dblAmountDue
				,B.dblPayment
				,B.dblDiscount
				,B.dblInterest 
			FROM
				tblARPayment A
			INNER JOIN
				tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
			INNER JOIN
				tblARInvoice C
					ON B.intInvoiceId = C.intInvoiceId
			INNER JOIN
				@ARReceivablePostData P
					ON A.intPaymentId = P.[intTransactionId]
			WHERE
				C.intInvoiceId = @DiscountedInvID
			ORDER BY
				P.[intTransactionId]
				
			WHILE EXISTS(SELECT TOP 1 NULL FROM @PaymentsWithDiscount)
			BEGIN
				DECLARE @DiscountepPaymetID INT
						,@DiscountepPaymetDetailID INT
				SELECT TOP 1 
					@DiscountepPaymetID = intPaymentId
					,@DiscountepPaymetDetailID = intPaymentDetailId
					,@DicountedInvoiceAmountDue = dblAmountDue
					,@InvoiceDiscount = @InvoiceDiscount + dblDiscount
					,@InvoiceInterest = @InvoiceInterest + dblInterest
					,@DicountedInvoicePayment = @DicountedInvoicePayment + dblPayment 
				FROM
					@PaymentsWithDiscount
				ORDER BY intPaymentId
				
				IF @DicountedInvoiceAmountDue <> ((@DicountedInvoicePayment - @InvoiceInterest) + @InvoiceDiscount)
				BEGIN
					UPDATE tblARPaymentDetail
					SET
						 dblDiscount = 0.00
						,dblBaseDiscount = 0.00
						,dblInterest = 0.00
						,dblBaseInterest = 0.00
					WHERE
						intPaymentDetailId = @DiscountepPaymetDetailID
						
					SET @InvoiceDiscount = 0										
					SET @InvoiceInterest = 0										
				END									
				SET @DicountedInvoiceAmountDue = @DicountedInvoiceAmountDue - ((@DicountedInvoicePayment - @InvoiceInterest) + @InvoiceDiscount)
				DELETE FROM @PaymentsWithDiscount WHERE intPaymentId = @DiscountepPaymetID	
			END 						
			DELETE FROM @DiscouuntedInvoices WHERE intInvoiceId = @DiscountedInvID							
		END
	END
		

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
-- Create a unique transaction name for recap. 
DECLARE @TransactionName AS VARCHAR(500) = 'Payment Transaction' + CAST(NEWID() AS NVARCHAR(100));
if @recap = 1 AND @raiseError = 0
	SAVE TRAN @TransactionName	

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @post = 1  
	BEGIN
		---- Delete zero payment temporarily
		--DELETE FROM A
		--FROM @ARReceivablePostData A
		--WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.intPaymentId = B.intPaymentId)
		
	--BEGIN TRY

	--IF (@bankAccountId IS NULL)
	--		BEGIN
	--		UPDATE 
	--			tblARPayment
	--		SET 
	--			 intAccountId			= C.intUndepositedFundsId
	--			,intWriteOffAccountId	= CASE WHEN ISNULL(P.intWriteOffAccountId,0) = 0 THEN @WriteOffAccount ELSE P.intWriteOffAccountId END
	--		FROM
	--			tblARPayment P								
	--		INNER JOIN 
	--			tblSMCompanyLocation C
	--				ON P.intLocationId = C.intCompanyLocationId
	--		WHERE
	--			P.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
	--			AND ISNULL(C.intUndepositedFundsId,0) <> 0
	--			AND ISNULL(P.strPaymentMethod, '') <> 'CF Invoice'
	--		END
	--	ELSE
	--		BEGIN
	--		DECLARE @intNewAccountID INT 
	--		SELECT @intNewAccountID = intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = @bankAccountId

	--			UPDATE 
	--				tblARPayment
	--			SET 
	--				 intAccountId			= @intNewAccountID
	--				,intWriteOffAccountId	= CASE WHEN ISNULL(intWriteOffAccountId,0) = 0 THEN @WriteOffAccount ELSE intWriteOffAccountId END
	--			FROM
	--				tblARPayment												
	--			WHERE
	--				intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)					
	--		END
					
	--END TRY
	--BEGIN CATCH	
	--	SELECT @ErrorMerssage = ERROR_MESSAGE()										
	--	GOTO Do_Rollback
	--END CATCH
		
	BEGIN TRY
			  		 
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
		FROM [dbo].[fnARGenerateGLEntriesForPayments] (@ARReceivablePostData, @AROverpayment, @ARPrepayment)
									
		
			
	END TRY
	BEGIN CATCH	
		SELECT @ErrorMerssage = ERROR_MESSAGE()										
		GOTO Do_Rollback
	END CATCH
					
			
	END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @post = 0   
	BEGIN   								
		BEGIN TRY 
			INSERT INTO @GLEntries(
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
			)
			SELECT	
				 GL.dtmDate
				,@batchId
				,GL.intAccountId
				,dblDebit						= GL.dblCredit
				,dblCredit						= GL.dblDebit
				,dblDebitUnit					= GL.dblCreditUnit
				,dblCreditUnit					= GL.dblDebitUnit				
				,GL.strDescription
				,GL.strCode
				,GL.strReference
				,GL.intCurrencyId
				,GL.dblExchangeRate
				,dtmDateEntered					= @PostDate
				,GL.dtmTransactionDate
				,strJournalLineDescription		= REPLACE(GL.strJournalLineDescription, @POSTDESC, 'Unposted ')
				,GL.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @userId
				,intEntityId					= @UserEntityID
				,GL.strTransactionId
				,GL.intTransactionId
				,GL.strTransactionType
				,GL.strTransactionForm
				,GL.strModuleName
				,GL.intConcurrencyId
				,[dblDebitForeign]				= GL.dblCreditForeign
				,[dblDebitReport]				= GL.dblCreditReport
				,[dblCreditForeign]				= GL.dblDebitForeign
				,[dblCreditReport]				= GL.dblDebitReport
				,[dblReportingRate]				= GL.dblReportingRate 
				,[dblForeignRate]				= GL.dblForeignRate 
				,[strRateType]					= ''
			FROM
				tblGLDetail GL
			INNER JOIN (
				SELECT intTransactionId
					 , strTransactionId
				FROM @ARReceivablePostData P
				GROUP BY intTransactionId, strTransactionId
			) P ON GL.intTransactionId = P.[intTransactionId]  
					AND GL.strTransactionId = P.strTransactionId
			WHERE
				GL.ysnIsUnposted = 0
			ORDER BY
				GL.intGLDetailId		
						
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH		
	END   

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1.	Store all the GL entries in a holding table. It will be used later as data  
--		for the recap screen.
--
-- 2.	Rollback the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 1
	BEGIN
		IF @raiseError = 0
			ROLLBACK TRAN @TransactionName 

		DELETE GLDR  
		FROM 
			@ARReceivablePostData B  
		INNER JOIN 
			dbo.tblGLPostRecap GLDR 
				ON (B.strTransactionId = GLDR.strTransactionId OR B.[intTransactionId] = GLDR.intTransactionId)  
				AND GLDR.strCode = @CODE  			   
		   
	BEGIN TRY	
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
			,[strDescription]					= B.strDescription
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value
			,Credit.Value
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblDebitForeign] END
			,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblCreditForeign] END 		
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,[dblExchangeRate]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.dblForeignRate END 
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,[strRateType]						= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN NULL ELSE A.[strRateType]	 END 
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit
		--EXEC uspGLPostRecap @GLEntries, @UserEntityID 
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

				EXEC uspARInsertPostResult @batchId, 'Receive Payment', @ErrorMerssage, @param						

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
	END
ELSE
	BEGIN
		DECLARE @tmpBatchId NVARCHAR(100)
		SELECT @tmpBatchId = [strBatchId] 
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit

		UPDATE tblGLPostRecap 
		SET 
			dblCreditForeign = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN 0.00 ELSE dblDebitForeign END
			, dblDebitForeign = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN 0.00 ELSE dblDebitForeign END
			, dblExchangeRate = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN 0.00 ELSE dblExchangeRate END
			, strRateType = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN NULL ELSE strRateType END
		WHERE 			
			tblGLPostRecap.strBatchId = @tmpBatchId

	END	 

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 0
	BEGIN
		BEGIN TRY 
			--SELECT * FROM @GLEntries
			IF @post = 1
			BEGIN
				DECLARE @DetailId INT
				SELECT TOP 1
					@DetailId = GE.intJournalLineNo
				FROM
					@GLEntries GE
				INNER JOIN
					tblARPaymentDetail ARPD
						ON GE.intJournalLineNo = ARPD.intPaymentDetailId
						AND GE.intTransactionId = ARPD.intPaymentId
				WHERE				
					GE.intAccountId = @DiscountAccount
					AND ARPD.dblDiscount = @ZeroDecimal
					AND ARPD.dblBaseDiscount = @ZeroDecimal

				IF ISNULL(@DetailId,0) <> 0
				BEGIN
					SELECT @ErrorMerssage = 'Invalid Discount Entry(Record - ' + CAST(@DetailId AS NVARCHAR(30)) + ')!'								
					GOTO Do_Rollback
				END
			END
			
			DECLARE @InvalidGLEntries AS TABLE
				(strTransactionId	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
				,strText			NVARCHAR(150)  COLLATE Latin1_General_CI_AS NULL
				,intErrorCode		INT
				,strModuleName		NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL)

			INSERT INTO @InvalidGLEntries
				(strTransactionId
				,strText
				,intErrorCode
				,strModuleName)
			SELECT DISTINCT
				strTransactionId
				,strText
				,intErrorCode
				,strModuleName
			FROM
				[dbo].[fnGetGLEntriesErrors](@GLEntries)

			SET @invalidCount = @invalidCount + ISNULL((SELECT COUNT(strTransactionId) FROM @InvalidGLEntries), 0)

			INSERT INTO 
					tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT DISTINCT
					 strError				= IGLE.strText
					,strTransactionType		= GLE.strTransactionType 
					,strTransactionId		= IGLE.strTransactionId
					,strBatchNumber			= GLE.strBatchId
					,intTransactionId		= GLE.intTransactionId 
				FROM
					@InvalidGLEntries IGLE
				LEFT OUTER JOIN
					@GLEntries GLE
						ON IGLE.strTransactionId = GLE.strTransactionId
					

			DELETE FROM @GLEntries
			WHERE
				strTransactionId IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

			DELETE FROM @ARReceivablePostData
			WHERE
				strTransactionId IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

			EXEC dbo.uspGLBookEntries @GLEntries, @post
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH	
		 
		BEGIN TRY 
		
		DECLARE @arPaymentIds AS Id --parameter for updating AP transactions
		INSERT INTO @arPaymentIds
		SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData
		
		IF @post = 0
			BEGIN
			
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT * FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE [intTransactionId] = Z.[intTransactionId])

			--update payment record
            UPDATE A
                SET A.intCurrentStatus = 5
            FROM tblARPayment A 
            WHERE intPaymentId IN (SELECT [intPaymentId] FROM @ARReceivablePostData)


			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblPayment = ISNULL(tblARInvoice.dblPayment,0.00) - P.dblPayment 
				,tblARInvoice.dblBasePayment = ISNULL(tblARInvoice.dblBasePayment,0.00) - P.dblBasePayment 
				,tblARInvoice.dblDiscount = ISNULL(tblARInvoice.dblDiscount,0.00) - P.dblDiscount			
				,tblARInvoice.dblBaseDiscount = ISNULL(tblARInvoice.dblBaseDiscount,0.00) - P.dblBaseDiscount			
				,tblARInvoice.dblInterest = ISNULL(tblARInvoice.dblInterest,0.00) - P.dblInterest				
				,tblARInvoice.dblBaseInterest = ISNULL(tblARInvoice.dblBaseInterest,0.00) - P.dblBaseInterest				
			FROM
				(
					SELECT 
						SUM(A.dblPayment * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblPayment
						, SUM(A.dblBasePayment * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblBasePayment
						, SUM(A.dblDiscount) dblDiscount
						, SUM(A.dblBaseDiscount) dblBaseDiscount
						, SUM(A.dblInterest) dblInterest						
						, SUM(A.dblBaseInterest) dblBaseInterest						
						,A.intInvoiceId 
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.intPaymentId = B.intPaymentId						
					INNER JOIN tblARInvoice C
						ON A.intInvoiceId = C.intInvoiceId
					WHERE
						A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
					GROUP BY
						A.intInvoiceId
				) P
			WHERE
				tblARInvoice.intInvoiceId = P.intInvoiceId
				
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblAmountDue = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
												THEN 
													CASE WHEN C.strTransactionType = 'Credit Memo'
															THEN ISNULL(C.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal)))
															ELSE (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))) - ISNULL(C.dblProvisionalAmount, @ZeroDecimal)
													END
												ELSE ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))
											END				
				,tblARInvoice.dblBaseAmountDue = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
												THEN 
													CASE WHEN C.strTransactionType = 'Credit Memo'
															THEN ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal)))
															ELSE (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))) - ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal)
													END
												ELSE ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))
											END	
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
			
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.ysnPaid = 0
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId				
			WHERE
				A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
								
			UPDATE 
				tblARPaymentDetail
			SET 
				dblAmountDue = ((((ISNULL(C.dblAmountDue, 0.00) + ISNULL(A.dblInterest,0.00)) - ISNULL(A.dblDiscount,0.00)) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) - A.dblPayment)
				,dblBaseAmountDue = ((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(A.dblBaseInterest,0.00)) - ISNULL(A.dblBaseDiscount,0.00)) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) - A.dblBasePayment)
			FROM
				tblARPaymentDetail A
			INNER JOIN
				tblARPayment B
					ON A.intPaymentId = B.intPaymentId
					AND A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
			INNER JOIN 
				tblARInvoice C
					ON A.intInvoiceId = C.intInvoiceId
			WHERE
				ISNULL(B.[ysnInvoicePrepayment],0) = 0							
					
			UPDATE tblGLDetail
				SET tblGLDetail.ysnIsUnposted = 1
			FROM tblARPayment A
				INNER JOIN tblGLDetail B
					ON A.intPaymentId = B.intTransactionId
			WHERE B.[strTransactionId] IN (SELECT strRecordNumber FROM tblARPayment WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData))					
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARReceivablePostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.[intTransactionId] = B.[intTransactionId])						
					
			-- Creating the temp table:
			DECLARE @isSuccessful BIT
			CREATE TABLE #tmpCMBankTransaction (strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,UNIQUE (strTransactionId))

			INSERT INTO #tmpCMBankTransaction
			SELECT DISTINCT strRecordNumber FROM tblARPayment A
			INNER JOIN @ARReceivablePostData B ON A.intPaymentId = B.[intTransactionId]

			-- Calling the stored procedure
			DECLARE @ReverseDate AS DATETIME
			SET @ReverseDate = @PostDate
			EXEC uspCMBankTransactionReversal @userId, @ReverseDate, @isSuccessful OUTPUT
			
			--update payment record based on record from tblCMBankTransaction
			UPDATE tblARPayment
				SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
			FROM tblARPayment A 
				INNER JOIN tblCMBankTransaction B
					ON A.strRecordNumber = B.strTransactionId
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)	
			
			--DELETE IF NOT CHECK PAYMENT AND DOESN'T HAVE CHECK NUMBER
			DELETE FROM tblCMBankTransaction
			WHERE strTransactionId IN (
			SELECT strRecordNumber 
			FROM tblARPayment
				INNER JOIN tblSMPaymentMethod ON tblARPayment.intPaymentMethodId = tblSMPaymentMethod.intPaymentMethodID
			 WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData) 
			AND tblSMPaymentMethod.strPaymentMethod != 'Check' 
			OR (ISNULL(tblARPayment.strPaymentInfo,'') = '' AND tblSMPaymentMethod.strPaymentMethod = 'Check')
			)
			
			DELETE FROM tblCMUndepositedFund
			WHERE
				intUndepositedFundId IN 
				(
				SELECT 
					B.intUndepositedFundId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.[intTransactionId]
				INNER JOIN
					tblCMUndepositedFund B 
						ON A.intPaymentId = B.intSourceTransactionId 
						AND A.strRecordNumber = B.strSourceTransactionId
				LEFT OUTER JOIN
					tblCMBankTransactionDetail TD
						ON B.intUndepositedFundId = TD.intUndepositedFundId
				WHERE 
					B.strSourceSystem = 'AR'
					AND TD.intUndepositedFundId IS NULL
				)
				
			
			----VOID IF CHECK PAYMENT
			--UPDATE tblCMBankTransaction
			--SET ysnCheckVoid = 1,
			--	ysnPosted = 0
			--WHERE strTransactionId IN (
			--	SELECT strRecordNumber 
			--	FROM tblARPayment
			--	 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData) 
			--)							
				
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT * FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE [intTransactionId] = Z.[intTransactionId])			
			
			--update payment record
			UPDATE A
				SET A.ysnPosted = 0
			FROM tblARPayment A 
			WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)

			--Insert Successfully unposted transactions.
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 
				@UnpostSuccessfulMsg,
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
			WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
			
			--DELETE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN			
					DECLARE @PaymentIdToDelete int		
					SELECT TOP 1 @PaymentIdToDelete = [intId] FROM @AROverpayment
					
					EXEC [dbo].[uspARDeleteOverPayment] @PaymentIdToDelete, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE [intId] = @PaymentIdToDelete
				END	
				
			--DELETE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN			
					DECLARE @PaymentIdToDeletePre int		
					SELECT TOP 1 @PaymentIdToDeletePre = [intId] FROM @ARPrepayment
					
					EXEC [dbo].[uspARDeletePrePayment] @PaymentIdToDeletePre, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE [intId] = @PaymentIdToDeletePre
					
				END
				
			UPDATE 
				tblARPayment
			SET 
				intAccountId = NULL			
			WHERE
				intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)		

			EXEC uspAPUpdateBillPaymentFromAR @paymentIds = @arPaymentIds, @post = 0

			--update payment record
            UPDATE A
                SET A.intCurrentStatus = NULL
            FROM tblARPayment A 
            WHERE intPaymentId IN (SELECT [intPaymentId] FROM @ARReceivablePostData)

			END
		ELSE
			BEGIN
			
			--CREATE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN
					DECLARE @PaymentIdToAdd int
					SELECT TOP 1 @PaymentIdToAdd = [intId] FROM @AROverpayment
					
					EXEC [dbo].[uspARCreateOverPayment] @PaymentIdToAdd, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE [intId] = @PaymentIdToAdd
				END
				
			--CREATE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN
					DECLARE @PaymentIdToAddPre int
					SELECT TOP 1 @PaymentIdToAddPre = [intId] FROM @ARPrepayment
					
					EXEC [dbo].[uspARCreatePrePayment] @PaymentIdToAddPre, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE [intId] = @PaymentIdToAddPre
				END				

			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT * FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE [intTransactionId] = Z.[intTransactionId])		

			-- Delete Invoice with Zero Payment
			DELETE FROM tblARPaymentDetail
			WHERE
				dblPayment = 0
				AND dblDiscount = 0
				AND (
					intInvoiceId IN (SELECT intInvoiceId FROM @ARReceivablePostData)
					OR
					intBillId IN (SELECT intBillId FROM @ARReceivablePostData)
					)

			-- Update the posted flag in the transaction table
			UPDATE ARP
			SET
				 ARP.[ysnPosted]			= 1
				,ARP.[intAccountId]			= P.[intUndepositedFundsId]
				,ARP.[intWriteOffAccountId]	= P.[intWriteOffAccountId]
			FROM
				tblARPayment ARP
			INNER JOIN
				@ARReceivablePostData P
					ON ARP.[intPaymentId] = P.[intTransactionId] 
					AND P.[intTransactionDetailId] IS NULL

			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblPayment = ISNULL(tblARInvoice.dblPayment,0.00) + P.dblPayment 
				,tblARInvoice.dblBasePayment = ISNULL(tblARInvoice.dblBasePayment,0.00) + P.dblBasePayment 
				,tblARInvoice.dblDiscount = ISNULL(tblARInvoice.dblDiscount,0.00) + P.dblDiscount				
				,tblARInvoice.dblBaseDiscount = ISNULL(tblARInvoice.dblBaseDiscount,0.00) + P.dblBaseDiscount				
				,tblARInvoice.dblInterest = ISNULL(tblARInvoice.dblInterest,0.00) + P.dblInterest
				,tblARInvoice.dblBaseInterest = ISNULL(tblARInvoice.dblBaseInterest,0.00) + P.dblBaseInterest
			FROM
				(
					SELECT 
						SUM(A.dblPayment * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblPayment
						,SUM(A.dblBasePayment * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblBasePayment
						,SUM(A.dblDiscount) dblDiscount
						,SUM(A.dblBaseDiscount) dblBaseDiscount
						,SUM(A.dblInterest) dblInterest
						,SUM(A.dblBaseInterest) dblBaseInterest
						,A.intInvoiceId 
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.intPaymentId = B.intPaymentId						
					INNER JOIN tblARInvoice C
						ON A.intInvoiceId = C.intInvoiceId
					WHERE
						A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
						AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId WHERE ARID.intPrepayTypeId > 0 AND ARID.intInvoiceId = C.intInvoiceId AND ARI.intPaymentId = A.intPaymentId)						
					GROUP BY
						A.intInvoiceId
				) P
			WHERE
				tblARInvoice.intInvoiceId = P.intInvoiceId				
				
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblAmountDue = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
												THEN 
													CASE WHEN C.strTransactionType = 'Credit Memo'
															THEN ISNULL(C.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal)))
															ELSE (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))) - ISNULL(C.dblProvisionalAmount, @ZeroDecimal)
													END
												ELSE ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))
											END				
				,tblARInvoice.dblBaseAmountDue = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
												THEN 
													CASE WHEN C.strTransactionType = 'Credit Memo'
															THEN ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal)))
															ELSE (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))) - ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal)
													END
												ELSE ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))
											END	
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
				AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId WHERE ARID.intPrepayTypeId > 0 AND ARID.intInvoiceId = C.intInvoiceId AND ARI.intPaymentId = A.intPaymentId)						
					
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.ysnPaid = (CASE WHEN (C.dblAmountDue) = 0 THEN 1 ELSE 0 END)
				--,tblARInvoice.dtmPostDate = (CASE WHEN (C.dblAmountDue) = 0 THEN @PostDate ELSE C.dtmPostDate END)
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)	
				AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId WHERE ARID.intPrepayTypeId > 0 AND ARID.intInvoiceId = C.intInvoiceId AND ARI.intPaymentId = A.intPaymentId)						
								

			--UPDATE 
			--	tblARPaymentDetail
			--SET 
			--	dblAmountDue = ISNULL(C.dblAmountDue, 0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)-- ISNULL(A.dblDiscount,0.00)) - A.dblPayment							
			--	,dblBaseAmountDue = ISNULL(C.dblBaseAmountDue, 0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)-- ISNULL(A.dblDiscount,0.00)) - A.dblPayment							
			--FROM
			--	tblARPaymentDetail A
			--INNER JOIN
			--	tblARPayment B
			--		ON A.intPaymentId = B.intPaymentId
			--		AND A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
			--INNER JOIN 
			--	tblARInvoice C
			--		ON A.intInvoiceId = C.intInvoiceId
			--WHERE
			--	ISNULL(B.[ysnInvoicePrepayment],0) = 0					
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARReceivablePostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.[intTransactionId] = B.[intTransactionId])						

			----Insert to bank transaction
			--INSERT INTO tblCMBankTransaction(
			--	strTransactionId,
			--	intBankTransactionTypeId,
			--	intBankAccountId,
			--	intCurrencyId,
			--	dblExchangeRate,
			--	dtmDate,
			--	strPayee,
			--	intPayeeId,
			--	strAddress,
			--	strZipCode,
			--	strCity,
			--	strState,
			--	strCountry,
			--	dblAmount,
			--	strAmountInWords,
			--	strMemo,
			--	strReferenceNo,
			--	ysnCheckToBePrinted,
			--	ysnCheckVoid,
			--	ysnPosted,
			--	strLink,
			--	ysnClr,
			--	dtmDateReconciled,
			--	intCreatedUserId,
			--	dtmCreated,
			--	intLastModifiedUserId,
			--	dtmLastModified,
			--	strSourceSystem,
			--	intConcurrencyId
			--)
			--SELECT DISTINCT
			--	strTransactionId = A.strRecordNumber,
			--	intBankTransactionTypeID = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AR Payment'),
			--	intBankAccountID = (SELECT TOP 1 intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = A.intAccountId),
			--	intCurrencyID = A.intCurrencyId,
			--	dblExchangeRate = 0,
			--	dtmDate = A.dtmDatePaid,
			--	strPayee = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = B.[intEntityCustomerId]),
			--	intPayeeID = B.[intEntityCustomerId],
			--	strAddress = '',
			--	strZipCode = '',
			--	strCity = '',
			--	strState = '',
			--	strCountry = '',
			--	dblAmount = A.dblAmountPaid,
			--	strAmountInWords = dbo.fnConvertNumberToWord(A.dblAmountPaid),
			--	strMemo = SUBSTRING(ISNULL(A.strPaymentInfo + ' - ', '') + ISNULL(A.strNotes, ''), 1 ,255),
			--	strReferenceNo = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE A.strPaymentInfo END,
			--	ysnCheckToBePrinted = 1,
			--	ysnCheckVoid = 0,
			--	ysnPosted = 1,
			--	strLink = @batchId,
			--	ysnClr = 0,
			--	dtmDateReconciled = NULL,
			--	intCreatedUserID = @userId,
			--	dtmCreated = GETDATE(),
			--	intLastModifiedUserID = NULL,
			--	dtmLastModified = GETDATE(),
			--	strSourceSystem = 'AR',
			--	intConcurrencyId = 1
			--	FROM tblARPayment A
			--		INNER JOIN tblARCustomer B
			--			ON A.[intEntityCustomerId] = B.[intEntityCustomerId]
			--	INNER JOIN
			--		tblGLAccount GL
			--			ON A.intAccountId = GL.intAccountId 
			--	INNER JOIN 
			--		tblGLAccountGroup AG
			--			ON GL.intAccountGroupId = AG.intAccountGroupId 		
			--	INNER JOIN 
			--		tblGLAccountCategory AC
			--			ON GL.intAccountCategoryId = AC.intAccountCategoryId										 
			--	INNER JOIN
			--		tblCMBankAccount BA
			--			ON A.intAccountId = BA.intGLAccountId 						
			--	WHERE
			--		AC.strAccountCategory = 'Cash Account'
			--		AND BA.intGLAccountId IS NOT NULL
			--		AND BA.ysnActive = 1
			--		AND A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
					
											
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT * FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE [intTransactionId] = Z.[intTransactionId])											

			--Insert Successfully posted transactions.
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 
				@PostSuccessfulMsg,
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
			WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)

			EXEC uspAPUpdateBillPaymentFromAR @paymentIds = @arPaymentIds, @post = 1

			END						

		--UPDATE 
		--	tblARPaymentDetail
		--SET 
		--	dblAmountDue = ISNULL(C.dblAmountDue, 0.00) -- ISNULL(A.dblDiscount,0.00)) - A.dblPayment							
		--	,dblBaseAmountDue = ISNULL(C.dblBaseAmountDue, 0.00) -- ISNULL(A.dblDiscount,0.00)) - A.dblPayment							
		--FROM
		--	tblARPaymentDetail A
		--INNER JOIN
		--	tblARPayment B
		--		ON A.intPaymentId = B.intPaymentId
		--		AND A.intPaymentId NOT IN (SELECT intPaymentId FROM @ARReceivablePostData)
		--INNER JOIN 
		--	tblARInvoice C
		--		ON A.intInvoiceId = C.intInvoiceId
		--WHERE
		--	B.ysnPosted = 1
		--	AND ISNULL(B.[ysnInvoicePrepayment],0) = 0		
						
		--UPDATE 
		--	tblARPaymentDetail
		--SET 
		--	dblPayment = CASE WHEN (((ISNULL(C.dblAmountDue,0.00) + ISNULL(A.dblInterest,0.00)) - ISNULL(A.dblDiscount,0.00)) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.dblPayment THEN (((ISNULL(C.dblAmountDue,0.00) + ISNULL(A.dblInterest,0.00)) - ISNULL(A.dblDiscount,0.00))* (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.dblPayment END
		--	,dblBasePayment = CASE WHEN (((ISNULL(C.dblBaseAmountDue,0.00) + ISNULL(A.dblBaseInterest,0.00)) - ISNULL(A.dblBaseDiscount,0.00)) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.dblBasePayment THEN (((ISNULL(C.dblBaseAmountDue,0.00) + ISNULL(A.dblBaseInterest,0.00)) - ISNULL(A.dblBaseDiscount,0.00))* (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.dblBasePayment END
		--FROM
		--	tblARPaymentDetail A
		--INNER JOIN
		--	tblARPayment B
		--		ON A.intPaymentId = B.intPaymentId
		--		AND A.intPaymentId NOT IN (SELECT intPaymentId FROM @ARReceivablePostData)
		--INNER JOIN 
		--	tblARInvoice C
		--		ON A.intInvoiceId = C.intInvoiceId
		--WHERE
		--	B.ysnPosted = 0
		--	AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
				
		--UPDATE 
		--	tblARPaymentDetail
		--SET 
		--	dblAmountDue = ((((ISNULL(C.dblAmountDue, 0.00) + ISNULL(A.dblInterest,0.00)) - ISNULL(A.dblDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - A.dblPayment)
		--	,dblBaseAmountDue = ((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(A.dblBaseInterest,0.00)) - ISNULL(A.dblBaseDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - A.dblBasePayment)
		--FROM
		--	tblARPaymentDetail A
		--INNER JOIN
		--	tblARPayment B
		--		ON A.intPaymentId = B.intPaymentId
		--		AND A.intPaymentId NOT IN (SELECT intPaymentId FROM @ARReceivablePostData)
		--INNER JOIN 
		--	tblARInvoice C
		--		ON A.intInvoiceId = C.intInvoiceId
		--WHERE
		--	B.ysnPosted = 0
		--	AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
					
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

		BEGIN TRY			
			DECLARE @PaymentsToUpdate TABLE (intPaymentId INT);
			
			INSERT INTO @PaymentsToUpdate(intPaymentId)
			SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData
				
			WHILE EXISTS(SELECT TOP 1 NULL FROM @PaymentsToUpdate ORDER BY intPaymentId)
				BEGIN
				
					DECLARE @intPaymentIntegractionId INT
							,@actionType AS NVARCHAR(50)

					SELECT @actionType = CASE WHEN @post = 1 THEN 'Posted'  ELSE 'Unposted' END 
					
					SELECT TOP 1 @intPaymentIntegractionId = intPaymentId FROM @PaymentsToUpdate ORDER BY intPaymentId

					--Audit Log          
					EXEC dbo.uspSMAuditLog 
						 @keyValue			= @intPaymentIntegractionId							-- Primary Key Value of the Invoice. 
						,@screenName		= 'AccountsReceivable.view.ReceivePaymentsDetail'	-- Screen Namespace
						,@entityId			= @UserEntityID										-- Entity Id.
						,@actionType		= @actionType										-- Action Type
						,@changeDescription	= ''												-- Description
						,@fromValue			= ''												-- Previous Value
						,@toValue			= ''												-- New Value
									
					DELETE FROM @PaymentsToUpdate WHERE intPaymentId = @intPaymentIntegractionId
												
				END 
																
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH	
					
	END

	IF @recap = 0
		BEGIN			
			DECLARE @tblPaymentsToUpdateBudget TABLE (intPaymentId INT)			

			INSERT INTO @tblPaymentsToUpdateBudget
			SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData

			--Update Customer's AR Balance
			UPDATE CUSTOMER
			SET dblARBalance = dblARBalance - (CASE WHEN @post = 1 THEN ISNULL(PAYMENT.dblTotalPayment, 0) ELSE ISNULL(PAYMENT.dblTotalPayment, 0) * -1 END)
			FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
			INNER JOIN (SELECT intEntityCustomerId
							 , dblTotalPayment	= (SUM(PD.dblPayment) + SUM(PD.dblDiscount)) - SUM(PD.dblInterest)
						FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
							INNER JOIN (SELECT intPaymentId
											 , intEntityCustomerId
										FROM dbo.tblARPayment WITH (NOLOCK)
							) P ON PD.intPaymentId = P.intPaymentId
						WHERE PD.intPaymentId IN (SELECT intPaymentId FROM @tblPaymentsToUpdateBudget)
						GROUP BY intEntityCustomerId
			) PAYMENT ON CUSTOMER.intEntityId = PAYMENT.intEntityCustomerId

			--Update Customer's Budget 
			WHILE EXISTS (SELECT NULL FROM @tblPaymentsToUpdateBudget)
				BEGIN
					DECLARE @paymentToUpdate INT,
							@customerId		 INT

					SELECT TOP 1 @paymentToUpdate = intPaymentId FROM @tblPaymentsToUpdateBudget ORDER BY intPaymentId
					SELECT @customerId = intEntityCustomerId FROM tblARPayment WHERE intPaymentId = @paymentToUpdate
			
					EXEC dbo.uspARUpdateCustomerBudget @paymentToUpdate, @post

					DELETE FROM @tblPaymentsToUpdateBudget WHERE intPaymentId = @paymentToUpdate
				END

			--UPDATE BatchIds Used
			UPDATE tblARPayment 
			SET strBatchId		= CASE WHEN @post = 1 THEN @batchIdUsed ELSE NULL END
			  , dtmBatchDate	= CASE WHEN @post = 1 THEN @PostDate ELSE NULL END
			  , intPostedById	= CASE WHEN @post = 1 THEN @UserEntityID ELSE NULL END
			  , ysnPosted       = @post
			WHERE intPaymentId IN (SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData)
			
		END	

SET @successfulCount = @totalRecords
SET @invalidCount = @totalInvalid	
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

			EXEC uspARInsertPostResult @batchId, 'Receive Payment', @ErrorMerssage, @param								

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
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;
	