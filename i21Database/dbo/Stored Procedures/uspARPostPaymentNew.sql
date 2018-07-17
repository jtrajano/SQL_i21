CREATE PROCEDURE [dbo].[uspARPostPaymentNew]
     @BatchId			AS NVARCHAR(40)		= NULL
	,@Post				AS BIT				= 0
	,@Recap				AS BIT				= 0
	,@UserId			AS INT				= NULL
	,@PaymentIds		AS PaymentId		READONLY
	,@IntegrationLogId	AS INT
	,@BeginDate			AS DATE				= NULL
	,@EndDate			AS DATE				= NULL
	,@BeginTransaction	AS NVARCHAR(50)		= NULL
	,@EndTransaction	AS NVARCHAR(50)		= NULL
	,@Exclude			AS NVARCHAR(MAX)	= NULL
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@Success			AS BIT				= 0 OUTPUT
	,@RaiseError		AS BIT				= 0
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

IF @RaiseError = 1
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

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
 

DECLARE @ARReceivablePostData AS [dbo].[ReceivePaymentPostingTable]
DECLARE @TempPaymentIds AS [dbo].[Id]

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
DECLARE @invalidCount INT
DECLARE @ErrorMerssage NVARCHAR(MAX)

DECLARE @UserEntityID			INT
		,@AllowOtherUserToPost	BIT

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WITH (NOLOCK) WHERE [intEntityId] = @UserId),@UserId)
--SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WITH (NOLOCK) WHERE intEntityUserSecurityId = @UserEntityID)

IF(@BatchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @BatchId OUT
	END

SET @BatchIdUsed = @BatchId	
SET @Success = 1

-- Ensure @Post and @Recap is not NULL  
SET @Post = ISNULL(@Post, 0)
SET @Recap = ISNULL(@Recap, 0)

--@IntegrationLogId
DELETE FROM @TempPaymentIds
INSERT INTO @ARReceivablePostData 
SELECT *
FROM [dbo].[fnARGetPaymentDetailsForPosting](@TempPaymentIds, @PostDate, @BatchIdUsed, NULL, @Post, @Recap, @UserEntityID, @IntegrationLogId)

--@PaymentIds
DELETE FROM @TempPaymentIds
INSERT INTO @TempPaymentIds
SELECT P.[intHeaderId] FROM @PaymentIds P WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData I WHERE I.[intTransactionId] = P.[intHeaderId] AND I.[intTransactionDetailId] IS NULL)



INSERT INTO @ARReceivablePostData 
SELECT *
FROM [dbo].[fnARGetPaymentDetailsForPosting](@TempPaymentIds, @PostDate, @BatchIdUsed, NULL, @Post, @Recap, @UserEntityID, NULL)

UPDATE RPD
SET
	 RPD.[intBankAccountId]		= ISNULL(P.[intBankAccountId], RPD.[intBankAccountId])
	,RPD.[intDiscountAccount]	= ISNULL(P.[intDiscountAccountId], RPD.[intDiscountAccount])
	,RPD.[intInterestAccount]	= ISNULL(P.[intInterestAccountId], RPD.[intInterestAccount])
	,RPD.[intWriteOffAccountId]	= ISNULL(P.[intWriteOffAccountId], RPD.[intWriteOffAccountId])
	,RPD.[intGainLossAccount]	= ISNULL(P.[intGainLossAccountId], RPD.[intGainLossAccount])
	,RPD.[intCFAccountId]		= ISNULL(P.[intCFAccountId], RPD.[intCFAccountId])
FROM
	@ARReceivablePostData RPD
INNER JOIN
	@PaymentIds P
		ON RPD.[intTransactionId] = P.[intHeaderId]
 

IF(@BeginDate IS NOT NULL)
	BEGIN
		DELETE FROM @TempPaymentIds
		INSERT INTO @TempPaymentIds
		SELECT [intPaymentId] FROM tblARPayment  ARP
		WHERE
			NOT EXISTS(SELECT NULL FROM @ARReceivablePostData PID WHERE PID.[intTransactionId] = ARP.[intPaymentId] AND PID.[intTransactionDetailId] IS NULL)
			AND CAST(ISNULL(ARP.[dtmDatePaid], @DateNow) AS DATE) BETWEEN CAST(ISNULL(@BeginDate, @DateNow) AS DATE) AND CAST(ISNULL(@EndDate, @DateNow) AS DATE)
			AND ARP.ysnPosted <> @Post
				
		INSERT INTO @ARReceivablePostData 
		SELECT *
		FROM [dbo].[fnARGetPaymentDetailsForPosting](@TempPaymentIds, @PostDate, @BatchIdUsed, NULL, @Post, @Recap, @UserId, NULL)
	END

IF(@BeginTransaction IS NOT NULL)
	BEGIN
		DELETE FROM @TempPaymentIds
		INSERT INTO @TempPaymentIds
		SELECT ARP.[intPaymentId] FROM tblARPayment ARP
		WHERE
			NOT EXISTS(SELECT NULL FROM @ARReceivablePostData PID WHERE PID.[intTransactionId] = ARP.[intPaymentId] AND PID.[intTransactionDetailId] IS NULL)
			AND ARP.[intPaymentId] BETWEEN @BeginTransaction AND @EndTransaction
			AND ARP.ysnPosted <> @Post
				
		INSERT INTO @ARReceivablePostData 
		SELECT *
		FROM [dbo].[fnARGetPaymentDetailsForPosting](@TempPaymentIds, @PostDate, @BatchIdUsed, NULL, @Post, @Recap, @UserId, NULL)
	END

--Removed excluded payments to post/unpost
IF(@Exclude IS NOT NULL)
	BEGIN
		DECLARE @PaymentsExclude TABLE  (
			intPaymentId INT
		);

		INSERT INTO @PaymentsExclude
		SELECT intID FROM fnGetRowsFromDelimitedValues(@Exclude)


		DELETE FROM A
		FROM @ARReceivablePostData A
		WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.[intTransactionId] = B.[intPaymentId])
	END
	
--------------------------------------------------------------------------------------------  
-- Validations  
--------------------------------------------------------------------------------------------  
--IF @Recap = 0
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
		SELECT * FROM [dbo].[fnARGetInvalidPaymentsForPosting](@ARReceivablePostData, @Post, @Recap)

		--POST VALIDATIONS
		IF @Post = 1
			BEGIN
							
				DELETE FROM @TempPaymentIds
				INSERT INTO @TempPaymentIds
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

				DECLARE @PaymentIdsForChecking TABLE (
						intInvoiceId int PRIMARY KEY,
						UNIQUE (intInvoiceId)
					);

				INSERT INTO @PaymentIdsForChecking(intInvoiceId)
				SELECT DISTINCT
					ARPD.[intInvoiceId] 
				FROM
					tblARPaymentDetail ARPD WITH (NOLOCK)
				INNER JOIN
					@ARReceivablePostData PPD
						ON ARPD.[intPaymentId] = PPD.[intTransactionId]
						AND PPD.[intTransactionDetailId] IS NULL
				WHERE
					ARPD.[dblPayment] <> @ZeroDecimal
				GROUP BY
					ARPD.[intInvoiceId]
				HAVING
					COUNT(ARPD.[intInvoiceId]) > 1
					
				WHILE(EXISTS(SELECT TOP 1 NULL FROM @PaymentIdsForChecking))
				BEGIN
					DECLARE @InvID INT			
							,@InvoicePayment NUMERIC(18,6) = 0
							
					SELECT TOP 1 @InvID = intInvoiceId FROM @PaymentIdsForChecking
					
					DECLARE @InvoicePaymentDetail TABLE(
						intPaymentId INT,
						intInvoiceId INT,
						dblInvoiceTotal NUMERIC(18,6),
						dblAmountDue NUMERIC(18,6),
						dblPayment NUMERIC(18,6)
					);
					
					INSERT INTO @InvoicePaymentDetail(intPaymentId, intInvoiceId, dblInvoiceTotal, dblAmountDue, dblPayment)
					SELECT
						 ARP.[intPaymentId]
						,ARI.[intInvoiceId]
						,ARI.[dblInvoiceTotal]
						,ARI.[dblAmountDue]
						,ARPD.[dblPayment] 
					FROM
						tblARPayment ARP WITH (NOLOCK)
					INNER JOIN
						(SELECT [intPaymentId], [dblPayment], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
							ON ARP.[intPaymentId] = ARPD.[intPaymentId]
					INNER JOIN
						(SELECT [intInvoiceId], [dblInvoiceTotal], [dblAmountDue] FROM tblARInvoice WITH (NOLOCK)) ARI
							ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
					INNER JOIN
						@ARReceivablePostData PPD
							ON ARP.[intPaymentId] = PPD.[intTransactionId]
							AND PPD.[intTransactionDetailId] IS NULL
					WHERE
						ARI.[intInvoiceId] = @InvID
							
					WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicePaymentDetail)
					BEGIN
						DECLARE @PayID INT
								,@AmountDue NUMERIC(18,6) = 0
						SELECT TOP 1 @PayID = intPaymentId, @AmountDue = dblAmountDue, @InvoicePayment = @InvoicePayment + dblPayment FROM @InvoicePaymentDetail ORDER BY intPaymentId
						
						IF @AmountDue < @InvoicePayment
						BEGIN
							INSERT INTO
									@ARReceivableInvalidData 
									([intTransactionId]
									,[strTransactionId]
									,[strTransactionType]
									,[intTransactionDetailId]
									,[strBatchId]
									,[strError])
								SELECT 
									 [intTransactionId]			= ARP.[intPaymentId]
									,[strTransactionId]			= ARP.[strRecordNumber]
									,[strTransactionType]		= 'Receivable'
									,[intTransactionDetailId]	= ARPD.[intPaymentDetailId]
									,[strBatchId]				= @BatchId
									,[strError]					= 'Payment on ' + ARI.[strInvoiceNumber] + ' is over the transaction''s amount due'
								FROM
									tblARPayment ARP WITH (NOLOCK)
								INNER JOIN
									(SELECT [intPaymentId], [intInvoiceId], [intPaymentDetailId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
										ON ARP.[intPaymentId] = ARPD.[intPaymentId]
								INNER JOIN
									(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice WITH (NOLOCK)) ARI
										ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
								INNER JOIN
									@ARReceivablePostData P
										ON ARP.[intPaymentId] = P.[intTransactionId]
								WHERE
									ARI.[intInvoiceId] = @InvID
									AND ARP.[intPaymentId] = @PayID
						END									
						DELETE FROM @InvoicePaymentDetail WHERE intPaymentId = @PayID	
					END
					DELETE FROM @PaymentIdsForChecking WHERE intInvoiceId = @InvID							
				END		 																
			END

		--UNPOSTING VALIDATIONS
		IF @Post = 0 And @Recap = 0
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
				UPDATE ILD
				SET
					 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
					,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
					,ILD.[strPostingMessage]	= PID.[strError]
					,ILD.[strBatchId]			= PID.[strBatchId]
					,ILD.[strPostedTransactionId] = PID.[strTransactionId] 
				FROM
					tblARPaymentIntegrationLogDetail ILD WITH (NOLOCK)
				INNER JOIN
					@ARReceivableInvalidData PID
						ON ILD.[intPaymentId] = PID.[intTransactionId]
				WHERE
					ILD.[intIntegrationLogId] = @IntegrationLogId
					AND ILD.[ysnPost] IS NOT NULL

				--DELETE Invalid Transaction From temp table
				DELETE 
					A
				FROM
					@ARReceivablePostData A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intTransactionId = I.intTransactionId
																
				DELETE 
					A
				FROM
					@AROverpayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intId = I.intTransactionId	
						
				DELETE 
					@ARPrepayment
				FROM
					@ARPrepayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intId = I.intTransactionId
						
			IF @RaiseError = 1
				BEGIN
					SELECT TOP 1 @ErrorMerssage = strError FROM @ARReceivableInvalidData
					RAISERROR(@ErrorMerssage, 11, 1)							
					GOTO Post_Exit
				END													

			END

	--Get all to be post record
		SELECT @totalRecords = (SELECT COUNT(DISTINCT [intTransactionId]) FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL)

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
				END
				IF @RaiseError = 1
					BEGIN
						SELECT TOP 1 @ErrorMerssage = strError FROM @ARReceivableInvalidData
						RAISERROR(@ErrorMerssage, 11, 1)							
						GOTO Post_Exit
					END	
				GOTO Post_Exit
			END			

	END
	
	IF (SELECT COUNT(1) FROM @ARReceivablePostData) > 1 AND @Post = 1
	BEGIN
		DECLARE @DiscouuntedInvoices TABLE (
				intInvoiceId int PRIMARY KEY,
				UNIQUE (intInvoiceId)
			);

		INSERT INTO @DiscouuntedInvoices(intInvoiceId)
		SELECT DISTINCT
			PD.[intInvoiceId] 
		FROM
			tblARPaymentDetail PD 
		INNER JOIN
			@ARReceivablePostData P
				ON PD.[intPaymentId] = P.[intTransactionId]
		WHERE
			PD.[dblPayment] <> 0
			AND (ISNULL(PD.[dblDiscount],0) <> 0 OR ISNULL(PD.[dblInterest],0) <> 0)
		GROUP BY
			PD.[intInvoiceId]
		HAVING
			COUNT(PD.[intInvoiceId]) > 1
			
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
				 A.[intPaymentId]
				,B.intPaymentDetailId
				,C.[intInvoiceId]
				,C.[dblInvoiceTotal]
				,C.[dblAmountDue]
				,B.[dblPayment]
				,B.[dblDiscount]
				,B.[dblInterest] 
			FROM
				tblARPayment A
			INNER JOIN
				tblARPaymentDetail B
					ON A.[intPaymentId] = B.[intPaymentId]
			INNER JOIN
				tblARInvoice C
					ON B.[intInvoiceId] = C.[intInvoiceId]
			INNER JOIN
				@ARReceivablePostData P
					ON A.[intPaymentId] = P.[intTransactionId]
			WHERE
				C.[intInvoiceId] = @DiscountedInvID
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
						,dblInterest = 0.00
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
if @Recap = 1 AND @RaiseError = 0
	SAVE TRAN @TransactionName	

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @Post = 1  
	BEGIN	
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


        DELETE FROM @TempPaymentIds
        INSERT INTO @TempPaymentIds
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
		FROM [dbo].[fnAPCreateClaimARGLEntries] (@TempPaymentIds, @UserId, @BatchIdUsed)
			
	END TRY
	BEGIN CATCH	
		SELECT @ErrorMerssage = ERROR_MESSAGE()										
		GOTO Do_Rollback
	END CATCH
					
			
	END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @Post = 0   
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
				,@BatchId
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
				,intUserId						= @UserId
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
IF @Recap = 1
	BEGIN
		IF @RaiseError = 0
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

		--DECLARE @tmpBatchId NVARCHAR(100)
		--SELECT @tmpBatchId = [strBatchId] 
		--FROM @GLEntries A
		--INNER JOIN dbo.tblGLAccount B 
		--	ON A.[intAccountId] = B.[intAccountId]
		--INNER JOIN dbo.tblGLAccountGroup C
		--	ON B.intAccountGroupId = C.intAccountGroupId
		--CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		--CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		--CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		--CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit

		--UPDATE tblGLPostRecap SET strDescription = ABC.strDescription
		--FROM 
		--	tblGLPostRecap
		--INNER JOIN
		--(
		--	SELECT GLA.[intAccountId], GLA.strDescription 
		--	FROM 
		--		(SELECT intAccountId, strDescription, strBatchId FROM tblGLPostRecap) GLPR
		--		INNER JOIN 
		--		(SELECT intAccountId, strDescription FROM tblGLAccount) GLA ON GLPR.[intAccountId] = GLPR.[intAccountId]
		--		WHERE
		--			(ISNULL(GLPR.strDescription, '') = '' OR (GLPR.strDescription = 'Thank you for your business!'))
		--			AND GLPR.strBatchId = @tmpBatchId
		--) ABC ON tblGLPostRecap.[intAccountId] = ABC.[intAccountId]
		--WHERE 
		--	((ISNULL(tblGLPostRecap.strDescription, '') = '') OR  (tblGLPostRecap.strDescription = 'Thank you for your business!'))
		--	AND tblGLPostRecap.strBatchId = @tmpBatchId

		--EXEC uspGLPostRecap @GLEntries, @UserEntityID 
					
	END TRY
	BEGIN CATCH
		SELECT @ErrorMerssage = ERROR_MESSAGE()
		IF @RaiseError = 0
			BEGIN
				SET @CurrentTranCount = @@TRANCOUNT
				SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
				IF @CurrentTranCount = 0
					BEGIN TRANSACTION
				ELSE
					SAVE TRANSACTION @CurrentSavepoint
											
				UPDATE ILD
				SET
					 PLD.[ysnPosted]			= CASE WHEN PLD.[ysnPost] = 1 THEN 1 ELSE PLD.[ysnPosted] END
					,PLD.[ysnUnPosted]			= CASE WHEN PLD.[ysnPost] = 1 THEN PLD.[ysnUnPosted] ELSE 1 END
					,PLD.[strPostingMessage]	= @ErrorMerssage
					,PLD.[strBatchId]			= @BatchId
					,PLD.[strPostedTransactionId] = PPD.[strTransactionId] 
				FROM
					tblARPaymentIntegrationLogDetail PLD  WITH (NOLOCK)
				INNER JOIN
					@ARReceivablePostData PPD
						ON PLD.[intPaymentId] = PPD.[intTransactionId]
				WHERE
					PLD.[intIntegrationLogId] = @IntegrationLogId
					AND PLD.[ysnPost] IS NOT NULL 

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
IF @Recap = 0
	BEGIN
		BEGIN TRY 
			--SELECT * FROM @GLEntries
			IF @Post = 1
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
											
				--UPDATE ILD
				--SET
				--	 PLD.[ysnPosted]			= 0
				--	,PLD.[strPostingMessage]	= PPD.[strText]
				--	,PLD.[strBatchId]			= @BatchId
				--	,PLD.[strPostedTransactionId] = PPD.[strTransactionId] 
				--FROM
				--	tblARPaymentIntegrationLogDetail PLD  WITH (NOLOCK)
				--INNER JOIN
				--	@InvalidGLEntries PPD
				--		ON PLD.[intPaymentId] = PPD.[intTransactionId]
				--WHERE
				--	PLD.[intIntegrationLogId] = @IntegrationLogId
				--	AND PLD.[ysnPost] = 1				

				DELETE FROM @GLEntries
				WHERE
					strTransactionId IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

				DELETE FROM @ARReceivablePostData
				WHERE
					strTransactionId IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)
			END

			IF EXISTS(SELECT TOP 1 NULL FROM @GLEntries)
				EXEC dbo.uspGLBookEntries @GLEntries, @Post
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
				,@Post					= @Post
				,@PostDate				= @PostDate
				,@BatchId				= @BatchId
				,@UserId				= @UserId
				,@IntegrationLogId		= @IntegrationLogId

		IF @Post = 0
			BEGIN			
					
			--DELETE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN			
					DECLARE @PaymentIdToDelete int		
					SELECT TOP 1 @PaymentIdToDelete = intId FROM @AROverpayment
					
					EXEC [dbo].[uspARDeleteOverPayment] @PaymentIdToDelete, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intId = @PaymentIdToDelete
				END	
				
			--DELETE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN			
					DECLARE @PaymentIdToDeletePre int		
					SELECT TOP 1 @PaymentIdToDeletePre = intId FROM @ARPrepayment
					
					EXEC [dbo].[uspARDeletePrePayment] @PaymentIdToDeletePre, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intId = @PaymentIdToDeletePre
					
				END												

			END
		ELSE
			BEGIN
			
			--CREATE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN
					DECLARE @PaymentIdToAdd int
					SELECT TOP 1 @PaymentIdToAdd = intId FROM @AROverpayment
					
					EXEC [dbo].[uspARCreateOverPayment] @PaymentIdToAdd, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intId = @PaymentIdToAdd
				END
				
			--CREATE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN
					DECLARE @PaymentIdToAddPre int
					SELECT TOP 1 @PaymentIdToAddPre = intId FROM @ARPrepayment
					
					EXEC [dbo].[uspARCreatePrePayment] @PaymentIdToAddPre, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intId = @PaymentIdToAddPre
				END				
									
			END						


		--UPDATE 
		--	tblARPaymentDetail
		--SET 
		--	dblAmountDue = ISNULL(C.[dblAmountDue], 0.00) -- ISNULL(A.[dblDiscount],0.00)) - A.[dblPayment]							
		--	,dblBaseAmountDue = ISNULL(C.[dblBaseAmountDue], 0.00) -- ISNULL(A.[dblDiscount],0.00)) - A.[dblPayment]							
		--FROM
		--	tblARPaymentDetail A
		--INNER JOIN
		--	tblARPayment B
		--		ON A.[intPaymentId] = B.[intPaymentId]
		--		AND A.[intPaymentId] NOT IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
		--INNER JOIN 
		--	tblARInvoice C
		--		ON A.[intInvoiceId] = C.[intInvoiceId]
		--WHERE
		--	B.[ysnPosted] = 1
		--	AND ISNULL(B.[ysnInvoicePrepayment],0) = 0		

						
		--UPDATE 
		--	tblARPaymentDetail
		--SET 
		--	dblPayment = CASE WHEN (((ISNULL(C.[dblAmountDue],0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00)) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.[dblPayment] THEN (((ISNULL(C.[dblAmountDue],0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.[dblPayment] END
		--	,dblBasePayment = CASE WHEN (((ISNULL(C.[dblBaseAmountDue],0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00)) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.[dblBasePayment] THEN (((ISNULL(C.[dblBaseAmountDue],0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.[dblBasePayment] END
		--FROM
		--	tblARPaymentDetail A
		--INNER JOIN
		--	tblARPayment B
		--		ON A.[intPaymentId] = B.[intPaymentId]
		--		AND A.[intPaymentId] NOT IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
		--INNER JOIN 
		--	tblARInvoice C
		--		ON A.[intInvoiceId] = C.[intInvoiceId]
		--WHERE
		--	B.[ysnPosted] = 0
		--	AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
				
		--UPDATE 
		--	tblARPaymentDetail
		--SET 
		--	dblAmountDue = ((((ISNULL(C.[dblAmountDue], 0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - A.[dblPayment])
		--	,dblBaseAmountDue = ((((ISNULL(C.[dblBaseAmountDue], 0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - A.[dblBasePayment])
		--FROM
		--	tblARPaymentDetail A
		--INNER JOIN
		--	tblARPayment B
		--		ON A.[intPaymentId] = B.[intPaymentId]
		--		AND A.[intPaymentId] NOT IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
		--INNER JOIN 
		--	tblARInvoice C
		--		ON A.[intInvoiceId] = C.[intInvoiceId]
		--WHERE
		--	B.[ysnPosted] = 0
		--	AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
			
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

	END

	--IF @Recap = 0
	--	BEGIN			
	--		DECLARE @tblPaymentsToUpdateBudget TABLE (intPaymentId INT)			

	--		INSERT INTO @tblPaymentsToUpdateBudget
	--		SELECT DISTINCT [intTransactionId] FROM @ARReceivablePostData

	--		--Update Customer's AR Balance
	--		UPDATE CUSTOMER
	--		SET dblARBalance = dblARBalance - (CASE WHEN @Post = 1 THEN ISNULL(PAYMENT.dblTotalPayment, 0) ELSE ISNULL(PAYMENT.dblTotalPayment, 0) * -1 END)
	--		FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	--		INNER JOIN (SELECT intEntityCustomerId
	--						 , dblTotalPayment	= (SUM(PD.dblPayment) + SUM(PD.dblDiscount)) - SUM(PD.dblInterest)
	--					FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	--						INNER JOIN (SELECT intPaymentId
	--										 , intEntityCustomerId
	--									FROM dbo.tblARPayment WITH (NOLOCK)
	--						) P ON PD.[intPaymentId] = P.[intPaymentId]
	--					WHERE PD.[intPaymentId] IN (SELECT intPaymentId FROM @tblPaymentsToUpdateBudget)
	--					GROUP BY intEntityCustomerId
	--		) PAYMENT ON CUSTOMER.[intEntityId] = PAYMENT.intEntityCustomerId

	--		--Update Customer's Budget 
	--		WHILE EXISTS (SELECT NULL FROM @tblPaymentsToUpdateBudget)
	--			BEGIN
	--				DECLARE @paymentToUpdate INT,
	--						@customerId		 INT

	--				SELECT TOP 1 @paymentToUpdate = intPaymentId FROM @tblPaymentsToUpdateBudget ORDER BY intPaymentId
	--				SELECT @customerId = intEntityCustomerId FROM tblARPayment WHERE intPaymentId = @paymentToUpdate
			
	--				EXEC dbo.uspARUpdateCustomerBudget @paymentToUpdate, @Post

	--				DELETE FROM @tblPaymentsToUpdateBudget WHERE intPaymentId = @paymentToUpdate
	--			END
			
	--		--Process ACH Payments
	--		IF @Post = 1
	--			BEGIN
	--				DECLARE @tblACHPayments TABLE (intPaymentId INT)
	--				DECLARE @intACHPaymentMethodId INT

	--				SELECT TOP 1 @intACHPaymentMethodId = intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH'

	--				INSERT INTO @tblACHPayments
	--				SELECT ACH.[intTransactionId] FROM @ARReceivablePostData ACH 
	--					INNER JOIN tblARPayment P ON ACH.[intTransactionId] = P.[intPaymentId] AND P.intPaymentMethodId = @intACHPaymentMethodId

	--				WHILE EXISTS (SELECT NULL FROM @tblACHPayments)
	--					BEGIN
	--						DECLARE @paymentIdACH INT

	--						SELECT TOP 1 @paymentIdACH = intPaymentId FROM @tblACHPayments ORDER BY intPaymentId

	--						EXEC dbo.uspARProcessACHPayments @paymentIdACH, @UserId

	--						DELETE FROM @tblACHPayments WHERE intPaymentId = @paymentIdACH				
	--					END
	--			END
	--	END	

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
					 PLD.[ysnPosted]			= CASE WHEN PLD.[ysnPost] = 1 THEN 1 ELSE PLD.[ysnPosted] END
					,PLD.[ysnUnPosted]			= CASE WHEN PLD.[ysnPost] = 1 THEN PLD.[ysnUnPosted] ELSE 1 END
					,PLD.[strPostingMessage]	= @ErrorMerssage
					,PLD.[strBatchId]			= @BatchId
					,PLD.[strPostedTransactionId] = PPD.[strTransactionId] 
				FROM
					tblARPaymentIntegrationLogDetail PLD  WITH (NOLOCK)
				INNER JOIN
					@ARReceivablePostData PPD
						ON PLD.[intPaymentId] = PPD.[intTransactionId]
				WHERE
					PLD.[intIntegrationLogId] = @IntegrationLogId
					AND PLD.[ysnPost] IS NOT NULL							

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
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @Success = 0	
	RETURN 0;
	