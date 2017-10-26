CREATE PROCEDURE [dbo].[uspARProcessACHPayments]
	@strPaymentIds			NVARCHAR(MAX),
	@intBankAccountId		INT,
	@intUserId				INT,
	@strNewTransactionId	NVARCHAR(100) = '' OUTPUT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @tblACHPayments TABLE (
			intPaymentId		INT
		  , intCurrencyId		INT
		  , intAccountId		INT
		  , intEntityCustomerId	INT
		  , dblAmountPaid		NUMERIC(18, 6)
		  , dtmDatePaid			DATETIME
		)

DECLARE @strTransactionId					NVARCHAR(100)
	  , @STARTING_NUMBER_BANK_DEPOSIT AS	NVARCHAR(100) = 'Bank Deposit'
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
			 , dblAmountPaid
			 , dtmDatePaid
		FROM dbo.tblARPayment P WITH (NOLOCK)
			INNER JOIN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strPaymentIds) 
						WHERE ISNULL(intID, 0) <> 0
			) PAYMENT ON P.intPaymentId = PAYMENT.intID
			INNER JOIN (SELECT intPaymentMethodID
							 , strPaymentMethod 
						FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
			) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
			    AND PM.strPaymentMethod = 'ACH'
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

IF ISNULL(@intBankAccountId, 0) = 0
	BEGIN
		RAISERROR('Bank Account is required when processing ACH Payments.', 16, 1)
		RETURN;
	END

IF ISNULL(@intUserId, 0) = 0
	BEGIN
		RAISERROR('User is required when processing ACH Payments.', 16, 1)
		RETURN;
	END

-- IF EXISTS(SELECT NULL FROM @tblACHPayments WHERE dtmDatePaid > GETDATE())
-- 	BEGIN
-- 		RAISERROR('Unable to process, ACH Payment record/s should be less than or equal to date today.', 16, 1)
-- 		RETURN;
-- 	END

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
	, [intCompanyLocationId])
SELECT 
	 [intBankAccountId]				= UF.intBankAccountId
	,[strTransactionId]				= 'temp'
	,[intCurrencyId]				= P.intCurrencyId
	,[intBankTransactionTypeId]		= 1
	,[dtmDate]						= P.dtmDatePaid
	,[dblAmount]					= SUM(UF.dblAmount)
	,[strMemo]						= 'AR ACH'
	,[intCompanyLocationId]			= UF.intLocationId
FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
	CROSS APPLY (
		SELECT TOP 1 * FROM @tblACHPayments
		WHERE UF.intSourceTransactionId = intPaymentId
	) P
GROUP BY UF.intBankAccountId
	   , P.intCurrencyId
	   , P.dtmDatePaid
	   , UF.intLocationId


--PaymentDup
INSERT INTO @BankTransactionDup([intBankAccountId], [strTransactionId], [intCurrencyId], [intBankTransactionTypeId] , [dtmDate], [dblAmount], [strMemo], [intCompanyLocationId]) 
SELECT [intBankAccountId], [strTransactionId], [intCurrencyId], [intBankTransactionTypeId] , [dtmDate], [dblAmount], [strMemo]	, [intCompanyLocationId] FROM @BankTransaction

DECLARE @DupBankId INT
,@DupCurrency INT
,@DupDatePaid DATETIME
,@DupLocation INT

DECLARE @COUNTER INT
SET @COUNTER = 1

WHILE EXISTS(SELECT TOP 1 1 FROM @BankTransactionDup)
BEGIN
	
	
	BEGIN TRANSACTION

	

	--Get the Bank Deposit strTransactionId by using this script.
	SELECT	@intStartingNumberId = intStartingNumberId FROM	dbo.tblSMStartingNumber WHERE strTransactionType = @STARTING_NUMBER_BANK_DEPOSIT
	EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT
 

	SELECT 
		@DupBankId = NULL,
		@DupCurrency = NULL,
		@DupDatePaid = NULL,
		@DupLocation = NULL
	
	DELETE FROM @BankTransactionDetail
	DELETE FROM @BankTransactionCur


	SELECT TOP 1 
		@DupBankId = [intBankAccountId],
		@DupCurrency = [intCurrencyId],
		@DupDatePaid = [dtmDate],
		@DupLocation = [intCompanyLocationId]
	FROM @BankTransactionDup
	
	--Payment Current
	INSERT INTO @BankTransactionCur([intBankAccountId], [strTransactionId], [intCurrencyId], [intBankTransactionTypeId] , [dtmDate], [dblAmount], [strMemo], [intCompanyLocationId]) 
	SELECT [intBankAccountId], @strTransactionId, [intCurrencyId], [intBankTransactionTypeId] , [dtmDate], [dblAmount], [strMemo]	, [intCompanyLocationId] 
		FROM @BankTransaction 
			WHERE [intBankAccountId] = @DupBankId 
				AND [intCurrencyId] = @DupCurrency
				AND [dtmDate] = @DupDatePaid
				AND [intCompanyLocationId] = @DupLocation 
	
	
	--GETTING THE DETAIL
	INSERT INTO @BankTransactionDetail(
			  [intTransactionId]
			, [intUndepositedFundId]
			, [dtmDate]
			, [intGLAccountId]
			, [strDescription]
			, [dblDebit]
			, [dblCredit]
			, [intEntityId])
	SELECT 
		  [intTransactionId]	= 0
		, [intUndepositedFundId] = UF.intUndepositedFundId
		, [dtmDate]				= UF.dtmDate
		, [intGLAccountId]		= PAYMENTS.intAccountId
		, [strDescription]		= PAYMENTS.strDescription
		, [dblDebit]			= 0
		, [dblCredit]			= ISNULL(PAYMENTS.dblAmountPaid, 0)
		, [intEntityId]			= PAYMENTS.intEntityCustomerId
	FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
		CROSS APPLY (
			SELECT P.*
				 , GL.strDescription 
			FROM @tblACHPayments P
				LEFT JOIN (SELECT intAccountId
								, strDescription 
						   FROM dbo.tblGLAccount WITH (NOLOCK)
				) GL ON GL.intAccountId = P.intPaymentId
			WHERE UF.intSourceTransactionId = intPaymentId
		) PAYMENTS 
			WHERE  UF.intBankAccountId = @DupBankId 
			AND PAYMENTS.intCurrencyId = @DupCurrency
			AND PAYMENTS.dtmDatePaid = @DupDatePaid
			AND UF.intLocationId = @DupLocation 

	

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
			EXEC dbo.uspCMPostBankDeposit @ysnPost			= 1
										, @ysnRecap			= 0
										, @strTransactionId = @strTransactionId
										, @strBatchId		= NULL
										, @intUserId		= @intUserId
										, @intEntityId		= @intEntityId
										, @isSuccessful		= @ysnSuccess OUT
										, @message_id		= @intMessageId OUT

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
			RAISERROR(@strErrorMsg, 11, 1)
			RETURN;
		END CATCH
		


	DELETE FROM @BankTransactionDup WHERE [intBankAccountId] = @DupBankId 
		AND [intCurrencyId] = @DupCurrency
		AND [dtmDate] = @DupDatePaid
		AND [intCompanyLocationId] = @DupLocation 

	SET @COUNTER = @COUNTER + 1
END
