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
	/****************************************
	   INSERT BANK TRANSACTION HEADER
	*****************************************/
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
	/********************************************
	  INSERT BANK TRANSACTION DETAIL - EARNINGS
	*********************************************/

	--Create Earning Distribution Temporary Table
	CREATE TABLE #tmpEarning (
		intTmpEarningId			INT IDENTITY(1, 1)
		,intPaycheckEarningId	INT
		,intPaycheckId			INT
		,intEmployeeEarningId	INT
		,intTypeEarningId		INT
		,intAccountId			INT
		,dblAmount				NUMERIC (18, 6)
		,dblPercentage			NUMERIC (18, 6)
		,intDepartmentId		INT
		,intProfitCenter		INT
		,intLOB					INT
		,intWCCodeId			INT
	)

	--Insert Earning Distribution to Temporary Table
	INSERT INTO #tmpEarning (intPaycheckEarningId, intPaycheckId, intEmployeeEarningId, intTypeEarningId, intAccountId, dblAmount, dblPercentage, intDepartmentId, intProfitCenter, intLOB, intWCCodeId)
	SELECT A.intPaycheckEarningId, A.intPaycheckId, A.intEmployeeEarningId, A.intTypeEarningId, A.intAccountId, ISNULL(A.dblTotal, 0), ISNULL(B.dblPercentage, 0),
			C.intDepartmentId, ISNULL(B.intProfitCenter, C.intProfitCenter), C.intLOB, intWCCodeId = A.intWorkersCompensationId
	FROM (SELECT intPaycheckEarningId, tblPRPaycheckEarning.intPaycheckId, intEmployeeEarningId, intEntityEmployeeId, intAccountId,
			intTypeEarningId, strCalculationType, intEmployeeDepartmentId, intWorkersCompensationId, dblTotal 
		  FROM tblPRPaycheckEarning INNER JOIN tblPRPaycheck ON tblPRPaycheckEarning.intPaycheckId = tblPRPaycheck.intPaycheckId) A 
		LEFT JOIN tblPREmployeeLocationDistribution B
				ON A.intEntityEmployeeId = B.intEntityEmployeeId
		LEFT JOIN tblPRDepartment C 
	ON A.intEmployeeDepartmentId = C.intDepartmentId
	WHERE A.dblTotal <> 0 AND A.strCalculationType <> 'Fringe Benefit'
	AND intPaycheckId = @intPaycheckId

	--PERFORM GL ACCOUNT SEGMENT SWITCHING AND VALIDATION
	--Place Earning to Temporary Table to Validate Account ID Distribution
	SELECT * INTO #tmpEarningValidateAccounts 
	FROM #tmpEarning WHERE intEmployeeEarningId IN (SELECT intEmployeeEarningId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = @intEmployeeId AND ysnUseLocationDistribution = 1)
	AND (ISNULL((SELECT SUM(dblPercentage) FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @intEmployeeId), 0) = 100 OR intDepartmentId IS NOT NULL)

	DECLARE @intEarningTempEarningId INT, @intEarningTempDepartmentId INT, @intEarningTempWCCodeId INT, @intEarningTempAccountId INT,
		@intEarningTempProfitCenter INT, @intEarningTempLOB INT, @intEarningTempFinalAccountId INT, @strMsg NVARCHAR(MAX) = ''

	--Validate Earning GL Distribution
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEarningValidateAccounts)
	BEGIN
		SELECT TOP 1 @intEarningTempEarningId = intTypeEarningId, @intEarningTempDepartmentId = intDepartmentId, @intEarningTempWCCodeId = intWCCodeId
					,@intEarningTempAccountId = intAccountId, @intEarningTempProfitCenter = intProfitCenter, @intEarningTempLOB = intLOB
					,@intEarningTempFinalAccountId = dbo.fnPRGetAccountIdWithThisLocationLOB(intAccountId, intProfitCenter, intLOB)
					FROM #tmpEarningValidateAccounts

		--Replace the Earning Account with the Distribution Account
		IF (@intEarningTempFinalAccountId IS NOT NULL) 
			UPDATE #tmpEarning SET intAccountId = @intEarningTempFinalAccountId 
			WHERE intTypeEarningId = @intEarningTempEarningId 
				AND intAccountId = @intEarningTempAccountId 
				AND ISNULL(intDepartmentId, 0) = ISNULL(@intEarningTempDepartmentId, 0)
				AND ISNULL(intProfitCenter, 0) = ISNULL(@intEarningTempProfitCenter, 0)
				AND ISNULL(intLOB, 0) = ISNULL(@intEarningTempLOB, 0)
		ELSE
			SELECT @strMsg = 'Earning Type ''' + (SELECT TOP 1 strEarning FROM tblPRTypeEarning WHERE intTypeEarningId = @intEarningTempEarningId) + ''''
				+ ' with Account ID ''' + (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = @intEarningTempAccountId) + ''''
				+ ' does not have a corresponding Account' + 
				+ ' for Location ''' + (SELECT TOP 1 strCode FROM tblGLAccountSegment WHERE intAccountSegmentId = @intEarningTempProfitCenter) + '''' 
				+ CASE WHEN (@intEarningTempLOB IS NOT NULL) THEN 
					'and LOB ''' + (SELECT TOP 1 strCode FROM tblGLAccountSegment WHERE intAccountSegmentId = @intEarningTempLOB) + '''' ELSE '' END
				+ '. Make sure all accounts for this employee''s GL Location Distribution and Department exists.'
			

		--Immediately end the process once an invalid account combination has been found
		IF (LEN(@strMsg) > 0) 
		BEGIN 
			RAISERROR(@strMsg, 11, 1)
			SET @isSuccessful = 0
			GOTO Post_Exit
		END

		DELETE FROM #tmpEarningValidateAccounts 
			WHERE intTypeEarningId = @intEarningTempEarningId
			AND intAccountId = @intEarningTempAccountId
			AND ISNULL(intDepartmentId, 0) = ISNULL(@intEarningTempDepartmentId, 0)
			AND ISNULL(intWCCodeId, 0) = ISNULL(@intEarningTempWCCodeId, 0)
			AND ISNULL(intProfitCenter, 0) = ISNULL(@intEarningTempProfitCenter, 0)
			AND ISNULL(intLOB, 0) = ISNULL(@intEarningTempLOB, 0)
	END

	--PERFORM AMOUNT DISTRIBUTION
	--Place Earning to Temporary Table to Distribute Amounts
	SELECT intTmpEarningId, intPaycheckEarningId, dblAmount INTO #tmpEarningAmount FROM #tmpEarning
	DECLARE @intAmountTempPaycheckEarningId INT, @dblAmountTempEarningFullAmount NUMERIC(18, 6), @intAmountTempTmpEarningId INT

	--Distribute Amounts
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEarningAmount)
	BEGIN
		SELECT TOP 1 @dblAmountTempEarningFullAmount = dblAmount
					,@intAmountTempPaycheckEarningId = intPaycheckEarningId
		FROM #tmpEarningAmount

		WHILE (@dblAmountTempEarningFullAmount <> 0)
		BEGIN
			SELECT TOP 1 @intAmountTempTmpEarningId = intTmpEarningId FROM #tmpEarningAmount 
			WHERE intPaycheckEarningId = @intAmountTempPaycheckEarningId

			IF ((SELECT COUNT(1) FROM #tmpEarningAmount WHERE intPaycheckEarningId = @intAmountTempPaycheckEarningId) = 1) 
				BEGIN
					UPDATE #tmpEarning SET dblAmount = @dblAmountTempEarningFullAmount WHERE intTmpEarningId = @intAmountTempTmpEarningId
					SELECT @dblAmountTempEarningFullAmount = 0.000000
				END
			ELSE
				BEGIN
					SELECT @dblAmountTempEarningFullAmount = @dblAmountTempEarningFullAmount - ROUND(dblAmount * (dblPercentage / 100.000000), 2) FROM #tmpEarning WHERE intTmpEarningId = @intAmountTempTmpEarningId
					UPDATE #tmpEarning SET dblAmount = ROUND(dblAmount * (dblPercentage / 100.000000), 2) WHERE intTmpEarningId = @intAmountTempTmpEarningId
				END

			DELETE FROM #tmpEarningAmount WHERE intTmpEarningId = @intAmountTempTmpEarningId
		END

		DELETE FROM #tmpEarningAmount 
			WHERE intPaycheckEarningId = @intAmountTempPaycheckEarningId
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
		,[dblDebit]					= CASE WHEN (SUM(E.dblAmount) > 0) THEN SUM(E.dblAmount) ELSE 0 END
		,[dblCredit]				= CASE WHEN (SUM(E.dblAmount) < 0) THEN ABS(SUM(E.dblAmount)) ELSE 0 END
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM #tmpEarning E
	GROUP BY
		E.intAccountId

	--Get Earning Department Distribution Percentage For Deduction and Tax Distribution
	SELECT intDepartmentId, dblAmount = SUM(dblAmount), dblPercent = 0 INTO #tmpEarningDepartmentPercentage FROM #tmpEarning GROUP BY intDepartmentId
	UPDATE #tmpEarningDepartmentPercentage SET dblPercent = (dblAmount / dblTotalAmount) * 100 FROM (SELECT dblTotalAmount = SUM(dblAmount) FROM #tmpEarningDepartmentPercentage) T

	/********************************************
	  INSERT BANK TRANSACTION DETAIL - DEDUCTIONS
	*********************************************/

	--Create Deduction Distribution Temporary Table
	CREATE TABLE #tmpDeduction (
		intTmpDeductionId		INT IDENTITY(1, 1)
		,intPaycheckId			INT
		,intEmployeeDeductionId	INT
		,intTypeDeductionId		INT
		,strPaidBy				NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL
		,intAccountId			INT
		,intExpenseAccountId	INT
		,ysnSplitAccount		BIT
		,ysnSplitExpense		BIT
		,dblAmount				NUMERIC (18, 6)
		,dblPercentage			NUMERIC (18, 6)
		,intDepartmentId		INT
		,intProfitCenter		INT
		,intLOB					INT
	)

	--Insert Deduction Distribution to Temporary Table
	INSERT INTO #tmpDeduction (intPaycheckId, intEmployeeDeductionId, intTypeDeductionId, strPaidBy, intAccountId, intExpenseAccountId, ysnSplitAccount, ysnSplitExpense,
								dblAmount, dblPercentage, intDepartmentId, intProfitCenter, intLOB)
	SELECT A.intPaycheckId, A.intEmployeeDeductionId, A.intTypeDeductionId, A.strPaidBy, A.intAccountId, A.intExpenseAccountId, A.ysnSplitAccount, A.ysnSplitExpense,
			ISNULL(A.dblTotal, 0), ISNULL(ISNULL(B.dblPercentage, A.dblDepartmentPercent), 0), C.intDepartmentId, ISNULL(B.intProfitCenter, C.intProfitCenter), C.intLOB
	FROM (SELECT PD.intPaycheckId, PD.intEmployeeDeductionId, PC.intEntityEmployeeId, PD.strPaidBy, PD.intAccountId, PD.intExpenseAccountId,
			ysnSplitAccount = ED.ysnUseLocationDistribution, ysnSplitExpense = ED.ysnUseLocationDistributionExpense,
			PD.intTypeDeductionId, dblTotal, intEmployeeDepartmentId, dblDepartmentPercent
		  FROM tblPRPaycheckDeduction PD
			INNER JOIN tblPRPaycheck PC ON PD.intPaycheckId = PC.intPaycheckId
			INNER JOIN tblPREmployeeDeduction ED ON PD.intEmployeeDeductionId = ED.intEmployeeDeductionId
			OUTER APPLY (SELECT intEmployeeDepartmentId = intDepartmentId, dblDepartmentPercent = dblPercent FROM #tmpEarningDepartmentPercentage) DP
			) A 
		LEFT JOIN tblPREmployeeLocationDistribution B
				ON A.intEntityEmployeeId = B.intEntityEmployeeId
		LEFT JOIN tblPRDepartment C 
	ON A.intEmployeeDepartmentId = C.intDepartmentId
	WHERE A.dblTotal <> 0
	AND intPaycheckId = @intPaycheckId

	--PERFORM GL ACCOUNT SEGMENT SWITCHING AND VALIDATION
	--Place Deduction to Temporary Table to Validate Account ID Distribution
	SELECT * INTO #tmpDeductionValidateAccounts 
	FROM #tmpDeduction WHERE intEmployeeDeductionId IN (SELECT intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intEntityEmployeeId = @intEmployeeId
														AND (ysnUseLocationDistribution = 1 OR ysnUseLocationDistributionExpense = 1))
	AND (ISNULL((SELECT SUM(dblPercentage) FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @intEmployeeId), 0) = 100 OR intDepartmentId IS NOT NULL)

	DECLARE @intDeductionTempDeductionId INT, @intDeductionTempDepartmentId INT, @intDeductionTempAccountId INT, @intDeductionTempExpenseAccountId INT,
		@intDeductionTempProfitCenter INT, @intDeductionTempLOB INT, @intDeductionTempFinalAccountId INT, @intDeductionTempFinalExpenseAccountId INT

	--Validate Deduction GL Distribution
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDeductionValidateAccounts)
	BEGIN
		SELECT TOP 1 @intDeductionTempDeductionId = intTypeDeductionId, @intDeductionTempDepartmentId = intDepartmentId
					,@intDeductionTempAccountId = intAccountId, @intDeductionTempExpenseAccountId = intExpenseAccountId 
					,@intDeductionTempProfitCenter = intProfitCenter, @intDeductionTempLOB = intLOB
					,@intDeductionTempFinalAccountId = CASE WHEN (ysnSplitAccount = 1) THEN dbo.fnPRGetAccountIdWithThisLocationLOB(intAccountId, intProfitCenter, intLOB) ELSE intAccountId END
					,@intDeductionTempFinalExpenseAccountId = CASE WHEN (ysnSplitExpense = 1) THEN dbo.fnPRGetAccountIdWithThisLocationLOB(intExpenseAccountId, intProfitCenter, intLOB) ELSE intExpenseAccountId END
					FROM #tmpDeductionValidateAccounts

		--Replace the Deduction Account with the Distribution Account
		IF (@intDeductionTempFinalAccountId IS NOT NULL AND (@intDeductionTempExpenseAccountId IS NULL OR @intDeductionTempFinalExpenseAccountId IS NOT NULL)) 
			UPDATE #tmpDeduction SET intAccountId = @intDeductionTempFinalAccountId, intExpenseAccountId = @intDeductionTempFinalExpenseAccountId
			WHERE intTypeDeductionId = @intDeductionTempDeductionId 
				AND intAccountId = @intDeductionTempAccountId AND ISNULL(intExpenseAccountId, 0) = ISNULL(@intDeductionTempExpenseAccountId, 0)
				AND ISNULL(intDepartmentId, 0) = ISNULL(@intDeductionTempDepartmentId, 0)
				AND ISNULL(intProfitCenter, 0) = ISNULL(@intDeductionTempProfitCenter, 0)
				AND ISNULL(intLOB, 0) = ISNULL(@intDeductionTempLOB, 0)
		ELSE
			SELECT @strMsg = 'Deduction Type ''' + (SELECT TOP 1 strDeduction FROM tblPRTypeDeduction WHERE intTypeDeductionId = @intDeductionTempDeductionId) + ''''
				+ ' with Liability Account ''' + (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = @intDeductionTempAccountId) + ''''
				+ CASE WHEN (@intDeductionTempExpenseAccountId IS NOT NULL) THEN 
					' or Expense Account ''' + (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = @intDeductionTempExpenseAccountId) + '''' ELSE '' END
				+ ' does not have a corresponding Account' + 
				+ ' for Location ''' + (SELECT TOP 1 strCode FROM tblGLAccountSegment WHERE intAccountSegmentId = @intDeductionTempProfitCenter) + '''' 
				+ CASE WHEN (@intDeductionTempLOB IS NOT NULL) THEN 
					'and LOB ''' + (SELECT TOP 1 strCode FROM tblGLAccountSegment WHERE intAccountSegmentId = @intDeductionTempLOB) + '''' ELSE '' END
				+ '. Make sure all accounts for this employee''s GL Location Distribution and Department exists.'

		--Immediately end the process once an invalid account combination has been found
		IF (LEN(@strMsg) > 0) 
		BEGIN 
			RAISERROR(@strMsg, 11, 1)
			SET @isSuccessful = 0
			GOTO Post_Exit
		END

		DELETE FROM #tmpDeductionValidateAccounts 
			WHERE intTypeDeductionId = @intDeductionTempDeductionId
			AND intAccountId = @intDeductionTempAccountId AND ISNULL(intExpenseAccountId, 0) = ISNULL(@intDeductionTempExpenseAccountId, 0)
			AND ISNULL(intDepartmentId, 0) = ISNULL(@intDeductionTempDepartmentId, 0)
			AND ISNULL(intProfitCenter, 0) = ISNULL(@intDeductionTempProfitCenter, 0)
			AND ISNULL(intLOB, 0) = ISNULL(@intDeductionTempLOB, 0)
	END

	--PERFORM AMOUNT DISTRIBUTION
	--Place Deduction to Temporary Table to Distribute Amounts
	SELECT intTmpDeductionId, intTypeDeductionId, dblAmount INTO #tmpDeductionAmount FROM #tmpDeduction
	DECLARE @intTypeDeductionId INT, @dblDeductionFullAmount NUMERIC(18, 6), @intTmpDeductionId INT

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDeductionAmount)
	BEGIN
		SELECT TOP 1 @dblDeductionFullAmount = dblAmount
					,@intTypeDeductionId = intTypeDeductionId
		FROM #tmpDeductionAmount

		WHILE (@dblDeductionFullAmount <> 0)
		BEGIN
			SELECT TOP 1 @intTmpDeductionId = intTmpDeductionId FROM #tmpDeductionAmount WHERE intTypeDeductionId = @intTypeDeductionId

			IF ((SELECT COUNT(1) FROM #tmpDeductionAmount WHERE intTypeDeductionId = @intTypeDeductionId) = 1) 
				BEGIN
					UPDATE #tmpDeduction SET dblAmount = @dblDeductionFullAmount WHERE intTmpDeductionId = @intTmpDeductionId
					SELECT @dblDeductionFullAmount = 0.000000
				END
			ELSE
				BEGIN
					SELECT @dblDeductionFullAmount = @dblDeductionFullAmount - ROUND(dblAmount * (dblPercentage / 100.000000), 2) FROM #tmpDeduction WHERE intTmpDeductionId = @intTmpDeductionId
					UPDATE #tmpDeduction SET dblAmount = ROUND(dblAmount * (dblPercentage / 100.000000), 2) WHERE intTmpDeductionId = @intTmpDeductionId
				END

			DELETE FROM #tmpDeductionAmount WHERE intTmpDeductionId = @intTmpDeductionId
		END

		DELETE FROM #tmpDeductionAmount WHERE intTypeDeductionId = @intTypeDeductionId
	END

	--PRINT 'Insert Deductions into tblCMBankTransactionDetail'
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
		,[dblCredit]				= SUM(D.dblAmount)
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM #tmpDeduction D
		LEFT JOIN tblPRPaycheckDeduction D2
		ON D.intPaycheckId = D2.intPaycheckId
		AND D.intEmployeeDeductionId = D2.intEmployeeDeductionId
	WHERE D2.strPaidBy IN ('Company', 'Employee')
		AND D2.dblTotal > 0 
		AND D.intPaycheckId = @intPaycheckId
	GROUP BY
		D.intAccountId
	UNION ALL
	SELECT
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= D.intExpenseAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = D.intExpenseAccountId)
		,[dblDebit]					= SUM(D.dblAmount)
		,[dblCredit]				= 0
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM #tmpDeduction D
		LEFT JOIN tblPRPaycheckDeduction D2
		ON D.intPaycheckId = D2.intPaycheckId
		AND D.intEmployeeDeductionId = D2.intEmployeeDeductionId
	WHERE D2.strPaidBy = 'Company'
		AND D2.dblTotal > 0 
		AND D.intPaycheckId = @intPaycheckId
	GROUP BY
		D.intExpenseAccountId

	/********************************************
	  INSERT BANK TRANSACTION DETAIL - TAXES
	*********************************************/

	--Create Tax Distribution Temporary Table
	CREATE TABLE #tmpTax (
		intTmpTaxId				INT IDENTITY(1, 1)
		,intPaycheckId			INT
		,intTypeTaxId			INT
		,strPaidBy				NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL
		,intAccountId			INT
		,intExpenseAccountId	INT
		,ysnSplitAccount		BIT
		,ysnSplitExpense		BIT
		,dblAmount				NUMERIC (18, 6)
		,dblPercentage			NUMERIC (18, 6)
		,intDepartmentId		INT
		,intProfitCenter		INT
		,intLOB					INT
	)

	--Insert Tax Distribution to Temporary Table
	INSERT INTO #tmpTax (intPaycheckId, intTypeTaxId, strPaidBy, intAccountId, intExpenseAccountId, ysnSplitAccount, ysnSplitExpense,
								dblAmount, dblPercentage, intDepartmentId, intProfitCenter, intLOB)
	SELECT A.intPaycheckId, A.intTypeTaxId, A.strPaidBy, A.intAccountId, A.intExpenseAccountId, A.ysnSplitAccount, A.ysnSplitExpense,
			A.dblTotal, ISNULL(ISNULL(B.dblPercentage, A.dblDepartmentPercent), 0), C.intDepartmentId, ISNULL(B.intProfitCenter, C.intProfitCenter), C.intLOB
	FROM (SELECT PD.intPaycheckId, PC.intEntityEmployeeId, PD.strPaidBy, PD.intAccountId, PD.intExpenseAccountId, 
			ysnSplitAccount = ET.ysnUseLocationDistribution, ysnSplitExpense = ET.ysnUseLocationDistributionExpense,
			PD.intTypeTaxId, dblTotal, intEmployeeDepartmentId, dblDepartmentPercent
		  FROM tblPRPaycheckTax PD
			INNER JOIN tblPRPaycheck PC ON PD.intPaycheckId = PC.intPaycheckId
			INNER JOIN tblPREmployeeTax ET ON PD.intTypeTaxId = ET.intTypeTaxId AND ET.intEntityEmployeeId = PC.intEntityEmployeeId
			OUTER APPLY (SELECT intEmployeeDepartmentId = intDepartmentId, dblDepartmentPercent = dblPercent FROM #tmpEarningDepartmentPercentage) DP
			) A 
		LEFT JOIN tblPREmployeeLocationDistribution B
				ON A.intEntityEmployeeId = B.intEntityEmployeeId
		LEFT JOIN tblPRDepartment C 
	ON A.intEmployeeDepartmentId = C.intDepartmentId
	WHERE A.dblTotal <> 0
	AND intPaycheckId = @intPaycheckId

	--PERFORM GL ACCOUNT SEGMENT SWITCHING AND VALIDATION
	--Place Tax to Temporary Table to Validate Account ID Distribution
	SELECT * INTO #tmpTaxValidateAccounts 
	FROM #tmpTax WHERE intTypeTaxId IN (SELECT intTypeTaxId FROM tblPREmployeeTax WHERE intEntityEmployeeId = @intEmployeeId AND (ysnUseLocationDistribution = 1 OR ysnUseLocationDistributionExpense = 1))
	AND (ISNULL((SELECT SUM(dblPercentage) FROM tblPREmployeeLocationDistribution WHERE intEntityEmployeeId = @intEmployeeId), 0) = 100 OR intDepartmentId IS NOT NULL)

	DECLARE @intTaxTempTaxId INT, @intTaxTempDepartmentId INT, @intTaxTempAccountId INT, @intTaxTempExpenseAccountId INT,
		@intTaxTempProfitCenter INT, @intTaxTempLOB INT, @intTaxTempFinalAccountId INT, @intTaxTempFinalExpenseAccountId INT

	--Validate Tax GL Distribution
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpTaxValidateAccounts)
	BEGIN
		SELECT TOP 1 @intTaxTempTaxId = intTypeTaxId, @intTaxTempDepartmentId = intDepartmentId
					,@intTaxTempAccountId = intAccountId, @intTaxTempExpenseAccountId = intExpenseAccountId 
					,@intTaxTempProfitCenter = intProfitCenter, @intTaxTempLOB = intLOB
					,@intTaxTempFinalAccountId = CASE WHEN (ysnSplitAccount = 1) THEN dbo.fnPRGetAccountIdWithThisLocationLOB(intAccountId, intProfitCenter, intLOB) ELSE intAccountId END
					,@intTaxTempFinalExpenseAccountId = CASE WHEN (ysnSplitExpense = 1) THEN dbo.fnPRGetAccountIdWithThisLocationLOB(intExpenseAccountId, intProfitCenter, intLOB) ELSE intExpenseAccountId END
					FROM #tmpTaxValidateAccounts

		--Replace the Tax Account with the Distribution Account
		IF (@intTaxTempFinalAccountId IS NOT NULL AND (@intTaxTempExpenseAccountId IS NULL OR @intTaxTempFinalExpenseAccountId IS NOT NULL)) 
			UPDATE #tmpTax SET intAccountId = @intTaxTempFinalAccountId, intExpenseAccountId = @intTaxTempFinalExpenseAccountId
			WHERE intTypeTaxId = @intTaxTempTaxId 
				AND intAccountId = @intTaxTempAccountId AND ISNULL(intExpenseAccountId, 0) = ISNULL(@intTaxTempExpenseAccountId, 0)
				AND ISNULL(intDepartmentId, 0) = ISNULL(@intTaxTempDepartmentId, 0)
				AND ISNULL(intProfitCenter, 0) = ISNULL(@intTaxTempProfitCenter, 0)
				AND ISNULL(intLOB, 0) = ISNULL(@intTaxTempLOB, 0)
		ELSE
			SELECT @strMsg = 'Tax Type ''' + (SELECT TOP 1 strTax FROM tblPRTypeTax WHERE intTypeTaxId = @intTaxTempTaxId) + ''''
				+ ' with Liability Account ''' + (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = @intTaxTempAccountId) + ''''
				+ CASE WHEN (@intTaxTempExpenseAccountId IS NOT NULL) THEN 
					' or Expense Account ''' + (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = @intTaxTempExpenseAccountId) + '''' ELSE '' END
				+ ' does not have a corresponding Account' + 
				+ ' for Location ''' + (SELECT TOP 1 strCode FROM tblGLAccountSegment WHERE intAccountSegmentId = @intTaxTempProfitCenter) + '''' 
				+ CASE WHEN (@intTaxTempLOB IS NOT NULL) THEN 
					'and LOB ''' + (SELECT TOP 1 strCode FROM tblGLAccountSegment WHERE intAccountSegmentId = @intTaxTempLOB) + '''' ELSE '' END
				+ '. Make sure all accounts for this employee''s GL Location Distribution and Department exists.'

		--Immediately end the process once an invalid account combination has been found
		IF (LEN(@strMsg) > 0) 
		BEGIN 
			RAISERROR(@strMsg, 11, 1)
			SET @isSuccessful = 0
			GOTO Post_Exit
		END

		DELETE FROM #tmpTaxValidateAccounts 
			WHERE intTypeTaxId = @intTaxTempTaxId
			AND intAccountId = @intTaxTempAccountId AND ISNULL(intExpenseAccountId, 0) = ISNULL(@intTaxTempExpenseAccountId, 0)
			AND ISNULL(intDepartmentId, 0) = ISNULL(@intTaxTempDepartmentId, 0)
			AND ISNULL(intProfitCenter, 0) = ISNULL(@intTaxTempProfitCenter, 0)
			AND ISNULL(intLOB, 0) = ISNULL(@intTaxTempLOB, 0)
	END

	--PERFORM AMOUNT DISTRIBUTION
	--Place Tax to Temporary Table to Distribute Amounts
	SELECT intTmpTaxId, intTypeTaxId, dblAmount INTO #tmpTaxAmount FROM #tmpTax
	DECLARE @intTypeTaxId INT, @dblTaxFullAmount NUMERIC(18, 6), @intTmpTaxId INT

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpTaxAmount)
	BEGIN
		SELECT TOP 1 @dblTaxFullAmount = dblAmount
					,@intTypeTaxId = intTypeTaxId
		FROM #tmpTaxAmount

		WHILE (@dblTaxFullAmount <> 0)
		BEGIN
			SELECT TOP 1 @intTmpTaxId = intTmpTaxId FROM #tmpTaxAmount WHERE intTypeTaxId = @intTypeTaxId

			IF ((SELECT COUNT(1) FROM #tmpTaxAmount WHERE intTypeTaxId = @intTypeTaxId) = 1) 
				BEGIN
					UPDATE #tmpTax SET dblAmount = @dblTaxFullAmount WHERE intTmpTaxId = @intTmpTaxId
					SELECT @dblTaxFullAmount = 0.000000
				END
			ELSE
				BEGIN
					SELECT @dblTaxFullAmount = @dblTaxFullAmount - ROUND(dblAmount * (dblPercentage / 100.000000), 2) FROM #tmpTax WHERE intTmpTaxId = @intTmpTaxId
					UPDATE #tmpTax SET dblAmount = ROUND(dblAmount * (dblPercentage / 100.000000), 2) WHERE intTmpTaxId = @intTmpTaxId
				END

			DELETE FROM #tmpTaxAmount WHERE intTmpTaxId = @intTmpTaxId
		END

		DELETE FROM #tmpTaxAmount WHERE intTypeTaxId = @intTypeTaxId
	END

	--PRINT 'Insert Taxes into tblCMBankTransactionDetail'
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
		,[dblCredit]				= SUM(T.dblAmount)
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM #tmpTax T
		LEFT JOIN tblPRPaycheckTax T2
		ON T.intPaycheckId = T2.intPaycheckId
		AND T.intTypeTaxId = T2.intTypeTaxId
	WHERE T.strPaidBy IN ('Company', 'Employee')
		AND T2.dblTotal > 0
		AND T.intPaycheckId = @intPaycheckId
	GROUP BY
		T.intAccountId
	UNION ALL
	SELECT
		[dtmDate]					= @dtmPayDate
		,[intGLAccountId]			= T.intExpenseAccountId
		,[strDescription]			= (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = T.intExpenseAccountId)
		,[dblDebit]					= SUM(T.dblAmount)
		,[dblCredit]				= 0
		,[intUndepositedFundId]		= NULL
		,[intEntityId]				= NULL
		,[intCreatedUserId]			= @intCreatedEntityId
		,[dtmCreated]				= GETDATE()
		,[intLastModifiedUserId]	= @intUserId
		,[dtmLastModified]			= GETDATE()
		,[intConcurrencyId]			= 1
	FROM #tmpTax T
		LEFT JOIN tblPRPaycheckTax T2
		ON T.intPaycheckId = T2.intPaycheckId
		AND T.intTypeTaxId = T2.intTypeTaxId
	WHERE T.strPaidBy = 'Company'
		AND T2.dblTotal > 0
		AND T.intPaycheckId = @intPaycheckId
	GROUP BY
		T.intExpenseAccountId
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
	,@ysnTransactionCommittedFlag AS BIT	
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
		,@ysnTransactionCommittedFlag = CASE WHEN (dtmCheckPrinted IS NOT NULL) THEN 1 ELSE 0 END
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

-- Check if the transaction is already committed and cannot be unposted
IF @ysnPost = 0 AND @ysnRecap = 0 AND @ysnTransactionCommittedFlag = 1
BEGIN 
	-- The transaction is already unposted.
	RAISERROR('The transaction is already committed.', 11, 1)
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
DECLARE @ysnBatchRecap AS BIT = 0
SELECT @ysnBatchRecap = CASE WHEN (@strBatchNo IS NOT NULL) THEN 1 ELSE 0 END

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
	UPDATE tblGLDetail 
	SET ysnIsUnposted = 1
	WHERE strBatchId = @batchIdUsed
		AND strTransactionId = @strTransactionId
		AND strCode = @GL_DETAIL_CODE

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
	EXEC dbo.uspGLPostRecap @RecapTable, NULL, @ysnBatchRecap
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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarningAmount')) DROP TABLE #tmpEarningAmount
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarningValidateAccounts')) DROP TABLE #tmpEarningValidateAccounts
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarningDepartmentPercentage')) DROP TABLE #tmpEarningDepartmentPercentage

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDeduction')) DROP TABLE #tmpDeduction
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDeductionAmount')) DROP TABLE #tmpDeductionAmount
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDeductionValidateAccounts')) DROP TABLE #tmpDeductionValidateAccounts

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTax')) DROP TABLE #tmpTax
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTaxAmount')) DROP TABLE #tmpTaxAmount
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTaxValidateAccounts')) DROP TABLE #tmpTaxValidateAccounts


/****************************************
	AFTER POSTING PROCEDURES
*****************************************/
IF (@isSuccessful <> 0)
BEGIN
	/* Update the Employee Time Off Tiers and trigger Hours Reset */
	SELECT DISTINCT intTypeTimeOffId INTO #tmpEmployeeTimeOffTiers FROM tblPREmployeeTimeOff WHERE intEntityEmployeeId = @intEmployeeId
		
	DECLARE @intTypeTimeOffId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeTimeOffTiers)
	BEGIN
		SELECT TOP 1 @intTypeTimeOffId = intTypeTimeOffId FROM #tmpEmployeeTimeOffTiers

		EXEC uspPRUpdateEmployeeTimeOff @intTypeTimeOffId, @intEmployeeId

		DELETE FROM #tmpEmployeeTimeOffTiers WHERE intTypeTimeOffId = @intTypeTimeOffId
	END

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

			/* Delete Any Direct Deposit Entry */
			IF (@intBankTransactionTypeId = @DIRECT_DEPOSIT)
				DELETE FROM tblPRPaycheckDirectDeposit WHERE intPaycheckId = @intPaycheckId

			SET @isSuccessful = 1
		END
	END

	/* Update the Employee Accrued or Earned Hours */
	SELECT DISTINCT intTypeTimeOffId INTO #tmpEmployeeTimeOffHours FROM tblPREmployeeTimeOff WHERE intEntityEmployeeId = @intEmployeeId
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeTimeOffHours)
	BEGIN
		SELECT TOP 1 @intTypeTimeOffId = intTypeTimeOffId FROM #tmpEmployeeTimeOffHours

		EXEC uspPRUpdateEmployeeTimeOffHours @intTypeTimeOffId, @intEmployeeId, @intPaycheckId

		DELETE FROM #tmpEmployeeTimeOffHours WHERE intTypeTimeOffId = @intTypeTimeOffId
	END

	EXEC uspPRInsertPaycheckTimeOff @intPaycheckId
END
END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeTimeOffTiers')) DROP TABLE #tmpEmployeeTimeOffTiers
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeTimeOffHours')) DROP TABLE #tmpEmployeeTimeOffHours