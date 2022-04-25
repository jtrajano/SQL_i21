CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeDeduction]
	@intTypeDeductionId INT
	,@ysnUpdateCalcType BIT
	,@ysnUpdateAmount BIT
	,@ysnUpdateLimit BIT
	,@ysnUpdateDeductFrom BIT
	,@ysnUpdateAccount BIT
	,@ysnUpdateExpense BIT
	,@ysnUpdateTaxes BIT
	,@intUserId INT = NULL
AS
BEGIN

	DECLARE @EmployeeDeductionAudit TABLE  
	(  
		intEmployeeDeductionId INT,
		intEntityEmployeeId INT,
		strCalculationTypeOld NVARCHAR(50),
		strCalculationTypeNew NVARCHAR(50),
		dblAmountOld NUMERIC(18, 6),
		dblAmountNew NUMERIC(18, 6),
		dblLimitOld NUMERIC(18, 6),
		dblLimitNew NUMERIC(18, 6),
		dblPaycheckMaxOld NUMERIC(18, 6),
		dblPaycheckMaxNew NUMERIC(18, 6),
		strDeductFromOld NVARCHAR(50),
		strDeductFromNew NVARCHAR(50),
		intAccountIdOld INT,
		intAccountIdNew INT,
		intExpenseAccountIdOld INT,
		intExpenseAccountIdNew INT
	)

	--Update Deduction 
	UPDATE tblPREmployeeDeduction
		SET strCalculationType = CASE WHEN (@ysnUpdateCalcType = 1) THEN Deduction.strCalculationType ELSE EmpDeduction.strCalculationType END,
			dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Deduction.dblAmount ELSE EmpDeduction.dblAmount END,
			dblLimit = CASE WHEN (@ysnUpdateLimit = 1) THEN Deduction.dblLimit ELSE EmpDeduction.dblLimit END,
			dblPaycheckMax = CASE WHEN (@ysnUpdateDeductFrom = 1) THEN Deduction.dblPaycheckMax ELSE EmpDeduction.dblPaycheckMax END,
			strDeductFrom = CASE WHEN (@ysnUpdateDeductFrom = 1) THEN Deduction.strDeductFrom ELSE EmpDeduction.strDeductFrom END,
			intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Deduction.intAccountId ELSE EmpDeduction.intAccountId END,
			intExpenseAccountId = CASE WHEN (@ysnUpdateExpense = 1) THEN Deduction.intExpenseAccountId ELSE EmpDeduction.intExpenseAccountId END,
			strPaidBy = Deduction.strPaidBy
		OUTPUT
			inserted.intEmployeeDeductionId, inserted.intEntityEmployeeId,
			deleted.strCalculationType, inserted.strCalculationType,
			deleted.dblAmount, inserted.dblAmount,
			deleted.dblLimit, inserted.dblLimit,
			deleted.dblPaycheckMax, inserted.dblPaycheckMax,
			deleted.strDeductFrom, inserted.strDeductFrom,
			deleted.intAccountId, inserted.intAccountId,
			deleted.intAccountId, inserted.intExpenseAccountId
		INTO
			@EmployeeDeductionAudit
		FROM tblPRTypeDeduction Deduction 
			INNER JOIN tblPREmployeeDeduction EmpDeduction
				ON Deduction.intTypeDeductionId = EmpDeduction.intTypeDeductionId
		WHERE EmpDeduction.intTypeDeductionId = @intTypeDeductionId

	DECLARE @details NVARCHAR(MAX)
	DECLARE @employeeDeductionIdLog INT
	DECLARE @entityEmployeeIdLog INT

	DECLARE @logAction NVARCHAR(100)
	DECLARE @logChange NVARCHAR(100)
	DECLARE @logIcon NVARCHAR(100)

	--log from
	DECLARE @logFromAmount NVARCHAR(100)
	DECLARE @logFromCalcType NVARCHAR(100)
	DECLARE @logFromLimit NVARCHAR(100)
	DECLARE @logFromDeductFrom NVARCHAR(100)
	DECLARE @logFromAccount NVARCHAR(100)
	DECLARE @logFromExpense NVARCHAR(100)
	--log to
	DECLARE @logToAmount NVARCHAR(100)
	DECLARE @logToCalcType NVARCHAR(100)
	DECLARE @logToLimit NVARCHAR(100)
	DECLARE @logToDeductFrom NVARCHAR(100)
	DECLARE @logToAccount NVARCHAR(100)
	DECLARE @logToExpense NVARCHAR(100)

	DECLARE @AuditSingle NVARCHAR(10)

	--fields
	DECLARE @logFieldAmount NVARCHAR(100)
	DECLARE @logFieldCalcType NVARCHAR(100)
	DECLARE @logFieldLimit NVARCHAR(100)
	DECLARE @logFieldDeductFrom NVARCHAR(100)
	DECLARE @logFieldAccount NVARCHAR(100)
	DECLARE @logFieldExpense NVARCHAR(100)

	--Create Audit Log Entry for the changes
	WHILE EXISTS (SELECT TOP 1 1 FROM @EmployeeDeductionAudit)
	BEGIN
		SELECT TOP 1 
			@employeeDeductionIdLog = intEmployeeDeductionId,
			@entityEmployeeIdLog = intEntityEmployeeId,
			@logAction = 'Updated',
			@logChange = 'Updated - Record: ' + (SELECT TOP 1 strDeduction COLLATE Latin1_General_CI_AS FROM tblPRTypeDeduction WHERE intTypeDeductionId = @intTypeDeductionId),
			
			@logFromAmount = CAST(CAST(dblAmountOld AS FLOAT) AS NVARCHAR(20)) ,
			@logFromCalcType  = strCalculationTypeOld,
			@logFromLimit  = CAST(CAST(dblLimitOld AS FLOAT) AS NVARCHAR(20)),
			@logFromDeductFrom  = CAST(CAST(dblPaycheckMaxOld AS FLOAT) AS NVARCHAR(20)) + '% of ' + strDeductFromOld,
			@logFromAccount  = (SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdOld),
			@logFromExpense  = ISNULL((SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdOld), ''),
			
			@logToAmount = CAST(CAST(dblAmountNew AS FLOAT) AS NVARCHAR(20)),
			@logToCalcType = strCalculationTypeNew,
			@logToLimit = CAST(CAST(dblLimitNew AS FLOAT) AS NVARCHAR(20)),
			@logToDeductFrom = CAST(CAST(dblPaycheckMaxNew AS FLOAT) AS NVARCHAR(20)) + '% of ' + strDeductFromNew,
			@logToAccount = (SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdNew),
			@logToExpense = ISNULL((SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdNew), ''),

			
			@logFieldAmount = 'Rate',
			@logFieldCalcType = 'Rate Type',
			@logFieldLimit = 'Annual Limit',
			@logFieldDeductFrom = 'Deduct From',
			@logFieldAccount = 'Account ID',
			@logFieldExpense = 'Expense Account'
			
			FROM @EmployeeDeductionAudit


		-- Start: New way of audit logging
		BEGIN TRY
			DECLARE @auditLogsParam SingleAuditLogParam
			INSERT INTO @auditLogsParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT 1, '', @logAction, @logChange, NULL, NULL, NULL, NULL, NULL, NULL
					UNION ALL
					SELECT 2, '', '', 'tblPREmployeeDeduction', NULL, NULL, NULL, NULL, NULL, 1
					UNION ALL
					SELECT 3, '', @logAction, @logChange, NULL, NULL, NULL, NULL, NULL, 2

					UNION ALL
					SELECT 4, '', '', @logFieldAmount, @logFromAmount, @logToAmount, NULL, NULL, NULL, 3
					WHERE @ysnUpdateAmount = 1

					UNION ALL
					SELECT 5, '', '', @logFieldCalcType, @logFromCalcType, @logToCalcType, NULL, NULL, NULL, 3
					WHERE @ysnUpdateCalcType = 1

					UNION ALL
					SELECT 6, '', '', @logFieldLimit, @logFromLimit, @logToLimit, NULL, NULL, NULL, 3
					WHERE @ysnUpdateLimit = 1

					UNION ALL
					SELECT 7, '', '', @logFieldDeductFrom, @logFromDeductFrom, @logToDeductFrom, NULL, NULL, NULL, 3
					WHERE  @ysnUpdateDeductFrom = 1

					UNION ALL
					SELECT 8, '', '', @logFieldAccount, @logFromAccount, @logToAccount, NULL, NULL, NULL, 3
					WHERE @ysnUpdateAccount = 1

					UNION ALL
					SELECT 9, '', '', @logFieldExpense, @logFromExpense, @logToExpense, NULL, NULL, NULL, 3
					WHERE @ysnUpdateExpense = 1

			EXEC uspSMSingleAuditLog 'EntityManagement.view.Entity', @entityEmployeeIdLog, @intUserId, @auditLogsParam
		END TRY
		BEGIN CATCH
		END CATCH
		-- End: New way of audit logging


		DELETE FROM @EmployeeDeductionAudit WHERE intEmployeeDeductionId = @employeeDeductionIdLog AND intEntityEmployeeId = @entityEmployeeIdLog
	END

	--Update Template Deduction
	UPDATE tblPRTemplateDeduction
		SET strCalculationType = CASE WHEN (@ysnUpdateCalcType = 1) THEN Deduction.strCalculationType ELSE EmpDeduction.strCalculationType END,
			dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Deduction.dblAmount ELSE EmpDeduction.dblAmount END,
			dblLimit = CASE WHEN (@ysnUpdateLimit = 1) THEN Deduction.dblLimit ELSE EmpDeduction.dblLimit END,
			dblPaycheckMax = CASE WHEN (@ysnUpdateDeductFrom = 1) THEN Deduction.dblPaycheckMax ELSE EmpDeduction.dblPaycheckMax END,
			strDeductFrom = CASE WHEN (@ysnUpdateDeductFrom = 1) THEN Deduction.strDeductFrom ELSE EmpDeduction.strDeductFrom END,
			intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Deduction.intAccountId ELSE EmpDeduction.intAccountId END,
			intExpenseAccountId = CASE WHEN (@ysnUpdateExpense = 1) THEN Deduction.intExpenseAccountId ELSE EmpDeduction.intExpenseAccountId END,
			strPaidBy = Deduction.strPaidBy
		FROM tblPRTypeDeduction Deduction 
			INNER JOIN tblPRTemplateDeduction EmpDeduction
				ON Deduction.intTypeDeductionId = EmpDeduction.intTypeDeductionId
		WHERE EmpDeduction.intTypeDeductionId = @intTypeDeductionId

	IF (@ysnUpdateTaxes = 1)
		BEGIN
		--Insert Employee Deductions to Temp Table
		SELECT intEmployeeDeductionId 
			INTO #tmpEmployeeDeduction
			FROM tblPREmployeeDeduction 
			WHERE intTypeDeductionId = @intTypeDeductionId

		DELETE FROM tblPREmployeeDeductionTax 
				WHERE intEmployeeDeductionId IN (SELECT intEmployeeDeductionId FROM #tmpEmployeeDeduction)

		DECLARE @intEmployeeDeductionId INT
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeDeduction)
		BEGIN
			SELECT TOP 1 @intEmployeeDeductionId = intEmployeeDeductionId FROM #tmpEmployeeDeduction

			--Reinsert Deduction Taxes
			INSERT INTO tblPREmployeeDeductionTax (intEmployeeDeductionId, intTypeTaxId, intSort, intConcurrencyId)
				SELECT @intEmployeeDeductionId, intTypeTaxId, intSort, intConcurrencyId 
				FROM tblPRTypeDeductionTax
				WHERE intTypeDeductionId = @intTypeDeductionId

			DELETE FROM #tmpEmployeeDeduction WHERE intEmployeeDeductionId = @intEmployeeDeductionId
		END

		--Insert Template Deductions to Temp Table
		SELECT intTemplateDeductionId 
			INTO #tmpTemplateDeduction
			FROM tblPRTemplateDeduction 
			WHERE intTypeDeductionId = @intTypeDeductionId

		--Delete Template Deduction Taxes
		DELETE FROM tblPRTemplateDeductionTax 
				WHERE intTemplateDeductionId IN (SELECT intTemplateDeductionId FROM #tmpTemplateDeduction)

		DECLARE @intTemplateDeductionId INT
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTemplateDeduction)
		BEGIN
			SELECT TOP 1 @intTemplateDeductionId = intTemplateDeductionId FROM #tmpTemplateDeduction

			--Reinsert Template Deduction Taxes
			INSERT INTO tblPRTemplateDeductionTax (intTemplateDeductionId, intTypeTaxId, intSort, intConcurrencyId)
				SELECT @intTemplateDeductionId, intTypeTaxId, intSort, intConcurrencyId
				FROM tblPRTypeDeductionTax
				WHERE intTypeDeductionId = @intTypeDeductionId

			DELETE FROM #tmpTemplateDeduction WHERE intTemplateDeductionId = @intTemplateDeductionId
		END

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeDeduction')) DROP TABLE #tmpEmployeeDeduction
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTemplateDeduction')) DROP TABLE #tmpTemplateDeduction
	END
END
GO