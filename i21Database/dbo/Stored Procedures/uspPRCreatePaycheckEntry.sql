CREATE PROCEDURE [dbo].[uspPRCreatePaycheckEntry]
	@intPaycheckId INT
	,@intUserId INT       
AS
BEGIN

DECLARE @intTransactionId INT
		,@intEmployeeId INT
		,@strTransactionId NVARCHAR(50) = ''

--[insert validations here]--

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
	,[dblAmount]				= PC.dblNetPayTotal
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

/* Get Employee Details */
SELECT @intEmployeeId = intEmployeeId
	  ,@strTransactionId = strPaycheckId 
  FROM tblPRPaycheck 
  WHERE intPaycheckId = @intTransactionId

DECLARE @ysnPost BIT = 1
		,@ysnRecap BIT = 0
		,@isSuccessful BIT
		,@message_id BIT

/* Execute Bank Transaction Post Procedure */
EXEC dbo.uspCMPostBankTransaction @ysnPost, @ysnRecap, @strTransactionId, @intUserId, @intEmployeeId, @isSuccessful, @message_id

END
GO