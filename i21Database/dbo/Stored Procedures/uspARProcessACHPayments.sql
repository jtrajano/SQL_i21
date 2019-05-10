﻿CREATE PROCEDURE [dbo].[uspARProcessACHPayments]
	@strPaymentIds			NVARCHAR(MAX),
	@intBankAccountId		INT,
	@intCompanyLocationId	INT = NULL,
	@intUserId				INT,
	@strNewTransactionId	NVARCHAR(100) = '' OUTPUT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- FOR AR-10210: Patterned from uspARPostPaymentIntegration>PROCESS CUSTOMER BUDGET TO ACH
IF @intCompanyLocationId IS NULL
BEGIN
	SELECT TOP 1 @intCompanyLocationId	= intLocationId
	FROM dbo.tblARPayment P 
	INNER JOIN 
		(SELECT * FROM dbo.fnGetRowsFromDelimitedValues(@strPaymentIds) ) PI
			ON P.intPaymentId = PI.intID
	WHERE 
		P.strPaymentMethod = 'ACH'
		AND P.intBankAccountId IS NOT NULL
END
--

DECLARE @tblACHPayments TABLE (
	  intPaymentId			INT
	, intCurrencyId			INT
	, intAccountId			INT
	, intEntityCustomerId	INT
	, strRecordNumber		NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, dblAmountPaid			NUMERIC(18, 6)
	, dtmDatePaid			DATETIME
	, ysnVendorRefund		BIT
)

DECLARE @strTransactionId					NVARCHAR(100)
	  , @STARTING_NUMBER_BANK_DEPOSIT AS	NVARCHAR(100) = 'Bank Deposit'
	  , @STARTING_NUMBER_BANK_WITHDRAWAL AS NVARCHAR(100) = 'Bank Withdrawal'
	  , @BankTransaction					BankTransactionTable
	  , @BankTransactionDup					BankTransactionTable
	  , @BankTransactionCur					BankTransactionTable
	  , @BankTransactionDetail				BankTransactionDetailTable
	  , @ysnSuccess							BIT
	  , @intEntityId						INT
	  , @intMessageId						INT
	  , @intNewTransactionId				INT = NULL
	  , @strErrorMsg						NVARCHAR(MAX) = ''
	  , @intStartingNumberId				INT

IF ISNULL(@strPaymentIds, '') != ''
	BEGIN
		INSERT INTO @tblACHPayments
		SELECT intPaymentId
			 , intCurrencyId
			 , intAccountId
			 , intEntityCustomerId
			 , strRecordNumber
			 , dblAmountPaid
			 , dtmDatePaid
			 , CASE WHEN P.strReceivePaymentType = 'Vendor Refund' THEN 1 ELSE 0 END
		FROM dbo.tblARPayment P WITH (NOLOCK)
		INNER JOIN (
			SELECT intID 
			FROM dbo.fnGetRowsFromDelimitedValues(@strPaymentIds) 
			WHERE ISNULL(intID, 0) <> 0
		) PAYMENT ON P.intPaymentId = PAYMENT.intID
		LEFT JOIN (
			SELECT intPaymentMethodID
				 , strPaymentMethod 
			FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
		   AND (PM.strPaymentMethod = 'ACH' OR P.strReceivePaymentType = 'Vendor Refund')
		WHERE P.ysnPosted = 1
	END
ELSE
	BEGIN
		RAISERROR('No ACH Payments to process.', 16, 1)
		RETURN;
	END

IF NOT EXISTS (SELECT TOP 1 NULL FROM @tblACHPayments)
	BEGIN
		RAISERROR('No ACH Payments to process.', 16, 1)
		RETURN;
	END
IF EXISTS (SELECT TOP 1 NULL FROM @tblACHPayments where dtmDatePaid > CAST(CURRENT_TIMESTAMP AS DATE))
	BEGIN
		RAISERROR('Unable to process, ACH Payment record/s should be less than or equal to date today.', 16, 1)
		RETURN;
	END
IF ISNULL(@intBankAccountId, 0) = 0
	BEGIN
		RAISERROR('Bank Account is required when processing ACH Payments.', 16, 1)
		RETURN;
	END

IF ISNULL(@intCompanyLocationId, 0) = 0
	BEGIN
		RAISERROR('Current Location is required when processing ACH Payments.', 16, 1)
		RETURN;
	END

IF ISNULL(@intUserId, 0) = 0
	BEGIN
		RAISERROR('User is required when processing ACH Payments.', 16, 1)
		RETURN;
	END

EXEC dbo.uspCMRefreshUndepositedFundsFromOrigin @intBankAccountId, @intUserId

--Payment Header
INSERT INTO @BankTransaction (
	  [intBankAccountId]
	, [strTransactionId]
	, [intCurrencyId]
	, [intBankTransactionTypeId] 
	, [dtmDate]
	, [dblAmount]
	, [strMemo]			
	, [intCompanyLocationId]
	, [intEntityId]
	, [intCreatedUserId]
	, [intLastModifiedUserId])
SELECT 
	 [intBankAccountId]				= UF.intBankAccountId
	,[strTransactionId]				= 'temp'
	,[intCurrencyId]				= P.intCurrencyId
	,[intBankTransactionTypeId]		= 1
	,[dtmDate]						= P.dtmDatePaid
	,[dblAmount]					= SUM(UF.dblAmount)
	,[strMemo]						= CASE WHEN P.ysnVendorRefund = 1 THEN 'Vendor Refund' ELSE 'AR ACH' END
	,[intCompanyLocationId]			= @intCompanyLocationId
	,[intEntityId]					= ISNULL(@intUserId, UF.intLastModifiedUserId)
	,[intCreatedUserId]				= ISNULL(@intUserId, UF.intLastModifiedUserId)
	,[intLastModifiedUserId]		= ISNULL(@intUserId, UF.intLastModifiedUserId)
FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
CROSS APPLY (
	SELECT TOP 1 * FROM @tblACHPayments
	WHERE UF.intSourceTransactionId = intPaymentId
	  AND UF.strSourceTransactionId = strRecordNumber
) P
GROUP BY UF.intBankAccountId
	   , P.intCurrencyId
	   , P.dtmDatePaid
	   , P.ysnVendorRefund
	   , ISNULL(@intUserId, UF.intLastModifiedUserId)
	   
--PaymentDup
INSERT INTO @BankTransactionDup(
	  [intBankAccountId]
	, [strTransactionId]
	, [intCurrencyId]
	, [intBankTransactionTypeId] 
	, [dtmDate]
	, [dblAmount]
	, [strMemo]
	, [intCompanyLocationId]
	, [intEntityId]
	, [intCreatedUserId]
	, [intLastModifiedUserId]) 
SELECT 
	[intBankAccountId]
	, [strTransactionId]
	, [intCurrencyId]
	, [intBankTransactionTypeId] 
	, [dtmDate], [dblAmount]
	, [strMemo]	
	, [intCompanyLocationId] 
	, [intEntityId]
	, [intCreatedUserId]
	, [intLastModifiedUserId]
FROM @BankTransaction



DECLARE @DupBankId		INT
	  , @DupCurrency	INT
	  , @DupLocation	INT
	  , @DupBankTransId	INT
	  , @DupDatePaid	DATETIME	  
	  , @COUNTER		INT = 1
	  , @intBankTransactionDupID INT

WHILE EXISTS(SELECT TOP 1 1 FROM @BankTransactionDup)
BEGIN
	BEGIN TRANSACTION		 
	SET @DupBankId				= NULL
	SET @DupCurrency			= NULL
	SET @DupDatePaid			= NULL
	SET @DupLocation			= NULL
	SET @DupBankTransId			= NULL
	SET @intStartingNumberId	= NULL
	SET @strTransactionId		= NULL

	DELETE FROM @BankTransactionDetail
	DELETE FROM @BankTransactionCur
	
	SELECT TOP 1 @DupBankId			= intBankAccountId
			   , @DupCurrency		= intCurrencyId
			   , @DupDatePaid		= dtmDate
			   , @DupLocation		= intCompanyLocationId
			   , @DupBankTransId	= intBankTransactionTypeId
			   , @intBankTransactionDupID = intTransactionId
	FROM @BankTransactionDup

	--Get the Bank Deposit strTransactionId by using this script.
	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM dbo.tblSMStartingNumber 
	WHERE strTransactionType = CASE WHEN @DupBankTransId = 1 THEN @STARTING_NUMBER_BANK_DEPOSIT ELSE @STARTING_NUMBER_BANK_WITHDRAWAL END

	EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT
	
	--Payment Current
	INSERT INTO @BankTransactionCur(
		[intBankAccountId]
		, [strTransactionId]
		, [intCurrencyId]
		, [intBankTransactionTypeId]
		, [dtmDate]
		, [dblAmount]
		, [strMemo]
		, [intCompanyLocationId] 
		, [intEntityId]
		, [intCreatedUserId]
		, [intLastModifiedUserId]) 
	SELECT 
		[intBankAccountId]
		, @strTransactionId
		, [intCurrencyId]
		, [intBankTransactionTypeId]
		, [dtmDate]
		, [dblAmount]
		, [strMemo]
		, [intCompanyLocationId] 
		, [intEntityId]
		, [intCreatedUserId]
		, [intLastModifiedUserId]
	FROM @BankTransaction 
	WHERE [intBankAccountId] = @DupBankId 
	  AND [intCurrencyId] = @DupCurrency
	  AND [dtmDate] = @DupDatePaid
	  AND [intCompanyLocationId] = @DupLocation 
	  AND [intTransactionId] = @intBankTransactionDupID
 	
	--GETTING THE DETAIL
	INSERT INTO @BankTransactionDetail(
		  [intTransactionId]
		, [intUndepositedFundId]
		, [dtmDate]
		, [intGLAccountId]
		, [strDescription]
		, [dblDebit]
		, [dblCredit]
		, [intEntityId]
	)
	SELECT 
		  [intTransactionId]	= 0
		, [intUndepositedFundId] = UF.intUndepositedFundId
		, [dtmDate]				= UF.dtmDate
		, [intGLAccountId]		= PAYMENTS.intAccountId
		, [strDescription]		= PAYMENTS.strDescription
		, [dblDebit]			= CASE WHEN @DupBankTransId = 2 THEN ABS(ISNULL(PAYMENTS.dblAmountPaid, 0)) ELSE 0 END
		, [dblCredit]			= CASE WHEN @DupBankTransId = 1 THEN ISNULL(PAYMENTS.dblAmountPaid, 0) ELSE 0 END
		, [intEntityId]			= PAYMENTS.intEntityCustomerId
	FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
	CROSS APPLY (
		SELECT P.*
			 , GL.strDescription 
		FROM @tblACHPayments P
		LEFT JOIN (
			SELECT intAccountId
				 , strDescription 
			FROM dbo.tblGLAccount WITH (NOLOCK)
		) GL ON GL.intAccountId = P.intAccountId
		WHERE UF.intSourceTransactionId = P.intPaymentId
		  AND UF.strSourceTransactionId = P.strRecordNumber
		  AND P.intCurrencyId = @DupCurrency
		  AND P.dtmDatePaid = @DupDatePaid
		
	) PAYMENTS 
	WHERE UF.intBankAccountId = @DupBankId 	  

	SELECT TOP 1 @intEntityId = intEntityCustomerId FROM @tblACHPayments

	BEGIN TRY
		EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries			= @BankTransactionCur
												 , @BankTransactionDetailEntries	= @BankTransactionDetail
												 , @intTransactionId				= @intNewTransactionId OUT
		IF ISNULL(@intNewTransactionId, 0) > 0
			COMMIT TRANSACTION
		ELSE
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR('Failed to Create Bank Transaction Entry', 11, 1)
				RETURN;
			END
	END TRY
	BEGIN CATCH
		SELECT @strErrorMsg = ERROR_MESSAGE()
		ROLLBACK TRANSACTION
		RAISERROR(@strErrorMsg, 11, 1)
		RETURN;
	END CATCH

	BEGIN TRANSACTION

	BEGIN TRY
		IF @DupBankTransId = 1
			BEGIN
				EXEC dbo.uspCMPostBankDeposit @ysnPost			= 1
											, @ysnRecap			= 0
											, @strTransactionId = @strTransactionId
											, @strBatchId		= NULL
											, @intUserId		= @intUserId
											, @intEntityId		= @intEntityId
											, @isSuccessful		= @ysnSuccess OUT
											, @message_id		= @intMessageId OUT
			END
		ELSE
			BEGIN
				EXEC dbo.uspCMPostBankTransaction @ysnPost			= 1
												, @ysnRecap			= 0
												, @strTransactionId = @strTransactionId
												, @strBatchId		= NULL
												, @intUserId		= @intUserId
												, @intEntityId		= @intEntityId
												, @isSuccessful		= @ysnSuccess OUT
												, @message_id		= @intMessageId OUT
			END

		IF ISNULL(@ysnSuccess, 0) = 1
			BEGIN
				COMMIT TRANSACTION
				SET @strNewTransactionId = @strTransactionId
			END
		ELSE
			BEGIN
				SELECT @strErrorMsg = ERROR_MESSAGE()
				ROLLBACK TRANSACTION
				RAISERROR(@strErrorMsg, 11, 1)
			END
	END TRY
	BEGIN CATCH
		SELECT @strErrorMsg = ERROR_MESSAGE()
		ROLLBACK TRANSACTION

		BEGIN TRANSACTION
		--for AR-7182, they have separate try catch, the one above commits its transaction so 
		-- if there is an error on this try catch shouldn't we delete the generated bank transaction
		-- if just leave the bank transaciton
		-- please comment it to AR-7182 and remove below code
		-- thanks M.D.GONZALES
		IF ISNULL(@intNewTransactionId, 0) > 0
			DELETE FROM tblCMBankTransaction WHERE intTransactionId = @intNewTransactionId
		--
		COMMIT TRANSACTION

		RAISERROR(@strErrorMsg, 11, 1)
		RETURN;
	END CATCH

	DELETE FROM @BankTransactionDup 
	WHERE [intTransactionId] = @intBankTransactionDupID
	--WHERE [intBankAccountId] = @DupBankId 
	--  AND [intCurrencyId] = @DupCurrency
	--  AND [dtmDate] = @DupDatePaid
	--  AND [intCompanyLocationId] = @DupLocation 

	  

	SET @COUNTER = @COUNTER + 1
END
