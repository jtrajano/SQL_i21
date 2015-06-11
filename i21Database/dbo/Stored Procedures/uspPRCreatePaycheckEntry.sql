﻿CREATE PROCEDURE [dbo].[uspPRCreatePaycheckEntry]
	@intEmployeeId	INT
	,@dtmBeginDate	DATETIME
	,@dtmEndDate	DATETIME
	,@dtmPayDate	DATETIME
	,@intPaycheckId	INT = NULL OUTPUT
AS
BEGIN

--[insert validations here]--
DECLARE @intEmployee INT
	   ,@dtmBegin DATETIME
	   ,@dtmEnd DATETIME
	   ,@dtmPay DATETIME

/* Localize Parameters for Optimal Performance */
SELECT @intEmployee	= @intEmployeeId
	  ,@dtmBegin	= @dtmBeginDate
	  ,@dtmEnd		= @dtmEndDate
	  ,@dtmPay		= @dtmPayDate

/* Get Paycheck Starting Number */
DECLARE @strPaycheckId NVARCHAR(50)
EXEC uspSMGetStartingNumber 32, @strPaycheckId OUT

/* Create Paycheck Header */
INSERT INTO [dbo].[tblPRPaycheck]
	([strPaycheckId]
	,[intEmployeeId]
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
	,[dtmCreated]
	,[intConcurrencyId])
SELECT
	@strPaycheckId
	,@intEmployee
	,@dtmPay
	,tblPREmployee.strPayPeriod
	,@dtmBegin
	,@dtmEnd
	,(SELECT intBankAccountId FROM tblPRPayGroup WHERE intPayGroupId = tblPREmployee.intPayGroupId)
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
	,[ysnDirectDeposit]
	,GETDATE()
	,1
FROM [dbo].[tblPREmployee]
WHERE [intEmployeeId] = @intEmployee

/* Get the Created Paycheck Id*/
SELECT @intPaycheckId = @@IDENTITY

/* Create Paycheck Taxes */
INSERT INTO [dbo].[tblPRPaycheckTax]
	([intPaycheckId]
	,[intEmployeeTaxId]
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
	,[intEmployeeTaxId]
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
WHERE [intEmployeeId] = @intEmployee
  AND [ysnDefault] = 1

/* Create Paycheck Earnings and Taxes*/
DECLARE @intPaycheckEarningId INT
DECLARE @intEmployeeEarningId INT

/* Insert Earnings to Temp Table for iteration */
SELECT tblPREmployeeEarning.intEmployeeEarningId 
INTO #tmpEarnings FROM tblPREmployeeEarning 
WHERE intEmployeeId = @intEmployee 

/* Add Each Earning to Paycheck */
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEarnings)
	BEGIN

		/* Select Employee Earning to Add */
		SELECT TOP 1 @intEmployeeEarningId = intEmployeeEarningId FROM #tmpEarnings
	
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
			,[intEmployeeTimeOffId]
			,[intAccountId]
			,[intSort]
			,[intConcurrencyId])
		SELECT
			@intPaycheckId
			,@intEmployeeEarningId
			,[intTypeEarningId]
			,[strCalculationType]
			,[dblDefaultHours]
			,[dblAmount]
			,CASE WHEN ([strCalculationType] = 'Hourly Rate') THEN [dblDefaultHours] * [dblAmount] ELSE [dblAmount] END
			,[strW2Code]
			,[intEmployeeTimeOffId]
			,[intAccountId]
			,[intSort]
			,1
		FROM tblPREmployeeEarning
		WHERE intEmployeeId = @intEmployee
		  AND intEmployeeEarningId = @intEmployeeEarningId
		  AND ysnDefault = 1

		/* Get the Created Paycheck Earning Id*/
		SELECT @intPaycheckEarningId = @@IDENTITY

		IF EXISTS(SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE intEmployeeEarningId = @intEmployeeEarningId AND ysnDefault = 1)
			BEGIN
				/* Insert Paycheck Earning Taxes */
				INSERT INTO tblPRPaycheckEarningTax
					(intPaycheckEarningId
					,intTypeTaxId
					,intEmployeeTaxId
					,intConcurrencyId)
				SELECT 
					@intPaycheckEarningId
					,intTypeTaxId
					,intEmployeeTaxId
					,1
				FROM tblPREmployeeEarningTax
				WHERE intEmployeeEarningId = @intEmployeeEarningId
			END

		DELETE FROM #tmpEarnings WHERE intEmployeeEarningId = @intEmployeeEarningId
	END

/* Create Paycheck Deductions and Taxes*/
DECLARE @intPaycheckDeductionId INT
DECLARE @intEmployeeDeductionId INT

/* Insert Deductions to Temp Table for iteration */
SELECT tblPREmployeeDeduction.intEmployeeDeductionId 
INTO #tmpDeductions FROM tblPREmployeeDeduction 
WHERE intEmployeeId = @intEmployee 

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
			,[strPaidBy]
			,[intSort]
			,1
		FROM tblPREmployeeDeduction
		WHERE intEmployeeId = @intEmployee
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
					,intEmployeeTaxId
					,intConcurrencyId)
				SELECT 
					@intPaycheckDeductionId
					,intTypeTaxId
					,intEmployeeTaxId
					,1
				FROM tblPREmployeeDeductionTax
				WHERE intEmployeeDeductionId = @intEmployeeDeductionId
			END

		DELETE FROM #tmpDeductions WHERE intEmployeeDeductionId = @intEmployeeDeductionId
	END

END
GO