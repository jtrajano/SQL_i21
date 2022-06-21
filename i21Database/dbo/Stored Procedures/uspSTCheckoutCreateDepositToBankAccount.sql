CREATE PROCEDURE [dbo].[uspSTCheckoutCreateDepositToBankAccount]
	@intCheckoutId							INT,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT
AS
BEGIN
	--SET NOCOUNT ON
    SET XACT_ABORT ON
	BEGIN TRY
		
		DECLARE @intStoreId INT
		DECLARE @dblGrossFuelSales DECIMAL(18,6) = 0
		DECLARE @dblDealerCommission DECIMAL(18,6) = 0
		DECLARE @dblTotalDebitCreditCard DECIMAL(18,6) = 0
		DECLARE @BankTransaction BankTransactionTable
		DECLARE @BankTransactionDetail BankTransactionDetailTable
		DECLARE @strTransactionId					NVARCHAR(100)
		DECLARE @STARTING_NUMBER_BANK_DEPOSIT 		NVARCHAR(100) = 'Bank Deposit'
		DECLARE @intStartingNumberId				INT
		DECLARE @intNewTransactionId				INT
		DECLARE @intBankAccountId					INT
		DECLARE @intCurrencyId						INT
		DECLARE @intEntityId						INT
		DECLARE @intCompanyLocationId				INT
		DECLARE @intGLAccountId						INT
		

		SET @dblGrossFuelSales = dbo.fnSTGetGrossFuelSalesByCheckoutId(@intCheckoutId)

		SELECT		@dblDealerCommission = dblCommissionAmount 
		FROM		tblSTCheckoutDealerCommission
		WHERE		intCheckoutId = @intCheckoutId

		SELECT		@intStoreId = intStoreId
		FROM		dbo.tblSTCheckoutHeader 
		WHERE		intCheckoutId = @intCheckoutId

		SELECT		@dblTotalDebitCreditCard = ISNULL(SUM(dblTotalSalesAmountComputed), 0)
		FROM		tblSTCheckoutDepartmetTotals a
		INNER JOIN	tblICItem b
		ON			a.intItemId = b.intItemId
		WHERE		a.intCheckoutId = @intCheckoutId AND
					b.ysnFuelItem = 1

		--Get the Bank Deposit strTransactionId by using this script.
		SELECT		TOP 1 @intStartingNumberId = intStartingNumberId 
		FROM		dbo.tblSMStartingNumber 
		WHERE		strTransactionType = @STARTING_NUMBER_BANK_DEPOSIT
		
		EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT

		SELECT		@intBankAccountId = intBankAccountId,
					@intCurrencyId = intCurrencyId,
					@intGLAccountId = intGLAccountId
		FROM		tblCMBankAccount
		WHERE		intGLAccountId IN (	SELECT	intConsBankDepositDraftId 
										FROM	tblSTStore 
										WHERE	intStoreId = @intStoreId)

		SELECT		@intEntityId = intCheckoutCustomerId,
					@intCompanyLocationId = intCompanyLocationId
		FROM		tblSTStore
		WHERE		intStoreId = @intStoreId

		BEGIN TRANSACTION

			DECLARE @dblAmount			DECIMAL(18,6) = 0
			DECLARE @dblCreditAmount	DECIMAL(18,6) = 0
			DECLARE @dblDebitAmount		DECIMAL(18,6) = 0

			SET @dblAmount = @dblGrossFuelSales - @dblDealerCommission - @dblTotalDebitCreditCard

			IF @dblAmount >= 0
				BEGIN
					SET @dblCreditAmount = @dblAmount
				END
			ELSE
				BEGIN
					SET @dblDebitAmount = ABS(@dblAmount)
				END

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
				, 'Consignment Payment' --[strDescription]
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