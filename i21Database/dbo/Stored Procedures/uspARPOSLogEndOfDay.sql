CREATE PROCEDURE [dbo].[uspARPOSLogEndOfDay]
	@intPOSEndOfDayId AS INT,
	@intEntityId AS INT,
	@dblNewEndingBalance AS DECIMAL(18,6)
AS
	IF ISNULL(@intPOSEndOfDayId, 0) > 0
	BEGIN
		DECLARE @BankTransaction				BankTransactionTable
		DECLARE @BankTransactionDetail			BankTransactionDetailTable
		DECLARE @intUserId						INT				= NULL
			  , @intStartingNumberId			INT 			= (SELECT TOP 1 intStartingNumberId FROM dbo.tblSMStartingNumber WHERE strTransactionType = 'Bank Transaction')
			  , @intCompanyLocationId			INT 			= NULL
			  , @intCashOverAccountId			INT 			= NULL
			  , @intBankAccountId				INT 			= NULL
			  , @intMessageId					INT				= NULL
			  , @intNewTransactionId			INT				= NULL
			  , @intCurrencyId					INT				= (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
			  , @dblEndingBalance				NUMERIC(18, 6) 	= 0
			  , @dblOpeningBalance				NUMERIC(18, 6) 	= 0
			  , @dblCashReceipts				NUMERIC(18, 6) 	= 0
			  , @dblCashOverShort				NUMERIC(18, 6) 	= 0
			  , @dtmDateNow						DATETIME 		= GETDATE()
			  , @strCompanyLocatioName			NVARCHAR(100) 	= NULL
			  , @strTransactionId				NVARCHAR(100)	= NULL
			  , @strCashOverAccountId			NVARCHAR(100)	= NULL
			  , @ysnSuccess						BIT				= 0	
			  , @currentEndingBalance			INT				= 0		  
			

		--VALIDATE CASH OVER/SHORT GL ACCOUNT
		IF EXISTS(SELECT TOP 1 intPOSEndOfDayId FROM tblARPOSLog WHERE intPOSEndOfDayId = @intPOSEndOfDayId)
			BEGIN
				SELECT TOP 1
						@intCashOverAccountId 	= LOC.intCashOverShort,
						@strCompanyLocatioName 	= LOC.strLocationName,
						@strCashOverAccountId 	= GL.strDescription,
						@intBankAccountId		= BANK.intBankAccountId,
						@intCompanyLocationId	= LOC.intCompanyLocationId,
						@currentEndingBalance   = OD.dblExpectedEndingBalance
				FROM  tblSMCompanyLocation LOC
				LEFT JOIN tblSMCompanyLocationPOSDrawer DRAWER ON LOC.intCompanyLocationId = DRAWER.intCompanyLocationId
				INNER JOIN vyuARPOSEndOfDay OD ON DRAWER.intCompanyLocationPOSDrawerId = OD.intCompanyLocationPOSDrawerId
				INNER JOIN tblGLAccount GL ON LOC.intCashOverShort = GL.intAccountId
				INNER JOIN tblCMBankAccount BANK ON LOC.intCashAccount = BANK.intGLAccountId
				WHERE OD.intPOSEndOfDayId = @intPOSEndOfDayId
														

				IF ISNULL(@intCashOverAccountId, 0) = 0
				BEGIN
					DECLARE @strErrorMsg NVARCHAR(200) = '' + ISNULL(@strCompanyLocatioName, '') + ' does not have GL setup for Cash Over/Short. Please set it up in Company Location > GL Accounts.'
					RAISERROR(@strErrorMsg, 16, 1)
					RETURN;
				END
			END

			
		--CLOSE DRAWER 
		UPDATE	tblARPOSEndOfDay
			SET
				intEntityId = @intEntityId
				,dblFinalEndingBalance = @dblNewEndingBalance
				,dtmClose = GETDATE()
				,ysnClosed = 1
		WHERE intPOSEndOfDayId = @intPOSEndOfDayId


		--UPDATE POSLOG
		UPDATE tblARPOSLog
		SET dtmLogout 			= GETDATE()
		  , ysnLoggedIn 		= 0
		WHERE intPOSEndOfDayId = @intPOSEndOfDayId
			
		SELECT TOP 1 @dblOpeningBalance	= EOD.dblOpeningBalance
		FROM tblARPOSEndOfDay EOD
		WHERE EOD.intPOSEndOfDayId = @intPOSEndOfDayId
		
		--GET ALL CASH PAYMENTS
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
				 , dblAmount			= PAYMENT.dblAmountPaid
			FROM dbo.tblARPOSPayment POSP WITH (NOLOCK)	
			INNER JOIN dbo.tblARPayment PAYMENT WITH (NOLOCK) ON POSP.intPaymentId = PAYMENT.intPaymentId
			WHERE ISNULL(POSP.strPaymentMethod, '') <> 'On Account'			  
			  AND PAYMENT.ysnPosted = 1
		) POSPAYMENT ON POSPAYMENT.intPOSId = POS.intPOSId
		WHERE POSLOG.intPOSLogId IN (SELECT intPOSLogId FROM tblARPOSLog WHERE intPOSEndOfDayId = @intPOSEndOfDayId)

		SELECT @dblCashReceipts = SUM(dblAmount) FROM #CASHPAYMENTS

		--CREATE BANK TRANSACTION FOR CASH OVER/SHORT
		SET @dblCashOverShort = (ISNULL(@dblNewEndingBalance, 0) - (ISNULL(@dblCashReceipts, 0) + ISNULL(@dblOpeningBalance, 0)))

		IF ISNULL(@dblCashOverShort, 0) <> 0 AND ISNULL(@intCashOverAccountId, 0) <> 0
			BEGIN

				IF ISNULL(@intEntityId, 0) = 0
				BEGIN
					RAISERROR('User is required when creating Bank Deposits.', 16, 1)
					RETURN;
				END

				EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT

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
					, [intLastModifiedUserId]
				)
				SELECT 
					[intBankAccountId]				= @intBankAccountId
					,[strTransactionId]				= @strTransactionId
					,[intCurrencyId]				= @intCurrencyId
					,[intBankTransactionTypeId]		= 5
					,[dtmDate]						= @dtmDateNow
					,[dblAmount]					= @dblCashOverShort
					,[strMemo]						= 'POS Bank Deposit - End of Day'
					,[intCompanyLocationId]			= @intCompanyLocationId 
					,[intEntityId]					= @intEntityId
					,[intCreatedUserId]				= @intEntityId
					,[intLastModifiedUserId]		= @intEntityId

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
					, [dblDebit]			= CASE WHEN @dblCashOverShort < 0 THEN ABS(@dblCashOverShort) ELSE 0.000000 END
					, [dblCredit]			= CASE WHEN @dblCashOverShort > 0 THEN ABS(@dblCashOverShort) ELSE 0.000000 END
					, [intEntityId]			= @intEntityId
					
				EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries   	 = @BankTransaction
														 , @BankTransactionDetailEntries = @BankTransactionDetail
														 , @intTransactionId    		 = @intNewTransactionId OUT
			
				IF ISNULL(@intNewTransactionId, 0) <> 0
					BEGIN
						UPDATE tblARPOSEndOfDay
						SET intBankDepositId = @intNewTransactionId
						WHERE intPOSEndOfDayId = @intPOSEndOfDayId

						--UPDATE BANK TRANSACTION FLAG FOR POS
						UPDATE tblCMBankTransaction 
						SET ysnPOS = 1 
						WHERE intTransactionId = @intNewTransactionId
					
						--POST BANK TRANSACTION
						IF ISNULL((SELECT dblAmount FROM dbo.tblCMBankTransaction WHERE intTransactionId = @intNewTransactionId), 0) <> 0
							BEGIN
								EXEC dbo.uspCMPostBankTransaction @ysnPost   		= 1
															, @ysnRecap   		= 0
															, @strTransactionId = @strTransactionId
															, @strBatchId  		= NULL
															, @intUserId  		= @intEntityId
															, @intEntityId  	= @intEntityId
															, @isSuccessful  	= @ysnSuccess OUT
															, @message_id  		= @intMessageId OUT
							END
					END
			END
	END
	ELSE
	BEGIN
		RETURN;
	END

RETURN 0

