CREATE PROCEDURE [dbo].[uspPRCreatePaycheckEntry]
	@intEmployeeId			INT	
	,@dtmBeginDate			DATETIME
	,@dtmEndDate			DATETIME
	,@dtmPayDate			DATETIME
	,@strPayGroupIds		NVARCHAR(MAX) = ''
	,@strDepartmentIds		NVARCHAR(MAX) = ''
	,@ysnUseStandardHours	BIT = 1
	,@ysnExcludeDeductions  BIT = 0
	,@intUserId				INT = NULL
	,@intPaycheckId			INT = NULL OUTPUT
AS
BEGIN

DECLARE @intEmployee INT
	   ,@dtmBegin DATETIME
	   ,@dtmEnd DATETIME
	   ,@dtmPay DATETIME
	   ,@xmlPayGroups XML
	   ,@ysnUseStandard BIT
	   ,@xmlDepartments XML

/* Localize Parameters for Optimal Performance */
SELECT @intEmployee		= @intEmployeeId
	  ,@dtmBegin		= @dtmBeginDate
	  ,@dtmEnd			= @dtmEndDate
	  ,@dtmPay			= @dtmPayDate
	  ,@ysnUseStandard	= @ysnUseStandardHours
	  ,@xmlPayGroups	= CAST('<A>'+ REPLACE(@strPayGroupIds, ',', '</A><A>')+ '</A>' AS XML) 
	  ,@xmlDepartments  = CAST('<A>'+ REPLACE(@strDepartmentIds, ',', '</A><A>')+ '</A>' AS XML) 

--Parse the Departments Parameter to Temporary Table
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intDepartmentId
INTO #tmpDepartments
FROM @xmlDepartments.nodes('/A') AS X(T) 
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpDepartments) 
BEGIN
	INSERT INTO #tmpDepartments (intDepartmentId) SELECT intDepartmentId FROM tblPRDepartment
END

--Parse the Pay Groups Parameter to Temporary Table
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intPayGroupId
INTO #tmpPayGroups
FROM @xmlPayGroups.nodes('/A') AS X(T) 
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpPayGroups) 
BEGIN
	INSERT INTO #tmpPayGroups (intPayGroupId) SELECT intPayGroupId FROM tblPRPayGroup
END

/* Get Paycheck Starting Number */
DECLARE @strPaycheckId NVARCHAR(50)
EXEC uspSMGetStartingNumber 32, @strPaycheckId OUT

/* Create Paycheck Header */
INSERT INTO [dbo].[tblPRPaycheck]
	([strPaycheckId]
	,[intEntityEmployeeId]
	,[dtmPayDate]
	,[strPayPeriod]
	,[dtmDateFrom]
	,[dtmDateTo]
	,[intBankAccountId]
	,[strReferenceNo]
	,[dblTotalHours]
	,[dblGross]
	,[dblAdjustedGross]
	,[dblTaxTotal]
	,[dblDeductionTotal]
	,[dblNetPayTotal]
	,[dblCompanyTaxTotal]
	,[dtmPosted]
	,[ysnPosted]
	,[ysnPrinted]
	,[ysnVoid]
	,[ysnDirectDeposit]
	,[intCreatedUserId]
	,[dtmCreated]
	,[intLastModifiedUserId]
	,[dtmLastModified]
	,[intConcurrencyId])
SELECT
	@strPaycheckId
	,@intEmployee
	,@dtmPay
	,tblPREmployee.strPayPeriod
	,@dtmBegin
	,@dtmEnd
	,(SELECT TOP 1 intBankAccountId FROM tblPRPayGroup WHERE intPayGroupId IN (SELECT intPayGroupId FROM #tmpPayGroups))
	,''
	,0
	,0
	,0
	,0
	,0
	,0
	,0
	,NULL
	,0
	,0
	,0
	,CASE WHEN EXISTS (SELECT TOP 1 1 FROM [tblEMEntityEFTInformation] WHERE ysnActive = 1 AND intEntityId = tblPREmployee.[intEntityId]) THEN 1 ELSE 0 END
	,@intUserId
	,GETDATE()
	,@intUserId
	,GETDATE()
	,1
FROM [dbo].[tblPREmployee]
WHERE [intEntityId] = @intEmployee

/* Get the Created Paycheck Id*/
SELECT @intPaycheckId = @@IDENTITY

/* Create Paycheck Taxes */
INSERT INTO [dbo].[tblPRPaycheckTax]
	([intPaycheckId]
	,[intTypeTaxId]
	,[strCalculationType]
	,[strFilingStatus]
	,[intTypeTaxStateId]
	,[intTypeTaxLocalId]
	,[dblAmount]
	,[dblExtraWithholding]
	,[dblLimit]
	,[dblTotal]
	,[intAccountId]
	,[intExpenseAccountId]
	,[intAllowance]
	,[strPaidBy]
	,[strVal1]
	,[strVal2]
	,[strVal3]
	,[strVal4]
	,[strVal5]
	,[strVal6]
	,[ysnSet]
	,[intSort]
	,[intConcurrencyId])
SELECT
	@intPaycheckId
	,[intTypeTaxId]
	,[strCalculationType]
	,[strFilingStatus]
	,[intTypeTaxStateId]
	,[intTypeTaxLocalId]
	,[dblAmount]
	,[dblExtraWithholding]
	,[dblLimit]
	,0
	,[intAccountId]
	,[intExpenseAccountId]
	,[intAllowance]
	,[strPaidBy]
	,[strVal1]
	,[strVal2]
	,[strVal3]
	,[strVal4]
	,[strVal5]
	,[strVal6]
	,0
	,[intSort]
	,1
FROM [dbo].[tblPREmployeeTax]
WHERE [intEntityEmployeeId] = @intEmployee
  AND [ysnDefault] = 1

/* Create Paycheck Earnings and Taxes*/
DECLARE @intPaycheckEarningId INT
DECLARE @intEmployeeEarningId INT
DECLARE @intPayGroupDetailId INT
DECLARE @udtPRPaycheckEarningIn TABLE(intPaycheckEarningId INT)

/* Insert Earnings to Temp Table for iteration */
SELECT PGD.intPayGroupDetailId, PGD.intEmployeeEarningId
INTO #tmpEarnings 
FROM tblPRPayGroupDetail PGD
LEFT JOIN tblPRPayGroup PG ON PGD.intPayGroupId = PG.intPayGroupId
WHERE intEntityEmployeeId = @intEmployee
	AND PGD.intPayGroupId IN (SELECT intPayGroupId FROM #tmpPayGroups)
	AND ISNULL(PGD.dtmDateFrom, PG.dtmBeginDate) >= PG.dtmBeginDate AND ISNULL(PGD.dtmDateFrom, PG.dtmBeginDate) <= PG.dtmEndDate

/* Insert Pay Group Details for Deletion */
SELECT intPayGroupDetailId INTO #tmpPayGroupDetail FROM #tmpEarnings

/* Add Each Earning to Paycheck */
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEarnings)
	BEGIN

		/* Select Employee Earning to Add */
		SELECT TOP 1 @intPayGroupDetailId		= intPayGroupDetailId
					 ,@intEmployeeEarningId		= intEmployeeEarningId
				FROM #tmpEarnings

		/* Insert Paycheck Earning */
		INSERT INTO tblPRPaycheckEarning
			([intPaycheckId]
			,[intEmployeeEarningId]
			,[intTypeEarningId]
			,[strCalculationType]
			,[dblHours]
			,[dblAmount]
			,[dblTotal]
			,[strW2Code]
			,[intEmployeeDepartmentId]
			,[intWorkersCompensationId]
			,[intEmployeeTimeOffId]
			,[intEmployeeEarningLinkId]
			,[intAccountId]
			,[intTaxCalculationType]
			,[intSort]
			,[intConcurrencyId])
		OUTPUT
			Inserted.intPaycheckEarningId
		INTO 
			@udtPRPaycheckEarningIn 
		SELECT
			@intPaycheckId
			,P.intEmployeeEarningId
			,P.intTypeEarningId
			,P.strCalculationType
			,P.dblHoursToProcess
			,P.dblAmount
			,P.dblTotal
			,E.strW2Code
			,P.intDepartmentId
			,P.intWorkersCompensationId
			,E.intEmployeeTimeOffId
			,E.intEmployeeEarningLinkId
			,E.intAccountId
			,E.intTaxCalculationType
			,P.intSort
			,1
		FROM tblPRPayGroupDetail P INNER JOIN tblPREmployeeEarning E 
			ON P.intEmployeeEarningId = E.intEmployeeEarningId
		WHERE P.intEntityEmployeeId = @intEmployee
		  AND P.intPayGroupDetailId = @intPayGroupDetailId
		  AND P.intEmployeeEarningId = @intEmployeeEarningId
		  AND (P.dblTotal <> 0 OR E.ysnDefault = 1)

		/* Get the Created Paycheck Earning Id*/
		SELECT TOP 1 @intPaycheckEarningId = intPaycheckEarningId FROM @udtPRPaycheckEarningIn

		IF EXISTS(SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @intEmployeeEarningId AND @intPaycheckEarningId IS NOT NULL)
			BEGIN
				/* Insert Paycheck Earning Taxes */
				INSERT INTO tblPRPaycheckEarningTax
					(intPaycheckEarningId
					,intTypeTaxId
					,intConcurrencyId)
				SELECT 
					@intPaycheckEarningId
					,intTypeTaxId
					,1
				FROM tblPREmployeeEarningTax
				WHERE intEmployeeEarningId = @intEmployeeEarningId
				AND @intPaycheckEarningId NOT IN (SELECT intPaycheckEarningId 
													FROM tblPRPaycheckEarningTax 
													WHERE intTypeTaxId = tblPREmployeeEarningTax.intTypeTaxId)
			END

		DELETE FROM @udtPRPaycheckEarningIn

		/* Loop Control */
		DELETE FROM #tmpEarnings 
		WHERE intPayGroupDetailId = @intPayGroupDetailId
			AND intEmployeeEarningId = @intEmployeeEarningId 

	END

/* Create Paycheck Deductions and Taxes*/
DECLARE @intPaycheckDeductionId INT
DECLARE @intEmployeeDeductionId INT
DECLARE @udtPRPaycheckDeductionIn TABLE(intPaycheckDeductionId INT)

/* Insert Deductions to Temp Table for iteration */
SELECT tblPREmployeeDeduction.intEmployeeDeductionId 
INTO #tmpDeductions FROM tblPREmployeeDeduction 
WHERE [intEntityEmployeeId] = @intEmployee AND @ysnExcludeDeductions = 0

/* Add Each Deduction to Paycheck */
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDeductions)
	BEGIN

		/* Select Employee Deduction to Add */
		SELECT TOP 1 @intEmployeeDeductionId = intEmployeeDeductionId, @intPaycheckDeductionId = NULL FROM #tmpDeductions
	
		/* Insert Paycheck Deduction */
		INSERT INTO tblPRPaycheckDeduction
			([intPaycheckId]
			,[intEmployeeDeductionId]
			,[intTypeDeductionId]
			,[strDeductFrom]
			,[strCalculationType]
			,[dblAmount]
			,[dblLimit]
			,[dblTotal]
			,[dtmBeginDate]
			,[dtmEndDate]
			,[intAccountId]
			,[intExpenseAccountId]
			,[strPaidBy]
			,[intSort]
			,[intConcurrencyId])
		OUTPUT
			Inserted.intPaycheckDeductionId
		INTO
			@udtPRPaycheckDeductionIn
		SELECT
			@intPaycheckId
			,@intEmployeeDeductionId
			,[intTypeDeductionId]
			,[strDeductFrom]
			,[strCalculationType]
			,[dblAmount]
			,[dblLimit]
			,0
			,[dtmBeginDate]
			,[dtmEndDate]
			,[intAccountId]
			,[intExpenseAccountId]
			,[strPaidBy]
			,[intSort]
			,1
		FROM tblPREmployeeDeduction
		WHERE [intEntityEmployeeId] = @intEmployee
		  AND intEmployeeDeductionId = @intEmployeeDeductionId
		  AND ysnDefault = 1

		/* Get the Created Paycheck Deduction Id*/
		SELECT TOP 1 @intPaycheckDeductionId = intPaycheckDeductionId FROM @udtPRPaycheckDeductionIn

		IF EXISTS(SELECT TOP 1 1 FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @intEmployeeDeductionId AND ysnDefault = 1 AND @intPaycheckDeductionId IS NOT NULL)
			BEGIN
				/* Insert Paycheck Deduction Taxes */
				INSERT INTO tblPRPaycheckDeductionTax
					(intPaycheckDeductionId
					,intTypeTaxId
					,intConcurrencyId)
				SELECT 
					@intPaycheckDeductionId
					,intTypeTaxId
					,1
				FROM tblPREmployeeDeductionTax
				WHERE intEmployeeDeductionId = @intEmployeeDeductionId
				AND @intPaycheckDeductionId NOT IN (SELECT intPaycheckDeductionId 
													FROM tblPRPaycheckDeductionTax 
													WHERE intTypeTaxId = tblPREmployeeDeductionTax.intTypeTaxId)
			END

		DELETE FROM @udtPRPaycheckDeductionIn
		DELETE FROM #tmpDeductions WHERE intEmployeeDeductionId = @intEmployeeDeductionId
	END


	/* Associate Timecards to created Paycheck */
	UPDATE tblPRTimecard 
	SET intPaycheckId = @intPaycheckId
	WHERE ysnApproved = 1 AND intPaycheckId IS NULL
	AND intEntityEmployeeId = @intEmployee AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)
	AND intPayGroupDetailId IN (SELECT intPayGroupDetailId FROM #tmpPayGroupDetail)

	/* Delete Processed Pay Group Details */
	DELETE FROM tblPRPayGroupDetail WHERE intPayGroupDetailId IN (SELECT intPayGroupDetailId FROM #tmpPayGroupDetail)

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDepartments')) DROP TABLE #tmpDepartments
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayGroups')) DROP TABLE #tmpPayGroups
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayGroupDetail')) DROP TABLE #tmpPayGroupDetail
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarnings')) DROP TABLE #tmpEarnings
END
GO