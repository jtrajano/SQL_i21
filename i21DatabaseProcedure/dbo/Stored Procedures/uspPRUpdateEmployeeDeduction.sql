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

	--Create Audit Log Entry for the changes
	WHILE EXISTS (SELECT TOP 1 1 FROM @EmployeeDeductionAudit)
	BEGIN
		SELECT TOP 1 
			@employeeDeductionIdLog = intEmployeeDeductionId,
			@entityEmployeeIdLog = intEntityEmployeeId,
			@details = '{"change": "Deductions (via Update Employees)","children": [' + 
							'{"action": "Updated","change": "Updated - Record: ' + 
							(SELECT TOP 1 strDeduction COLLATE Latin1_General_CI_AS FROM tblPRTypeDeduction WHERE intTypeDeductionId = @intTypeDeductionId) + 
							'","iconCls": "small-tree-modified","children": [' +
					CASE WHEN (@ysnUpdateAmount = 1 AND dblAmountOld <> dblAmountNew) THEN 
						'{"change":"Rate","from": "' + CAST(CAST(dblAmountOld AS FLOAT) AS NVARCHAR(20)) + 
										'","to": "' + CAST(CAST(dblAmountNew AS FLOAT) AS NVARCHAR(20)) + '","leaf": true,"iconCls": "small-gear"},' ELSE '' END +
					CASE WHEN (@ysnUpdateCalcType = 1 AND strCalculationTypeOld <> strCalculationTypeNew) THEN 
						'{"change":"Rate Type","from": "' + strCalculationTypeOld + 
											'","to": "' + strCalculationTypeNew + '","leaf": true,"iconCls": "small-gear"},' ELSE '' END +
					CASE WHEN (@ysnUpdateLimit = 1 AND dblLimitOld <> dblLimitNew) THEN 
						'{"change":"Annual Limit","from": "' + CAST(CAST(dblLimitOld AS FLOAT) AS NVARCHAR(20)) + 
												'","to": "' + CAST(CAST(dblLimitNew AS FLOAT) AS NVARCHAR(20)) + '","leaf": true,"iconCls": "small-gear"},' ELSE '' END +
					CASE WHEN (@ysnUpdateDeductFrom = 1 AND (dblPaycheckMaxOld <> dblPaycheckMaxNew OR strDeductFromOld <> strDeductFromNew)) THEN 
						'{"change":"Deduct From","from": "' + CAST(CAST(dblPaycheckMaxOld AS FLOAT) AS NVARCHAR(20)) + '% of ' + strDeductFromOld + 
												'","to": "' + CAST(CAST(dblPaycheckMaxNew AS FLOAT) AS NVARCHAR(20)) + '% of ' + strDeductFromNew +
												'","leaf": true,"iconCls": "small-gear"},' ELSE '' END +
					CASE WHEN (@ysnUpdateAccount = 1 AND intAccountIdOld <> intAccountIdNew) THEN 
						'{"change":"Account ID","from": "' + (SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdOld) + 
												'","to": "' + (SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdNew) + 
												' ","leaf": true,"iconCls": "small-gear"},' ELSE '' END +
					CASE WHEN (@ysnUpdateExpense = 1 AND (intExpenseAccountIdOld <> intExpenseAccountIdNew 
														OR (intExpenseAccountIdOld IS NOT NULL AND intExpenseAccountIdNew IS NULL)
														OR (intExpenseAccountIdOld IS NULL AND intExpenseAccountIdNew IS NOT NULL))) THEN 
						'{"change":"Expense Account","from": "' + ISNULL((SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdOld), '') + 
												'","to": "' + ISNULL((SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdNew), '') + 
												' ","leaf": true,"iconCls": "small-gear"},' ELSE '' END +
					CASE WHEN (@ysnUpdateTaxes = 1) THEN 
						'{"change":"Deduction Taxes","from": "","to":"Override All","leaf": true,"iconCls": "small-gear"}' ELSE '' END +
					']' +
				'}],"iconCls":"small-tree-grid"}'
			FROM @EmployeeDeductionAudit

		SET @details = REPLACE(@details, '"small-gear"},]', '"small-gear"}]')

		IF (@details NOT LIKE '%"children": []%')
			EXEC dbo.uspSMAuditLog
				@keyValue				= @entityEmployeeIdLog,				
				@screenName				= 'EntityManagement.view.Entity', 
				@entityId				= @intUserId,	
				@actionType				= 'Updated',
				@actionIcon				= 'small-tree-modified',
				@changeDescription		= '',
				@fromValue				= '',
				@toValue				= '',
				@details				= @details 

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