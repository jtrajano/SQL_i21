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

IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
 
DECLARE @ARReceivablePostData TABLE (
	intPaymentId			INT PRIMARY KEY,
	strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intWriteOffAccountId	INT NULL,
	intEntityId				INT,
	intInterestAccountId	INT NULL,
	intSalesDiscounts	INT NULL,
	UNIQUE (intPaymentId)
);

DECLARE @ARReceivableInvalidData TABLE (
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
	intSalesDiscounts INT NULL,
	UNIQUE (intPaymentId)
);

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE  @ARAccount				INT
		,@DiscountAccount		INT
		,@WriteOffAccount		INT
		,@IncomeInterestAccount	INT
		,@GainLossAccount		INT
		,@DefaultCurrencyId		INT
		
DECLARE @totalInvalid INT
DECLARE @totalRecords INT
DECLARE @ErrorMerssage NVARCHAR(MAX)
DECLARE @intCFAccount INT

SET @WriteOffAccount = NULL
SET @IncomeInterestAccount = NULL
SET @GainLossAccount = NULL
SET @intCFAccount = NULL
		
SET @ARAccount = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0)
SET @DiscountAccount = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
SET @WriteOffAccount = (SELECT TOP 1 intWriteOffAccountId FROM tblARCompanyPreference WHERE intWriteOffAccountId IS NOT NULL AND intWriteOffAccountId <> 0)
SET @IncomeInterestAccount = (SELECT TOP 1 intInterestIncomeAccountId FROM tblARCompanyPreference WHERE intInterestIncomeAccountId IS NOT NULL AND intInterestIncomeAccountId <> 0)
SET @GainLossAccount = (SELECT TOP 1 intAccountsReceivableRealizedId FROM tblSMMultiCurrency WHERE intAccountsReceivableRealizedId IS NOT NULL AND intAccountsReceivableRealizedId <> 0)
SET @intCFAccount = (SELECT TOP 1 intGLAccountId FROM tblCFCompanyPreference WHERE intGLAccountId IS NOT NULL AND intGLAccountId <> 0)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)

DECLARE @UserEntityID			INT
	,@AllowOtherUserToPost		BIT

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @userId),@userId)
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @UserEntityID)

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
				INSERT INTO @ARReceivablePostData 
				SELECT P.intPaymentId, P.strRecordNumber, P.intWriteOffAccountId, P.intEntityId, L.intInterestAccountId, L.intSalesDiscounts
				FROM tblARPayment P
					LEFT JOIN tblSMCompanyLocation L ON P.intLocationId = L.intCompanyLocationId
				WHERE P.ysnPosted = 0
			END
		ELSE
			BEGIN
				INSERT INTO @ARReceivablePostData 
				SELECT P.intPaymentId, P.strRecordNumber, P.intWriteOffAccountId, P.intEntityId, L.intInterestAccountId, L.intSalesDiscounts
				FROM tblARPayment P
					LEFT JOIN tblSMCompanyLocation L ON P.intLocationId = L.intCompanyLocationId
				WHERE P.intPaymentId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@param))
			END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		INSERT INTO @ARReceivablePostData
		SELECT P.intPaymentId, P.strRecordNumber, P.intWriteOffAccountId, P.intEntityId, L.intInterestAccountId, L.intSalesDiscounts
		FROM tblARPayment P
			LEFT JOIN tblSMCompanyLocation L ON P.intLocationId = L.intCompanyLocationId
		WHERE P.dtmDatePaid BETWEEN @beginDate AND @endDate AND ysnPosted = 0
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @ARReceivablePostData
		SELECT P.intPaymentId, P.strRecordNumber, P.intWriteOffAccountId, P.intEntityId, L.intInterestAccountId, L.intSalesDiscounts
		FROM tblARPayment P
			LEFT JOIN tblSMCompanyLocation L ON P.intLocationId = L.intCompanyLocationId
		WHERE P.intPaymentId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
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
		WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.intPaymentId = B.intPaymentId)
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
	
IF(@batchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @batchId OUT
	END

SET @batchIdUsed = @batchId	

--------------------------------------------------------------------------------------------  
-- Validations  
--------------------------------------------------------------------------------------------  
--IF @recap = 0
	BEGIN
	
		-- Zero Payment
		INSERT INTO
			@ZeroPayment
		SELECT
			A.intPaymentId
			,A.strRecordNumber
			,A.intWriteOffAccountId
			,A.intEntityId
			,P.intInterestAccountId
			,P.intSalesDiscounts
		FROM
			tblARPayment A 
		INNER JOIN 
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId	
		WHERE
			A.dblAmountPaid = 0					
		GROUP BY
			A.intPaymentId, A.strRecordNumber, A.intWriteOffAccountId, A.intEntityId, P.intInterestAccountId, P.intSalesDiscounts
		HAVING
			SUM(B.dblPayment) = 0
			AND SUM(B.dblDiscount) = 0
		

		--POST VALIDATIONS
		IF @post = 1
			BEGIN

				DECLARE @PaymentIds PaymentId	
				DELETE FROM @PaymentIds

				INSERT INTO @PaymentIds(
					 [intHeaderId]
					,[intDetailId])
				SELECT 
					 [intHeaderId]						= [intPaymentId]
					,[intDetailId]						= NULL
				 FROM @ARReceivablePostData

				--EXEC [dbo].[uspARReComputePaymentAmounts] @PaymentIds = @PaymentIds

				--Undeposited Funds Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Undeposited Funds account in Company Location - ' + CL.strLocationName  + ' was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail D
						ON A.intPaymentId = D.intPaymentId
				INNER JOIN
					tblSMCompanyLocation CL
						ON A.intLocationId = CL.intCompanyLocationId 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				WHERE
					ISNULL(CL.intUndepositedFundsId,0)  = 0
												
				--Sales Discount Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The AR Account in Company Configuration was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail D
						ON A.intPaymentId = D.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				WHERE
					(@ARAccount IS NULL OR @ARAccount = 0)

				--Payment without payment on detail (get all detail that has 0 payment)
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT
					'There was no payment to receive.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN 
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId					
				WHERE
					A.dblAmountPaid = 0
					AND B.intPaymentId = 107
				GROUP BY
					 A.strRecordNumber
					,A.intPaymentId			
				HAVING
					SUM(B.dblPayment) = 0
					AND MAX(B.dblPayment) = 0
					AND MIN(B.dblPayment) = 0					

				--Payment without detail
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'There was no payment to receive.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM 
					tblARPayment A 
				LEFT JOIN 
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						
				WHERE
					B.intPaymentId IS NULL
					AND A.dblAmountPaid = 0

				--Unposted Invoice(s)
				INSERT INTO   
					@ARReceivableInvalidData  
				SELECT  
					'Invoice ' + ARI.strInvoiceNumber + ' is not posted!'  
					,'Receivable'  
					,ARP.strRecordNumber  
					,@batchId  
					,ARP.intPaymentId  
				FROM  
					tblARPaymentDetail ARPD   
				INNER JOIN   
					tblARPayment ARP  
						ON ARPD.intPaymentId = ARP.intPaymentId  
				INNER JOIN
					tblARInvoice ARI
						ON ARPD.intInvoiceId = ARI.intInvoiceId
				INNER JOIN  
					@ARReceivablePostData P  
						ON ARP.intPaymentId = ARP.intPaymentId
				WHERE
					ISNULL(ARPD.dblPayment,0.00) <> 0.00
					AND ISNULL(ARI.ysnPosted,0) = 0

				--Invoice Prepayment
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					A.strRecordNumber + '''s payment amount must be equal to ' + B.strTransactionNumber + '''s prepay amount!'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM 
					tblARPaymentDetail B
				INNER JOIN 
					tblARPayment A 
						ON B.intPaymentId = A.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						
				WHERE
					ISNULL(A.ysnInvoicePrepayment, 0) = 1
					AND (B.dblInvoiceTotal <> B.dblPayment OR B.dblInvoiceTotal <> A.dblAmountPaid)
					
				--Forgiven Invoice(s)
				INSERT INTO   
					@ARReceivableInvalidData  
				SELECT  
					'Invoice ' + ARI.strInvoiceNumber + ' has been forgiven!'  
					,'Receivable'  
					,ARP.strRecordNumber  
					,@batchId  
					,ARP.intPaymentId  
				FROM  
					tblARPaymentDetail ARPD   
				INNER JOIN   
					tblARPayment ARP  
						ON ARPD.intPaymentId = ARP.intPaymentId  
				INNER JOIN
					tblARInvoice ARI
						ON ARPD.intInvoiceId = ARI.intInvoiceId
				INNER JOIN  
					@ARReceivablePostData P  
						ON ARP.intPaymentId = ARP.intPaymentId
				WHERE
					ISNULL(ARPD.dblPayment,0.00) <> 0.00
					AND ARI.strType = 'Service Charge'
					AND ARI.ysnForgiven = 1
					
				--Return Payment not allowed
				INSERT INTO
					@ARReceivableInvalidData
				SELECT
					'Return Payment is not allowed.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN 
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) < 0
					AND A.ysnInvoicePrepayment = 0
					AND A.strPaymentMethod = 'ACH'


					-- AND EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = B.intInvoiceId 
					
					-- AND 
					
					-- CASE WHEN A.strPaymentMethod = 'ACH' THEN 
					-- 	0 
					-- ELSE 
					-- 	CASE WHEN B.dblPayment > 0 AND strTransactionType NOT IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 
					-- 		1 
					-- 	ELSE 
					-- 		1 
					-- 	END 
					-- END = 1
					-- )

				--Fiscal Year
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId					
				WHERE
					ISNULL([dbo].isOpenAccountingDate(A.dtmDatePaid), 0) = 0
					
				--Company Location
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Company location of ' + A.strRecordNumber + ' was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				WHERE L.intCompanyLocationId IS NULL
				
				--INACTIVE GL ACCOUNT
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Undeposited Funds Account : ' + CL.strUndepositedFundsId+ ' is not active.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN vyuSMCompanyLocation CL
					ON L.intCompanyLocationId = CL.intCompanyLocationId
				INNER JOIN tblGLAccount GL
					ON GL.strAccountId = CL.strUndepositedFundsId
				WHERE GL.ysnActive != 1


				-- GL Account Does not Exist
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Undeposited Funds Account : ' + CL.strUndepositedFundsId+ ' does not exist.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN vyuSMCompanyLocation CL
					ON L.intCompanyLocationId = CL.intCompanyLocationId
				LEFT JOIN tblGLAccount GL
					ON GL.strAccountId = CL.strUndepositedFundsId
				WHERE  GL.strAccountId IS NULL AND strUndepositedFundsId != ''

				----Bank Account
				--INSERT INTO 
				--	@ARReceivableInvalidData
				--SELECT 
				--	'Bank Account of ' + A.strRecordNumber + ' was not set.'
				--	,'Receivable'
				--	,A.strRecordNumber
				--	,@batchId
				--	,A.intPaymentId
				--FROM
				--	tblARPayment A
				--INNER JOIN
				--	@ARReceivablePostData P
				--		ON A.intPaymentId = P.intPaymentId						 
				--LEFT OUTER JOIN
				--	tblCMBankAccount B
				--		ON A.intBankAccountId = B.intBankAccountId 
				--WHERE B.intBankAccountId  IS NULL
				
				
				--In-active Bank Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Bank Account ' + B.strBankAccountNo + ' is not active.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				LEFT OUTER JOIN
					tblCMBankAccount B
						ON A.intBankAccountId = B.intBankAccountId 
				WHERE ISNULL(B.ysnActive,0) = 0
					AND ISNULL(B.intBankAccountId,0) <> 0
				
				
				--Sales Discount Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Discounts account in Company Configuration was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail D
						ON A.intPaymentId = D.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				WHERE
					ISNULL(D.dblDiscount,0) <> 0
					AND (@DiscountAccount IS NULL OR @DiscountAccount = 0)
					
				--Income Interest Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Income Interest account in Company Location or Company Configuration was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail D
						ON A.intPaymentId = D.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				WHERE
					ISNULL(D.dblInterest,0) <> 0
					AND (P.intInterestAccountId IS NULL AND (@IncomeInterestAccount IS NULL OR @IncomeInterestAccount = 0))
					
				--Bank Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Cash Account is not linked to any of the active Bank Account in Cash Management'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					vyuGLAccountDetail GL
						ON A.intAccountId = GL.intAccountId 
				--INNER JOIN 
				--	tblGLAccountGroup AG
				--		ON GL.intAccountGroupId = AG.intAccountGroupId
				--INNER JOIN 
				--	tblGLAccountCategory AC
				--		ON GL.intAccountCategoryId = AC.intAccountCategoryId											 
				LEFT OUTER JOIN
					tblCMBankAccount BA
						ON A.intAccountId = BA.intGLAccountId 						
				WHERE
					GL.strAccountCategory = 'Cash Account'
					AND (BA.intGLAccountId IS NULL
						 OR BA.ysnActive = 0)
						 
						 
				--Write Off Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Write Off account in Company Configuration was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblSMPaymentMethod PM
						ON A.intPaymentMethodId = PM.intPaymentMethodID
						AND ISNULL(A.intWriteOffAccountId, 0) = 0
				WHERE
					(UPPER(RTRIM(LTRIM(PM.strPaymentMethod))) = UPPER('Write Off') OR UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('Write Off'))
					AND (@WriteOffAccount IS NULL OR @WriteOffAccount = 0)


				--CF Invoice Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The CF Invoice Account # in Company Configuration was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblSMPaymentMethod PM
						ON A.intPaymentMethodId = PM.intPaymentMethodID
						AND ISNULL(A.intWriteOffAccountId, 0) = 0
				WHERE
					(UPPER(RTRIM(LTRIM(PM.strPaymentMethod))) = UPPER('CF Invoice') OR UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('CF Invoice'))
					AND (@intCFAccount IS NULL OR @intCFAccount = 0)
					

				--NOT BALANCE 
				INSERT INTO
					@ARReceivableInvalidData
				SELECT
					'The debit and credit amounts are not balanced.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) < (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
					
					
				--Payment Date
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Payment Date(' + CONVERT(NVARCHAR(30),A.dtmDatePaid, 101) + ') cannot be earlier than the Invoice(' + C.strInvoiceNumber + ') Post Date(' + CONVERT(NVARCHAR(30),C.dtmPostDate, 101) + ')!'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice C
						ON B.intInvoiceId = C.intInvoiceId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					B.dblPayment <> 0
					AND CAST(C.dtmPostDate AS DATE) > CAST(A.dtmDatePaid AS DATE)				
					
				--Income Interest Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Accounts Receivable Realized Gain or Loss account in Company Configuration was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPaymentDetail D
				INNER JOIN
					tblARPayment A
						ON D.intPaymentId = A.intPaymentId
				INNER JOIN
					tblARInvoice C
						ON D.intInvoiceId = C.intInvoiceId 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				WHERE
					ISNULL(((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(D.dblBaseInterest,0.00)) - ISNULL(D.dblBaseDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - D.dblBasePayment),0) <> 0
					AND  (@GainLossAccount IS NULL OR @GainLossAccount = 0)
					AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) = ((D.dblPayment - D.dblInterest) + D.dblDiscount)	

				--Validate Bank Account for ACH Payment Method
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Bank Account is required for payment with ACH payment method!'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE A.strPaymentMethod = 'ACH' AND ISNULL(intBankAccountId, 0) = 0 

				--+overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
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
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) <> 0
					AND ISNULL((SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId), 0) = 0	
					AND NOT EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)		
					
					
				--Prepaid Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Customer Prepaid account in Company Location - ' + CL.strLocationName  + ' was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblSMCompanyLocation CL
						ON A.intLocationId = CL.intCompanyLocationId 
				INNER JOIN
					@ARPrepayment P
						ON A.intPaymentId = P.intPaymentId						 
				WHERE
					ISNULL(CL.intSalesAdvAcct,0)  = 0										

				--ALREADY POSTED
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'The transaction is already posted.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					A.ysnPosted = 1
												

				--RECEIVABLES(S) ALREADY PAID IN FULL
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					C.strInvoiceNumber + ' already paid in full.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice C
						ON B.intInvoiceId = C.intInvoiceId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					C.ysnPaid = 1 
					AND B.dblPayment <> 0
					
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
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
						ON A.intPaymentId = P.intPaymentId
				WHERE
					B.dblPayment <> 0 
					AND C.ysnPaid = 0 
					AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) < ((B.dblPayment - B.dblInterest) + B.dblDiscount)
					AND C.strTransactionType IN ('Invoice', 'Debit Memo')

				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
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
						ON A.intPaymentId = P.intPaymentId
				WHERE
					B.dblPayment <> 0 
					AND C.ysnPaid = 0 
					AND (((C.dblAmountDue + C.dblInterest) - C.dblDiscount) * -1) > ((B.dblPayment - B.dblInterest) + B.dblDiscount)
					AND C.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
					
				--If ysnAllowUserSelfPost is True in User Role
				IF (@AllowOtherUserToPost IS NOT NULL AND @AllowOtherUserToPost = 1)
				BEGIN
					INSERT INTO 
						@ARReceivableInvalidData
					SELECT 
						'You cannot Post/Unpost transactions you did not create.'
						,'Receivable'
						,A.strRecordNumber
						,@batchId
						,A.intPaymentId
					FROM
						tblARPayment A
					INNER JOIN
						tblARPaymentDetail D
							ON A.intPaymentId = D.intPaymentId
					INNER JOIN
						tblSMCompanyLocation CL
							ON A.intLocationId = CL.intCompanyLocationId 
					INNER JOIN
						@ARReceivablePostData P
							ON A.intPaymentId = P.intPaymentId						 
					WHERE
						P.intEntityId <> @UserEntityID
				END

				DECLARE @InvoiceIdsForChecking TABLE (
						intInvoiceId int PRIMARY KEY,
						UNIQUE (intInvoiceId)
					);

				INSERT INTO @InvoiceIdsForChecking(intInvoiceId)
				SELECT DISTINCT
					PD.intInvoiceId 
				FROM
					tblARPaymentDetail PD 
				INNER JOIN
					@ARReceivablePostData P
						ON PD.intPaymentId = P.intPaymentId
				WHERE
					PD.dblPayment <> 0
				GROUP BY
					PD.intInvoiceId
				HAVING
					COUNT(PD.intInvoiceId) > 1
					
				WHILE(EXISTS(SELECT TOP 1 NULL FROM @InvoiceIdsForChecking))
				BEGIN
					DECLARE @InvID INT			
							,@InvoicePayment NUMERIC(18,6) = 0
							
					SELECT TOP 1 @InvID = intInvoiceId FROM @InvoiceIdsForChecking
					
					DECLARE @InvoicePaymentDetail TABLE(
						intPaymentId INT,
						intInvoiceId INT,
						dblInvoiceTotal NUMERIC(18,6),
						dblAmountDue NUMERIC(18,6),
						dblPayment NUMERIC(18,6)
					);
					
					INSERT INTO @InvoicePaymentDetail(intPaymentId, intInvoiceId, dblInvoiceTotal, dblAmountDue, dblPayment)
					SELECT
						 A.intPaymentId
						,C.intInvoiceId
						,C.dblInvoiceTotal
						,C.dblAmountDue
						,B.dblPayment 
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
							ON A.intPaymentId = P.intPaymentId
					WHERE
						C.intInvoiceId = @InvID
							
					WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicePaymentDetail)
					BEGIN
						DECLARE @PayID INT
								,@AmountDue NUMERIC(18,6) = 0
						SELECT TOP 1 @PayID = intPaymentId, @AmountDue = dblAmountDue, @InvoicePayment = @InvoicePayment + dblPayment FROM @InvoicePaymentDetail ORDER BY intPaymentId
						
						IF @AmountDue < @InvoicePayment
						BEGIN
							INSERT INTO
									@ARReceivableInvalidData
								SELECT 
									'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
									,'Receivable'
									,A.strRecordNumber
									,@batchId
									,A.intPaymentId
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
										ON A.intPaymentId = P.intPaymentId
								WHERE
									C.intInvoiceId = @InvID
									AND A.intPaymentId = @PayID
						END									
						DELETE FROM @InvoicePaymentDetail WHERE intPaymentId = @PayID	
					END
					DELETE FROM @InvoiceIdsForChecking WHERE intInvoiceId = @InvID							
				END		 																
			
			
			
			END

		--UNPOSTING VALIDATIONS
		IF @post = 0 And @recap = 0
			BEGIN
			
				--Invoice with Discount
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Discount has been applied to Invoice: ' + I.strInvoiceNumber + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
					,'Receivable'
					,P.strRecordNumber
					,@batchId
					,P.intPaymentId
				FROM
					tblARPaymentDetail PD		
				INNER JOIN
					tblARPayment P
						ON PD.intPaymentId = P.intPaymentId
				INNER JOIN
					@ARReceivablePostData P2
						ON P.intPaymentId = P2.intPaymentId	
				INNER JOIN
					tblARInvoice I
						ON PD.intInvoiceId = I.intInvoiceId
				INNER JOIN
					(
					SELECT
						I.intInvoiceId
						,P.intPaymentId
						,P.strRecordNumber
					FROM
						tblARPaymentDetail PD		
					INNER JOIN	
						tblARPayment P ON PD.intPaymentId = P.intPaymentId	
					INNER JOIN	
						tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
					WHERE
						PD.dblDiscount <> 0
						AND I.dblAmountDue = 0
					) AS P1
						ON I.intInvoiceId = P1.intInvoiceId AND P.intPaymentId <> P1.intPaymentId 		
						
				--Invoice with Interest
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Interest has been applied to Invoice: ' + I.strInvoiceNumber + '. Payment: ' + P1.strRecordNumber + ' must unposted first!'
					,'Receivable'
					,P.strRecordNumber
					,@batchId
					,P.intPaymentId
				FROM
					tblARPaymentDetail PD		
				INNER JOIN
					tblARPayment P
						ON PD.intPaymentId = P.intPaymentId
				INNER JOIN
					@ARReceivablePostData P2
						ON P.intPaymentId = P2.intPaymentId	
				INNER JOIN
					tblARInvoice I
						ON PD.intInvoiceId = I.intInvoiceId
				INNER JOIN
					(
					SELECT
						I.intInvoiceId
						,P.intPaymentId
						,P.strRecordNumber
					FROM
						tblARPaymentDetail PD		
					INNER JOIN	
						tblARPayment P ON PD.intPaymentId = P.intPaymentId	
					INNER JOIN	
						tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
					WHERE
						ISNULL(PD.dblInterest,0) <> 0
						AND I.dblAmountDue = 0
					) AS P1
						ON I.intInvoiceId = P1.intInvoiceId AND P.intPaymentId <> P1.intPaymentId 			

				--Already cleared/reconciled
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'The transaction is already cleared.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblCMBankTransaction B 
						ON A.strRecordNumber = B.strTransactionId
				WHERE B.ysnClr = 1
				
				--Payment with created Bank Deposit
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'You cannot unpost payment with created Bank Deposit.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblCMUndepositedFund B 
						ON A.intPaymentId = B.intSourceTransactionId 
						AND A.strRecordNumber = B.strSourceTransactionId
				INNER JOIN
					tblCMBankTransactionDetail TD
						ON B.intUndepositedFundId = TD.intUndepositedFundId
				WHERE 
					B.strSourceSystem = 'AR'


				--Payment with applied Prepayment
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'You cannot unpost payment with applied prepaids.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN
					tblARInvoice I
						ON B.intInvoiceId = I.intInvoiceId
				INNER JOIN
					tblARPrepaidAndCredit  PC
						ON I.intInvoiceId = PC.intPrepaymentId 
						AND PC.ysnApplied = 1
						AND PC.dblAppliedInvoiceDetailAmount <> 0
				INNER JOIN
					tblARInvoice I2
						ON PC.intInvoiceId = I2.intInvoiceId 
						AND I2.ysnPosted = 1

				--Payment with associated Overpayment
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'There''s an overpayment(' + I.[strInvoiceNumber] + ') created from ' + A.[strRecordNumber] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
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
					@ARReceivableInvalidData
				SELECT 
					'There''s a prepayment(' + I.[strInvoiceNumber] + ') created from ' + A.[strRecordNumber] + '. Disassociate it from ' + ARP.[strRecordNumber] + ' first.' 
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
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

				--Payment with associated Prepayment
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'Provisional Invoice(' + I.[strInvoiceNumber] + ') was already processed!' 
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice I
						ON B.intInvoiceId = I.intInvoiceId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					I.strType = 'Provisional'
					AND I.ysnProcessed = 1


				--If ysnAllowUserSelfPost is True in User Role
				IF (@AllowOtherUserToPost IS NOT NULL AND @AllowOtherUserToPost = 1)
				BEGIN
					INSERT INTO 
						@ARReceivableInvalidData
					SELECT 
						'You cannot Post/Unpost transactions you did not create.'
						,'Receivable'
						,A.strRecordNumber
						,@batchId
						,A.intPaymentId
					FROM
						tblARPayment A
					INNER JOIN
						tblARPaymentDetail D
							ON A.intPaymentId = D.intPaymentId
					INNER JOIN
						tblSMCompanyLocation CL
							ON A.intLocationId = CL.intCompanyLocationId 
					INNER JOIN
						@ARReceivablePostData P
							ON A.intPaymentId = P.intPaymentId						 
					WHERE
						P.intEntityId <> @UserEntityID
				END
								
				---overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
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
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblARInvoice I
						ON A.strRecordNumber = I.strComments OR A.intPaymentId = I.intPaymentId 				
				WHERE
					I.strTransactionType = 'Customer Prepayment'					
					
			END
		
	--Get all invalid		
		SET @totalInvalid = (SELECT COUNT(*) FROM @ARReceivableInvalidData)

		IF(@totalInvalid > 0)
			BEGIN

				INSERT INTO 
					tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					strError
					,strTransactionType
					,strTransactionId
					,strBatchNumber
					,intTransactionId
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
						ON A.intPaymentId = I.intTransactionId
												
						
				DELETE 
					@AROverpayment
				FROM
					@AROverpayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intPaymentId = I.intTransactionId	
						
				DELETE 
					@ARPrepayment
				FROM
					@ARPrepayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intPaymentId = I.intTransactionId
						
			IF @raiseError = 1
				BEGIN
					SELECT TOP 1 @ErrorMerssage = strError FROM @ARReceivableInvalidData
					RAISERROR(@ErrorMerssage, 11, 1)							
					GOTO Post_Exit
				END													

			END

	--Get all to be post record
		SELECT @totalRecords = COUNT(*) FROM @ARReceivablePostData

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
	
	IF (SELECT COUNT(1) FROM @ARReceivablePostData) > 1
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
				ON PD.intPaymentId = P.intPaymentId
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
					ON A.intPaymentId = P.intPaymentId
			WHERE
				C.intInvoiceId = @DiscountedInvID
			ORDER BY
				P.intPaymentId
				
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
		
	BEGIN TRY

	IF (@bankAccountId IS NULL)
			BEGIN
			UPDATE 
				tblARPayment
			SET 
				 intAccountId			= C.intUndepositedFundsId
				,intWriteOffAccountId	= CASE WHEN ISNULL(P.intWriteOffAccountId,0) = 0 THEN @WriteOffAccount ELSE P.intWriteOffAccountId END
			FROM
				tblARPayment P								
			INNER JOIN 
				tblSMCompanyLocation C
					ON P.intLocationId = C.intCompanyLocationId
			WHERE
				P.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
				AND ISNULL(C.intUndepositedFundsId,0) <> 0
				AND ISNULL(P.strPaymentMethod, '') <> 'CF Invoice'
			END
		ELSE
			BEGIN
			DECLARE @intNewAccountID INT 
			SELECT @intNewAccountID = intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = @bankAccountId

				UPDATE 
					tblARPayment
				SET 
					 intAccountId			= @intNewAccountID
					,intWriteOffAccountId	= CASE WHEN ISNULL(intWriteOffAccountId,0) = 0 THEN @WriteOffAccount ELSE intWriteOffAccountId END
				FROM
					tblARPayment												
				WHERE
					intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)					
			END
					
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
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId			
			,intAccountId				= CASE WHEN UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('Write Off') THEN A.intWriteOffAccountId
											WHEN UPPER(RTRIM(LTRIM(A.strPaymentMethod))) = UPPER('CF Invoice') THEN ISNULL(A.intWriteOffAccountId, @intCFAccount)
											ELSE A.intAccountId
											END
			,dblDebit					= (CASE WHEN (B.dblBaseAmountDue = (B.dblBasePayment - B.dblBaseInterest) + B.dblBaseDiscount)
												THEN (B.dblBasePayment - B.dblBaseInterest)  + B.dblBaseDiscount
												ELSE B.dblBasePayment END)
										  * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= A.strNotes 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= A.dblAmountPaid * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
			,[dblDebitReport]			= A.dblBaseAmountPaid * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= 0
			,[dblForeignRate]			= 0
			,[strRateType]				= ''			 
		FROM
			tblARPayment A		
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId and B.dblBasePayment <> 0
		INNER JOIN
			tblSMPaymentMethod PM
				ON A.intPaymentMethodId = PM.intPaymentMethodID
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
				
		UNION ALL
		--CREDIT Overpayment
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
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
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
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
				ON A.intPaymentId = P.intPaymentId
		WHERE
			A.dblBaseUnappliedAmount <> @ZeroDecimal
			OR A.dblUnappliedAmount <> @ZeroDecimal
				
		UNION ALL
		--CREDIT Prepayment
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= SMCL.intSalesAdvAcct 
			,dblDebit					= 0
			,dblCredit					= A.dblBaseAmountPaid
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = SMCL.intSalesAdvAcct) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= A.dblAmountPaid
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
				ON A.intLocationId = SMCL.intCompanyLocationId 
		INNER JOIN
			@ARPrepayment P
				ON A.intPaymentId = P.intPaymentId
		WHERE
			A.dblAmountPaid <> @ZeroDecimal
			OR A.dblBaseAmountPaid <> @ZeroDecimal
				
				
		UNION ALL
		--DEBIT Discount
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= ISNULL(P.intSalesDiscounts, @DiscountAccount)
			,dblDebit					= B.dblBaseDiscount
			,dblCredit					= 0 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = ISNULL(P.intSalesDiscounts, @DiscountAccount)) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= B.intPaymentDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= B.dblDiscount
			,[dblDebitReport]			= B.dblBaseDiscount
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType 	 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
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
			(B.dblDiscount <> @ZeroDecimal
			AND B.dblAmountDue = @ZeroDecimal)
			OR
			(B.dblBaseDiscount <> @ZeroDecimal
			AND B.dblBaseAmountDue = @ZeroDecimal)
		--GROUP BY
		--	A.intPaymentId
		--	,A.strRecordNumber
		--	,C.strCustomerNumber
		--	,A.dtmDatePaid
		--	,A.intCurrencyId	
			
		UNION ALL
		--DEBIT Interest
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= @ARAccount 
			,dblDebit					= B.dblBaseInterest
			,dblCredit					= 0 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0	
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= B.intPaymentDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= B.dblInterest
			,[dblDebitReport]			= B.dblBaseInterest
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType	 			 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
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
			(B.dblInterest <> @ZeroDecimal
			AND B.dblPayment <> @ZeroDecimal
			AND B.dblAmountDue = @ZeroDecimal)
			OR
			(B.dblBaseInterest <> @ZeroDecimal
			AND B.dblBasePayment <> @ZeroDecimal
			AND B.dblBaseAmountDue = @ZeroDecimal)
		--GROUP BY
		--	A.intPaymentId
		--	,A.strRecordNumber
		--	,C.strCustomerNumber
		--	,A.dtmDatePaid
		--	,A.intCurrencyId	
			
			
		UNION ALL
		--CREDIT
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= B.intAccountId 
			,dblDebit					= 0
			,dblCredit					= (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END) * (A.dblBaseAmountPaid + ISNULL((SELECT SUM(ISNULL(((((ISNULL(C.dblBaseAmountDue, 0.00) + ISNULL(ARPD.dblBaseInterest,0.00)) - ISNULL(ARPD.dblBaseDiscount,0.00) * (CASE WHEN C.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - ARPD.dblBasePayment),0)) FROM tblARPaymentDetail ARPD INNER JOIN tblARInvoice C ON ARPD.intInvoiceId = C.intInvoiceId  WHERE ARPD.intPaymentId = A.intPaymentId AND ((C.dblAmountDue + C.dblInterest) - C.dblDiscount) = ((ARPD.dblPayment - ARPD.dblInterest) + ARPD.dblDiscount)),0))
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= B.intPaymentDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= (CASE WHEN (B.dblAmountDue = (B.dblPayment - B.dblInterest) + B.dblDiscount)
												THEN (B.dblPayment - B.dblInterest)  + B.dblDiscount
												ELSE B.dblPayment END)
										  * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
			,[dblCreditReport]			= (CASE WHEN (B.dblBaseAmountDue = (B.dblBasePayment - B.dblBaseInterest) + B.dblBaseDiscount)
												THEN (B.dblBasePayment - B.dblBaseInterest)  + B.dblBaseDiscount
												ELSE B.dblBasePayment END)
										  * (CASE WHEN ISNULL(A.ysnInvoicePrepayment,0) = 1 THEN -1 ELSE 1 END)
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType				 
		FROM
			tblARPayment A 
		INNER JOIN 
			tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN 
			tblARCustomer C 
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
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
			B.dblPayment <> @ZeroDecimal
			OR B.dblBasePayment <> @ZeroDecimal
		--GROUP BY
		--	A.intPaymentId
		--	,A.strRecordNumber
		--	,B.intAccountId
		--	,C.strCustomerNumber
		--	,A.dtmDatePaid
		--	,A.intCurrencyId
		--	,A.ysnInvoicePrepayment
			
		UNION ALL

		--GAIN LOSS
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= @GainLossAccount
			,dblDebit					= CASE WHEN (ISNULL((( B.dblBasePayment- ((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0)) > 0 THEN 0 ELSE ABS((ISNULL((B.dblBasePayment - (((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0))) END
			,dblCredit					= CASE WHEN (ISNULL((B.dblBasePayment - (((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0)) > 0 THEN ABS((ISNULL(( B.dblBasePayment - (((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END)))),0))) ELSE 0 END
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 0
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= 0
			,[dblCreditReport]			= 0
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType					 
		FROM
			tblARPaymentDetail B
		INNER JOIN 
			tblARPayment A  
				ON B.intPaymentId = A.intPaymentId
		INNER JOIN 
			tblARCustomer C 
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			tblARInvoice I
				ON B.intInvoiceId = I.intInvoiceId
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
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
			((ISNULL(((((ISNULL(I.dblBaseAmountDue, 0.00) + ISNULL(B.dblBaseInterest,0.00)) - ISNULL(B.dblBaseDiscount,0.00) * (CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE -1 END))) - B.dblBasePayment),0)))  <> 0
			AND ((I.dblAmountDue + I.dblInterest) - I.dblDiscount) = ((B.dblPayment - B.dblInterest) + B.dblDiscount)
		--GROUP BY
		--	A.intPaymentId
		--	,A.strRecordNumber
		--	,B.intAccountId
		--	,C.strCustomerNumber
		--	,A.dtmDatePaid
		--	,A.intCurrencyId
		--	,A.ysnInvoicePrepayment

		UNION ALL
		
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= @ARAccount
			,dblDebit					= 0
			,dblCredit					= B.dblBaseDiscount
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= B.intPaymentDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= B.dblDiscount
			,[dblCreditReport]			= B.dblBaseDiscount
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType		 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
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
			(B.dblDiscount <> @ZeroDecimal
			AND B.dblAmountDue = @ZeroDecimal)
			OR
			(B.dblBaseDiscount <> @ZeroDecimal
			AND B.dblBaseAmountDue = @ZeroDecimal)
		--GROUP BY
		--	A.intPaymentId
		--	,A.strRecordNumber
		--	,C.strCustomerNumber
		--	,A.dtmDatePaid
		--	,A.intCurrencyId			
			
		UNION ALL
		
		SELECT
			 dtmDate					= CAST(A.dtmDatePaid AS DATE)
			,strBatchID					= @batchId
			,intAccountId				= ISNULL(P.intInterestAccountId, @IncomeInterestAccount)
			,dblDebit					= 0
			,dblCredit					= B.dblBaseInterest
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0		
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = ISNULL(P.intInterestAccountId, @IncomeInterestAccount)) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= @PostDate
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= @POSTDESC + @SCREEN_NAME 
			,intJournalLineNo			= B.intPaymentDetailId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				
			,[dblDebitForeign]			= 0
			,[dblDebitReport]			= 0
			,[dblCreditForeign]			= B.dblInterest
			,[dblCreditReport]			= B.dblBaseInterest
			,[dblReportingRate]			= B.dblCurrencyExchangeRate
			,[dblForeignRate]			= B.dblCurrencyExchangeRate
			,[strRateType]				= SMCERT.strCurrencyExchangeRateType		  
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
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
			(B.dblInterest <> @ZeroDecimal
			AND B.dblPayment <> @ZeroDecimal
			AND B.dblAmountDue = @ZeroDecimal)
			OR
			(B.dblBaseInterest <> @ZeroDecimal
			AND B.dblBasePayment <> @ZeroDecimal
			AND B.dblBaseAmountDue = @ZeroDecimal)
		--GROUP BY
		--	A.intPaymentId
		--	,A.strRecordNumber
		--	,C.strCustomerNumber
		--	,A.dtmDatePaid
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
			INNER JOIN
				@ARReceivablePostData P
					ON GL.intTransactionId = P.intPaymentId  
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
				ON (B.strTransactionId = GLDR.strTransactionId OR B.intPaymentId = GLDR.intTransactionId)  
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
		SELECT intPaymentId FROM @ARReceivablePostData
		
		IF @post = 0
			BEGIN
			
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT Z.intPaymentId, Z.strTransactionId, intWriteOffAccountId, intEntityId, Z.intInterestAccountId, Z.intSalesDiscounts FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)

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
						A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
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
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
			
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
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
								
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
					AND A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
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
			WHERE B.[strTransactionId] IN (SELECT strRecordNumber FROM tblARPayment WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData))					
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARReceivablePostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.intPaymentId = B.intPaymentId)						
					
			-- Creating the temp table:
			DECLARE @isSuccessful BIT
			CREATE TABLE #tmpCMBankTransaction (strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,UNIQUE (strTransactionId))

			INSERT INTO #tmpCMBankTransaction
			SELECT strRecordNumber FROM tblARPayment A
			INNER JOIN @ARReceivablePostData B ON A.intPaymentId = B.intPaymentId

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
			 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData) 
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
						ON A.intPaymentId = P.intPaymentId
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
			SELECT Z.intPaymentId, Z.strTransactionId, intWriteOffAccountId, Z.intEntityId, intInterestAccountId, Z.intSalesDiscounts FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)			
			
			--update payment record
			UPDATE tblARPayment
				SET ysnPosted= 0
			FROM tblARPayment A 
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)

			--Insert Successfully unposted transactions.
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 
				@UnpostSuccessfulMsg,
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
			
			--DELETE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN			
					DECLARE @PaymentIdToDelete int		
					SELECT TOP 1 @PaymentIdToDelete = intPaymentId FROM @AROverpayment
					
					EXEC [dbo].[uspARDeleteOverPayment] @PaymentIdToDelete, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intPaymentId = @PaymentIdToDelete
				END	
				
			--DELETE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN			
					DECLARE @PaymentIdToDeletePre int		
					SELECT TOP 1 @PaymentIdToDeletePre = intPaymentId FROM @ARPrepayment
					
					EXEC [dbo].[uspARDeletePrePayment] @PaymentIdToDeletePre, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intPaymentId = @PaymentIdToDeletePre
					
				END
				
			UPDATE 
				tblARPayment
			SET 
				intAccountId = NULL			
			WHERE
				intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)		

			EXEC uspAPUpdateBillPaymentFromAR @paymentIds = @arPaymentIds, @post = 0

			END
		ELSE
			BEGIN
			
			--CREATE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN
					DECLARE @PaymentIdToAdd int
					SELECT TOP 1 @PaymentIdToAdd = intPaymentId FROM @AROverpayment
					
					EXEC [dbo].[uspARCreateOverPayment] @PaymentIdToAdd, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intPaymentId = @PaymentIdToAdd
				END
				
			--CREATE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN
					DECLARE @PaymentIdToAddPre int
					SELECT TOP 1 @PaymentIdToAddPre = intPaymentId FROM @ARPrepayment
					
					EXEC [dbo].[uspARCreatePrePayment] @PaymentIdToAddPre, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intPaymentId = @PaymentIdToAddPre
				END				

			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT Z.intPaymentId, Z.strTransactionId, intWriteOffAccountId, Z.intEntityId, Z.intInterestAccountId, Z.intSalesDiscounts FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)		

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
			UPDATE tblARPayment
			SET		ysnPosted = 1
					--,intConcurrencyId += 1 
			WHERE	intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)

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
						A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
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
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
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
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)	
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
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.intPaymentId = B.intPaymentId)						

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
			SELECT Z.intPaymentId, Z.strTransactionId, intWriteOffAccountId, Z.intEntityId, Z.intInterestAccountId, Z.intSalesDiscounts FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)											

			--Insert Successfully posted transactions.
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 
				@PostSuccessfulMsg,
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)

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
			SELECT DISTINCT intPaymentId FROM @ARReceivablePostData
				
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
			SELECT DISTINCT intPaymentId FROM @ARReceivablePostData

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
			WHERE intPaymentId IN (SELECT DISTINCT intPaymentId FROM @ARReceivablePostData)
			
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
	