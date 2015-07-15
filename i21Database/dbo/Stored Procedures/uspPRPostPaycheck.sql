CREATE PROCEDURE [dbo].[uspPRPostPaycheck]
	@ysnPost BIT, 
	@ysnRecap BIT,
	@strPaycheckId NVARCHAR(50)
	,@intUserId INT
	,@intEntityId INT
	,@strBatchId NVARCHAR(50) = NULL
	,@isSuccessful BIT = 0 OUTPUT
	,@message_id INT = 0 OUTPUT

AS
BEGIN

DECLARE @intPaycheckId INT
		,@intTransactionId INT = -1
		,@intEmployeeId INT
		,@dtmPayDate DATETIME
		,@strTransactionId NVARCHAR(50) = ''

/* Get Paycheck Details */
SELECT @intPaycheckId = intPaycheckId
	  ,@intEmployeeId = intEmployeeId
	  ,@strTransactionId = strPaycheckId
	  ,@dtmPayDate = dtmPayDate
FROM tblPRPaycheck 
WHERE strPaycheckId = @strPaycheckId


IF (@ysnPost = 1)
BEGIN

IF NOT EXISTS (SELECT strTransactionId FROM tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN
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
			,[dtmDate]					= @dtmPayDate
			,[strPayee]					= (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = @intEmployeeId)
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
			,[dtmDate]					= @dtmPayDate
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
			,[dtmDate]					= @dtmPayDate
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
			,[dtmDate]					= @dtmPayDate
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
			,[dtmDate]					= @dtmPayDate
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
			,[dtmDate]					= @dtmPayDate
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
	END
END


/* Execute Bank Transaction Post Procedure */
EXEC dbo.uspCMPostBankTransaction @ysnPost, @ysnRecap, @strTransactionId, @strBatchId, @intUserId, @intEntityId, @isSuccessful OUTPUT, @message_id OUTPUT

IF (@isSuccessful <> 0)
	BEGIN
		IF (@ysnPost = 1) 
			BEGIN
				/* If Posting succeeds, mark transaction as posted */
				UPDATE tblPRPaycheck SET 
					ysnPosted = 1
					,dtmPosted = (SELECT TOP 1 dtmDate FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId) 
				WHERE strPaycheckId = @strTransactionId
				SET @isSuccessful = 1

				/* Update the Employee Time Off Hours */
				UPDATE tblPREmployeeTimeOff
					SET	dblHoursUsed = dblHoursUsed + A.dblHours
					FROM tblPRPaycheckEarning A
					WHERE tblPREmployeeTimeOff.intEmployeeTimeOffId = A.intEmployeeTimeOffId
						AND tblPREmployeeTimeOff.intEmployeeId = @intEmployeeId
						AND A.intPaycheckId = @intPaycheckId
			END
		ELSE
			BEGIN 
			/* If Unposting succeeds, mark transaction as unposted and delete the corresponding bank transaction */
				UPDATE tblPRPaycheck SET 
					ysnPosted = 0
					,dtmPosted = NULL 
				WHERE strPaycheckId = @strTransactionId

				/* Update the Employee Time Off Hours */
				UPDATE tblPREmployeeTimeOff
					SET	dblHoursUsed = dblHoursUsed - A.dblHours
					FROM tblPRPaycheckEarning A
					WHERE tblPREmployeeTimeOff.intEmployeeTimeOffId = A.intEmployeeTimeOffId
						AND tblPREmployeeTimeOff.intEmployeeId = @intEmployeeId
						AND A.intPaycheckId = @intPaycheckId

				SELECT @intTransactionId = intTransactionId FROM tblCMBankTransaction WHERE strTransactionId = @strTransactionId
				DELETE FROM tblCMBankTransactionDetail WHERE intTransactionId = @intTransactionId
				DELETE FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId

				SET @isSuccessful = 1
			END
	END
ELSE
	BEGIN
		IF (@ysnPost = 1) 
			BEGIN
				/* If Posting fails, delete the created bank transaction */
				DELETE FROM tblCMBankTransactionDetail WHERE intTransactionId = @intTransactionId
				DELETE FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId
				SET @isSuccessful = 0
			END
		ELSE
			BEGIN
				SET @isSuccessful = 0
			END
	END

END
GO