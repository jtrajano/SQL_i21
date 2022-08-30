﻿CREATE PROCEDURE [dbo].[uspSTCheckoutCreateDepositToBankAccount]
	@intCheckoutId							INT,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT
AS
BEGIN
	--SET NOCOUNT ON
    SET XACT_ABORT ON
	BEGIN TRY
		
		DECLARE @intStoreId											INT
		DECLARE @dblGrossFuelSales									DECIMAL(18,6) = 0
		DECLARE @dblDealerCommission								DECIMAL(18,6) = 0
		DECLARE @dblTotalDebitCreditCard							DECIMAL(18,6) = 0
		DECLARE @BankTransaction									BankTransactionTable
		DECLARE @BankTransactionDetail								BankTransactionDetailTable
		DECLARE @strTransactionId									NVARCHAR(100)
		DECLARE @STARTING_NUMBER_BANK_DEPOSIT 						NVARCHAR(100) = 'Bank Deposit'
		DECLARE @intStartingNumberId								INT
		DECLARE @intNewTransactionId								INT
		DECLARE @intBankAccountId									INT
		DECLARE @intCurrencyId										INT
		DECLARE @intEntityId										INT
		DECLARE @intCompanyLocationId								INT
		DECLARE @intGLAccountId										INT
		DECLARE @dblTotalToDeposit									DECIMAL(18,6) = 0 
		DECLARE @dblCashOverShort									DECIMAL(18,6) = 0  
		DECLARE @strGLAccountDescription	 						NVARCHAR(100)
		

		SET @dblGrossFuelSales = dbo.fnSTGetGrossFuelSalesByCheckoutId(@intCheckoutId)

		SELECT		@dblDealerCommission = dblCommissionAmount 
		FROM		tblSTCheckoutDealerCommission
		WHERE		intCheckoutId = @intCheckoutId

		SELECT		@intStoreId = intStoreId
					,@dblTotalToDeposit = dblTotalToDeposit
		FROM		dbo.tblSTCheckoutHeader 
		WHERE		intCheckoutId = @intCheckoutId

		SET	@dblTotalDebitCreditCard = dbo.fnSTTotalAmountOfDepositablePaymentMethods(@intCheckoutId)

		--Get the Bank Deposit strTransactionId by using this script.
		SELECT		TOP 1 @intStartingNumberId = intStartingNumberId 
		FROM		dbo.tblSMStartingNumber 
		WHERE		strTransactionType = @STARTING_NUMBER_BANK_DEPOSIT
		
		EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT

		SELECT		@intBankAccountId = intBankAccountId,
					@intCurrencyId = intCurrencyId
		FROM		tblCMBankAccount
		WHERE		intGLAccountId IN (	SELECT			b.intCashAccount 
										FROM			tblSTStore a
										INNER JOIN		tblSMCompanyLocation b
										ON				a.intCompanyLocationId = b.intCompanyLocationId
										WHERE			a.intStoreId = @intStoreId)
		
		SELECT		@intEntityId = a.intCheckoutCustomerId,
					@intCompanyLocationId = a.intCompanyLocationId,
					@intGLAccountId = c.intUndepositedFundsId,
					@strGLAccountDescription = b.strDescription
		FROM		tblSTStore a
		INNER JOIN	tblSMCompanyLocation c
		ON			a.intCompanyLocationId = c.intCompanyLocationId
		LEFT JOIN	tblGLAccount b
		ON			c.intUndepositedFundsId = b.intAccountId
		WHERE		intStoreId = @intStoreId

		BEGIN TRANSACTION

			DECLARE @dblAmount			DECIMAL(18,6) = 0
			DECLARE @dblCreditAmount	DECIMAL(18,6) = 0
			DECLARE @dblDebitAmount		DECIMAL(18,6) = 0

			SET @dblAmount = @dblGrossFuelSales - @dblDealerCommission - @dblTotalDebitCreditCard

			IF @dblAmount >= 0
				BEGIN
					SET @dblDebitAmount = @dblAmount
				END
			ELSE
				BEGIN
					SET @dblCreditAmount = ABS(@dblAmount)
				END

			SET @dblAmount = @dblAmount * -1

			INSERT INTO @BankTransaction(
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
			VALUES (
				@intBankAccountId
				, @strTransactionId
				, @intCurrencyId
				, 1 --1 Means 'Bank Deposit'
				, GETDATE()
				, @dblAmount
				, '' --[strMemo]
				, @intCompanyLocationId
				, @intEntityId
				, NULL --[intCreatedUserId]
				, NULL --[intLastModifiedUserId]
				)

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
			VALUES (
				  0						--[intTransactionId]
				, NULL					--[intUndepositedFundId]
				, GETDATE()				--[dtmDate]
				, @intGLAccountId		--[intGLAccountId]
				, @strGLAccountDescription --[strDescription]
				, @dblDebitAmount		--[dblDebit]
				, @dblCreditAmount		--[dblCredit]
				, @intEntityId			--[intEntityId
				)

		EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries			= @BankTransaction
												 , @BankTransactionDetailEntries	= @BankTransactionDetail
												 , @intTransactionId				= @intNewTransactionId OUT

		IF ISNULL(@intNewTransactionId, 0) > 0
			BEGIN
				EXEC dbo.uspCMPostBankTransaction @ysnPost			= 1
												, @ysnRecap			= 0
												, @strTransactionId = @strTransactionId
												, @strBatchId		= NULL
												, @intUserId		= @intEntityId
												, @intEntityId		= @intEntityId
												, @isSuccessful		= @ysnSuccess OUT

				IF EXISTS (SELECT '' FROM tblSTCheckoutDeposits WHERE intCheckoutId = @intCheckoutId)  
					BEGIN  
					UPDATE tblSTCheckoutDeposits SET intBDepId = @intNewTransactionId WHERE intCheckoutId = @intCheckoutId
					END  
				ELSE  
					BEGIN  
						INSERT INTO tblSTCheckoutDeposits  
						(intCheckoutId,dblCash,dblTotalCash,dblTotalDeposit,intBDepId,intConcurrencyId)  
						VALUES  
						(@intCheckoutId,ABS(@dblAmount),ABS(@dblAmount),ABS(@dblAmount),@intNewTransactionId,0)  
					END  
	 
				SET @dblCashOverShort = @dblTotalToDeposit - ABS(@dblAmount)
				UPDATE tblSTCheckoutHeader SET dblTotalDeposits = ABS(@dblAmount), dblCashOverShort = @dblCashOverShort WHERE intCheckoutId = @intCheckoutId
			END
		ELSE
			BEGIN
				SET @strMessage = 'Failed to Create Bank Transaction Entry'
				GOTO ExitWithRollback
			END

		SET @strMessage = 'Success'
		SET @ysnSuccess = 1

		-- COMMIT
		GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
		SET @strMessage = ERROR_MESSAGE()
		SET @ysnSuccess = 0

		-- ROLLBACK
		GOTO ExitWithRollback
	END CATCH
END


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END
		
ExitPost: