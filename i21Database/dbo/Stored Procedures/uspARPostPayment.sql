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
		,@DateNow AS DATETIME

SET @PostDate = GETDATE()
SET @DateNow = CAST(@PostDate AS DATE)

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'


DECLARE @DefaultCurrencyId INT		
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
				FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId, NULL)
			END
		ELSE
			BEGIN
				DELETE FROM @PaymentIds
				INSERT INTO @PaymentIds
				SELECT intID FROM fnGetRowsFromDelimitedValues(@param)
				
				INSERT INTO @ARReceivablePostData 
				SELECT *
				FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId, NULL)				
			END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		DELETE FROM @PaymentIds
		INSERT INTO @PaymentIds
		SELECT ARP.[intPaymentId] FROM tblARPayment ARP
		WHERE
			NOT EXISTS(SELECT NULL FROM @ARReceivablePostData PID WHERE PID.[intTransactionId] = ARP.[intPaymentId])
			AND CAST(ISNULL(ARP.[dtmDatePaid], @DateNow) AS DATE) BETWEEN CAST(ISNULL(@beginDate, @DateNow) AS DATE) AND CAST(ISNULL(@endDate, @DateNow) AS DATE)
			AND ARP.ysnPosted <> @post

				
		INSERT INTO @ARReceivablePostData 
		SELECT *
		FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId, NULL)
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		DELETE FROM @PaymentIds
		INSERT INTO @PaymentIds
		SELECT ARP.[intPaymentId] FROM tblARPayment ARP
		WHERE
			NOT EXISTS(SELECT NULL FROM @ARReceivablePostData PID WHERE PID.[intTransactionId] = ARP.[intPaymentId])
			AND ARP.intPaymentId BETWEEN @beginTransaction AND @endTransaction
			AND ARP.ysnPosted <> @post
				
		INSERT INTO @ARReceivablePostData 
		SELECT *
		FROM [dbo].[fnARGetPaymentDetailsForPosting](@PaymentIds, @PostDate, @batchIdUsed, @bankAccountId, @post, @recap, @userId, NULL)
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
				SELECT DISTINCT [intTransactionId]
				FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL

				--+overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					DISTINCT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					(
					SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL
					) P
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
					(
					SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL
					) P
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
					(
					SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL
					) P
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
					(
					SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL
					) P
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
		SET @totalRecords = (SELECT COUNT(DISTINCT [intTransactionId]) FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL)

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
				AND P.[intTransactionDetailId] IS NULL
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
					AND P.[intTransactionDetailId] IS NULL
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


        DELETE FROM @PaymentIds
        INSERT INTO @PaymentIds
        SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NOT NULL AND [strTransactionType] = 'Claim'

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
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
		FROM [dbo].[fnAPCreateClaimARGLEntries] (@PaymentIds, @userId, @batchIdUsed)

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
				WHERE P.[intTransactionDetailId] IS NULL
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
				AND B.[intTransactionDetailId] IS NULL 			   
		   
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
			,[strRateType]						= A.[strRateType] --CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN NULL ELSE A.[strRateType]	 END 
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
			END					

			IF EXISTS(SELECT TOP 1 NULL FROM @GLEntries)
				EXEC dbo.uspGLBookEntries @GLEntries, @post
			ELSE
				GOTO Do_Rollback
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH	
		 
		BEGIN TRY 
		

		EXEC [dbo].[uspARPostPaymentIntegration]
					 @ARReceivablePostData	= @ARReceivablePostData
					,@ZeroReceivable		= @ZeroPayment
					,@Post					= @post
					,@PostDate				= @PostDate
					,@BatchId				= @batchId
					,@UserId				= @userId

		IF @post = 0
			BEGIN
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

		END

		--Insert Successfully unposted transactions.
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			 strMessage			= CASE WHEN @post = 0 THEN @UnpostSuccessfulMsg ELSE @PostSuccessfulMsg END
			,strTransactionType	= 'Receivable'
			,strTransactionId	= A.strRecordNumber
			,strBatchNumber		= @batchId
			,intTransactionId	= A.intPaymentId
		FROM tblARPayment A
		WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL)					

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