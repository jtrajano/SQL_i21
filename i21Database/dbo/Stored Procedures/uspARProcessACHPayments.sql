CREATE PROCEDURE [dbo].[uspARProcessACHPayments]
	@intPaymentId	INT,
	@intUserId		INT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @intBankAccountId INT
      , @strTransactionId NVARCHAR(100)
	  , @STARTING_NUMBER_BANK_TRANSACTION AS NVARCHAR(100) = 'Bank Transaction'
	  , @BankTransaction BankTransactionTable
	  , @BankTransactionDetail BankTransactionDetailTable
	  , @ysnSuccess	BIT
	  , @intEntityId INT
	  , @intMessageId INT

SELECT TOP 1 @intBankAccountId = intBankAccountId, @intEntityId = intEntityCustomerId FROM tblARPayment WHERE intPaymentId = @intPaymentId

EXEC dbo.uspCMRefreshUndepositedFundsFromOrigin @intBankAccountId, @intUserId

--Get the Bank Deposit strTransactionId by using this script.
SELECT  @strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20))
FROM tblSMStartingNumber WHERE strTransactionType = @STARTING_NUMBER_BANK_TRANSACTION
 
-- Increment the next transaction number
UPDATE tblSMStartingNumber SET intNumber += 1
WHERE strTransactionType = @STARTING_NUMBER_BANK_TRANSACTION

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
	,[strTransactionId]				= @strTransactionId
	,[intCurrencyId]				= P.intCurrencyId
	,[intBankTransactionTypeId]		= 1
	,[dtmDate]						= GETDATE()
	,[dblAmount]					= UF.dblAmount
	,[strMemo]						= P.strNotes
	,[intCompanyLocationId]			= UF.intLocationId
FROM tblCMUndepositedFund UF
	INNER JOIN tblARPayment P ON UF.intSourceTransactionId = P.intPaymentId
WHERE UF.intSourceTransactionId = @intPaymentId 

--Payment Detail
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
	, [intGLAccountId]		= P.intAccountId
	, [strDescription]		= GL.strDescription
	, [dblDebit]			= 0
	, [dblCredit]			= ISNULL(P.dblAmountPaid, 0)
	, [intEntityId]			= @intEntityId
FROM tblCMUndepositedFund UF
	INNER JOIN tblARPayment P ON UF.intSourceTransactionId = P.intPaymentId
	LEFT JOIN tblGLAccount GL ON P.intAccountId = GL.intAccountId
WHERE P.intPaymentId = @intPaymentId

EXEC [dbo].[uspCMCreateBankTransactionEntries]
			@BankTransactionEntries = @BankTransaction
			, @BankTransactionDetailEntries = @BankTransactionDetail

EXEC dbo.uspCMPostBankDeposit 1, 0, @strTransactionId, NULL, @intUserId, @intEntityId, @ysnSuccess OUT, @intMessageId OUT