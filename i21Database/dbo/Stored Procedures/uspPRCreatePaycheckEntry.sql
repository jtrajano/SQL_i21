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

--[insert validations here]--
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
	,CASE WHEN EXISTS (SELECT TOP 1 1 FROM tblEntityEFTInformation WHERE ysnActive = 1 AND intEntityId = tblPREmployee.[intEntityEmployeeId]) THEN 1 ELSE 0 END
	,@intUserId
	,GETDATE()
	,@intUserId
	,GETDATE()
	,1
FROM [dbo].[tblPREmployee]
WHERE [intEntityEmployeeId] = @intEmployee

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
DECLARE @intEmployeeEarningOriginalId INT
DECLARE @strCalculationType NVARCHAR(50)
DECLARE @intEmployeeEarningLinkId INT
DECLARE @intEmployeeTimeOffId INT
DECLARE @intEmployeeDepartmentId INT
DECLARE @intTypeEarningId INT
DECLARE @dblDefaultHours NUMERIC(18,6)
DECLARE @dblEarningAmount NUMERIC(18,6)
DECLARE @strW2Code NVARCHAR(50)
DECLARE @intAccountId INT
DECLARE @intSort INT

/* Insert Earnings and Department to Temp Table for iteration */
SELECT DISTINCT
E.intEmployeeEarningId
,E.strCalculationType
,E.dblAmount
,intEmployeeDepartmentId = ISNULL(T.intEmployeeDepartmentId, 0)
,E.intEmployeeEarningOriginalId
,E.intTypeEarningId
,dblDefaultHours = E.dblHoursToProcess
,E.strW2Code
,E.intEmployeeTimeOffId
,E.intEmployeeEarningLinkId
,E.intAccountId 
,E.intSort
INTO #tmpEarnings
FROM 
(SELECT 
intEmployeeEarningId = CASE WHEN (intEmployeeEarningLinkId IS NULL) 
								THEN intEmployeeEarningId 
							ELSE 
								ISNULL((SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning 
								 WHERE intTypeEarningId = E.intEmployeeEarningLinkId AND [intEntityEmployeeId] = @intEmployee), intEmployeeEarningId)
							END
,dblAmount = dblRateAmount
,strCalculationType
,intEmployeeEarningOriginalId = E.intEmployeeEarningId
,strW2Code
,intTypeEarningId
,intEmployeeEarningLinkId
,intEmployeeTimeOffId
,dblDefaultHours
,dblHoursToProcess
,intAccountId
,intSort
FROM tblPREmployeeEarning E
WHERE [intEntityEmployeeId] = @intEmployee
	AND (E.ysnDefault = 1 OR E.dblHoursToProcess > 0)
	AND intPayGroupId IN (SELECT intPayGroupId FROM #tmpPayGroups)
) E
LEFT JOIN 
(SELECT intEmployeeEarningId, intEmployeeDepartmentId 
 FROM tblPRTimecard
 WHERE ysnApproved = 1 AND intPaycheckId IS NULL
	AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)
	AND CAST(FLOOR(CAST(dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDateIn) AS FLOAT)) AS DATETIME)
	AND CAST(FLOOR(CAST(dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDateOut) AS FLOAT)) AS DATETIME)
	AND @ysnUseStandard = 0
) T ON E.intEmployeeEarningId = T.intEmployeeEarningId
	
/* Add Each Earning to Paycheck */
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEarnings)
	BEGIN

		/* Select Employee Earning to Add */
		SELECT TOP 1 @intEmployeeEarningId		= intEmployeeEarningId
				, @intEmployeeDepartmentId		= intEmployeeDepartmentId
				, @dblEarningAmount				= dblAmount 
				, @intEmployeeEarningOriginalId = intEmployeeEarningOriginalId
				, @strCalculationType			= strCalculationType
				, @intTypeEarningId				= intTypeEarningId
				, @intEmployeeEarningLinkId		= intEmployeeEarningLinkId
				, @intEmployeeTimeOffId			= intEmployeeTimeOffId 
				, @dblDefaultHours				= dblDefaultHours 
				, @strW2Code					= strW2Code 
				, @intAccountId					= intAccountId 
				, @intSort						= intSort 
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
			,[intEmployeeTimeOffId]
			,[intEmployeeEarningLinkId]
			,[intAccountId]
			,[intSort]
			,[intConcurrencyId])
		SELECT
			@intPaycheckId
			,@intEmployeeEarningOriginalId
			,@intTypeEarningId
			,@strCalculationType
			,CASE 
				--If Earning Id is HOLIDAY, use the specified Pay Group Holiday Hours
				WHEN (((SELECT TOP 1 LOWER(strEarning) FROM tblPRTypeEarning WHERE intTypeEarningId = @intTypeEarningId) LIKE '%holiday%')
				AND ISNULL((SELECT TOP 1 dblHolidayHours FROM tblPRPayGroup P LEFT JOIN tblPREmployeeEarning E ON P.intPayGroupId = E.intPayGroupId WHERE E.intTypeEarningId = @intTypeEarningId), 0) > 0)
					THEN ISNULL((SELECT TOP 1 dblHolidayHours FROM tblPRPayGroup P LEFT JOIN tblPREmployeeEarning E ON P.intPayGroupId = E.intPayGroupId WHERE E.intTypeEarningId = @intTypeEarningId), 0)
			    --If Use Standard Hours, get hours based on Default in Employee Setup
				WHEN (@ysnUseStandard = 1) 
					THEN @dblDefaultHours 
				--If not Use Standard Hours, get total approved hours from Timecard within the date range
				ELSE 
					ISNULL((SELECT dblTotalHours = CASE WHEN (@strCalculationType IN ('Overtime')) 
												 THEN SUM(dblOvertimeHours) 
												 ELSE SUM(dblRegularHours) 
											END
						FROM tblPRTimecard 
						WHERE intEmployeeEarningId = @intEmployeeEarningId
						AND ysnApproved = 1 AND intPaycheckId IS NULL
						AND [intEntityEmployeeId] = @intEmployee AND intEmployeeDepartmentId = @intEmployeeDepartmentId
						AND CAST(FLOOR(CAST(dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDateIn) AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDateOut) AS FLOAT)) AS DATETIME)	
					), 0)
				END
			,@dblEarningAmount
			,CASE WHEN (@strCalculationType IN ('Hourly Rate', 'Overtime')
					OR (@strCalculationType = 'Rate Factor' AND (SELECT TOP 1 strCalculationType FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @intEmployeeEarningId) = 'Hourly Rate')) THEN 
				-- If Calculation is Hourly Based
				CASE 
					--If Earning Id is HOLIDAY, use the specified Pay Group Holiday Hours
					WHEN (((SELECT TOP 1 LOWER(strEarning) FROM tblPRTypeEarning WHERE intTypeEarningId = @intTypeEarningId) LIKE '%holiday%')
					AND ISNULL((SELECT TOP 1 dblHolidayHours FROM tblPRPayGroup P LEFT JOIN tblPREmployeeEarning E ON P.intPayGroupId = E.intPayGroupId WHERE E.intTypeEarningId = @intTypeEarningId), 0) > 0)
						THEN ISNULL((SELECT TOP 1 dblHolidayHours FROM tblPRPayGroup P LEFT JOIN tblPREmployeeEarning E ON P.intPayGroupId = E.intPayGroupId WHERE E.intTypeEarningId = @intTypeEarningId), 0)
					--If Use Standard Hours, get hours based on Default in Employee Setup
					WHEN (@ysnUseStandard = 1) 
						THEN @dblDefaultHours 
					--If not Use Standard Hours, get total approved hours from Timecard within the date range
					ELSE 
						ISNULL((SELECT dblTotalHours = CASE WHEN (@strCalculationType IN ('Overtime')) 
													 THEN SUM(dblOvertimeHours) 
													 ELSE SUM(dblRegularHours) 
												END
							FROM tblPRTimecard 
							WHERE intEmployeeEarningId = @intEmployeeEarningId
							AND ysnApproved = 1 AND intPaycheckId IS NULL
							AND [intEntityEmployeeId] = @intEmployee AND intEmployeeDepartmentId = @intEmployeeDepartmentId
							AND CAST(FLOOR(CAST(dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDateIn) AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDateOut) AS FLOAT)) AS DATETIME)	
						), 0)
					END 
				  * @dblEarningAmount
			 ELSE 
				 -- If Calculation is Fixed Amount
				 @dblEarningAmount
			 END
			,@strW2Code
			,CASE WHEN (@intEmployeeDepartmentId = 0) THEN NULL ELSE @intEmployeeDepartmentId END
			,@intEmployeeTimeOffId
			,@intEmployeeEarningLinkId
			,@intAccountId
			,@intSort
			,1
		FROM tblPREmployeeEarning
		WHERE [intEntityEmployeeId] = @intEmployee
		  AND intEmployeeEarningId = @intEmployeeEarningId

		/* Get the Created Paycheck Earning Id*/
		SELECT @intPaycheckEarningId = @@IDENTITY

		IF EXISTS(SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @intEmployeeEarningId AND (ysnDefault = 1 OR dblHoursToProcess > 0))
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
			END

		DELETE FROM #tmpEarnings 
		WHERE intEmployeeEarningId = @intEmployeeEarningId 
		AND intEmployeeDepartmentId = @intEmployeeDepartmentId
		AND intEmployeeEarningOriginalId = @intEmployeeEarningOriginalId
	END

/* Create Paycheck Deductions and Taxes*/
DECLARE @intPaycheckDeductionId INT
DECLARE @intEmployeeDeductionId INT

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
		SELECT @intPaycheckDeductionId = @@IDENTITY

		IF EXISTS(SELECT TOP 1 1 FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = @intEmployeeDeductionId AND ysnDefault = 1)
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
			END

		DELETE FROM #tmpDeductions WHERE intEmployeeDeductionId = @intEmployeeDeductionId
	END

	IF (@ysnUseStandardHours = 0)
		BEGIN
			/* Associate Timecards to created Paycheck */
			UPDATE tblPRTimecard 
			SET intPaycheckId = @intPaycheckId
			WHERE ysnApproved = 1 AND intPaycheckId IS NULL
			AND [intEntityEmployeeId] = @intEmployee AND intEmployeeDepartmentId IN (SELECT intDepartmentId FROM #tmpDepartments)
			AND CAST(FLOOR(CAST(dtmDateIn AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(ISNULL(@dtmBegin,dtmDateIn) AS FLOAT)) AS DATETIME)
			AND CAST(FLOOR(CAST(dtmDateOut AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmEnd,dtmDateOut) AS FLOAT)) AS DATETIME)	
		END
	ELSE
		BEGIN
			/* Reset Hours to Process to Default */
			UPDATE tblPREmployeeEarning SET dblHoursToProcess = dblDefaultHours WHERE intEntityEmployeeId = @intEmployee 
		END

	/* Reset Rate Amount to Default */
	UPDATE tblPREmployeeEarning 
	SET dblRateAmount = CASE WHEN (strCalculationType IN ('Rate Factor', 'Overtime')) THEN 
						dblAmount * ISNULL((SELECT dblAmount FROM tblPREmployeeEarning X 
											WHERE X.intTypeEarningId = tblPREmployeeEarning.intEmployeeEarningLinkId 
											  AND X.intEntityEmployeeId = tblPREmployeeEarning.intEntityEmployeeId), 0)
						ELSE
							dblAmount
						END
	WHERE intEntityEmployeeId = @intEmployee AND (intPayGroupId IS NULL OR intPayGroupId IN (SELECT intPayGroupId FROM #tmpPayGroups))

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDepartments')) DROP TABLE #tmpDepartments
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayGroups')) DROP TABLE #tmpPayGroups
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarnings')) DROP TABLE #tmpEarnings
END
GO