CREATE PROCEDURE [dbo].[uspARPOSLogEndOfDay]
	@dblNewEndingBalance	AS NUMERIC(18, 6) = 0,
	@intCompanyLocationPOSDrawerId AS INT,
	@intEntityId AS INT
AS
	IF ISNULL(@intCompanyLocationPOSDrawerId, NULL) > 0
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
			  , @strEODNo						NVARCHAR(20)	= NULL
			  , @intPOSLogId					INT				= (SELECT intPOSLogId FROM tblARPOSLog WHERE intCompanyLocationPOSDrawerId = @intCompanyLocationPOSDrawerId AND ysnLoggedIn = 1 AND intPOSLogOriginId IS NULL)				  
					  
		--Get POS EOD starting number
		SELECT	@strEODNo = (strPrefix + CAST(intNumber AS NVARCHAR(10)))
		FROM tblSMStartingNumber
		WHERE strTransactionType = 'POS End of Day'

		--VALIDATE CASH OVER/SHORT GL ACCOUNT
		IF EXISTS(SELECT TOP 1 intPOSLogId FROM tblARPOSLog WHERE intCompanyLocationPOSDrawerId = @intCompanyLocationPOSDrawerId AND ysnLoggedIn = 1)
			BEGIN
				SELECT
						@intCashOverAccountId 	= LOC.intCashOverShort,
						@strCompanyLocatioName 	= LOC.strLocationName,
						@strCashOverAccountId 	= GL.strDescription,
						@intBankAccountId		= BANK.intBankAccountId,
						@intCompanyLocationId	= LOC.intCompanyLocationId,
						@currentEndingBalance   = OD.dblEndingBalance
				FROM  tblSMCompanyLocation LOC
				LEFT JOIN tblSMCompanyLocationPOSDrawer DRAWER ON LOC.intCompanyLocationId = DRAWER.intCompanyLocationId
				INNER JOIN vyuARPOSOpenDrawers OD ON DRAWER.intCompanyLocationPOSDrawerId = OD.intCompanyLocationPOSDrawerId
				INNER JOIN tblGLAccount GL ON LOC.intCashOverShort = GL.intAccountId
				INNER JOIN tblCMBankAccount BANK ON LOC.intCashAccount = BANK.intGLAccountId
				WHERE OD.intCompanyLocationPOSDrawerId = @intCompanyLocationPOSDrawerId
														
				IF ISNULL(@intCashOverAccountId, 0) = 0
				BEGIN
					DECLARE @strErrorMsg NVARCHAR(200) = '' + ISNULL(@strCompanyLocatioName, '') + ' does not have GL setup for Cash Over/Short. Please set it up in Company Location > GL Accounts.'
					RAISERROR(@strErrorMsg, 16, 1)
					RETURN;
				END
			END

			
		--CREATE EOD ENTRY
		INSERT INTO tblARPOSEndOfDay(strEODNo, intPOSLogId, dblFinalEndingBalance, intEntityId)
		VALUES(@strEODNo, @intPOSLogId, @dblNewEndingBalance, @intEntityId)

		--UPDATE POSLOG
		--CLOSE THE DRAWER
		UPDATE tblARPOSLog
		SET dtmLogout 			= @dtmDateNow
		  , ysnLoggedIn 		= 0
		WHERE intCompanyLocationPOSDrawerId = @intCompanyLocationPOSDrawerId
			AND ysnLoggedIn = 1

		SELECT TOP 1 @dblOpeningBalance	= POSLOG.dblOpeningBalance
		
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
		WHERE POSLOG.intPOSLogId = @intPOSLogId

		SELECT @dblCashReceipts = SUM(dblAmount) FROM #CASHPAYMENTS

		--CREATE BANK TRANSACTION FOR CASH OVER/SHORT
		SET @dblCashOverShort = (ISNULL(@dblNewEndingBalance, 0) - (ISNULL(@dblCashReceipts, 0) + ISNULL(@dblOpeningBalance, 0)))

		IF ISNULL(@dblCashOverShort, 0) <> 0 AND ISNULL(@intCashOverAccountId, 0) <> 0
			BEGIN

				IF ISNULL(@intUserId, 0) = 0
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
					, [intEntityId]			= @intUserId
					
				EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries   	 = @BankTransaction
														 , @BankTransactionDetailEntries = @BankTransactionDetail
														 , @intTransactionId    		 = @intNewTransactionId OUT
			
				IF ISNULL(@intNewTransactionId, 0) <> 0
					BEGIN
						UPDATE tblARPOSLog
						SET intBankDepositId = @intNewTransactionId
						WHERE intPOSLogId = @intPOSLogId OR intPOSLogOriginId = @intPOSLogId

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
															, @intUserId  		= @intUserId
															, @intEntityId  	= @intUserId
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
