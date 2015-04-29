CREATE PROCEDURE [dbo].[uspPRCreatePaycheckEntry]
	@strPaycheckId NVARCHAR(50)
	,@intUserId INT
	,@intEntityId INT
	,@isSuccessful BIT = 0 OUTPUT
	,@message_id INT = 0 OUTPUT

AS
BEGIN

DECLARE @intPaycheckId INT
		,@intTransactionId INT
		,@intEmployeeId INT
		,@strTransactionId NVARCHAR(50) = ''

--[insert validations here]--

/* Get Paycheck Details */
SELECT @intPaycheckId = intPaycheckId
	  ,@intEmployeeId = intEmployeeId
	  ,@strTransactionId = strPaycheckId
FROM tblPRPaycheck 
WHERE strPaycheckId = @strPaycheckId

/* Insert Paycheck data into tblCMBankTransaction */
INSERT INTO [dbo].[tblCMBankTransaction]
	([strTransactionId]
	,[intBankTransactionTypeId] 
	,[intBankAccountId] 
	,[intCurrencyId] 
	,[dblExchangeRate]            
	,[dtmDate] 
	,[strPayee] 
	,[intPayeeId] 
	,[strAddress] 
	,[strZipCode] 
	,[strCity] 
	,[strState] 
	,[strCountry]               
	,[dblAmount] 
	,[strAmountInWords] 
	,[strMemo] 
	,[strReferenceNo] 
	,[dtmCheckPrinted] 
	,[ysnCheckToBePrinted]       
	,[ysnCheckVoid] 
	,[ysnPosted] 
	,[strLink] 
	,[ysnClr] 
	,[dtmDateReconciled] 
	,[intBankStatementImportId] 
	,[intBankFileAuditId] 
	,[strSourceSystem] 
	,[intEntityId] 
	,[intCreatedUserId] 
	,[intCompanyLocationId]              
	,[dtmCreated] 
	,[intLastModifiedUserId] 
	,[dtmLastModified] 
	,[intConcurrencyId])
SELECT		 
	 [strTransactionId]			= PC.strPaycheckId
	,[intBankTransactionTypeId] = 21
	,[intBankAccountId]			= PC.intBankAccountId
	,[intCurrencyId]			= BA.intCurrencyId
	,[dblExchangeRate]			= (SELECT TOP 1 dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = BA.intCurrencyId)
	,[dtmDate]					= GETDATE()
	,[strPayee]					= ''
	,[intPayeeId]				= PC.intEmployeeId
	,[strAddress]				= BA.strAddress
	,[strZipCode]				= BA.strZipCode
	,[strCity]					= BA.strCity
	,[strState]					= BA.strState
	,[strCountry]				= BA.strCountry             
	,[dblAmount]				= PC.dblNetPayTotal * -1 --Insert as Credit
	,[strAmountInWords]			= dbo.fnConvertNumberToWord(PC.dblNetPayTotal)
	,[strMemo]					= ''
	,[strReferenceNo]			= ''
	,[dtmCheckPrinted]			= NULL
	,[ysnCheckToBePrinted]		= 0
	,[ysnCheckVoid]				= 0
	,[ysnPosted]				= 0
	,[strLink]					= ''
	,[ysnClr]					= 0
	,[dtmDateReconciled]		= NULL
	,[intBankStatementImportId]	= 1
	,[intBankFileAuditId]		= NULL
	,[strSourceSystem]			= 'PR'
	,[intEntityId]				= PC.intEmployeeId
	,[intCreatedUserId]			= @intUserId
	,[intCompanyLocationId]		= NULL
	,[dtmCreated]				= GETDATE()
	,[intLastModifiedUserId]	= @intUserId
	,[dtmLastModified]			= GETDATE()
	,[intConcurrencyId]			= 1
FROM tblPRPaycheck PC LEFT JOIN tblCMBankAccount BA 
	ON PC.intBankAccountId = BA.intBankAccountId
WHERE PC.intPaycheckId = @intPaycheckId

SELECT @intTransactionId = @@IDENTITY

/* Insert Earnings into tblCMBankTransactionDetail */
INSERT INTO [dbo].[tblCMBankTransactionDetail]
	([intTransactionId]
	,[dtmDate]
	,[intGLAccountId]
	,[strDescription]
	,[dblDebit]
	,[dblCredit]
	,[intUndepositedFundId]
	,[intEntityId]
	,[intCreatedUserId]
	,[dtmCreated]
	,[intLastModifiedUserId]
	,[dtmLastModified]
	,[intConcurrencyId])
SELECT
	[intTransactionId]			= @intTransactionId
	,[dtmDate]					= GETDATE()
	,[intGLAccountId]			= E.intAccountId
	,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = E.intAccountId)
	,[dblDebit]					= E.dblTotal
	,[dblCredit]				= 0
	,[intUndepositedFundId]		= NULL
	,[intEntityId]				= NULL
	,[intCreatedUserId]			= @intUserId
	,[dtmCreated]				= GETDATE()
	,[intLastModifiedUserId]	= @intUserId
	,[dtmLastModified]			= GETDATE()
	,[intConcurrencyId]			= 1
FROM tblPRPaycheckEarning E
WHERE E.dblTotal > 0
  AND E.intPaycheckId = @intPaycheckId

/* Insert Earnings into tblCMBankTransactionDetail */
INSERT INTO [dbo].[tblCMBankTransactionDetail]
	([intTransactionId]
	,[dtmDate]
	,[intGLAccountId]
	,[strDescription]
	,[dblDebit]
	,[dblCredit]
	,[intUndepositedFundId]
	,[intEntityId]
	,[intCreatedUserId]
	,[dtmCreated]
	,[intLastModifiedUserId]
	,[dtmLastModified]
	,[intConcurrencyId])
SELECT
	[intTransactionId]			= @intTransactionId
	,[dtmDate]					= GETDATE()
	,[intGLAccountId]			= D.intAccountId
	,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = D.intAccountId)
	,[dblDebit]					= 0
	,[dblCredit]				= D.dblTotal
	,[intUndepositedFundId]		= NULL
	,[intEntityId]				= NULL
	,[intCreatedUserId]			= @intUserId
	,[dtmCreated]				= GETDATE()
	,[intLastModifiedUserId]	= @intUserId
	,[dtmLastModified]			= GETDATE()
	,[intConcurrencyId]			= 1
FROM tblPRPaycheckDeduction D
WHERE D.dblTotal > 0 
  AND D.intPaycheckId = @intPaycheckId

/* Insert Employee Taxes into tblCMBankTransactionDetail */
INSERT INTO [dbo].[tblCMBankTransactionDetail]
	([intTransactionId]
	,[dtmDate]
	,[intGLAccountId]
	,[strDescription]
	,[dblDebit]
	,[dblCredit]
	,[intUndepositedFundId]
	,[intEntityId]
	,[intCreatedUserId]
	,[dtmCreated]
	,[intLastModifiedUserId]
	,[dtmLastModified]
	,[intConcurrencyId])
SELECT
	[intTransactionId]			= @intTransactionId
	,[dtmDate]					= GETDATE()
	,[intGLAccountId]			= T.intAccountId
	,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intAccountId)
	,[dblDebit]					= 0
	,[dblCredit]				= T.dblTotal
	,[intUndepositedFundId]		= NULL
	,[intEntityId]				= NULL
	,[intCreatedUserId]			= @intUserId
	,[dtmCreated]				= GETDATE()
	,[intLastModifiedUserId]	= @intUserId
	,[dtmLastModified]			= GETDATE()
	,[intConcurrencyId]			= 1
FROM tblPRPaycheckTax T
WHERE T.strPaidBy = 'Employee'
  AND T.dblTotal > 0
  AND T.intPaycheckId = @intPaycheckId

/* Insert Company Taxes into tblCMBankTransactionDetail */
INSERT INTO [dbo].[tblCMBankTransactionDetail]
	([intTransactionId]
	,[dtmDate]
	,[intGLAccountId]
	,[strDescription]
	,[dblDebit]
	,[dblCredit]
	,[intUndepositedFundId]
	,[intEntityId]
	,[intCreatedUserId]
	,[dtmCreated]
	,[intLastModifiedUserId]
	,[dtmLastModified]
	,[intConcurrencyId])
SELECT
	[intTransactionId]			= @intTransactionId
	,[dtmDate]					= GETDATE()
	,[intGLAccountId]			= T.intAccountId
	,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intAccountId)
	,[dblDebit]					= 0
	,[dblCredit]				= T.dblTotal
	,[intUndepositedFundId]		= NULL
	,[intEntityId]				= NULL
	,[intCreatedUserId]			= @intUserId
	,[dtmCreated]				= GETDATE()
	,[intLastModifiedUserId]	= @intUserId
	,[dtmLastModified]			= GETDATE()
	,[intConcurrencyId]			= 1
FROM tblPRPaycheckTax T
WHERE T.strPaidBy = 'Company'
  AND T.dblTotal > 0
  AND intPaycheckId = @intPaycheckId
UNION ALL
SELECT
	[intTransactionId]			= @intTransactionId
	,[dtmDate]					= GETDATE()
	,[intGLAccountId]			= T.intExpenseAccountId
	,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intExpenseAccountId)
	,[dblDebit]					= T.dblTotal
	,[dblCredit]				= 0
	,[intUndepositedFundId]		= NULL
	,[intEntityId]				= NULL
	,[intCreatedUserId]			= @intUserId
	,[dtmCreated]				= GETDATE()
	,[intLastModifiedUserId]	= @intUserId
	,[dtmLastModified]			= GETDATE()
	,[intConcurrencyId]			= 1
FROM tblPRPaycheckTax T
WHERE T.strPaidBy = 'Company'
  AND T.dblTotal > 0
  AND T.intPaycheckId = @intPaycheckId

DECLARE @ysnPost BIT = 1
		,@ysnRecap BIT = 0

/* Execute Bank Transaction Post Procedure */
EXEC dbo.uspCMPostBankTransaction @ysnPost, @ysnRecap, @strTransactionId, @intUserId, @intEntityId, @isSuccessful OUTPUT, @message_id OUTPUT

IF (@isSuccessful <> 0)
	BEGIN
		/* If Posting succeeds, mark transaction as posted */
		UPDATE tblPRPaycheck SET ysnPosted = 1 WHERE strPaycheckId = @strTransactionId
		SET @isSuccessful = 1
	END
ELSE
	BEGIN
		/* If Posting fails, delete the created bank transaction */
		DELETE FROM tblCMBankTransactionDetail WHERE intTransactionId = @intTransactionId
		DELETE FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId
		SET @isSuccessful = 0
	END

END
GO