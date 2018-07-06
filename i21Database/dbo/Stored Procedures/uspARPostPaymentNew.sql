﻿CREATE PROCEDURE [dbo].[uspARPostPaymentNew]
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
SET @Savepoint = SUBSTRING(('ARPostPaymentNew' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
 
DECLARE @ARPaymentPostData TABLE (
	 [intPaymentId]			INT PRIMARY KEY
	,[strTransactionId]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,[intARAccountId]		INT	NULL
	,[intBankAccountId]		INT	NULL
	,[intDiscountAccountId]	INT	NULL
	,[intInterestAccountId]	INT	NULL
	,[intWriteOffAccountId]	INT	NULL
	,[intGainLossAccountId]	INT	NULL
	,[intCFAccountId]		INT	NULL
	,[intEntityId]			INT
	UNIQUE (intPaymentId)
);


DECLARE @ARPaymentInvalidData TABLE (
	strError NVARCHAR(100),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	strBatchNumber NVARCHAR(50),
	intTransactionId INT
);

DECLARE @AROverpayment TABLE (
	intPaymentId int PRIMARY KEY,
	UNIQUE (intPaymentId)
);

DECLARE @ARPrepayment TABLE (
	intPaymentId int PRIMARY KEY,
	UNIQUE (intPaymentId)
);

DECLARE @ZeroPayment TABLE (
	intPaymentId int PRIMARY KEY,
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intWriteOffAccountId INT NULL,
	intEntityId INT,
	intInterestAccountId INT NULL,
	intBankAccountId		INT NULL,
	UNIQUE (intPaymentId)
);

DECLARE @PostDate AS DATETIME
		,@DateNow AS DATETIME
SET @PostDate = GETDATE()
SET @DateNow = CAST(@PostDate AS DATE)

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
DECLARE @CODE NVARCHAR(25) = 'AR'

DECLARE  @ARAccount				INT
		,@DiscountAccount		INT
		,@WriteOffAccount		INT
		,@IncomeInterestAccount	INT
		,@GainLossAccount		INT
		
DECLARE @totalInvalid INT
DECLARE @totalRecords INT
DECLARE @intWriteOff INT
DECLARE @ErrorMerssage NVARCHAR(MAX)
DECLARE @intWriteOffAccount INT
DECLARE @intCFAccount INT

SET @WriteOffAccount = NULL
SET @IncomeInterestAccount = NULL
SET @intWriteOff = NULL
SET @intWriteOffAccount = NULL
SET @GainLossAccount = NULL
SET @intCFAccount = NULL
		
SET @ARAccount = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WITH (NOLOCK) WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0)
SET @DiscountAccount = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WITH (NOLOCK) WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
SET @WriteOffAccount = (SELECT TOP 1 intWriteOffAccountId FROM tblARCompanyPreference WITH (NOLOCK) WHERE intWriteOffAccountId IS NOT NULL AND intWriteOffAccountId <> 0)
SET @IncomeInterestAccount = (SELECT TOP 1 intInterestIncomeAccountId FROM tblARCompanyPreference WITH (NOLOCK) WHERE intInterestIncomeAccountId IS NOT NULL AND intInterestIncomeAccountId <> 0)
SET @GainLossAccount = (SELECT TOP 1 intAccountsReceivableRealizedId FROM tblSMMultiCurrency WITH (NOLOCK) WHERE intAccountsReceivableRealizedId IS NOT NULL AND intAccountsReceivableRealizedId <> 0)
SET @intCFAccount = (SELECT TOP 1 intGLAccountId FROM tblCFCompanyPreference WITH (NOLOCK) WHERE intGLAccountId IS NOT NULL AND intGLAccountId <> 0)

DECLARE @UserEntityID			INT
	,@AllowOtherUserToPost		BIT

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WITH (NOLOCK) WHERE [intEntityId] = @UserId),@UserId)
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WITH (NOLOCK) WHERE intEntityUserSecurityId = @UserEntityID)

INSERT INTO @ARPaymentPostData
	([intPaymentId]
	,[strTransactionId]
	,[intARAccountId]
	,[intBankAccountId]
	,[intDiscountAccountId]
	,[intInterestAccountId]
	,[intWriteOffAccountId]
	,[intGainLossAccountId]
	,[intCFAccountId]
	,[intEntityId])
SELECT DISTINCT
	 [intPaymentId]			= [intHeaderId]
	,[strTransactionId]		= [strTransactionId]
	,[intARAccountId]		= ISNULL([intARAccountId], @ARAccount)
	,[intBankAccountId]		= [intBankAccountId]
	,[intDiscountAccountId]	= ISNULL([intDiscountAccountId], @DiscountAccount)
	,[intInterestAccountId]	= ISNULL([intInterestAccountId], @IncomeInterestAccount)
	,[intWriteOffAccountId]	= ISNULL([intWriteOffAccountId], @WriteOffAccount)
	,[intGainLossAccountId]	= ISNULL([intGainLossAccountId], @GainLossAccount)
	,[intCFAccountId]		= ISNULL([intCFAccountId], @intCFAccount)
	,[intEntityId]			= @UserEntityID
FROM
	@PaymentIds

SET @Success = 1

-- Ensure @Post and @Recap is not NULL  
SET @Post = ISNULL(@Post, 0)
SET @Recap = ISNULL(@Recap, 0)  
 
IF @IntegrationLogId IS NOT NULL
	BEGIN
        INSERT INTO @ARPaymentPostData
			([intPaymentId]
			,[strTransactionId]
			,[intARAccountId]
			,[intBankAccountId]
			,[intDiscountAccountId]
			,[intInterestAccountId]
			,[intWriteOffAccountId]
			,[intGainLossAccountId]
			,[intCFAccountId]
			,[intEntityId]) 
        SELECT DISTINCT
			 [intPaymentId]			= ARPILD.[intPaymentId]
			,[strTransactionId]		= ARP.[strRecordNumber]
			,[intARAccountId]		= @ARAccount
			,[intBankAccountId]		= ARP.[intBankAccountId]
			,[intDiscountAccountId]	= @DiscountAccount
			,[intInterestAccountId]	= @IncomeInterestAccount
			,[intWriteOffAccountId]	= ISNULL(ARP.[intWriteOffAccountId], @WriteOffAccount)
			,[intGainLossAccountId]	= @GainLossAccount
			,[intCFAccountId]		= @intCFAccount
			,[intEntityId]			= @UserEntityID
        FROM
            tblARPaymentIntegrationLogDetail ARPILD WITH (NOLOCK)
		INNER JOIN
			(
				SELECT
					[intPaymentId]
					,[strRecordNumber]
					,[intAccountId]
					,[intBankAccountId]
					,[intWriteOffAccountId]
				FROM
					tblARPayment WITH (NOLOCK)
			) ARP
				ON ARPILD.[intPaymentId] = ARP.[intPaymentId]
        WHERE
            NOT EXISTS(SELECT NULL FROM @ARPaymentPostData PID WHERE PID.[intPaymentId] = ARPILD.[intPaymentId])
			AND ARPILD.[ysnPost] IS NOT NULL 
            AND ARPILD.[ysnPost] = @Post
            AND ARPILD.[ysnHeader] = 1
            AND ARPILD.[intIntegrationLogId] = @IntegrationLogId
	END


IF(@BeginDate IS NOT NULL)
	BEGIN
		INSERT INTO @ARPaymentPostData
			([intPaymentId]
			,[strTransactionId]
			,[intARAccountId]
			,[intBankAccountId]
			,[intDiscountAccountId]
			,[intInterestAccountId]
			,[intWriteOffAccountId]
			,[intGainLossAccountId]
			,[intCFAccountId]
			,[intEntityId]) 
        SELECT DISTINCT
			 [intPaymentId]			= ARP.[intPaymentId]
			,[strTransactionId]		= ARP.[strRecordNumber]
			,[intARAccountId]		= @ARAccount
			,[intBankAccountId]		= ARP.[intBankAccountId]
			,[intDiscountAccountId]	= @DiscountAccount
			,[intInterestAccountId]	= @IncomeInterestAccount
			,[intWriteOffAccountId]	= ISNULL(ARP.[intWriteOffAccountId], @WriteOffAccount)
			,[intGainLossAccountId]	= @GainLossAccount
			,[intCFAccountId]		= @intCFAccount
			,[intEntityId]			= @UserEntityID
		FROM 
			tblARPayment ARP WITH (NOLOCK)
		WHERE
			NOT EXISTS(SELECT NULL FROM @ARPaymentPostData PID WHERE PID.[intPaymentId] = ARP.[intPaymentId])
			AND CAST(ISNULL(ARP.[dtmDatePaid], @DateNow) AS DATE) BETWEEN CAST(ISNULL(@BeginDate, @DateNow) AS DATE) AND CAST(ISNULL(@EndDate, @DateNow) AS DATE) 
			AND ARP.[ysnPosted] <> @Post
	END

IF(@BeginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @ARPaymentPostData
		([intPaymentId]
			,[strTransactionId]
			,[intARAccountId]
			,[intBankAccountId]
			,[intDiscountAccountId]
			,[intInterestAccountId]
			,[intWriteOffAccountId]
			,[intGainLossAccountId]
			,[intCFAccountId]
			,[intEntityId]) 
        SELECT DISTINCT
			 [intPaymentId]			= ARP.[intPaymentId]
			,[strTransactionId]		= ARP.[strRecordNumber]
			,[intARAccountId]		= @ARAccount
			,[intBankAccountId]		= ARP.[intBankAccountId]
			,[intDiscountAccountId]	= @DiscountAccount
			,[intInterestAccountId]	= @IncomeInterestAccount
			,[intWriteOffAccountId]	= ISNULL(ARP.[intWriteOffAccountId], @WriteOffAccount)
			,[intGainLossAccountId]	= @GainLossAccount
			,[intCFAccountId]		= @intCFAccount
			,[intEntityId]			= @UserEntityID
		FROM 
			tblARPayment ARP WITH (NOLOCK)
		WHERE
			NOT EXISTS(SELECT NULL FROM @ARPaymentPostData PID WHERE PID.[intPaymentId] = ARP.[intPaymentId])
			AND ARP.[intPaymentId] BETWEEN @BeginTransaction AND @EndTransaction
			AND ARP.[ysnPosted] <> @Post
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
		FROM @ARPaymentPostData A
		WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.[intPaymentId] = B.[intPaymentId])
	END
	
		
IF(@BatchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @BatchId OUT
	END

SET @BatchIdUsed = @BatchId	

--------------------------------------------------------------------------------------------  
-- Validations  
--------------------------------------------------------------------------------------------  
--IF @Recap = 0
	BEGIN
	
		-- Zero Payment
		INSERT INTO
			@ZeroPayment
		SELECT
			 ARP.[intPaymentId]
			,ARP.[strRecordNumber]
			,ARP.[intWriteOffAccountId]
			,ARP.[intEntityId]
			,PPD.[intInterestAccountId]
			,PPD.[intBankAccountId]
		FROM
			tblARPayment ARP WITH (NOLOCK)
		INNER JOIN 
			(SELECT [intPaymentId], [dblPayment] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
				ON ARP.[intPaymentId] = ARPD.[intPaymentId]
		INNER JOIN
			@ARPaymentPostData PPD
				ON ARP.[intPaymentId] = PPD.[intPaymentId]	
		WHERE
			ARP.[dblAmountPaid] = 0					
		GROUP BY
			ARP.[intPaymentId], ARP.[strRecordNumber], ARP.[intWriteOffAccountId], ARP.[intEntityId], PPD.[intInterestAccountId], PPD.[intBankAccountId]
		HAVING
			SUM(ARPD.[dblPayment]) = @ZeroDecimal			
		

		--POST VALIDATIONS
		IF @Post = 1
			BEGIN


				--Undeposited Funds Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Undeposited Funds account in Company Location - ' + SMCL.[strLocationName]  + ' was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				--INNER JOIN
				--	tblARPaymentDetail ARPD WITH (NOLOCK)
				--		ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					(SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
						ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
				INNER JOIN
					@ARPaymentPostData P
						ON ARP.[intPaymentId] = P.[intPaymentId]						 
				WHERE
					ISNULL(SMCL.[intUndepositedFundsId],0)  = 0
												
				--Sales Discount Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The AR Account in Company Configuration was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				--INNER JOIN
				--	tblARPaymentDetail D
				--		ON ARP.[intPaymentId] = D.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
				WHERE
					(PPD.[intARAccountId] IS NULL OR PPD.[intARAccountId] = 0)

				--Payment without payment on detail (get all detail that has 0 payment)
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT
					'There was no payment to receive.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN 
					(SELECT [intPaymentId], [dblPayment], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]					
				WHERE
					ARP.[dblAmountPaid] = @ZeroDecimal
					AND (NOT EXISTS(SELECT NULL FROM tblARInvoice WITH (NOLOCK) WHERE [strTransactionType] NOT IN ('Invoice','Debit Memo') AND [intInvoiceId] = ARPD.[intInvoiceId])
						AND ARPD.[dblPayment] <> @ZeroDecimal)					
				GROUP BY
					ARP.[intPaymentId], ARP.[strRecordNumber]
				HAVING
					SUM(ARPD.[dblPayment]) = @ZeroDecimal					

				--Payment without detail
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'There was no payment to receive.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM 
					tblARPayment ARP WITH (NOLOCK)
				LEFT JOIN 
					(SELECT [intPaymentId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						
				WHERE
					ARPD.[intPaymentId] IS NULL
					AND ARP.[dblAmountPaid] = @ZeroDecimal

				--Unposted Invoice(s)
				INSERT INTO   
					@ARPaymentInvalidData  
				SELECT  
					'Invoice ' + ARI.[strInvoiceNumber] + ' is not posted!'  
					,'Receivable'  
					,ARP.[strRecordNumber]  
					,@BatchId  
					,ARP.[intPaymentId]  
				FROM  
					tblARPaymentDetail ARPD WITH (NOLOCK)
				INNER JOIN   
					(SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment  WITH (NOLOCK)) ARP
						ON ARPD.[intPaymentId] = ARP.[intPaymentId]  
				INNER JOIN
					(SELECT [intInvoiceId], [strInvoiceNumber], [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN  
					@ARPaymentPostData PPD  
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				WHERE
					ISNULL(ARPD.[dblPayment], @ZeroDecimal) <> @ZeroDecimal
					AND ISNULL(ARI.[ysnPosted],0) = 0

				----Exclude Recieved Amount in Final Invoice enabled
				--INSERT INTO   
				--	@ARPaymentInvalidData  
				--SELECT  
				--	'Invoice ' + ARI.strInvoiceNumber + ' was posted with ''Exclude Recieved Amount in Final Invoice'' option enabled! Payment not allowed!'  
				--	,'Receivable'  
				--	,ARP.strRecordNumber  
				--	,@BatchId  
				--	,ARP.intPaymentId  
				--FROM  
				--	tblARPaymentDetail ARPD   
				--INNER JOIN   
				--	tblARPayment ARP  
				--		ON ARPD.intPaymentId = ARP.intPaymentId  
				--INNER JOIN
				--	tblARInvoice ARI
				--		ON ARPD.intInvoiceId = ARI.intInvoiceId
				--INNER JOIN  
				--	@ARPaymentPostData P  
				--		ON ARP.intPaymentId = ARP.intPaymentId
				--WHERE
				--	ISNULL(ARPD.dblPayment,0.00) <> 0.00
				--	AND ISNULL(ARI.ysnPosted,0) = 1
				--	AND ISNULL(ARI.ysnExcludeFromPayment,0) = 1

				--Invoice Prepayment
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					A.strRecordNumber + '''s payment amount must be equal to ' + B.strTransactionNumber + '''s prepay amount!'
					,'Receivable'
					,A.strRecordNumber
					,@BatchId
					,A.intPaymentId
				FROM 
					tblARPaymentDetail B
				INNER JOIN 
					tblARPayment A 
						ON B.intPaymentId = A.intPaymentId
				INNER JOIN
					@ARPaymentPostData P
						ON A.intPaymentId = P.intPaymentId						
				WHERE
					ISNULL(A.ysnInvoicePrepayment, 0) = 1
					AND (B.dblInvoiceTotal <> B.dblPayment OR B.dblInvoiceTotal <> A.dblAmountPaid)

				--Forgiven Invoice(s)
				INSERT INTO   
					@ARPaymentInvalidData  
				SELECT  
					'Invoice ' + ARI.strInvoiceNumber + ' has been forgiven!'  
					,'Receivable'  
					,ARP.[strRecordNumber]  
					,@BatchId  
					,ARP.[intPaymentId]  
				FROM  
					tblARPaymentDetail ARPD WITH (NOLOCK)
				INNER JOIN   
					(SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment  WITH (NOLOCK)) ARP
						ON ARPD.[intPaymentId] = ARP.[intPaymentId]  
				INNER JOIN
					(SELECT [intInvoiceId], [strType], [strInvoiceNumber], [ysnPosted], [ysnForgiven] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN  
					@ARPaymentPostData PPD  
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				WHERE
					ISNULL(ARPD.[dblPayment], @ZeroDecimal) <> @ZeroDecimal
					AND ARI.strType = 'Service Charge'
					AND ARI.ysnForgiven = 1
					
				--Return Payment not allowed
				INSERT INTO
					@ARPaymentInvalidData
				SELECT
					'Return Payment is not allowed.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN 
					(SELECT [intPaymentId], [dblPayment], [intInvoiceId] FROM tblARPaymentDetail  WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId] 
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]				
				WHERE
					(ARP.[dblAmountPaid]) < @ZeroDecimal
					AND EXISTS(SELECT NULL FROM tblARInvoice WHERE [intInvoiceId] = ARPD.[intInvoiceId] AND ARPD.[dblPayment] > 0 AND [strTransactionType] NOT IN ('Credit Memo', 'Overpayment', 'Customer Prepayment'))

				--Fiscal Year
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]					
				WHERE
					ISNULL([dbo].isOpenAccountingDate(ARP.[dtmDatePaid]), 0) = 0
					
				--Company Location
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'Company location of ' + ARP.[strRecordNumber] + ' was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
				LEFT OUTER JOIN
					(SELECT [intCompanyLocationId] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
						ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
				WHERE SMCL.[intCompanyLocationId] IS NULL
				
				----Bank Account
				--INSERT INTO 
				--	@ARPaymentInvalidData
				--SELECT 
				--	'Bank Account of ' + A.[strRecordNumber] + ' was not set.'
				--	,'Receivable'
				--	,A.[strRecordNumber]
				--	,@BatchId
				--	,A.[intPaymentId]
				--FROM
				--	tblARPayment A
				--INNER JOIN
				--	@ARPaymentPostData P
				--		ON A.[intPaymentId] = P.[intPaymentId]						 
				--LEFT OUTER JOIN
				--	tblCMBankAccount B
				--		ON A.intBankAccountId = B.intBankAccountId 
				--WHERE B.intBankAccountId  IS NULL
				
				
				--In-active Bank Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'Bank Account ' + CMBA.[strBankAccountNo] + ' is not active.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
				LEFT OUTER JOIN
					(SELECT [intBankAccountId], [strBankAccountNo], [ysnActive] FROM tblCMBankAccount WITH (NOLOCK)) CMBA
						ON ARP.[intBankAccountId] = CMBA.[intBankAccountId]
				WHERE 
					ISNULL(CMBA.[ysnActive],0) = 0
					AND ISNULL(CMBA.[intBankAccountId],0) <> 0
				
				
				--Sales Discount Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Discounts account in Company Configuration was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [dblDiscount] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
				WHERE
					ISNULL(ARPD.[dblDiscount], @ZeroDecimal) <> @ZeroDecimal
					AND (PPD.[intDiscountAccountId] IS NULL OR PPD.[intDiscountAccountId] = 0)
					
				--Income Interest Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Income Interest account in Company Location or Company Configuration was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [dblInterest] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
				WHERE
					ISNULL(ARPD.[dblInterest], @ZeroDecimal) <> @ZeroDecimal
					AND (PPD.[intInterestAccountId] IS NULL OR PPD.[intInterestAccountId] = 0)
					
				--Bank Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Cash Account is not linked to any of the active Bank Account in Cash Management'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				INNER JOIN
					(SELECT [intAccountId], [strAccountCategory] FROM vyuGLAccountDetail WITH (NOLOCK)) GLAD
						ON ARP.[intAccountId] = GLAD.[intAccountId]
				--INNER JOIN 
				--	tblGLAccountGroup AG
				--		ON GL.intAccountGroupId = AG.intAccountGroupId
				--INNER JOIN 
				--	tblGLAccountCategory AC
				--		ON GL.intAccountCategoryId = AC.intAccountCategoryId											 
				LEFT OUTER JOIN
					(SELECT [intGLAccountId], [ysnActive] FROM tblCMBankAccount WITH (NOLOCK)) CMBA
						ON ARP.[intAccountId] = CMBA.[intGLAccountId] 						
				WHERE
					GLAD.[strAccountCategory] = 'Cash Account'
					AND (CMBA.[intGLAccountId] IS NULL OR CMBA.[ysnActive] = 0)
						 
						 
				--Write Off Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Write Off account in Company Configuration was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				INNER JOIN
					(SELECT [strPaymentMethod], [intPaymentMethodID] FROM tblSMPaymentMethod WITH (NOLOCK)) SMPM
						ON ARP.[intPaymentMethodId] = SMPM.[intPaymentMethodID]						
				WHERE
					UPPER(RTRIM(LTRIM(SMPM.[strPaymentMethod]))) = UPPER('Write Off')
					AND (PPD.[intWriteOffAccountId] IS NULL OR PPD.[intWriteOffAccountId] = 0)
					

				--NOT BALANCE 
				INSERT INTO
					@ARPaymentInvalidData
				SELECT
					'The debit and credit amounts are not balanced.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData P
						ON ARP.[intPaymentId] = P.[intPaymentId]				
				WHERE
					(ARP.[dblAmountPaid]) < (SELECT SUM(dblPayment) FROM tblARPaymentDetail WITH (NOLOCK) WHERE intPaymentId = ARP.[intPaymentId])
					
					
				--Payment Date
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'Payment Date(' + CONVERT(NVARCHAR(30),ARP.[dtmDatePaid], 101) + ') cannot be earlier than the Invoice(' + ARI.[strInvoiceNumber] + ') Post Date(' + CONVERT(NVARCHAR(30),ARI.[dtmPostDate], 101) + ')!'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [dblPayment], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN 
					(SELECT [intInvoiceId], [strInvoiceNumber], [dtmPostDate] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				WHERE
					ARPD.[dblPayment] <> 0
					AND CAST(ARI.[dtmPostDate] AS DATE) > CAST(ARP.[dtmDatePaid] AS DATE)				
					
				--Income Interest Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Accounts Receivable Realized Gain or Loss account in Company Configuration was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPaymentDetail ARPD WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment WITH (NOLOCK)) ARP
						ON ARPD.[intPaymentId] = ARP.[intPaymentId]
				INNER JOIN
					(SELECT [intInvoiceId], [dblBaseAmountDue], [strTransactionType], [dblAmountDue], [dblInterest], [dblDiscount] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId] 
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
				WHERE
					ISNULL(((((ISNULL(ARI.[dblBaseAmountDue], 0.00) + ISNULL(ARPD.[dblBaseInterest],0.00)) - ISNULL(ARPD.[dblBaseDiscount],0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - ARPD.[dblBasePayment]),0) <> 0
					AND  (PPD.[intGainLossAccountId] IS NULL OR PPD.[intGainLossAccountId] = 0)
					AND ((ARI.[dblAmountDue] + ARI.[dblInterest]) - ARI.[dblDiscount]) = ((ARPD.[dblPayment] - ARPD.[dblInterest]) + ARPD.[dblDiscount])	

				--Validate Bank Account for ACH Payment Method
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'Bank Account is required for payment with ACH payment method!'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				WHERE
					ARP.[strPaymentMethod] = 'ACH' AND ISNULL(ARP.[intBankAccountId], 0) = 0 

				--+overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]				
				WHERE
					(ARP.[dblAmountPaid]) > (SELECT SUM([dblPayment]) FROM tblARPaymentDetail WITH (NOLOCK) WHERE [intPaymentId] = ARP.[intPaymentId])
					AND EXISTS(SELECT NULL FROM tblARPaymentDetail WITH (NOLOCK) WHERE [intPaymentId] = ARP.[intPaymentId] AND [dblPayment] <> 0)	
					
				--+prepayment
				INSERT INTO
					@ARPrepayment
				SELECT
					ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK) 
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]				
				WHERE
					(ARP.[dblAmountPaid]) <> 0
					AND ISNULL((SELECT SUM(dblPayment) FROM tblARPaymentDetail WITH (NOLOCK) WHERE intPaymentId = ARP.[intPaymentId]), 0) = 0	
					AND NOT EXISTS(SELECT NULL FROM tblARPaymentDetail WITH (NOLOCK) WHERE intPaymentId = ARP.[intPaymentId] AND dblPayment <> 0)		
					
					
				--Prepaid Account
				INSERT INTO 
					@ARPaymentInvalidData
				SELECT 
					'The Customer Prepaid account in Company Location - ' + SMCL.[strLocationName]  + ' was not set.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intCompanyLocationId], [strLocationName], [intSalesAdvAcct] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
						ON ARP.[intLocationId] = SMCL.[intCompanyLocationId] 
				INNER JOIN
					@ARPrepayment PP
						ON ARP.[intPaymentId] = PP.[intPaymentId]						 
				WHERE
					ISNULL(SMCL.[intSalesAdvAcct],0)  = 0										

				--ALREADY POSTED
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'The transaction is already posted.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK) 
				INNER JOIN
					@ARPaymentPostData P
						ON ARP.[intPaymentId] = P.[intPaymentId]
				WHERE
					ARP.[ysnPosted] = 1
												

				--RECEIVABLES(S) ALREADY PAID IN FULL
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					ARI.[strInvoiceNumber] + ' already paid in full.'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [dblPayment], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK))  ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					(SELECT [intInvoiceId], [strInvoiceNumber], [ysnPaid] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@ARPaymentPostData P
						ON ARP.[intPaymentId] = P.[intPaymentId]
				WHERE
					ARI.[ysnPaid] = 1 
					AND ARPD.[dblPayment] <> 0
					
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'Payment on ' + ARI.[strInvoiceNumber] + ' is over the transaction''s amount due'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [dblPayment], [dblInterest], [dblDiscount], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					(SELECT [intInvoiceId], [strInvoiceNumber], [ysnPaid], [dblAmountDue], [dblInterest], [dblDiscount], [strTransactionType] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				WHERE
					ARPD.[dblPayment] <> 0 
					AND ARI.[ysnPaid] = 0 
					AND ((ARI.[dblAmountDue] + ARI.[dblInterest]) - ARI.[dblDiscount]) < ((ARPD.[dblPayment] - ARPD.[dblInterest]) + ARPD.[dblDiscount])
					AND ARI.[strTransactionType] IN ('Invoice', 'Debit Memo')

				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'Payment on ' + ARI.[strInvoiceNumber] + ' is over the transaction''s amount due'
					,'Receivable'
					,ARP.[strRecordNumber]
					,@BatchId
					,ARP.[intPaymentId]
				FROM
					tblARPayment ARP WITH (NOLOCK)
				INNER JOIN
					(SELECT [intPaymentId], [intInvoiceId], [dblPayment], [dblInterest], [dblDiscount] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
						ON ARP.[intPaymentId] = ARPD.[intPaymentId]
				INNER JOIN
					(SELECT [intInvoiceId], [strInvoiceNumber], [ysnPaid], [dblAmountDue], [dblInterest], [dblDiscount], [strTransactionType] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@ARPaymentPostData PPD
						ON ARP.[intPaymentId] = PPD.[intPaymentId]
				WHERE
					ARPD.[dblPayment] <> 0 
					AND ARI.[ysnPaid] = 0 
					AND (((ARI.[dblAmountDue] + ARI.[dblInterest]) - ARI.[dblDiscount]) * -1) > ((ARPD.[dblPayment] - ARPD.[dblInterest]) + ARPD.[dblDiscount])
					AND ARI.[strTransactionType] IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
					
				--If ysnAllowUserSelfPost is True in User Role
				IF (@AllowOtherUserToPost IS NOT NULL AND @AllowOtherUserToPost = 1)
				BEGIN
					INSERT INTO 
						@ARPaymentInvalidData
					SELECT 
						'You cannot Post/Unpost transactions you did not create.'
						,'Receivable'
						,ARP.[strRecordNumber]
						,@BatchId
						,ARP.[intPaymentId]
					FROM
						tblARPayment ARP WITH (NOLOCK)
					INNER JOIN
						@ARPaymentPostData PPD
							ON ARP.[intPaymentId] = PPD.[intPaymentId]						 
					WHERE
						PPD.[intEntityId] <> @UserEntityID
				END

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
					@ARPaymentPostData PPD
						ON ARPD.[intPaymentId] = PPD.[intPaymentId]
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
						@ARPaymentPostData PPD
							ON ARP.[intPaymentId] = PPD.[intPaymentId]
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
									@ARPaymentInvalidData
								SELECT 
									'Payment on ' + ARI.[strInvoiceNumber] + ' is over the transaction''s amount due'
									,'Receivable'
									,ARP.[strRecordNumber]
									,@BatchId
									,ARP.[intPaymentId]
								FROM
									tblARPayment ARP WITH (NOLOCK)
								INNER JOIN
									(SELECT [intPaymentId], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD
										ON ARP.[intPaymentId] = ARPD.[intPaymentId]
								INNER JOIN
									(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice WITH (NOLOCK)) ARI
										ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
								INNER JOIN
									@ARPaymentPostData P
										ON ARP.[intPaymentId] = P.[intPaymentId]
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
			
				--Invoice with Discount
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'Discount has been applied to Invoice: ' + I.[strInvoiceNumber] + '. Payment: ' + P1.[strRecordNumber] + ' must unposted first!'
					,'Receivable'
					,P.[strRecordNumber]
					,@BatchId
					,P.[intPaymentId]
				FROM
					tblARPaymentDetail PD		
				INNER JOIN
					tblARPayment P
						ON PD.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData P2
						ON P.[intPaymentId] = P2.[intPaymentId]	
				INNER JOIN
					tblARInvoice I
						ON PD.[intInvoiceId] = I.[intInvoiceId]
				INNER JOIN
					(
					SELECT
						I.[intInvoiceId]
						,P.[intPaymentId]
						,P.[strRecordNumber]
					FROM
						tblARPaymentDetail PD		
					INNER JOIN	
						tblARPayment P ON PD.[intPaymentId] = P.[intPaymentId]	
					INNER JOIN	
						tblARInvoice I ON PD.[intInvoiceId] = I.[intInvoiceId]
					WHERE
						PD.[dblDiscount] <> 0
						AND I.[dblAmountDue] = 0
					) AS P1
						ON I.[intInvoiceId] = P1.[intInvoiceId] AND P.[intPaymentId] <> P1.[intPaymentId] 		
						
				--Invoice with Interest
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'Interest has been applied to Invoice: ' + I.[strInvoiceNumber] + '. Payment: ' + P1.[strRecordNumber] + ' must unposted first!'
					,'Receivable'
					,P.[strRecordNumber]
					,@BatchId
					,P.[intPaymentId]
				FROM
					tblARPaymentDetail PD		
				INNER JOIN
					tblARPayment P
						ON PD.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					@ARPaymentPostData P2
						ON P.[intPaymentId] = P2.[intPaymentId]	
				INNER JOIN
					tblARInvoice I
						ON PD.[intInvoiceId] = I.[intInvoiceId]
				INNER JOIN
					(
					SELECT
						I.[intInvoiceId]
						,P.[intPaymentId]
						,P.[strRecordNumber]
					FROM
						tblARPaymentDetail PD		
					INNER JOIN	
						tblARPayment P ON PD.[intPaymentId] = P.[intPaymentId]	
					INNER JOIN	
						tblARInvoice I ON PD.[intInvoiceId] = I.[intInvoiceId]
					WHERE
						ISNULL(PD.[dblInterest],0) <> 0
						AND I.[dblAmountDue] = 0
					) AS P1
						ON I.[intInvoiceId] = P1.[intInvoiceId] AND P.[intPaymentId] <> P1.[intPaymentId] 			

				--Already cleared/reconciled
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'The transaction is already cleared.'
					,'Receivable'
					,A.[strRecordNumber]
					,@BatchId
					,A.[intPaymentId]
				FROM
					tblARPayment A
				INNER JOIN
					@ARPaymentPostData P
						ON A.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					tblCMBankTransaction B 
						ON A.[strRecordNumber] = B.strTransactionId
				WHERE B.ysnClr = 1
				
				--Payment with created Bank Deposit
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					A.strRecordNumber + ' is currently attached to Bank Deposit # : ' + T.strTransactionId
					,'Receivable'
					,A.[strRecordNumber]
					,@BatchId
					,A.[intPaymentId]
				FROM
					tblARPayment A
				INNER JOIN
					@ARPaymentPostData P
						ON A.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					tblCMUndepositedFund B 
						ON A.[intPaymentId] = B.intSourceTransactionId 
						AND A.[strRecordNumber] = B.strSourceTransactionId
				INNER JOIN
					tblCMBankTransactionDetail TD
						ON B.intUndepositedFundId = TD.intUndepositedFundId
				INNER JOIN tblCMBankTransaction T
					ON T.intTransactionId = TD.intTransactionId
				WHERE 
					B.strSourceSystem = 'AR'


				--Payment with applied Prepayment
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'You cannot unpost payment with applied prepaids.'
					,'Receivable'
					,A.[strRecordNumber]
					,@BatchId
					,A.[intPaymentId]
				FROM
					tblARPayment A
				INNER JOIN
					@ARPaymentPostData P
						ON A.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					tblARPaymentDetail B
						ON A.[intPaymentId] = B.[intPaymentId]
				INNER JOIN
					tblARInvoice I
						ON B.[intInvoiceId] = I.[intInvoiceId]
				INNER JOIN
					tblARPrepaidAndCredit  PC
						ON I.[intInvoiceId] = PC.intPrepaymentId 
						AND PC.ysnApplied = 1
						AND PC.dblAppliedInvoiceDetailAmount <> 0
				INNER JOIN
					tblARInvoice I2
						ON PC.[intInvoiceId] = I2.[intInvoiceId] 
						AND I2.[ysnPosted] = 1


				--Payment with associated Overpayment
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'There''s an overpayment(' + I.[strInvoiceNumber] + ') created from ' + A.[strRecordNumber] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
					,'Receivable'
					,A.strRecordNumber
					,@BatchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARPaymentPostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblARInvoice I
						ON (A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId)
						AND I.strTransactionType = 'Overpayment'
				INNER JOIN
					tblARPaymentDetail ARPD
						ON I.[intInvoiceId] = ARPD.[intInvoiceId]
						AND A.[intPaymentId] <> ARPD.[intPaymentId]
				INNER JOIN
					tblARPayment ARP
						ON ARPD.[intPaymentId] = ARP.[intPaymentId]

				--Payment with associated Prepayment
				INSERT INTO
					@ARPaymentInvalidData
				SELECT 
					'There''s a prepayment(' + I.[strInvoiceNumber] + ') created from ' + A.[strRecordNumber] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
					,'Receivable'
					,A.strRecordNumber
					,@BatchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARPaymentPostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblARInvoice I
						ON (A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId)
						AND I.strTransactionType = 'Customer Prepayment'
				INNER JOIN
					tblARPaymentDetail ARPD
						ON I.[intInvoiceId] = ARPD.[intInvoiceId]
						AND A.[intPaymentId] <> ARPD.[intPaymentId]
				INNER JOIN
					tblARPayment ARP
						ON ARPD.[intPaymentId] = ARP.[intPaymentId]

				--If ysnAllowUserSelfPost is True in User Role
				IF (@AllowOtherUserToPost IS NOT NULL AND @AllowOtherUserToPost = 1)
				BEGIN
					INSERT INTO 
						@ARPaymentInvalidData
					SELECT 
						'You cannot Post/Unpost transactions you did not create.'
						,'Receivable'
						,A.[strRecordNumber]
						,@BatchId
						,A.[intPaymentId]
					FROM
						tblARPayment A
					INNER JOIN
						tblARPaymentDetail D
							ON A.[intPaymentId] = D.[intPaymentId]
					INNER JOIN
						tblSMCompanyLocation CL
							ON A.[intLocationId] = CL.[intCompanyLocationId] 
					INNER JOIN
						@ARPaymentPostData P
							ON A.[intPaymentId] = P.[intPaymentId]						 
					WHERE
						P.[intEntityId] <> @UserEntityID
				END
				
								
				---overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.[intPaymentId]
				FROM
					tblARPayment A 
				INNER JOIN
					@ARPaymentPostData P
						ON A.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					tblARInvoice I
						ON A.[strRecordNumber] = I.strComments OR A.[intPaymentId] = I.[intPaymentId] 				
				WHERE
					I.[strTransactionType] = 'Overpayment'
					
				---prepayment
				INSERT INTO
					@ARPrepayment
				SELECT
					A.[intPaymentId]
				FROM
					tblARPayment A 
				INNER JOIN
					@ARPaymentPostData P
						ON A.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					tblARInvoice I
						ON A.[strRecordNumber] = I.strComments OR A.[intPaymentId] = I.[intPaymentId] 				
				WHERE
					I.[strTransactionType] = 'Customer Prepayment'		
					
					
			END
		
	--Get all invalid		
		SET @totalInvalid = (SELECT COUNT(*) FROM @ARPaymentInvalidData)

		IF(@totalInvalid > 0)
			BEGIN

				--INSERT INTO 
				--	tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				--SELECT
				--	strError
				--	,strTransactionType
				--	,strTransactionId
				--	,strBatchNumber
				--	,intTransactionId
				--FROM
				--	@ARPaymentInvalidData
				UPDATE ILD
				SET
					 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
					,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
					,ILD.[strPostingMessage]	= PID.[strError]
					,ILD.[strBatchId]			= PID.[strBatchNumber]
					,ILD.[strPostedTransactionId] = PID.[strTransactionId] 
				FROM
					tblARPaymentIntegrationLogDetail ILD WITH (NOLOCK)
				INNER JOIN
					@ARPaymentInvalidData PID
						ON ILD.[intPaymentId] = PID.[intTransactionId]
				WHERE
					ILD.[intIntegrationLogId] = @IntegrationLogId
					AND ILD.[ysnPost] IS NOT NULL

				--DELETE Invalid Transaction From temp table
				DELETE 
					@ARPaymentPostData
				FROM
					@ARPaymentPostData A
				INNER JOIN 
					@ARPaymentInvalidData I
						ON A.[intPaymentId] = I.intTransactionId
																
				DELETE 
					@AROverpayment
				FROM
					@AROverpayment A
				INNER JOIN 
					@ARPaymentInvalidData I
						ON A.[intPaymentId] = I.intTransactionId	
						
				DELETE 
					@ARPrepayment
				FROM
					@ARPrepayment A
				INNER JOIN 
					@ARPaymentInvalidData I
						ON A.[intPaymentId] = I.intTransactionId
						
			IF @RaiseError = 1
				BEGIN
					SELECT TOP 1 @ErrorMerssage = strError FROM @ARPaymentInvalidData
					RAISERROR(@ErrorMerssage, 11, 1)							
					GOTO Post_Exit
				END													

			END

	--Get all to be post record
		SELECT @totalRecords = COUNT(*) FROM @ARPaymentPostData

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
						SELECT TOP 1 @ErrorMerssage = strError FROM @ARPaymentInvalidData
						RAISERROR(@ErrorMerssage, 11, 1)							
						GOTO Post_Exit
					END	
				GOTO Post_Exit
			END			

	END
	
	IF (SELECT COUNT(1) FROM @ARPaymentPostData) > 1
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
			@ARPaymentPostData P
				ON PD.[intPaymentId] = P.[intPaymentId]
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
				@ARPaymentPostData P
					ON A.[intPaymentId] = P.[intPaymentId]
			WHERE
				C.[intInvoiceId] = @DiscountedInvID
			ORDER BY
				P.[intPaymentId]
				
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
		---- Delete zero payment temporarily
		--DELETE FROM A
		--FROM @ARPaymentPostData A
		--WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.[intPaymentId] = B.[intPaymentId])
		
	BEGIN TRY

	UPDATE ARP
	SET 
		ARP.[intAccountId] = SMCL.[intUndepositedFundsId]
	FROM
		tblARPayment ARP
	INNER JOIN
		@ARPaymentPostData PPD
			ON ARP.[intPaymentId] = PPD.[intPaymentId]
	INNER JOIN 
		(SELECT [intCompanyLocationId], [intUndepositedFundsId] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
			ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
	WHERE
		(ARP.[intAccountId] IS NULL OR PPD.[intBankAccountId] IS NULL)
		AND ISNULL(SMCL.[intUndepositedFundsId], 0) <> 0


	UPDATE ARP
	SET 
		ARP.[intWriteOffAccountId] = PPD.[intWriteOffAccountId]
	FROM
		tblARPayment ARP
	INNER JOIN
		@ARPaymentPostData PPD
			ON ARP.[intPaymentId] = PPD.[intPaymentId]
			AND PPD.[intWriteOffAccountId] IS NOT NULL
	INNER JOIN
		(SELECT [intPaymentMethodID], [strPaymentMethod] FROM tblSMPaymentMethod WITH (NOLOCK)) SMPM
			ON ARP.[intPaymentMethodId] = SMPM.[intPaymentMethodID]
			AND UPPER(RTRIM(LTRIM(ISNULL(SMPM.[strPaymentMethod], '')))) = UPPER('Write Off')
	WHERE
		ARP.[intWriteOffAccountId] IS NULL
		AND ISNULL(ARP.[strPaymentMethod], '') <> 'CF Invoice'


	UPDATE ARP
	SET 
		ARP.[intAccountId] = CMBA.[intGLAccountId]
	FROM
		tblARPayment ARP
	INNER JOIN
		@ARPaymentPostData PPD
			ON ARP.[intPaymentId] = PPD.[intPaymentId]
	INNER JOIN
		(SELECT [intBankAccountId], [intGLAccountId] FROM tblCMBankAccount WITH (NOLOCK)) CMBA
			ON PPD.[intBankAccountId] = CMBA.[intBankAccountId]		
					
	END TRY
	BEGIN CATCH	
		SELECT @ErrorMerssage = ERROR_MESSAGE()										
		GOTO Do_Rollback
	END CATCH
		
	BEGIN TRY
			  		 
		INSERT INTO @GLEntries (
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
		--DEBIT
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId			
			,intAccountId				= CASE WHEN A.[strPaymentMethod] = '' THEN A.[intWriteOffAccountId] 
											ELSE
												(CASE WHEN (@intWriteOffAccount IS NOT NULL AND @intWriteOffAccount > 0) THEN 
													CASE WHEN @intWriteOffAccount IS NOT NULL THEN @intWriteOffAccount ELSE @WriteOffAccount END
												ELSE (CASE WHEN A.[strPaymentMethod] = 'CF Invoice' AND @intCFAccount IS NOT NULL THEN @intCFAccount ELSE A.[intAccountId] END) END)
											END
			,dblDebit					=  (A.dblBaseAmountPaid + ISNULL((SELECT SUM(ISNULL(((((ISNULL(C.[dblBaseAmountDue], 0.00) + ISNULL(ARPD.[dblBaseInterest],0.00)) - ISNULL(ARPD.[dblBaseDiscount],0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - ARPD.[dblBasePayment]),0)) FROM tblARPaymentDetail ARPD INNER JOIN tblARInvoice C ON ARPD.[intInvoiceId] = C.[intInvoiceId]  WHERE ARPD.[intPaymentId] = A.[intPaymentId] AND ((C.[dblAmountDue] + C.[dblInterest]) - C.[dblDiscount]) = ((ARPD.[dblPayment] - ARPD.[dblInterest]) + ARPD.[dblDiscount])),0))
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= A.strNotes 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= A.[dblAmountPaid]  
			,[dblDebitReport]			= A.[dblAmountPaid] 
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= 0
			,[dblForeignRate]			= 0
			,[strRateType]				= ''			 
		FROM
			tblARPayment A			 
		INNER JOIN
			tblSMPaymentMethod PM
				ON A.intPaymentMethodId = PM.intPaymentMethodID
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
				
		UNION ALL
		--CREDIT Overpayment
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= @ARAccount
			,dblDebit					= 0
			,dblCredit					= A.dblBaseUnappliedAmount
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0	
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount)  
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= A.dblUnappliedAmount
			,[dblCreditReport]			= A.dblBaseUnappliedAmount
			,[dblReportingRate]			= 0
			,[dblForeignRate]			= 0
			,[strRateType]				= ''	 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@AROverpayment P
				ON A.[intPaymentId] = P.[intPaymentId]
		WHERE
			A.dblUnappliedAmount <> 0
				
		UNION ALL
		--CREDIT Prepayment
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= SMCL.[intSalesAdvAcct] 
			,dblDebit					= 0
			,dblCredit					= A.dblBaseAmountPaid
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = SMCL.[intSalesAdvAcct]) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= A.[dblAmountPaid]
			,[dblCreditReport]			= A.dblBaseAmountPaid
			,[dblReportingRate]			= 0
			,[dblForeignRate]			= 0
			,[strRateType]				= ''	 
		FROM
			tblARPayment A
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			tblSMCompanyLocation SMCL
				ON A.[intLocationId] = SMCL.[intCompanyLocationId] 
		INNER JOIN
			@ARPrepayment P
				ON A.[intPaymentId] = P.[intPaymentId]
		WHERE
			A.[dblAmountPaid] <> 0
				
				
		UNION ALL
		--DEBIT Discount
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= @DiscountAccount 
			,dblDebit					= B.[dblBaseDiscount]
			,dblCredit					= 0 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @DiscountAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= B.[dblDiscount]
			,[dblDebitReport]			= B.[dblBaseDiscount]
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType 	 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.[intPaymentId] = B.[intPaymentId]
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
		LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		WHERE
			B.[dblDiscount] <> 0
			AND B.[dblPayment] <> 0
			AND B.[dblAmountDue] = 0
		--GROUP BY
		--	A.[intPaymentId]
		--	,A.[strRecordNumber]
		--	,C.strCustomerNumber
		--	,A.[dtmDatePaid]
		--	,A.intCurrencyId	
			
		UNION ALL
		--DEBIT Interest
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= @ARAccount 
			,dblDebit					= B.[dblBaseInterest]
			,dblCredit					= 0 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0	
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= B.[dblInterest]
			,[dblDebitReport]			= B.[dblBaseInterest]
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType	 			 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.[intPaymentId] = B.[intPaymentId]
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
		LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		WHERE
			B.[dblInterest] <> 0
			AND B.[dblPayment] <> 0
			AND B.[dblAmountDue] = 0
		--GROUP BY
		--	A.[intPaymentId]
		--	,A.[strRecordNumber]
		--	,C.strCustomerNumber
		--	,A.[dtmDatePaid]
		--	,A.intCurrencyId	
			
			
		UNION ALL
		--CREDIT
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= B.[intAccountId] 
			,dblDebit					= 0
			,dblCredit					= (CASE WHEN (B.[dblBaseAmountDue] = (B.[dblBasePayment] - B.[dblBaseInterest]) + B.[dblBaseDiscount])
												THEN (B.[dblBasePayment] - B.[dblBaseInterest])  + B.[dblBaseDiscount]
												ELSE B.[dblBasePayment] END) 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.[intAccountId]) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= (CASE WHEN (B.[dblAmountDue] = (B.[dblPayment] - B.[dblInterest]) + B.[dblDiscount])
												THEN (B.[dblPayment] - B.[dblInterest])  + B.[dblDiscount]
												ELSE B.[dblPayment] END) 
			,[dblCreditReport]			= (CASE WHEN (B.[dblBaseAmountDue] = (B.[dblBasePayment] - B.[dblBaseInterest]) + B.[dblBaseDiscount])
												THEN (B.[dblBasePayment] - B.[dblBaseInterest])  + B.[dblBaseDiscount]
												ELSE B.[dblBasePayment] END)
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType				 
		FROM
			tblARPayment A 
		INNER JOIN 
			tblARPaymentDetail B 
				ON A.[intPaymentId] = B.[intPaymentId]
		INNER JOIN 
			tblARCustomer C 
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
		LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		WHERE
			B.[dblPayment] <> 0
		--GROUP BY
		--	A.[intPaymentId]
		--	,A.[strRecordNumber]
		--	,B.[intAccountId]
		--	,C.strCustomerNumber
		--	,A.[dtmDatePaid]
		--	,A.intCurrencyId
		--	,A.ysnInvoicePrepayment
			
		UNION ALL

		--GAIN LOSS
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= @GainLossAccount
			,dblDebit					= CASE WHEN (ISNULL(((((ISNULL(I.[dblBaseAmountDue], 0.00) + ISNULL(B.[dblBaseInterest],0.00)) - ISNULL(B.[dblBaseDiscount],0.00) * (CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.[dblBasePayment]),0)) > 0 THEN 0 ELSE ABS((ISNULL(((((ISNULL(I.[dblBaseAmountDue], 0.00) + ISNULL(B.[dblBaseInterest],0.00)) - ISNULL(B.[dblBaseDiscount],0.00) * (CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.[dblBasePayment]),0))) END
			,dblCredit					= CASE WHEN ((ISNULL(((((ISNULL(I.[dblBaseAmountDue], 0.00) + ISNULL(B.[dblBaseInterest],0.00)) - ISNULL(B.[dblBaseDiscount],0.00) * (CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.[dblBasePayment]),0))) > 0 THEN ABS((ISNULL(((((ISNULL(I.[dblBaseAmountDue], 0.00) + ISNULL(B.[dblBaseInterest],0.00)) - ISNULL(B.[dblBaseDiscount],0.00) * (CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.[dblBasePayment]),0))) ELSE 0 END
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.[intAccountId]) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 0
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= 0
			,[dblForeignRate]			= 0
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType				 
		FROM
			tblARPaymentDetail B
		INNER JOIN 
			tblARPayment A  
				ON B.[intPaymentId] = A.[intPaymentId]
		INNER JOIN 
			tblARCustomer C 
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			tblARInvoice I
				ON B.[intInvoiceId] = I.[intInvoiceId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
		LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		WHERE
			((ISNULL(((((ISNULL(I.[dblBaseAmountDue], 0.00) + ISNULL(B.[dblBaseInterest],0.00)) - ISNULL(B.[dblBaseDiscount],0.00) * (CASE WHEN I.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.[dblBasePayment]),0)))  <> 0
			AND ((I.[dblAmountDue] + I.[dblInterest]) - I.[dblDiscount]) = ((B.[dblPayment] - B.[dblInterest]) + B.[dblDiscount])
		--GROUP BY
		--	A.[intPaymentId]
		--	,A.[strRecordNumber]
		--	,B.[intAccountId]
		--	,C.strCustomerNumber
		--	,A.[dtmDatePaid]
		--	,A.intCurrencyId
		--	,A.ysnInvoicePrepayment

		UNION ALL
		
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= @ARAccount
			,dblDebit					= 0
			,dblCredit					= B.[dblBaseDiscount]
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= B.[dblDiscount]
			,[dblCreditReport]			= B.[dblBaseDiscount]
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType		 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.[intPaymentId] = B.[intPaymentId]
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
		LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		WHERE
			B.[dblDiscount] <> 0
			AND B.[dblPayment] <> 0
			AND B.[dblAmountDue] = 0
		--GROUP BY
		--	A.[intPaymentId]
		--	,A.[strRecordNumber]
		--	,C.strCustomerNumber
		--	,A.[dtmDatePaid]
		--	,A.intCurrencyId			
			
		UNION ALL
		
		SELECT
			 dtmDate					= CAST(A.[dtmDatePaid] AS DATE)
			,strBatchID					= @BatchId
			,intAccountId				= ISNULL(P.intInterestAccountId, @IncomeInterestAccount)
			,dblDebit					= 0
			,dblCredit					= B.[dblBaseInterest]
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = ISNULL(P.intInterestAccountId, @IncomeInterestAccount)) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.[dtmDatePaid]
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.[intPaymentId]
			,ysnIsUnposted				= 0
			,intUserId					= @UserId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.[strRecordNumber]
			,intTransactionId			= A.[intPaymentId]
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= B.[dblInterest]
			,[dblCreditReport]			= B.[dblBaseInterest]
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType		  
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.[intPaymentId] = B.[intPaymentId]
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARPaymentPostData P
				ON A.[intPaymentId] = P.[intPaymentId]
		LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		WHERE
			B.[dblInterest] <> 0
			AND B.[dblPayment] <> 0
			AND B.[dblAmountDue] = 0
		--GROUP BY
		--	A.[intPaymentId]
		--	,A.[strRecordNumber]
		--	,C.strCustomerNumber
		--	,A.[dtmDatePaid]
		--	,A.intCurrencyId
		--	,P.intInterestAccountId
			
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
				,GL.[intAccountId]
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
				,GL.strJournalLineDescription
				,GL.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @UserId
				,intEntityId					= @UserEntityID
				,GL.strTransactionId
				,GL.intTransactionId
				,GL.[strTransactionType]
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
			INNER JOIN
				@ARPaymentPostData P
					ON GL.intTransactionId = P.[intPaymentId]  
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
			@ARPaymentPostData B  
		INNER JOIN 
			dbo.tblGLPostRecap GLDR 
				ON (B.strTransactionId = GLDR.strTransactionId OR B.[intPaymentId] = GLDR.intTransactionId)  
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
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value
			,Credit.Value
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,A.[dblDebitForeign]
			,A.[dblCreditForeign]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblExchangeRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,A.[strRateType]
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.[intAccountId] = B.[intAccountId]
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit

		DECLARE @tmpBatchId NVARCHAR(100)
		SELECT @tmpBatchId = [strBatchId] 
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.[intAccountId] = B.[intAccountId]
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit

		UPDATE tblGLPostRecap SET strDescription = ABC.strDescription
		FROM 
			tblGLPostRecap
		INNER JOIN
		(
			SELECT GLA.[intAccountId], GLA.strDescription 
			FROM 
				(SELECT intAccountId, strDescription, strBatchId FROM tblGLPostRecap) GLPR
				INNER JOIN 
				(SELECT intAccountId, strDescription FROM tblGLAccount) GLA ON GLPR.[intAccountId] = GLPR.[intAccountId]
				WHERE
					(ISNULL(GLPR.strDescription, '') = '' OR (GLPR.strDescription = 'Thank you for your business!'))
					AND GLPR.strBatchId = @tmpBatchId
		) ABC ON tblGLPostRecap.[intAccountId] = ABC.[intAccountId]
		WHERE 
			((ISNULL(tblGLPostRecap.strDescription, '') = '') OR  (tblGLPostRecap.strDescription = 'Thank you for your business!'))
			AND tblGLPostRecap.strBatchId = @tmpBatchId

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
					@ARPaymentPostData PPD
						ON PLD.[intPaymentId] = PPD.[intPaymentId]
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
			EXEC dbo.uspGLBookEntries @GLEntries, @Post
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH	
		 
		BEGIN TRY 
		IF @Post = 0
			BEGIN
			
			-- Insert Zero Payments for updating
			INSERT INTO @ARPaymentPostData
				([intPaymentId]
				,[strTransactionId]
				,[intARAccountId]
				,[intBankAccountId]
				,[intDiscountAccountId]
				,[intInterestAccountId]
				,[intWriteOffAccountId]
				,[intGainLossAccountId]
				,[intCFAccountId]
				,[intEntityId])
			SELECT
				 [intPaymentId]			= Z.[intPaymentId]
				,[strTransactionId]		= Z.strTransactionId
				,[intARAccountId]		= @ARAccount
				,[intBankAccountId]		= Z.intBankAccountId
				,[intDiscountAccountId]	= @DiscountAccount
				,[intInterestAccountId]	= Z.intInterestAccountId
				,[intWriteOffAccountId]	= Z.intWriteOffAccountId
				,[intGainLossAccountId]	= @GainLossAccount
				,[intCFAccountId]		= @intCFAccount
				,[intEntityId]			= Z.intEntityId
			FROM 
				@ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARPaymentPostData WHERE intPaymentId = Z.[intPaymentId])

			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.[dblPayment] = ISNULL(tblARInvoice.[dblPayment],0.00) - P.[dblPayment] 
				,tblARInvoice.[dblBasePayment] = ISNULL(tblARInvoice.[dblBasePayment],0.00) - P.[dblBasePayment] 
				,tblARInvoice.[dblDiscount] = ISNULL(tblARInvoice.[dblDiscount],0.00) - P.[dblDiscount]			
				,tblARInvoice.[dblBaseDiscount] = ISNULL(tblARInvoice.[dblBaseDiscount],0.00) - P.[dblBaseDiscount]			
				,tblARInvoice.[dblInterest] = ISNULL(tblARInvoice.[dblInterest],0.00) - P.[dblInterest]				
				,tblARInvoice.[dblBaseInterest] = ISNULL(tblARInvoice.[dblBaseInterest],0.00) - P.[dblBaseInterest]				
			FROM
				(
					SELECT 
						SUM(A.[dblPayment] * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblPayment
						, SUM(A.[dblBasePayment] * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblBasePayment
						, SUM(A.[dblDiscount]) dblDiscount
						, SUM(A.[dblBaseDiscount]) dblBaseDiscount
						, SUM(A.[dblInterest]) dblInterest						
						, SUM(A.[dblBaseInterest]) dblBaseInterest						
						,A.[intInvoiceId] 
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.[intPaymentId] = B.[intPaymentId]						
					INNER JOIN tblARInvoice C
						ON A.[intInvoiceId] = C.[intInvoiceId]
					WHERE
						A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
						AND ISNULL(B.ysnInvoicePrepayment,0) = 0
					GROUP BY
						A.[intInvoiceId]
				) P
			WHERE
				tblARInvoice.[intInvoiceId] = P.[intInvoiceId]
				
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.[dblAmountDue] = C.[dblInvoiceTotal] - ((C.[dblPayment] - C.[dblInterest]) + C.[dblDiscount])
				,tblARInvoice.[dblBaseAmountDue] = C.dblBaseInvoiceTotal - ((C.[dblBasePayment] - C.[dblBaseInterest]) + C.[dblBaseDiscount])
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.[intPaymentId] = B.[intPaymentId]
			INNER JOIN tblARInvoice C
				ON B.[intInvoiceId] = C.[intInvoiceId]
			WHERE
				A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
				AND ISNULL(A.ysnInvoicePrepayment,0) = 0
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.[ysnPaid] = 0
				--,tblARInvoice.[dtmPostDate] = ISNULL((SELECT TOP 1 dtmDate FROM tblGLDetail WHERE strTransactionId = C.[strInvoiceNumber] AND intTransactionId = C.[intInvoiceId] AND ysnIsUnposted = 0), C.[dtmPostDate])
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.[intPaymentId] = B.[intPaymentId]
			INNER JOIN tblARInvoice C
				ON B.[intInvoiceId] = C.[intInvoiceId]				
			WHERE
				A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
				AND ISNULL(A.ysnInvoicePrepayment,0) = 0
				
				
			UPDATE 
				tblARPaymentDetail
			SET 
				dblPayment = CASE WHEN (((ISNULL(C.[dblAmountDue],0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.[dblPayment] THEN (((ISNULL(C.[dblAmountDue],0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.[dblPayment] END
				,dblBasePayment = CASE WHEN (((ISNULL(C.[dblBaseAmountDue],0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.[dblBasePayment] THEN (((ISNULL(C.[dblBaseAmountDue],0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.[dblBasePayment] END
			FROM
				tblARPaymentDetail A
			INNER JOIN
				tblARPayment B
					ON A.[intPaymentId] = B.[intPaymentId]
					AND A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
			INNER JOIN 
				tblARInvoice C
					ON A.[intInvoiceId] = C.[intInvoiceId]
			WHERE
				ISNULL(B.[ysnInvoicePrepayment],0) = 0
					
			UPDATE 
				tblARPaymentDetail
			SET 
				dblAmountDue = ((((ISNULL(C.[dblAmountDue], 0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00)) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) - A.[dblPayment])
				,dblBaseAmountDue = ((((ISNULL(C.[dblBaseAmountDue], 0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00)) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) - A.[dblBasePayment])
			FROM
				tblARPaymentDetail A
			INNER JOIN
				tblARPayment B
					ON A.[intPaymentId] = B.[intPaymentId]
					AND A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
			INNER JOIN 
				tblARInvoice C
					ON A.[intInvoiceId] = C.[intInvoiceId]
			WHERE
				ISNULL(B.[ysnInvoicePrepayment],0) = 0							
					
			UPDATE tblGLDetail
				SET tblGLDetail.ysnIsUnposted = 1
			FROM tblARPayment A
				INNER JOIN tblGLDetail B
					ON A.[intPaymentId] = B.intTransactionId
			WHERE B.[strTransactionId] IN (SELECT strRecordNumber FROM tblARPayment WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData))					
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARPaymentPostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.[intPaymentId] = B.[intPaymentId])						
					
			-- Creating the temp table:
			DECLARE @isSuccessful BIT
			CREATE TABLE #tmpCMBankTransaction (strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,UNIQUE (strTransactionId))

			INSERT INTO #tmpCMBankTransaction
			SELECT strRecordNumber FROM tblARPayment A
			INNER JOIN @ARPaymentPostData B ON A.[intPaymentId] = B.[intPaymentId]

			-- Calling the stored procedure
			DECLARE @ReverseDate AS DATETIME
			SET @ReverseDate = @PostDate
			EXEC uspCMBankTransactionReversal @UserId, @ReverseDate, @isSuccessful OUTPUT
			
			--update payment record based on record from tblCMBankTransaction
			UPDATE tblARPayment
				SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
			FROM tblARPayment A 
				INNER JOIN tblCMBankTransaction B
					ON A.[strRecordNumber] = B.strTransactionId
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)	
			
			--DELETE IF NOT CHECK PAYMENT AND DOESN'T HAVE CHECK NUMBER
			DELETE FROM tblCMBankTransaction
			WHERE strTransactionId IN (
			SELECT strRecordNumber 
			FROM tblARPayment
				INNER JOIN tblSMPaymentMethod ON tblARPayment.intPaymentMethodId = tblSMPaymentMethod.intPaymentMethodID
			 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData) 
			AND tblSMPaymentMethod.[strPaymentMethod] != 'Check' 
			OR (ISNULL(tblARPayment.strPaymentInfo,'') = '' AND tblSMPaymentMethod.[strPaymentMethod] = 'Check')
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
					@ARPaymentPostData P
						ON A.[intPaymentId] = P.[intPaymentId]
				INNER JOIN
					tblCMUndepositedFund B 
						ON A.[intPaymentId] = B.intSourceTransactionId 
						AND A.[strRecordNumber] = B.strSourceTransactionId
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
			--	 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData) 
			--)							
				
			-- Insert Zero Payments for updating
			INSERT INTO @ARPaymentPostData
				([intPaymentId]
				,[strTransactionId]
				,[intARAccountId]
				,[intBankAccountId]
				,[intDiscountAccountId]
				,[intInterestAccountId]
				,[intWriteOffAccountId]
				,[intGainLossAccountId]
				,[intCFAccountId]
				,[intEntityId])
			SELECT
				 [intPaymentId]			= Z.[intPaymentId]
				,[strTransactionId]		= Z.strTransactionId
				,[intARAccountId]		= @ARAccount
				,[intBankAccountId]		= Z.intBankAccountId
				,[intDiscountAccountId]	= @DiscountAccount
				,[intInterestAccountId]	= Z.intInterestAccountId
				,[intWriteOffAccountId]	= Z.intWriteOffAccountId
				,[intGainLossAccountId]	= @GainLossAccount
				,[intCFAccountId]		= @intCFAccount
				,[intEntityId]			= Z.intEntityId
			 FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARPaymentPostData WHERE intPaymentId = Z.[intPaymentId])			
			
			--update payment record
			UPDATE tblARPayment
				SET ysnPosted= 0
			FROM tblARPayment A 
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)

			--Insert Successfully unposted transactions.
			--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			--SELECT 
			--	@UnpostSuccessfulMsg,
			--	'Receivable',
			--	A.[strRecordNumber],
			--	@BatchId,
			--	A.[intPaymentId]
			--FROM tblARPayment A
			--WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)

			UPDATE ILD
			SET
				 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
				,ILD.[strPostingMessage]	= @PostSuccessfulMsg
				,ILD.[strBatchId]			= @BatchId
				,ILD.[strPostedTransactionId] = PID.[strTransactionId] 
			FROM
				tblARPaymentIntegrationLogDetail ILD WITH (NOLOCK)
			INNER JOIN
				@ARPaymentPostData PID
					ON ILD.[intPaymentId] = PID.[intPaymentId]
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL
			
			--DELETE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN			
					DECLARE @PaymentIdToDelete int		
					SELECT TOP 1 @PaymentIdToDelete = intPaymentId FROM @AROverpayment
					
					EXEC [dbo].[uspARDeleteOverPayment] @PaymentIdToDelete, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intPaymentId = @PaymentIdToDelete
				END	
				
			--DELETE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN			
					DECLARE @PaymentIdToDeletePre int		
					SELECT TOP 1 @PaymentIdToDeletePre = intPaymentId FROM @ARPrepayment
					
					EXEC [dbo].[uspARDeletePrePayment] @PaymentIdToDeletePre, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intPaymentId = @PaymentIdToDeletePre
					
				END
				
			UPDATE 
				tblARPayment
			SET 
				intAccountId = NULL			
			WHERE
				intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)		
									

			END
		ELSE
			BEGIN
			
			--CREATE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN
					DECLARE @PaymentIdToAdd int
					SELECT TOP 1 @PaymentIdToAdd = intPaymentId FROM @AROverpayment
					
					EXEC [dbo].[uspARCreateOverPayment] @PaymentIdToAdd, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intPaymentId = @PaymentIdToAdd
				END
				
			--CREATE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN
					DECLARE @PaymentIdToAddPre int
					SELECT TOP 1 @PaymentIdToAddPre = intPaymentId FROM @ARPrepayment
					
					EXEC [dbo].[uspARCreatePrePayment] @PaymentIdToAddPre, 1, @BatchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intPaymentId = @PaymentIdToAddPre
				END				

			-- Insert Zero Payments for updating
			INSERT INTO @ARPaymentPostData
				([intPaymentId]
				,[strTransactionId]
				,[intARAccountId]
				,[intBankAccountId]
				,[intDiscountAccountId]
				,[intInterestAccountId]
				,[intWriteOffAccountId]
				,[intGainLossAccountId]
				,[intCFAccountId]
				,[intEntityId])
			SELECT
				 [intPaymentId]			= Z.[intPaymentId]
				,[strTransactionId]		= Z.strTransactionId
				,[intARAccountId]		= @ARAccount
				,[intBankAccountId]		= Z.intBankAccountId
				,[intDiscountAccountId]	= @DiscountAccount
				,[intInterestAccountId]	= Z.intInterestAccountId
				,[intWriteOffAccountId]	= Z.intWriteOffAccountId
				,[intGainLossAccountId]	= @GainLossAccount
				,[intCFAccountId]		= @intCFAccount
				,[intEntityId]			= Z.intEntityId
			FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARPaymentPostData WHERE intPaymentId = Z.[intPaymentId])		

			-- Delete Invoice with Zero Payment
			DELETE FROM tblARPaymentDetail
			WHERE
				dblPayment = 0
				AND intInvoiceId IN (SELECT intInvoiceId FROM @ARPaymentPostData)

			-- Update the posted flag in the transaction table
			UPDATE tblARPayment
			SET		ysnPosted = 1
					,intCurrentStatus = 4 
			WHERE	intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)			

			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.[dblPayment] = ISNULL(tblARInvoice.[dblPayment],0.00) + P.[dblPayment] 
				,tblARInvoice.[dblBasePayment] = ISNULL(tblARInvoice.[dblBasePayment],0.00) + P.[dblBasePayment] 
				,tblARInvoice.[dblDiscount] = ISNULL(tblARInvoice.[dblDiscount],0.00) + P.[dblDiscount]				
				,tblARInvoice.[dblBaseDiscount] = ISNULL(tblARInvoice.[dblBaseDiscount],0.00) + P.[dblBaseDiscount]				
				,tblARInvoice.[dblInterest] = ISNULL(tblARInvoice.[dblInterest],0.00) + P.[dblInterest]
				,tblARInvoice.[dblBaseInterest] = ISNULL(tblARInvoice.[dblBaseInterest],0.00) + P.[dblBaseInterest]
			FROM
				(
					SELECT 
						SUM(A.[dblPayment] * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblPayment
						,SUM(A.[dblBasePayment] * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) dblBasePayment
						,SUM(A.[dblDiscount]) dblDiscount
						,SUM(A.[dblBaseDiscount]) dblBaseDiscount
						,SUM(A.[dblInterest]) dblInterest
						,SUM(A.[dblBaseInterest]) dblBaseInterest
						,A.[intInvoiceId] 
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.[intPaymentId] = B.[intPaymentId]						
					INNER JOIN tblARInvoice C
						ON A.[intInvoiceId] = C.[intInvoiceId]
					WHERE
						A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
						AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId] WHERE ARID.intPrepayTypeId > 0 AND ARID.[intInvoiceId] = C.[intInvoiceId] AND ARI.[intPaymentId] = A.[intPaymentId])						
					GROUP BY
						A.[intInvoiceId]
				) P
			WHERE
				tblARInvoice.[intInvoiceId] = P.[intInvoiceId]				
				
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.[dblAmountDue] = (C.[dblInvoiceTotal] + C.[dblInterest]) - (C.[dblPayment] + C.[dblDiscount])
				,tblARInvoice.[dblBaseAmountDue] = (C.dblBaseInvoiceTotal + C.[dblBaseInterest]) - (C.[dblBasePayment] + C.[dblBaseDiscount])
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.[intPaymentId] = B.[intPaymentId]
			INNER JOIN tblARInvoice C
				ON B.[intInvoiceId] = C.[intInvoiceId]
			WHERE
				A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
				AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId] WHERE ARID.intPrepayTypeId > 0 AND ARID.[intInvoiceId] = C.[intInvoiceId] AND ARI.[intPaymentId] = A.[intPaymentId])						
					
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.[ysnPaid] = (CASE WHEN (C.[dblAmountDue]) = 0 THEN 1 ELSE 0 END)
				--,tblARInvoice.[dtmPostDate] = (CASE WHEN (C.[dblAmountDue]) = 0 THEN @PostDate ELSE C.[dtmPostDate] END)
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.[intPaymentId] = B.[intPaymentId]
			INNER JOIN tblARInvoice C
				ON B.[intInvoiceId] = C.[intInvoiceId]
			WHERE
				A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)	
				AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId] WHERE ARID.intPrepayTypeId > 0 AND ARID.[intInvoiceId] = C.[intInvoiceId] AND ARI.[intPaymentId] = A.[intPaymentId])						
								

			UPDATE 
				tblARPaymentDetail
			SET 
				dblAmountDue = ISNULL(C.[dblAmountDue], 0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)-- ISNULL(A.[dblDiscount],0.00)) - A.[dblPayment]							
				,dblBaseAmountDue = ISNULL(C.[dblBaseAmountDue], 0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)-- ISNULL(A.[dblDiscount],0.00)) - A.[dblPayment]							
			FROM
				tblARPaymentDetail A
			INNER JOIN
				tblARPayment B
					ON A.[intPaymentId] = B.[intPaymentId]
					AND A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
			INNER JOIN 
				tblARInvoice C
					ON A.[intInvoiceId] = C.[intInvoiceId]
			WHERE
				ISNULL(B.[ysnInvoicePrepayment],0) = 0					
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARPaymentPostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.[intPaymentId] = B.[intPaymentId])						

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
			--	strTransactionId = A.[strRecordNumber],
			--	intBankTransactionTypeID = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AR Payment'),
			--	intBankAccountID = (SELECT TOP 1 intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = A.[intAccountId]),
			--	intCurrencyID = A.intCurrencyId,
			--	dblExchangeRate = 0,
			--	dtmDate = A.[dtmDatePaid],
			--	strPayee = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = B.[intEntityCustomerId]),
			--	intPayeeID = B.[intEntityCustomerId],
			--	strAddress = '',
			--	strZipCode = '',
			--	strCity = '',
			--	strState = '',
			--	strCountry = '',
			--	dblAmount = A.[dblAmountPaid],
			--	strAmountInWords = dbo.fnConvertNumberToWord(A.[dblAmountPaid]),
			--	strMemo = SUBSTRING(ISNULL(A.strPaymentInfo + ' - ', '') + ISNULL(A.strNotes, ''), 1 ,255),
			--	strReferenceNo = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE A.strPaymentInfo END,
			--	ysnCheckToBePrinted = 1,
			--	ysnCheckVoid = 0,
			--	ysnPosted = 1,
			--	strLink = @BatchId,
			--	ysnClr = 0,
			--	dtmDateReconciled = NULL,
			--	intCreatedUserID = @UserId,
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
			--			ON A.[intAccountId] = GL.[intAccountId] 
			--	INNER JOIN 
			--		tblGLAccountGroup AG
			--			ON GL.intAccountGroupId = AG.intAccountGroupId 		
			--	INNER JOIN 
			--		tblGLAccountCategory AC
			--			ON GL.intAccountCategoryId = AC.intAccountCategoryId										 
			--	INNER JOIN
			--		tblCMBankAccount BA
			--			ON A.[intAccountId] = BA.intGLAccountId 						
			--	WHERE
			--		AC.strAccountCategory = 'Cash Account'
			--		AND BA.intGLAccountId IS NOT NULL
			--		AND BA.ysnActive = 1
			--		AND A.[intPaymentId] IN (SELECT intPaymentId FROM @ARPaymentPostData)
					
											
			-- Insert Zero Payments for updating
			INSERT INTO @ARPaymentPostData
				([intPaymentId]
				,[strTransactionId]
				,[intARAccountId]
				,[intBankAccountId]
				,[intDiscountAccountId]
				,[intInterestAccountId]
				,[intWriteOffAccountId]
				,[intGainLossAccountId]
				,[intCFAccountId]
				,[intEntityId])
			SELECT
				 [intPaymentId]			= Z.[intPaymentId]
				,[strTransactionId]		= Z.strTransactionId
				,[intARAccountId]		= @ARAccount
				,[intBankAccountId]		= Z.intBankAccountId
				,[intDiscountAccountId]	= @DiscountAccount
				,[intInterestAccountId]	= Z.intInterestAccountId
				,[intWriteOffAccountId]	= Z.intWriteOffAccountId
				,[intGainLossAccountId]	= @GainLossAccount
				,[intCFAccountId]		= @intCFAccount
				,[intEntityId]			= Z.intEntityId
			FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARPaymentPostData WHERE intPaymentId = Z.[intPaymentId])										

			--Insert Successfully posted transactions.
			--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			--SELECT 
			--	@PostSuccessfulMsg,
			--	'Receivable',
			--	A.[strRecordNumber],
			--	@BatchId,
			--	A.[intPaymentId]
			--FROM tblARPayment A
			--WHERE intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)
			UPDATE ILD
			SET
				 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
				,ILD.[strPostingMessage]	= @PostSuccessfulMsg
				,ILD.[strBatchId]			= @BatchId
				,ILD.[strPostedTransactionId] = PID.[strTransactionId] 
			FROM
				tblARPaymentIntegrationLogDetail ILD WITH (NOLOCK)
			INNER JOIN
				@ARPaymentPostData PID
					ON ILD.[intPaymentId] = PID.[intPaymentId]
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL

			UPDATE tblARPayment
			SET		intCurrentStatus = NULL 
			WHERE	intPaymentId IN (SELECT intPaymentId FROM @ARPaymentPostData)	
							
			END						

		UPDATE 
			B
		SET 
			B.intCurrentStatus = 4
		FROM
			tblARPaymentDetail A
		INNER JOIN
			tblARPayment B
				ON A.[intPaymentId] = B.[intPaymentId]
				AND A.[intPaymentId] NOT IN (SELECT intPaymentId FROM @ARPaymentPostData)
		INNER JOIN 
			tblARInvoice C
				ON A.[intInvoiceId] = C.[intInvoiceId]
		WHERE
			B.[ysnPosted] = 1
			AND ISNULL(B.[ysnInvoicePrepayment],0) = 0

		UPDATE 
			tblARPaymentDetail
		SET 
			dblAmountDue = ISNULL(C.[dblAmountDue], 0.00) -- ISNULL(A.[dblDiscount],0.00)) - A.[dblPayment]							
			,dblBaseAmountDue = ISNULL(C.[dblBaseAmountDue], 0.00) -- ISNULL(A.[dblDiscount],0.00)) - A.[dblPayment]							
		FROM
			tblARPaymentDetail A
		INNER JOIN
			tblARPayment B
				ON A.[intPaymentId] = B.[intPaymentId]
				AND A.[intPaymentId] NOT IN (SELECT intPaymentId FROM @ARPaymentPostData)
		INNER JOIN 
			tblARInvoice C
				ON A.[intInvoiceId] = C.[intInvoiceId]
		WHERE
			B.[ysnPosted] = 1
			AND ISNULL(B.[ysnInvoicePrepayment],0) = 0		

		UPDATE 
			B
		SET 
			B.intCurrentStatus = NULL
		FROM
			tblARPaymentDetail A
		INNER JOIN
			tblARPayment B
				ON A.[intPaymentId] = B.[intPaymentId]
				AND A.[intPaymentId] NOT IN (SELECT intPaymentId FROM @ARPaymentPostData)
		INNER JOIN 
			tblARInvoice C
				ON A.[intInvoiceId] = C.[intInvoiceId]
		WHERE
			B.[ysnPosted] = 1
			AND ISNULL(B.[ysnInvoicePrepayment],0) = 0
						
		UPDATE 
			tblARPaymentDetail
		SET 
			dblPayment = CASE WHEN (((ISNULL(C.[dblAmountDue],0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00)) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.[dblPayment] THEN (((ISNULL(C.[dblAmountDue],0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.[dblPayment] END
			,dblBasePayment = CASE WHEN (((ISNULL(C.[dblBaseAmountDue],0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00)) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) < A.[dblBasePayment] THEN (((ISNULL(C.[dblBaseAmountDue],0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00))* (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)) ELSE A.[dblBasePayment] END
		FROM
			tblARPaymentDetail A
		INNER JOIN
			tblARPayment B
				ON A.[intPaymentId] = B.[intPaymentId]
				AND A.[intPaymentId] NOT IN (SELECT intPaymentId FROM @ARPaymentPostData)
		INNER JOIN 
			tblARInvoice C
				ON A.[intInvoiceId] = C.[intInvoiceId]
		WHERE
			B.[ysnPosted] = 0
			AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
				
		UPDATE 
			tblARPaymentDetail
		SET 
			dblAmountDue = ((((ISNULL(C.[dblAmountDue], 0.00) + ISNULL(A.[dblInterest],0.00)) - ISNULL(A.[dblDiscount],0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - A.[dblPayment])
			,dblBaseAmountDue = ((((ISNULL(C.[dblBaseAmountDue], 0.00) + ISNULL(A.[dblBaseInterest],0.00)) - ISNULL(A.[dblBaseDiscount],0.00) * (CASE WHEN C.[strTransactionType] IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - A.[dblBasePayment])
		FROM
			tblARPaymentDetail A
		INNER JOIN
			tblARPayment B
				ON A.[intPaymentId] = B.[intPaymentId]
				AND A.[intPaymentId] NOT IN (SELECT intPaymentId FROM @ARPaymentPostData)
		INNER JOIN 
			tblARInvoice C
				ON A.[intInvoiceId] = C.[intInvoiceId]
		WHERE
			B.[ysnPosted] = 0
			AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
			
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

		BEGIN TRY			
			DECLARE @PaymentsToUpdate TABLE (intPaymentId INT);
			
			INSERT INTO @PaymentsToUpdate(intPaymentId)
			SELECT DISTINCT intPaymentId FROM @ARPaymentPostData
				
			WHILE EXISTS(SELECT TOP 1 NULL FROM @PaymentsToUpdate ORDER BY intPaymentId)
				BEGIN
				
					DECLARE @intPaymentIntegractionId INT
							,@actionType AS NVARCHAR(50)

					SELECT @actionType = CASE WHEN @Post = 1 THEN 'Posted'  ELSE 'Unposted' END 
					
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

	IF @Recap = 0
		BEGIN			
			DECLARE @tblPaymentsToUpdateBudget TABLE (intPaymentId INT)			

			INSERT INTO @tblPaymentsToUpdateBudget
			SELECT DISTINCT intPaymentId FROM @ARPaymentPostData

			--Update Customer's AR Balance
			UPDATE CUSTOMER
			SET dblARBalance = dblARBalance - (CASE WHEN @Post = 1 THEN ISNULL(PAYMENT.dblTotalPayment, 0) ELSE ISNULL(PAYMENT.dblTotalPayment, 0) * -1 END)
			FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
			INNER JOIN (SELECT intEntityCustomerId
							 , dblTotalPayment	= (SUM(PD.dblPayment) + SUM(PD.dblDiscount)) - SUM(PD.dblInterest)
						FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
							INNER JOIN (SELECT intPaymentId
											 , intEntityCustomerId
										FROM dbo.tblARPayment WITH (NOLOCK)
							) P ON PD.[intPaymentId] = P.[intPaymentId]
						WHERE PD.[intPaymentId] IN (SELECT intPaymentId FROM @tblPaymentsToUpdateBudget)
						GROUP BY intEntityCustomerId
			) PAYMENT ON CUSTOMER.[intEntityId] = PAYMENT.intEntityCustomerId

			--Update Customer's Budget 
			WHILE EXISTS (SELECT NULL FROM @tblPaymentsToUpdateBudget)
				BEGIN
					DECLARE @paymentToUpdate INT,
							@customerId		 INT

					SELECT TOP 1 @paymentToUpdate = intPaymentId FROM @tblPaymentsToUpdateBudget ORDER BY intPaymentId
					SELECT @customerId = intEntityCustomerId FROM tblARPayment WHERE intPaymentId = @paymentToUpdate
			
					EXEC dbo.uspARUpdateCustomerBudget @paymentToUpdate, @Post

					DELETE FROM @tblPaymentsToUpdateBudget WHERE intPaymentId = @paymentToUpdate
				END
			
			--Process ACH Payments
			IF @Post = 1
				BEGIN
					DECLARE @tblACHPayments TABLE (intPaymentId INT)
					DECLARE @intACHPaymentMethodId INT

					SELECT TOP 1 @intACHPaymentMethodId = intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH'

					INSERT INTO @tblACHPayments
					SELECT ACH.[intPaymentId] FROM @ARPaymentPostData ACH 
						INNER JOIN tblARPayment P ON ACH.[intPaymentId] = P.[intPaymentId] AND P.intPaymentMethodId = @intACHPaymentMethodId

					WHILE EXISTS (SELECT NULL FROM @tblACHPayments)
						BEGIN
							DECLARE @paymentIdACH INT

							SELECT TOP 1 @paymentIdACH = intPaymentId FROM @tblACHPayments ORDER BY intPaymentId

							EXEC dbo.uspARProcessACHPayments @paymentIdACH, @UserId

							DELETE FROM @tblACHPayments WHERE intPaymentId = @paymentIdACH				
						END
				END
		END	

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
					@ARPaymentPostData PPD
						ON PLD.[intPaymentId] = PPD.[intPaymentId]
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
	