﻿
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE AddPayment
	@intBankAccountID INT
	,@dtmDate DATETIME 
	,@intGLAccountID INT	
	,@dblAmount NUMERIC(18,6)
	,@strDescription NVARCHAR(250)
	,@intUserID INT
	,@isAddSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE @BANK_DEPOSIT INT = 1,
		@BANK_WITHDRAWAL INT = 2,
		@MISC_CHECKS INT = 3,
		@BANK_TRANSFER INT = 4,
		@BANK_TRANSACTION INT = 5,
		@CREDIT_CARD_CHARGE INT = 6,
		@CREDIT_CARD_RETURNS INT = 7,
		@CREDIT_CARD_PAYMENTS INT = 8,
		@BANK_TRANSFER_WD INT = 9,
		@BANK_TRANSFER_DEP INT = 10,
		
		@strTransactionID NVARCHAR(40),
		@msg_id INT


-- Initialize the transaction id. 
SELECT	@strTransactionID = strTransactionPrefix + '-' + CAST(intTransactionNo AS NVARCHAR(20))
FROM	tblCMBankTransactionType
WHERE	intBankTransactionTypeID = @BANK_TRANSACTION
IF @@ERROR <> 0	GOTO AddPayment_Rollback

-- Increment the next transaction number
UPDATE	tblCMBankTransactionType
SET		intTransactionNo += 1
WHERE	intBankTransactionTypeID = @BANK_TRANSACTION
IF @@ERROR <> 0	GOTO AddPayment_Rollback

-- Create the Bank Deposit HEADER
INSERT INTO tblCMBankTransaction(
	strTransactionID
	,intBankTransactionTypeID
	,intBankAccountID
	,intCurrencyID
	,dblExchangeRate
	,dtmDate
	,strPayee
	,intPayeeID
	,strAddress
	,strZipCode
	,strCity
	,strState
	,strCountry
	,dblAmount
	,strAmountInWords
	,strMemo
	,intReferenceNo
	,ysnCheckPrinted
	,ysnCheckToBePrinted
	,ysnCheckVoid
	,ysnPosted
	,strLink
	,ysnClr
	,dtmDateReconciled
	,intCreatedUserID
	,dtmCreated
	,intLastModifiedUserID
	,dtmLastModified
	,intConcurrencyID
)
SELECT	strTransactionID			= @strTransactionID
		,intBankTransactionTypeID	= @BANK_TRANSACTION
		,intBankAccountID			= @intBankAccountID
		,intCurrencyID				= NULL
		,dblExchangeRate			= 1
		,dtmDate					= @dtmDate
		,strPayee					= ''
		,intPayeeID					= NULL
		,strAddress					= ''
		,strZipCode					= ''
		,strCity					= ''
		,strState					= ''
		,strCountry					= ''
		,dblAmount					= @dblAmount * -1
		,strAmountInWords			= dbo.fn_ConvertNumberToWord(@dblAmount * -1)
		,strMemo					= ISNULL(@strDescription, '')
		,intReferenceNo				= 0
		,ysnCheckPrinted			= 0
		,ysnCheckToBePrinted		= 0
		,ysnCheckVoid				= 0
		,ysnPosted					= 0
		,strLink					= ''
		,ysnClr						= 0
		,dtmDateReconciled			= NULL
		,intCreatedUserID			= @intUserID
		,dtmCreated					= GETDATE()
		,intLastModifiedUserID		= @intUserID
		,dtmLastModified			= GETDATE()
		,intConcurrencyID			= 1
IF @@ERROR <> 0	GOTO AddPayment_Rollback

-- Create the Bank Deposit DETAIL
INSERT INTO tblCMBankTransactionDetail(
	strTransactionID
	,dtmDate
	,intGLAccountID
	,strDescription
	,dblDebit
	,dblCredit
	,intUndepositedFundID
	,intEntityID
	,intCreatedUserID
	,dtmCreated
	,intLastModifiedUserID
	,dtmLastModified
	,intConcurrencyID
)
SELECT	strTransactionID		= @strTransactionID
		,dtmDate				= @dtmDate
		,intGLAccountID			= @intGLAccountID
		,strDescription			= tblGLAccount.strDescription
		,dblDebit				= @dblAmount
		,dblCredit				= 0
		,intUndepositedFundID	= 0
		,intEntityID			= NULL
		,intCreatedUserID		= @intUserID
		,dtmCreated				= GETDATE()
		,intLastModifiedUserID	= @intUserID
		,dtmLastModified		= GETDATE()
		,intConcurrencyID		= 1
FROM	tblGLAccount 
WHERE	intAccountID = @intGLAccountID
IF @@ERROR <> 0	GOTO AddPayment_Rollback

-- Post the transaction 
BEGIN TRY
	EXEC dbo.PostCMBankTransaction 	
			@ysnPost = 1
			,@ysnRecap = 0
			,@strTransactionID = @strTransactionID
			,@isSuccessful = @isAddSuccessful OUTPUT
			,@message_id = @msg_id OUTPUT
			
	IF @@ERROR <> 0	GOTO AddPayment_Rollback	
	GOTO AddPayment_Commit
END TRY
BEGIN CATCH
	GOTO AddPayment_Rollback
END CATCH

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
AddPayment_Commit:
	SET @isAddSuccessful = 1
	COMMIT TRANSACTION
	GOTO AddPayment_Exit
	
AddPayment_Rollback:
	SET @isAddSuccessful = 0
	ROLLBACK TRANSACTION 

AddPayment_Exit:	

