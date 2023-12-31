﻿CREATE PROCEDURE uspCMAddDeposit
	@intBankAccountId INT
	,@dtmDate DATETIME 
	,@intGLAccountId INT	
	,@dblAmount NUMERIC(18,6)
	,@strDescription NVARCHAR(255)
	,@intUserId INT
	,@isAddSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @TransactionName AS VARCHAR(500) = 'CM Add Deposit' + CAST(NEWID() AS NVARCHAR(100));

BEGIN TRAN @TransactionName

DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15

		,@STARTING_NUMBER_DEPOSIT AS NVARCHAR(100) = 'Bank Deposit'
		,@STARTING_NUMBER_WITHDRAWAL AS NVARCHAR(100) = 'Bank Withdrawal'
		,@STARTING_NUMBER_TRANSFER AS NVARCHAR(100) = 'Bank Transfer'
		,@STARTING_NUMBER_BANK_TRANSACTION AS NVARCHAR(100) = 'Bank Transaction'

		-- Local variables		
		,@strTransactionId NVARCHAR(40)
		,@intTransactionId INT 
		,@msg_id INT
		
-- Check for invalid bank account id. 
IF NOT EXISTS (
	SELECT	* 
	FROM	dbo.tblCMBankAccount BankAccount INNER JOIN dbo.tblGLAccount GLAccount
				ON BankAccount.intGLAccountId = GLAccount.intAccountId
	WHERE	BankAccount.intBankAccountId = @intBankAccountId
			AND BankAccount.ysnActive = 1
			AND GLAccount.ysnActive = 1
)
BEGIN
	RAISERROR('The bank account or its associated GL account is inactive.', 11, 1, @strTransactionId)
	GOTO uspCMAddDeposit_Rollback
END

-- Initialize the transaction id. 
SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20))
FROM	dbo.tblSMStartingNumber
WHERE	strTransactionType = @STARTING_NUMBER_BANK_TRANSACTION
IF @@ERROR <> 0	GOTO uspCMAddDeposit_Rollback

-- Increment the next transaction number
UPDATE	dbo.tblSMStartingNumber
SET		intNumber += 1
WHERE	strTransactionType = @STARTING_NUMBER_BANK_TRANSACTION
IF @@ERROR <> 0	GOTO uspCMAddDeposit_Rollback

-- Check for duplicate transaction id. 
IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblCMBankTransaction] WHERE strTransactionId = @strTransactionId)
BEGIN
	RAISERROR('The transaction id %s already exists. Please ask your local administrator to check the starting numbers setup.', 11, 1, @strTransactionId)
	GOTO uspCMAddDeposit_Rollback
END

-- Create the Bank Deposit HEADER
INSERT INTO tblCMBankTransaction(
	strTransactionId
	,intBankTransactionTypeId
	,intBankAccountId
	,intCurrencyId
	,dblExchangeRate
	,dtmDate
	,strPayee
	,intPayeeId
	,strAddress
	,strZipCode
	,strCity
	,strState
	,strCountry
	,dblAmount
	,strAmountInWords
	,strMemo
	,strReferenceNo
	,dtmCheckPrinted
	,ysnCheckToBePrinted
	,ysnCheckVoid
	,ysnPosted
	,strLink
	,ysnClr
	,dtmDateReconciled
	,intEntityId
	,intCreatedUserId
	,intCompanyLocationId
	,dtmCreated
	,intLastModifiedUserId
	,dtmLastModified
	,intConcurrencyId
)
SELECT	strTransactionId			= @strTransactionId
		,intBankTransactionTypeId	= @BANK_TRANSACTION
		,intBankAccountId			= @intBankAccountId
		,intCurrencyId				= (SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = @intBankAccountId)
		,dblExchangeRate			= 1
		,dtmDate					= @dtmDate
		,strPayee					= ''
		,intPayeeId					= NULL
		,strAddress					= ''
		,strZipCode					= ''
		,strCity					= ''
		,strState					= ''
		,strCountry					= ''
		,dblAmount					= @dblAmount
		,strAmountInWords			= dbo.fnConvertNumberToWord(@dblAmount)
		,strMemo					= ISNULL(@strDescription, '')
		,strReferenceNo				= ''
		,dtmCheckPrinted			= NULL
		,ysnCheckToBePrinted		= 0
		,ysnCheckVoid				= 0
		,ysnPosted					= 0
		,strLink					= ''
		,ysnClr						= 0
		,dtmDateReconciled			= NULL
		,intEntityId				= @intUserId
		,intCreatedUserId			= @intUserId
		,intCompanyLocationId		= (SELECT TOP 1 intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityId] = @intUserId)
		,dtmCreated					= GETDATE()
		,intLastModifiedUserId		= @intUserId
		,dtmLastModified			= GETDATE()
		,intConcurrencyId			= 1
SET @intTransactionId = @@IDENTITY
IF @@ERROR <> 0	GOTO uspCMAddDeposit_Rollback

-- Create the Bank Deposit DETAIL
INSERT INTO tblCMBankTransactionDetail(
	intTransactionId
	,dtmDate
	,intGLAccountId
	,strDescription
	,dblDebit
	,dblCredit
	,intUndepositedFundId
	,intEntityId
	,intCreatedUserId
	,dtmCreated
	,intLastModifiedUserId
	,dtmLastModified
	,intConcurrencyId
)
SELECT	intTransactionId		= @intTransactionId
		,dtmDate				= @dtmDate
		,intGLAccountId			= @intGLAccountId
		,strDescription			= tblGLAccount.strDescription
		,dblDebit				= 0
		,dblCredit				= @dblAmount
		,intUndepositedFundId	= 0
		,intEntityId			= NULL
		,intCreatedUserId		= @intUserId
		,dtmCreated				= GETDATE()
		,intLastModifiedUserId	= @intUserId
		,dtmLastModified		= GETDATE()
		,intConcurrencyId		= 1
FROM	dbo.tblGLAccount 
WHERE	intAccountId = @intGLAccountId
IF @@ERROR <> 0	GOTO uspCMAddDeposit_Rollback

-- Post the transaction 
BEGIN TRY
EXEC dbo.uspCMPostBankTransaction
		@ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strTransactionId
		,@isSuccessful = @isAddSuccessful OUTPUT
		,@message_id = @msg_id OUTPUT

	IF @@ERROR <> 0	GOTO uspCMAddDeposit_Rollback	
	GOTO uspCMAddDeposit_Commit
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX), @ErrorSeverity INT, @ErrorState INT;
    SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	GOTO uspCMAddDeposit_Rollback
END CATCH

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
uspCMAddDeposit_Commit:
	SET @isAddSuccessful = 1
	COMMIT TRAN @TransactionName	
	GOTO uspCMAddDeposit_Exit
	
uspCMAddDeposit_Rollback:
	SET @isAddSuccessful = 0
	ROLLBACK TRAN @TransactionName
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	
uspCMAddDeposit_Exit:
