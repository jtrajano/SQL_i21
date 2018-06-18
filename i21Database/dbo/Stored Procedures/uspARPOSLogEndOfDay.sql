CREATE PROCEDURE [dbo].[uspARPOSLogEndOfDay]
	@intPOSLogId 			AS INT,
	@dblNewEndingBalance	AS NUMERIC(18, 6) = 0
AS
	IF ISNULL(@intPOSLogId, NULL) > 0
	BEGIN
		DECLARE @intUserId						INT	= NULL
			  , @intStartingNumberId			INT = NULL
			  , @dblEndingBalance				NUMERIC(18, 6) = 0
			  , @dblOpeningBalance				NUMERIC(18, 6) = 0
			  , @dblCashReceipts				NUMERIC(18, 6) = 0
			  , @dblCashOverShort				NUMERIC(18, 6) = 0
			  , @dtmDateNow						DATETIME = GETDATE()
			  , @STARTING_NUMBER_BANK_DEPOSIT	NVARCHAR(100) = 'Bank Deposit'

		--UPDATE ENDING BALANCE AND LOG
		UPDATE POSLOG
		SET dblEndingBalance 	= CASE WHEN ISNULL(POSLOG.dblOpeningBalance, 0) +  ISNULL(POS.dblTotalAmount, 0) <> ISNULL(@dblNewEndingBalance, 0) THEN ISNULL(@dblNewEndingBalance, 0) ELSE ISNULL(POSLOG.dblOpeningBalance, 0) + ISNULL(POS.dblTotalAmount, 0) END
		  , dtmLogout 			= @dtmDateNow
		  , ysnLoggedIn 		= 0
		FROM tblARPOSLog POSLOG
		OUTER APPLY (
			SELECT dblTotalAmount = SUM(PP.dblAmount)
			FROM tblARPOS P
			INNER JOIN (
				SELECT intPOSId
					 , dblAmount
				FROM tblARPOSPayment
				WHERE ISNULL(strPaymentMethod, '') <> 'On Account'
			) PP ON P.intPOSId = PP.intPOSId
			WHERE P.intPOSLogId = POSLOG.intPOSLogId
			GROUP BY P.intPOSLogId
		) POS
		WHERE POSLOG.intPOSLogId = @intPOSLogId 
		   OR POSLOG.intPOSLogOriginId = @intPOSLogId

		SELECT TOP 1 @intUserId 		= POSLOG.intEntityUserId
			       , @dblEndingBalance	= POSLOG.dblEndingBalance
				   , @dblOpeningBalance	= POSLOG.dblOpeningBalance
		FROM dbo.tblARPOSLog POSLOG
		WHERE POSLOG.intPOSLogId = @intPOSLogId 

		SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
		FROM dbo.tblSMStartingNumber 
		WHERE strTransactionType = @STARTING_NUMBER_BANK_DEPOSIT

		IF ISNULL(@intUserId, 0) = 0
		BEGIN
			RAISERROR('User is required when creating Bank Deposits.', 16, 1)
			RETURN;
		END
		
		--CREATE CASH DEPOSITS
		IF(OBJECT_ID('tempdb..#CASHPAYMENTS') IS NOT NULL)
		BEGIN
			DROP TABLE #CASHPAYMENTS
		END

		SELECT POSPAYMENT.*
		INTO #CASHPAYMENTS
		FROM dbo.tblARPOSLog POSLOG
		INNER JOIN dbo.tblARPOS POS WITH (NOLOCK)  ON POS.intPOSLogId = POSLOG.intPOSLogId
		INNER JOIN (
			SELECT intPOSId				= POSP.intPOSId
				 , intPaymentId			= PAYMENT.intPaymentId
				 , intCurrencyId		= PAYMENT.intCurrencyId
				 , intAccountId			= PAYMENT.intAccountId
				 , intBankAccountId		= PAYMENT.intBankAccountId
				 , intEntityCustomerId	= PAYMENT.intEntityCustomerId
				 , intCompanyLocationId	= PAYMENT.intLocationId
				 , dtmDatePaid			= PAYMENT.dtmDatePaid
				 , dblAmount			= PAYMENT.dblAmountPaid
				 , strPaymentMethod		= POSP.strPaymentMethod
			FROM dbo.tblARPOSPayment POSP WITH (NOLOCK)	
			INNER JOIN dbo.tblARPayment PAYMENT WITH (NOLOCK) ON POSP.intPaymentId = PAYMENT.intPaymentId
			WHERE ISNULL(POSP.strPaymentMethod, '') <> 'On Account'
			  AND ISNULL(PAYMENT.intBankAccountId, 0) <> 0
			  AND PAYMENT.ysnPosted = 1
		) POSPAYMENT ON POSPAYMENT.intPOSId = POS.intPOSId
		WHERE POSLOG.intPOSLogId = @intPOSLogId

		SELECT @dblCashReceipts = SUM(dblAmount) FROM #CASHPAYMENTS

		DELETE FROM #CASHPAYMENTS WHERE strPaymentMethod NOT IN ('Cash', 'Check')

		WHILE EXISTS (SELECT TOP 1 NULL FROM #CASHPAYMENTS)
			BEGIN
				DECLARE @BankTransaction				BankTransactionTable
					  , @BankTransactionDetail			BankTransactionDetailTable
					  , @intBankAccountId				INT 			= NULL
					  , @intEntityCustomerId			INT				= NULL
					  , @intCompanyLocationId			INT				= NULL
					  , @intMessageId					INT				= NULL
					  , @intNewTransactionId			INT				= NULL
					  , @intCashOverAccountId			INT				= NULL
					  , @intCurrencyId					INT				= NULL
					  , @strTransactionId				NVARCHAR(100)	= NULL
					  , @strCashOverAccountId			NVARCHAR(100)	= NULL
					  , @ysnSuccess						BIT				= 0

				SELECT TOP 1 @intBankAccountId 		= intBankAccountId
					       , @intEntityCustomerId 	= intEntityCustomerId
						   , @intCompanyLocationId	= intCompanyLocationId
						   , @intCurrencyId			= intCurrencyId
				FROM #CASHPAYMENTS

				SELECT TOP 1 @intCashOverAccountId = CL.intCashOverShort
					  	   , @strCashOverAccountId = GL.strDescription
				FROM tblSMCompanyLocation CL
				INNER JOIN tblGLAccount GL ON CL.intCashOverShort = GL.intAccountId
				WHERE intCompanyLocationId = @intCompanyLocationId

				DELETE FROM @BankTransaction
				DELETE FROM @BankTransactionDetail

				EXEC dbo.uspCMRefreshUndepositedFundsFromOrigin @intBankAccountId, @intUserId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT
				--CREATE CASH OVER/SHORT
				SET @dblCashOverShort = (ISNULL(@dblEndingBalance, 0) - (ISNULL(@dblCashReceipts, 0) + ISNULL(@dblOpeningBalance, 0)))

				INSERT INTO @BankTransaction (
					  [intBankAccountId]
					, [strTransactionId]
					, [intCurrencyId]
					, [intBankTransactionTypeId] 
					, [dtmDate]
					, [dblAmount]
					, [strMemo]			
					, [intCompanyLocationId]
				)
				SELECT 
					 [intBankAccountId]				= @intBankAccountId
					,[strTransactionId]				= @strTransactionId
					,[intCurrencyId]				= @intCurrencyId
					,[intBankTransactionTypeId]		= 1
					,[dtmDate]						= @dtmDateNow
					,[dblAmount]					= SUM(CP.dblAmount) + ISNULL(@dblCashOverShort, 0)
					,[strMemo]						= 'POS Bank Deposit - End of Day'
					,[intCompanyLocationId]			= @intCompanyLocationId
				FROM #CASHPAYMENTS CP
				WHERE intBankAccountId  	= @intBankAccountId
				  AND intCurrencyId			= @intCurrencyId
				  AND intCompanyLocationId	= @intCompanyLocationId

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
				SELECT [intTransactionId]	= 0
					, [intUndepositedFundId] = UF.intUndepositedFundId
					, [dtmDate]				= @dtmDateNow
					, [intGLAccountId]		= PAYMENTS.intAccountId
					, [strDescription]		= PAYMENTS.strDescription
					, [dblDebit]			= 0.000000
					, [dblCredit]			= ISNULL(PAYMENTS.dblAmount, 0)
					, [intEntityId]			= PAYMENTS.intEntityCustomerId
				FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
				INNER JOIN (
					SELECT P.*
						 , GL.strDescription 
					FROM #CASHPAYMENTS P
					LEFT JOIN (
						SELECT intAccountId
							 , strDescription 
						FROM dbo.tblGLAccount WITH (NOLOCK)
					) GL ON GL.intAccountId = P.intAccountId
					AND P.intBankAccountId  	= @intBankAccountId
					AND P.intCurrencyId			= @intCurrencyId
					AND P.intCompanyLocationId	= @intCompanyLocationId
				) PAYMENTS ON UF.intSourceTransactionId = PAYMENTS.intPaymentId
				WHERE UF.intBankAccountId 	= @intBankAccountId
				  AND UF.intLocationId		= @intCompanyLocationId

				IF ISNULL(@dblCashOverShort, 0) <> 0 AND ISNULL(@intCashOverAccountId, 0) <> 0
					BEGIN
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
						SELECT [intTransactionId]	= 0
							, [intUndepositedFundId] = NULL
							, [dtmDate]				= @dtmDateNow
							, [intGLAccountId]		= @intCashOverAccountId
							, [strDescription]		= @strCashOverAccountId
							, [dblDebit]			= CASE WHEN ISNULL(@dblCashOverShort, 0) < 0 THEN @dblCashOverShort ELSE 0.00000 END
							, [dblCredit]			= CASE WHEN ISNULL(@dblCashOverShort, 0) > 0 THEN @dblCashOverShort ELSE 0.00000 END
							, [intEntityId]			= @intEntityCustomerId						
					END

				EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries			= @BankTransaction
												 	 	 , @BankTransactionDetailEntries	= @BankTransactionDetail
												 		 , @intTransactionId				= @intNewTransactionId OUT

				IF ISNULL(@intNewTransactionId, 0) <> 0
					BEGIN
						EXEC dbo.uspCMPostBankDeposit @ysnPost			= 1
													, @ysnRecap			= 0
													, @strTransactionId = @strTransactionId
													, @strBatchId		= NULL
													, @intUserId		= @intUserId
													, @intEntityId		= @intEntityCustomerId
													, @isSuccessful		= @ysnSuccess OUT
													, @message_id		= @intMessageId OUT
					END

				DELETE FROM #CASHPAYMENTS 
				WHERE intBankAccountId 		= @intBankAccountId 
				 AND intCurrencyId			= @intCurrencyId
				 AND intCompanyLocationId	= @intCompanyLocationId
			END		
	END
	ELSE
	BEGIN
		RETURN;
	END

RETURN 0
