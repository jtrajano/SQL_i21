﻿CREATE PROCEDURE uspCMAddPayment
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

BEGIN TRANSACTION 

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
		
		-- Local variables:
		,@strTransactionId NVARCHAR(40)
		,@intTransactionId INT
		,@msg_id INT

-- Initialize the transaction id. 
SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20))
FROM	dbo.tblSMStartingNumber
WHERE	strTransactionType = @STARTING_NUMBER_BANK_TRANSACTION
IF @@ERROR <> 0	GOTO uspCMAddPayment_Rollback

-- Increment the next transaction number
UPDATE	dbo.tblSMStartingNumber
SET		intNumber += 1
WHERE	strTransactionType = @STARTING_NUMBER_BANK_TRANSACTION
IF @@ERROR <> 0	GOTO uspCMAddPayment_Rollback

-- Check for duplicate transaction id. 
IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblCMBankTransaction] WHERE strTransactionId = @strTransactionId)
BEGIN
	RAISERROR(70015, 11, 1, @strTransactionId)
	GOTO uspCMAddPayment_Rollback
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
		,dblAmount					= @dblAmount * -1
		,strAmountInWords			= dbo.fnConvertNumberToWord(@dblAmount * -1)
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
IF @@ERROR <> 0	GOTO uspCMAddPayment_Rollback

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
		,dblDebit				= @dblAmount
		,dblCredit				= 0
		,intUndepositedFundId	= 0
		,intEntityId			= NULL
		,intCreatedUserId		= @intUserId
		,dtmCreated				= GETDATE()
		,intLastModifiedUserId	= @intUserId
		,dtmLastModified		= GETDATE()
		,intConcurrencyId		= 1
FROM	tblGLAccount 
WHERE	intAccountId = @intGLAccountId
IF @@ERROR <> 0	GOTO uspCMAddPayment_Rollback

-- Post the transaction 
BEGIN TRY
	EXEC dbo.uspCMPostBankTransaction
			@ysnPost = 1
			,@ysnRecap = 0
			,@strTransactionId = @strTransactionId
			,@isSuccessful = @isAddSuccessful OUTPUT
			,@message_id = @msg_id OUTPUT
			
	IF @@ERROR <> 0	GOTO uspCMAddPayment_Rollback	
	GOTO uspCMAddPayment_Commit
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX), @ErrorSeverity INT, @ErrorState INT;
    SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	GOTO uspCMAddPayment_Rollback
END CATCH

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
uspCMAddPayment_Commit:
	SET @isAddSuccessful = 1
	COMMIT TRANSACTION
	GOTO uspCMAddPayment_Exit
	
uspCMAddPayment_Rollback:
	SET @isAddSuccessful = 0
	ROLLBACK TRANSACTION 
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

uspCMAddPayment_Exit: