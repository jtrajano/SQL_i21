CREATE PROCEDURE [dbo].[uspPRPostPaycheck]
	@ysnPost BIT, 
	@ysnRecap BIT,
	@strPaycheckId NVARCHAR(50)
	,@intUserId INT
	,@intEntityId INT
	,@strBatchId NVARCHAR(50) = NULL
	,@isSuccessful BIT = 0 OUTPUT
	,@message_id INT = 0 OUTPUT
	,@batchIdUsed NVARCHAR(50) = '' OUTPUT
AS
BEGIN

DECLARE @intPaycheckId INT
		,@intTransactionId INT
		,@intEmployeeId INT
		,@dtmPayDate DATETIME
		,@strTransactionId NVARCHAR(50) = ''
		,@intBankTransactionTypeId INT = 21
		,@intCreatedEntityId AS INT
		,@intBankAccountId AS INT
		,@strBatchNo AS NVARCHAR(50) = @strBatchId
		,@ysnPaycheckPosted AS BIT
		,@PAYCHECK INT = 21
		,@DIRECT_DEPOSIT INT = 23
		,@BankTransactionTable BankTransactionTable
		,@BankTransactionDetail BankTransactionDetailTable

/* Get Paycheck Details */
SELECT @intPaycheckId = intPaycheckId
	  ,@intEmployeeId = [intEntityEmployeeId]
	  ,@strTransactionId = strPaycheckId
	  ,@dtmPayDate = dtmPayDate
	  ,@intCreatedEntityId = intCreatedUserId
	  ,@intBankAccountId = intBankAccountId
	  ,@ysnPaycheckPosted = ysnPosted
	  ,@intBankTransactionTypeId = CASE WHEN (ISNULL(ysnDirectDeposit, 0) = 1) THEN @DIRECT_DEPOSIT ELSE @PAYCHECK END
FROM tblPRPaycheck 
WHERE strPaycheckId = @strPaycheckId

/****************************************
	CREATING BANK TRANSACTION RECORD
*****************************************/

-- Validations before generating Bank Transaction Record
IF @ysnPost = 1
BEGIN 
	IF (@intBankAccountId IS NULL)
	BEGIN
		RAISERROR('Bank Account is required to post the transaction.', 11, 1)
		GOTO Post_Exit
	END

	IF (@ysnRecap = 0 AND @ysnPaycheckPosted = 1)
	BEGIN
		RAISERROR('The transaction is already posted.', 11, 1)
		GOTO Post_Exit
	END
END

IF (@ysnPost = 1)
BEGIN
	--PRINT 'Insert Paycheck data into tblCMBankTransaction'
	INSERT INTO @BankTransactionTable
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
		,[intBankTransactionTypeId] = @intBankTransactionTypeId
		,[intBankAccountId]			= PC.intBankAccountId
		,[intCurrencyId]			= BA.intCurrencyId
		,[dblExchangeRate]			= (SELECT TOP 1 dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = BA.intCurrencyId)
		,[dtmDate]					= @dtmPayDate
		,[strPayee]					= (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @intEmployeeId)
		,[intPayeeId]				= PC.[intEntityEmployeeId]
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
		,[ysnCheckToBePrinted]		= 1
		,[ysnCheckVoid]				= 0
		,[ysnPosted]				= 0
		,[strLink]					= ''
		,[ysnClr]					= 0
		,[dtmDateReconciled]		= NULL
		,[intBankStatementImportId]	= 1
		,[intBankFileAuditId]		= NULL
		,[strSourceSystem]			= 'PR'
		,[intEntityId]				= PC.intCreatedUserId
		,[intCreatedUserId]			= PC.intCreatedUserId
		,[intCompanyLocationId]		= NULL
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= PC.intLastModifiedUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM tblPRPaycheck PC LEFT JOIN tblCMBankAccount BA 
		ON PC.intBankAccountId = BA.intBankAccountId
	WHERE PC.intPaycheckId = @intPaycheckId
END

IF (@ysnPost = 1)
BEGIN
	--Insert Earning Distribution to Temporary Table
	CREATE TABLE #tmpEarning (
		intPaycheckId			INT
		,intEmployeeEarningId	INT
		,intTypeEarningId		INT
		,intAccountId			INT
		,dblAmount				NUMERIC (18, 6)
		,intDepartmentId		INT
		,strDepartment			NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intProfitCenter		INT
		,intLOB					INT
	)

	INSERT INTO #tmpEarning 
	(
		intPaycheckId
		,intEmployeeEarningId
		,intTypeEarningId
		,intAccountId
		,dblAmount
		,intDepartmentId
		,strDepartment
		,intProfitCenter
		,intLOB
	)
	SELECT 
		A.intPaycheckId
		,A.intEmployeeEarningId
		,A.intTypeEarningId
		,B.intAccountId
		,dblAmount = A.dblTotal * (B.dblPercentage / 100)
		,C.intDepartmentId
		,C.strDepartment
		,C.intProfitCenter
		,C.intLOB
	FROM (
		SELECT intPaycheckId, intEmployeeEarningId, intTypeEarningId, strCalculationType, intEmployeeDepartmentId, dblTotal FROM tblPRPaycheckEarning) A 
		LEFT JOIN tblPREmployeeEarningDistribution B
				ON A.intEmployeeEarningId = B.intEmployeeEarningId
		LEFT JOIN tblPRDepartment C 
	ON A.intEmployeeDepartmentId = C.intDepartmentId
	WHERE A.dblTotal <> 0 AND A.strCalculationType <> 'Fringe Benefit'
	AND intPaycheckId = @intPaycheckId
		
	--Place Earning to Temporary Table to Validate Earning GL Distribution
	SELECT * INTO #tmpEarningTemp FROM #tmpEarning WHERE intDepartmentId IS NOT NULL

	DECLARE @intEarningTempEarningId INT
	DECLARE @intEarningTempDepartmentId INT
	DECLARE @intEarningTempAccountId INT
	DECLARE @intEarningTempProfitCenter INT
	DECLARE @intEarningTempLOB INT
	DECLARE @intEarningTempFinalAccountId INT
	DECLARE @strMsg NVARCHAR(MAX) = ''

	DECLARE @intEarningTempOrigPrimaryAccount INT
	DECLARE @intEarningTempOrigProfitCenter INT
	DECLARE @intEarningTempOrigLOB INT

	--Validate Earning GL Distribution
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEarningTemp)
	BEGIN
		SELECT TOP 1 @intEarningTempEarningId = intTypeEarningId
					,@intEarningTempDepartmentId = intDepartmentId
					,@intEarningTempAccountId = intAccountId
				    ,@intEarningTempProfitCenter = intProfitCenter
					,@intEarningTempLOB = intLOB
					,@intEarningTempFinalAccountId = NULL
					FROM #tmpEarningTemp

		--Step 1: Get the original Segments of the Account
		SELECT TOP 1 @intEarningTempOrigPrimaryAccount = [Primary Account], @intEarningTempOrigProfitCenter = [Location], @intEarningTempOrigLOB = [LOB]
		FROM (
			SELECT 
				A.intAccountId
				,D.strAccountId
				,B.intAccountSegmentId
				,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB' ELSE C.strStructureName END
			FROM tblGLAccountSegmentMapping A
			INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
			INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
			INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
		) AS S
		PIVOT
		(
			MAX(intAccountSegmentId)
			FOR [strStructureName] IN ([Primary Account], [Location], [LOB])
		) AS PVT
		WHERE [intAccountId] = @intEarningTempAccountId

		--Step 2: Get the Account that uses the acquired Primary Account, Profit Center, and LOB
		SELECT TOP 1 @intEarningTempFinalAccountId = intAccountId
		FROM (
			SELECT 
				A.intAccountId
				,D.strAccountId
				,B.intAccountSegmentId
				,strStructureName = CASE WHEN (LOWER(C.strStructureName) IN ('lob', 'line of business')) THEN 'LOB' ELSE C.strStructureName END
			FROM tblGLAccountSegmentMapping A
			INNER JOIN tblGLAccountSegment B ON B.intAccountSegmentId = A.intAccountSegmentId
			INNER JOIN tblGLAccountStructure C ON C.intAccountStructureId = B.intAccountStructureId
			INNER JOIN tblGLAccount D ON A.intAccountId = D.intAccountId
		) AS S
		PIVOT
		(
			MAX(intAccountSegmentId)
			FOR [strStructureName] IN ([Primary Account], [Location], [LOB])
		) AS PVT
		WHERE [Primary Account] = @intEarningTempOrigPrimaryAccount
			AND ISNULL([Location], 0) = ISNULL(@intEarningTempProfitCenter, ISNULL(@intEarningTempOrigProfitCenter, 0))
			AND ISNULL([LOB], 0) = ISNULL(@intEarningTempLOB, ISNULL(@intEarningTempOrigLOB, 0))

		--Step 3: Replace the Earning Account with the Distribution Account
		IF (@intEarningTempFinalAccountId IS NOT NULL) 
			UPDATE #tmpEarning SET intAccountId = @intEarningTempFinalAccountId 
			WHERE intTypeEarningId = @intEarningTempEarningId 
				AND intAccountId = @intEarningTempAccountId 
				AND ISNULL(intDepartmentId, 0) = ISNULL(@intEarningTempDepartmentId, 0)
				AND ISNULL(intProfitCenter, 0) = ISNULL(@intEarningTempProfitCenter, 0)
				AND ISNULL(intLOB, 0) = ISNULL(@intEarningTempLOB, 0)
		ELSE
			SELECT @strMsg = 'One or more accounts for ''' 
				+ (SELECT TOP 1 strEarning FROM tblPRTypeEarning WHERE intTypeEarningId = @intEarningTempEarningId) + ''''
				+ ' Earning GL Distribution does not have a corresponding account for Department ''' 
				+ (SELECT TOP 1 strDepartment FROM tblPRDepartment WHERE intDepartmentId = @intEarningTempDepartmentId) + '''.'
				+ ' Make sure all accounts for this Earning GL Distribution and Department exists.'

		--Immediately end the process once an invalid account combination has been found
		IF (LEN(@strMsg) > 0) 
		BEGIN 
			RAISERROR(@strMsg, 11, 1)
			SET @isSuccessful = 0
			GOTO Post_Exit
		END

		DELETE FROM #tmpEarningTemp 
			WHERE intTypeEarningId = @intEarningTempEarningId
			AND intAccountId = @intEarningTempAccountId
			AND ISNULL(intDepartmentId, 0) = ISNULL(@intEarningTempDepartmentId, 0)
			AND ISNULL(intProfitCenter, 0) = ISNULL(@intEarningTempProfitCenter, 0)
			AND ISNULL(intLOB, 0) = ISNULL(@intEarningTempLOB, 0)
	END

	--PRINT 'Insert Earnings into tblCMBankTransactionDetail'
	INSERT INTO @BankTransactionDetail
		([dtmDate]
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
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= E.intAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = E.intAccountId)
		,[dblDebit]					= CASE WHEN (E.dblAmount > 0) THEN E.dblAmount ELSE 0 END
		,[dblCredit]				= CASE WHEN (E.dblAmount < 0) THEN ABS(E.dblAmount) ELSE 0 END
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM #tmpEarning E

	--PRINT 'Insert Employee Paid Deductions into tblCMBankTransactionDetail'
	INSERT INTO @BankTransactionDetail
		([dtmDate]
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
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= D.intAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = D.intAccountId)
		,[dblDebit]					= 0
		,[dblCredit]				= D.dblTotal
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM tblPRPaycheckDeduction D
	WHERE D.strPaidBy = 'Employee'
		AND D.dblTotal > 0 
		AND D.intPaycheckId = @intPaycheckId

	--PRINT 'Insert Company Paid Deductions into tblCMBankTransactionDetail'
	INSERT INTO @BankTransactionDetail
		([dtmDate]
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
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= D.intAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = D.intAccountId)
		,[dblDebit]					= 0
		,[dblCredit]				= D.dblTotal
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM tblPRPaycheckDeduction D
	WHERE D.strPaidBy = 'Company'
		AND D.dblTotal > 0 
		AND D.intPaycheckId = @intPaycheckId
	UNION ALL
	SELECT
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= D.intExpenseAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = D.intExpenseAccountId)
		,[dblDebit]					= D.dblTotal
		,[dblCredit]				= 0
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM tblPRPaycheckDeduction D
	WHERE D.strPaidBy = 'Company'
		AND D.dblTotal > 0 
		AND D.intPaycheckId = @intPaycheckId

	--PRINT 'Insert Employee Taxes into tblCMBankTransactionDetail'
	INSERT INTO @BankTransactionDetail
		([dtmDate]
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
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= T.intAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intAccountId)
		,[dblDebit]					= 0
		,[dblCredit]				= T.dblTotal
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM tblPRPaycheckTax T
	WHERE T.strPaidBy = 'Employee'
		AND T.dblTotal > 0
		AND T.intPaycheckId = @intPaycheckId

	--PRINT 'Insert Company Taxes into tblCMBankTransactionDetail'
	INSERT INTO @BankTransactionDetail
		([dtmDate]
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
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= T.intAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intAccountId)
		,[dblDebit]					= 0
		,[dblCredit]				= T.dblTotal
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
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
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= T.intExpenseAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intExpenseAccountId)
		,[dblDebit]					= T.dblTotal
		,[dblCredit]				= 0
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM tblPRPaycheckTax T
	WHERE T.strPaidBy = 'Company'
		AND T.dblTotal > 0
		AND T.intPaycheckId = @intPaycheckId
END

IF (@ysnPost = 1) 
BEGIN
	DECLARE @dblCurrentAmount NUMERIC(18, 6)
	SELECT @intTransactionId = intTransactionId,
		   @dblCurrentAmount = dblAmount
		FROM tblCMBankTransaction WHERE strTransactionId = @strTransactionId

	IF (@intTransactionId IS NULL) 
	BEGIN
		EXEC uspCMCreateBankTransactionEntries @BankTransactionTable, @BankTransactionDetail, @intTransactionId
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR('Failed to Generate Bank Transaction entries.', 11, 1)
			GOTO Post_Rollback
		END
	END
	ELSE
	BEGIN
		UPDATE tblCMBankTransaction
		SET 
			[strTransactionId] = BT.strTransactionId	
			,[intBankTransactionTypeId] = BT.intBankTransactionTypeId
			,[intBankAccountId] = BT.intBankAccountId
			,[dtmDate] = BT.dtmDate
			,[strPayee] = BT.strPayee
			,[intPayeeId] = BT.intPayeeId
			,[strAddress] = BT.strAddress
			,[strZipCode] = BT.strZipCode
			,[strCity] = BT.strCity
			,[strState] = BT.strState
			,[strCountry] = BT.strCountry
			,[dblAmount] = BT.dblAmount
			,[strAmountInWords] = BT.strAmountInWords
			,[strMemo] = BT.strMemo
			,[strReferenceNo] = BT.strReferenceNo
			,[dtmCheckPrinted] = BT.dtmCheckPrinted
			,[ysnCheckToBePrinted] = BT.ysnCheckToBePrinted
			,[ysnCheckVoid] = BT.ysnCheckVoid
			,[ysnPosted] = BT.ysnPosted
			,[strLink] = BT.strLink			
			,[ysnClr] = BT.ysnClr			
			,[dtmDateReconciled] = BT.dtmDateReconciled
			,[intBankStatementImportId]	= BT.intBankStatementImportId
			,[intBankFileAuditId] = BT.intBankFileAuditId
			,[strSourceSystem] = BT.strSourceSystem
			,[intEntityId] = BT.intEntityId	
			,[intCreatedUserId] = BT.intCreatedUserId	
			,[intCompanyLocationId] = BT.intCompanyLocationId
			,[dtmCreated] = BT.dtmCreated	
			,[intLastModifiedUserId] = BT.intLastModifiedUserId
			,[dtmLastModified] = BT.dtmLastModified
		FROM @BankTransactionTable BT
		WHERE tblCMBankTransaction.intTransactionId = @intTransactionId

		/* Reinsert Bank Transaction Detail */
		DELETE FROM tblCMBankTransactionDetail WHERE intTransactionId = @intTransactionId
		
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
			@intTransactionId
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
			,[intConcurrencyId]
		FROM @BankTransactionDetail
	END
END


/****************************************
	EXECUTE POSTING PROCEDURE
*****************************************/

BEGIN TRANSACTION

-- CREATE THE TEMPORARY TABLE 
CREATE TABLE #tmpGLDetail (
	[dtmDate]						[datetime] NOT NULL
	,[strBatchId]					[nvarchar](20)  COLLATE Latin1_General_CI_AS NULL
	,[intAccountId]					[int] NULL
	,[dblDebit]						[numeric](18, 6) NULL
	,[dblCredit]					[numeric](18, 6) NULL
	,[dblDebitUnit]					[numeric](18, 6) NULL
	,[dblCreditUnit]				[numeric](18, 6) NULL
	,[strDescription]				[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strCode]						[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[strTransactionId] 			[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intTransactionId] 			[int] NULL
	,[strReference]					[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyId]				[int] NULL
	,[dblExchangeRate]				[numeric](38, 20) NOT NULL
	,[dtmDateEntered]				[datetime] NOT NULL
	,[dtmTransactionDate]			[datetime] NULL
	,[strJournalLineDescription]	[nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[intJournalLineNo]				[int]
	,[ysnIsUnposted]				[bit] NOT NULL
	,[intUserId]					[int] NULL
	,[intEntityId]					[int] NULL
	,[strTransactionType]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strTransactionForm]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strModuleName]				[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL		
	,[intConcurrencyId]				[int] NULL
)

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@STARTING_NUM_TRANSACTION_TYPE_Id AS INT = 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10) = 'PCHK'		-- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100) = 'Payroll'		-- Module where this posting code belongs. 
	,@TRANSACTION_FORM AS NVARCHAR(100) = 'Paychecks'
	,@TRANSACTION_TYPE AS NVARCHAR(100) = 'Paycheck'
	
	-- Local Variables
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@dblAmountDetailTotal AS NUMERIC(18,6)
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT	
	,@ysnBankAccountIdInactive AS BIT
	,@ysnCheckVoid AS BIT	
	,@ysnAllowUserSelfPost AS BIT = 0
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	,@GLEntries AS RecapTableType
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read the header table and populate the variables. 
SELECT	TOP 1 
		@intTransactionId = intTransactionId
		,@dtmDate = dtmDate
		,@dblAmount = dblAmount
		,@ysnTransactionPostedFlag = ysnPosted
		,@ysnTransactionClearedFlag = ysnClr
		,@ysnCheckVoid = ysnCheckVoid		
		,@intBankAccountId = intBankAccountId
		,@intCreatedEntityId = intCreatedUserId
FROM	[dbo].tblCMBankTransaction 
WHERE	strTransactionId = @strTransactionId 
		AND intBankTransactionTypeId = @intBankTransactionTypeId
IF @@ERROR <> 0	GOTO Post_Rollback		
		
-- Read the detail table and populate the variables. 
SELECT	@dblAmountDetailTotal = SUM(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0))
FROM	[dbo].tblCMBankTransactionDetail
WHERE	intTransactionId = @intTransactionId 
IF @@ERROR <> 0	GOTO Post_Rollback		

-- Read the user preference
SELECT	@ysnAllowUserSelfPost = 1
FROM	dbo.tblSMUserPreference 
WHERE	ysnAllowUserSelfPost = 1 
		AND [intEntityUserSecurityId] = @intUserId
IF @@ERROR <> 0	GOTO Post_Rollback	

--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the Paycheck exists. 
IF @intTransactionId IS NULL
BEGIN 
	-- Cannot find the transaction.
	RAISERROR('Cannot find the transaction.', 11, 1)
	GOTO Post_Rollback
END 

-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0) AND @ysnRecap = 0
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR('Unable to find an open fiscal year period to match the transaction date.', 11, 1)
	GOTO Post_Rollback
END

-- Check the amount in Paycheck. See if it is balanced. 
IF ISNULL(@dblAmountDetailTotal, 0) <> ISNULL(@dblAmount, 0) AND @ysnRecap = 0
BEGIN
	-- The debit and credit amounts are not balanced.
	RAISERROR('The debit and credit amounts are not balanced.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already posted
IF @ysnPost = 1 AND @ysnRecap = 0 AND @ysnTransactionPostedFlag = 1
BEGIN 
	-- The transaction is already posted.
	RAISERROR('The transaction is already posted.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already unposted
IF @ysnPost = 0 AND @ysnRecap = 0 AND @ysnTransactionPostedFlag = 0
BEGIN 
	-- The transaction is already unposted.
	RAISERROR('The transaction is already unposted.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already reconciled
IF @ysnPost = 0 AND @ysnRecap = 0 AND @ysnTransactionClearedFlag = 1
BEGIN
	-- 'The transaction is already cleared.'
	RAISERROR('The transaction is already cleared.', 11, 1)
	GOTO Post_Rollback
END

-- Check if the Check is already voided.
IF @ysnRecap = 0 AND @ysnCheckVoid = 1
BEGIN
	-- 'Check is already voided.'
	RAISERROR('Check is already voided.', 11, 1)
	GOTO Post_Rollback
END

-- Check if the bank account is inactive
IF @ysnRecap = 0 
BEGIN
	SELECT	@ysnBankAccountIdInactive = 1
	FROM	tblCMBankAccount
	WHERE	intBankAccountId = @intBankAccountId
			AND (ysnActive = 0 OR intGLAccountId IN (SELECT intAccountId FROM tblGLAccount WHERE ysnActive = 0))
	
	IF @ysnBankAccountIdInactive = 1
	BEGIN
		-- 'The bank account is inactive.'
		RAISERROR('The bank account or its associated GL account is inactive.', 11, 1)
		GOTO Post_Rollback
	END
END 

-- Check Company preference: Allow User Self Post
IF @ysnAllowUserSelfPost = 1 AND @intUserId <> @intCreatedEntityId AND @ysnRecap = 0 
BEGIN 
	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'
	IF @ysnPost = 1	
	BEGIN 
		RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Post')
		GOTO Post_Rollback
	END 
	IF @ysnPost = 0
	BEGIN
		RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Unpost')
		GOTO Post_Rollback		
	END
END 

-- Check if amount is zero. 
IF @dblAmount <= 0 AND @ysnPost = 1 AND @ysnRecap = 0
BEGIN 
	-- Cannot post a zero-value transaction.
	RAISERROR('Cannot post a zero-value transaction.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if transaction is under check printing. 
IF EXISTS (
		SELECT	TOP 1 1 
		FROM	tblCMBankTransaction a INNER JOIN tblCMCheckPrintJobSpool b
					ON a.intBankAccountId = b.intBankAccountId
					AND a.intTransactionId = b.intTransactionId
		WHERE	a.intTransactionId = @intTransactionId 
	)
BEGIN
	-- Unable to unpost while check printing is in progress.
	RAISERROR('Unable to unpost while check printing is in progress.', 11, 1)
	GOTO Post_Rollback
END 

-- Check if transaction has invalid date range
IF @ysnPost = 1 AND @ysnRecap = 0
BEGIN 
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	tblPRPaycheck
		WHERE	intPaycheckId = @intPaycheckId 
		    AND dtmDateFrom > dtmDateTo
	)
	BEGIN
		RAISERROR('Period To cannot be earlier than Period From.', 11, 1)
		GOTO Post_Rollback
	END
END 

-- Check if transaction has associated Payables
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0
BEGIN 
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	tblAPBillDetail
		WHERE	intPaycheckHeaderId = @intPaycheckId 
	)
	BEGIN
		-- Cannot Unpost Paycheck with associated Payables.
		RAISERROR('Cannot Unpost Paycheck with associated Payables.', 11, 1)
		GOTO Post_Rollback
	END
END 
--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
IF (@ysnPost = 1 AND @strBatchNo IS NULL)
BEGIN
	IF (@ysnRecap = 1)
		SET @strBatchNo = @strTransactionId
	ELSE
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchNo OUTPUT 
		IF @@ERROR <> 0	GOTO Post_Rollback
END

IF (@ysnPost = 1)
	SET @batchIdUsed = @strBatchNo
ELSE 
	SET	@batchIdUsed = (SELECT MAX(strBatchId) FROM	tblGLDetail 
		WHERE strTransactionId = @strTransactionId AND ysnIsUnposted = 0 AND strCode = @GL_DETAIL_CODE)

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Paychecks. 	
	INSERT INTO #tmpGLDetail (
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[ysnIsUnposted]
			,[intConcurrencyId]
			,[intUserId]
			,[strTransactionForm]
			,[strTransactionType]
			,[strModuleName]
			,[intEntityId]
	)
	-- 1. CREDIT SIDE
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchNo
			,[intAccountId]			= BankAccnt.intGLAccountId
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmount
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= GLAccnt.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strPayee
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strTransactionType]	= @TRANSACTION_TYPE
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankAccount BankAccnt
				ON A.intBankAccountId = BankAccnt.intBankAccountId
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON BankAccnt.intGLAccountId = GLAccnt.intAccountId
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId
		
	-- 2. DEBIT SIDE
	UNION ALL 
	SELECT	[strTransactionId]		= @strTransactionId
			,[intTransactionId]		= @intTransactionId
			,[dtmDate]				= @dtmDate
			,[strBatchId]			= @strBatchNo
			,[intAccountId]			= B.intGLAccountId
			,[dblDebit]				= B.dblDebit
			,[dblCredit]			= B.dblCredit
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= B.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strPayee
			,[intCurrencyId]		= A.intCurrencyId
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strJournalLineDescription] = GLAccnt.strDescription
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyId]		= 1
			,[intUserId]			= A.intLastModifiedUserId
			,[strTransactionForm]	= @TRANSACTION_FORM
			,[strTransactionType]	= @TRANSACTION_TYPE
			,[strModuleName]		= @MODULE_NAME
			,[intEntityId]			= A.intEntityId
	FROM	[dbo].tblCMBankTransaction A INNER JOIN [dbo].tblCMBankTransactionDetail B
				ON A.intTransactionId = B.intTransactionId
			INNER JOIN [dbo].tblGLAccount GLAccnt
				ON B.intGLAccountId = GLAccnt.intAccountId
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
	WHERE	A.strTransactionId = @strTransactionId		
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransaction
	SET		ysnPosted = 1
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	INSERT INTO #tmpGLDetail (
		[strTransactionId]
		,[intTransactionId]
		,[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[ysnIsUnposted]
		,[intConcurrencyId]
		,[intUserId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intEntityId]
	)
	SELECT	
		[strTransactionId]
		,[intTransactionId]
		,dtmDate = [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit] = [dblCredit]		-- (Debit -> Credit)
		,[dblCredit] = [dblDebit]		-- (Debit <- Credit)
		,[dblDebitUnit] = [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
		,[dblCreditUnit] = [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,dtmDateEntered = GETDATE()
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,ysnIsUnposted = 1
		,[intConcurrencyId]
		,intUserId = @intUserId
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intEntityId]
	FROM tblGLDetail 
	WHERE strBatchId = @batchIdUsed
		AND strTransactionId = @strTransactionId
		AND strCode = @GL_DETAIL_CODE
	ORDER BY intGLDetailId
		
	IF @@ERROR <> 0	GOTO Post_Rollback

	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransaction
	SET		ysnPosted = 0
			,intConcurrencyId += 1 
	WHERE	strTransactionId = @strTransactionId
	IF @@ERROR <> 0	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The G/L Ledger detail table)
---------------------------------------------------------------------------------------------------------------------------------------
--EXEC dbo.uspCMBookGLEntries @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
--IF @isSuccessful = 0 GOTO Post_Rollback

INSERT INTO @GLEntries(
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]	
			) 
SELECT
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]	 
FROM #tmpGLDetail

EXEC uspGLBookEntries @GLEntries, @ysnPost
		
IF @@ERROR <> 0	GOTO Post_Rollback

--=====================================================================================================================================
-- 	Check if process is only a RECAP
---------------------------------------------------------------------------------------------------------------------------------------
IF @ysnRecap = 1 
BEGIN	
	-- INSERT THE DATA FROM #tmpGLDetail TO @RecapTable
	INSERT INTO @RecapTable(
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]	
			) 
	SELECT
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intUserId]
			,[intEntityId]			
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]			
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]	 
	FROM #tmpGLDetail

	IF @@ERROR <> 0	GOTO Post_Rollback
	GOTO Recap_Rollback
END

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	SET @message_id = 10000
	SET @isSuccessful = 1	
	COMMIT TRANSACTION

	IF (@ysnPost = 1 AND @strBatchId IS NOT NULL)
	BEGIN
		UPDATE	tblSMStartingNumber
		SET		intNumber = ISNULL(intNumber, 0) + 1
		WHERE	intStartingNumberId = @STARTING_NUM_TRANSACTION_TYPE_Id
	END
	GOTO Audit_Log
	GOTO Post_Exit

-- If error occured, undo changes to all tables affected
Post_Rollback:
	SET @isSuccessful = 0
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION		            
	GOTO Post_Exit
	
Recap_Rollback: 
	SET @isSuccessful = 1
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	EXEC dbo.uspGLPostRecap @RecapTable
	GOTO Post_Exit
	
Audit_Log:
	DECLARE @actionType NVARCHAR(10)
	SELECT @actionType = CASE WHEN (@ysnPost = 1) THEN 'Posted' ELSE 'Unposted' END
	EXEC uspSMAuditLog 'Payroll.view.Paycheck', @intPaycheckId, @intUserId, @actionType, '', '', ''

-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarning')) DROP TABLE #tmpEarning


/****************************************
	AFTER POSTING PROCEDURES
*****************************************/
IF (@isSuccessful <> 0)
BEGIN
	IF (@ysnPost = 1) 
	BEGIN
		IF (@ysnRecap = 0) 
		BEGIN
			/* If Posting succeeds, mark transaction as posted */
			UPDATE tblPRPaycheck SET 
				ysnPosted = 1
				,dtmPosted = (SELECT TOP 1 dtmDate FROM tblCMBankTransaction WHERE intTransactionId = @intTransactionId) 
			WHERE strPaycheckId = @strTransactionId
			SET @isSuccessful = 1

			/* Delete zero amount Earnings */
			DELETE FROM tblPRPaycheckEarning 
			WHERE intPaycheckId = @intPaycheckId AND dblTotal = 0

			/* Update the Employee Time Off Hours Used */
			UPDATE tblPREmployeeTimeOff
				SET	dblHoursUsed = dblHoursUsed + A.dblHours
				FROM (SELECT 
						intPaycheckId
						,intEmployeeTimeOffId
						,dblHours = SUM(dblHours)
						FROM tblPRPaycheckEarning
						WHERE intPaycheckId = @intPaycheckId
						GROUP BY intPaycheckId, intEmployeeTimeOffId) A
				WHERE tblPREmployeeTimeOff.intTypeTimeOffId = A.intEmployeeTimeOffId
					AND tblPREmployeeTimeOff.[intEntityEmployeeId] = @intEmployeeId

			/* Update Paycheck Direct Deposit Distribution */
			IF (@intBankTransactionTypeId = @DIRECT_DEPOSIT)
				EXEC uspPRPaycheckEFTDistribution @intPaycheckId
		END
	END
	ELSE
	BEGIN 
		IF (@ysnRecap = 0) 
		BEGIN
			/* If Unposting succeeds, mark transaction as unposted */
			UPDATE tblPRPaycheck SET 
				ysnPosted = 0
				,dtmPosted = NULL 
			WHERE strPaycheckId = @strTransactionId

			/* Update the Employee Time Off Hours Used */
			UPDATE tblPREmployeeTimeOff
				SET	dblHoursUsed = dblHoursUsed - A.dblHours
				FROM (SELECT 
						intPaycheckId
						,intEmployeeTimeOffId
						,dblHours = SUM(dblHours)
						FROM tblPRPaycheckEarning
						WHERE intPaycheckId = @intPaycheckId
						GROUP BY intPaycheckId, intEmployeeTimeOffId) A
				WHERE tblPREmployeeTimeOff.intTypeTimeOffId = A.intEmployeeTimeOffId
					AND tblPREmployeeTimeOff.[intEntityEmployeeId] = @intEmployeeId

			/* Delete Any Direct Deposit Entry */
			IF (@intBankTransactionTypeId = @DIRECT_DEPOSIT)
				DELETE FROM tblPRPaycheckDirectDeposit WHERE intPaycheckId = @intPaycheckId

			SET @isSuccessful = 1
		END
	END

	/* Update the Employee Time Off Tiers and Accrued Hours */
	SELECT DISTINCT intTypeTimeOffId INTO #tmpEmployeeTimeOff FROM tblPREmployeeTimeOff WHERE intEntityEmployeeId = @intEmployeeId
		
	DECLARE @intTypeTimeOffId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeTimeOff)
	BEGIN
		SELECT TOP 1 @intTypeTimeOffId = intTypeTimeOffId FROM #tmpEmployeeTimeOff

		EXEC uspPRUpdateEmployeeTimeOff @intTypeTimeOffId, @intEmployeeId
		EXEC uspPRUpdateEmployeeTimeOffHours @intTypeTimeOffId, @intEmployeeId

		DELETE FROM #tmpEmployeeTimeOff WHERE intTypeTimeOffId = @intTypeTimeOffId
	END

	EXEC uspPRInsertPaycheckTimeOff @intPaycheckId
END
END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeTimeOff')) DROP TABLE #tmpEmployeeTimeOff