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
	CREATE TABLE #tmpTableForAudit(
		[Id] Int,
		[Namespace] VARCHAR(max),
		[Action] VARCHAR(30),
		[Description] VARCHAR(100),	
		[From] VARCHAR(100),
		[To] VARCHAR(100),
		[EntityId] Int
	)
	-- temporary Table for inserted tax type
	CREATE TABLE #tmpInsertedTaxDeduction(
		intEmployeeDeductionId int
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
			deleted.intExpenseAccountId, inserted.intExpenseAccountId
		INTO
			@EmployeeDeductionAudit
		FROM tblPRTypeDeduction Deduction 
			INNER JOIN tblPREmployeeDeduction EmpDeduction
				ON Deduction.intTypeDeductionId = EmpDeduction.intTypeDeductionId
		WHERE EmpDeduction.intTypeDeductionId = @intTypeDeductionId

		if(@ysnUpdateCalcType = 1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			Select intEntityEmployeeId,'EntityManagement.view.Entity', 'Updated','Rate Type(Updated in Update Employees)',strCalculationTypeOld,strCalculationTypeNew,@intUserId
			FROM @EmployeeDeductionAudit 
		END
		if(@ysnUpdateAmount = 1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			Select intEntityEmployeeId,'EntityManagement.view.Entity', 'Updated','Rate(Updated in Update Employees)',CAST(CAST(dblAmountOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblAmountNew AS FLOAT) AS NVARCHAR(20)),@intUserId
			FROM @EmployeeDeductionAudit
		END
		if(@ysnUpdateLimit = 1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			Select intEntityEmployeeId,'EntityManagement.view.Entity', 'Updated','Annual Limit(Updated in Update Employees)',CAST(CAST(dblLimitOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblLimitNew AS FLOAT) AS NVARCHAR(20)),@intUserId
			FROM @EmployeeDeductionAudit
		END
		IF(@ysnUpdateDeductFrom =1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			Select intEntityEmployeeId,'EntityManagement.view.Entity', 'Updated','Deduct from(Updated in Update Employees)',
				CAST(CAST(dblPaycheckMaxOld AS FLOAT) AS NVARCHAR(20)) + '% of ' + strDeductFromOld,
				CAST(CAST(dblPaycheckMaxNew AS FLOAT) AS NVARCHAR(20)) + '% of ' + strDeductFromNew,
				@intUserId
			FROM @EmployeeDeductionAudit
		END
		
		IF(@ysnUpdateAccount = 1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			Select intEntityEmployeeId,'EntityManagement.view.Entity', 'Updated','Account ID(Updated in Update Employees)',
				(SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdOld),
				(SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdNew)
				,@intUserId
				FROM @EmployeeDeductionAudit
		END

		IF(@ysnUpdateExpense = 1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			Select intEntityEmployeeId,'EntityManagement.view.Entity', 'Updated','Expense Account(Updated in Update Employees)',
				ISNULL((SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdOld), ''),
				ISNULL((SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdNew), '') 
				,@intUserId
				FROM @EmployeeDeductionAudit
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
		
		--Insert Deleted Employee Earning in temp Audit log table 
		if(@ysnUpdateTaxes=1)
		BEGIN
			INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
				SELECT ED.intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Deleted Deduction Taxes in Update Employees',TT.strDescription,NULL,@intUserId
				from tblPREmployeeDeduction ED
				inner join tblPREmployeeDeductionTax DT ON DT.intEmployeeDeductionId=ED.intEmployeeDeductionId
				inner join tblPRTypeTax TT ON TT.intTypeTaxId = DT.intTypeTaxId
				WHERE intTypeDeductionId = @intTypeDeductionId
		END

		DELETE FROM tblPREmployeeDeductionTax 
				WHERE intEmployeeDeductionId IN (SELECT intEmployeeDeductionId FROM #tmpEmployeeDeduction)

		DECLARE @intEmployeeDeductionId INT
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeDeduction)
		BEGIN
			SELECT TOP 1 @intEmployeeDeductionId = intEmployeeDeductionId FROM #tmpEmployeeDeduction

			--Reinsert Deduction Taxes
			INSERT INTO tblPREmployeeDeductionTax (intEmployeeDeductionId, intTypeTaxId, intSort, intConcurrencyId)
			OUTPUT inserted.intEmployeeDeductionId INTO #tmpInsertedTaxDeduction
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
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
			SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Inserted Deduction Taxes in Update Employees',NULL,TT.strDescription,@intUserId
			from tblPREmployeeDeduction ED
				inner join tblPREmployeeDeductionTax DT ON DT.intEmployeeDeductionId=ED.intEmployeeDeductionId
				inner join tblPRTypeTax TT ON TT.intTypeTaxId = DT.intTypeTaxId
				WHERE intTypeDeductionId = @intTypeDeductionId
			AND ED.intEmployeeDeductionId IN (SELECT Distinct(intEmployeeDeductionId) FROM #tmpInsertedTaxDeduction)
		


		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeDeduction')) DROP TABLE #tmpEmployeeDeduction
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTemplateDeduction')) DROP TABLE #tmpTemplateDeduction 
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInsertedTaxDeduction')) DROP TABLE #tmpInsertedTaxDeduction
		
	END
	------------CREATE AUDIT ENTRY
		DECLARE @cur_Id INT;
		DECLARE @cur_Namespace VARCHAR(max);
		DECLARE @cur_Action VARCHAR(30);
		DECLARE @cur_Description VARCHAR(100);
		DECLARE @cur_From VARCHAR(100);
		DECLARE @cur_To VARCHAR(100);
		DECLARE @cur_EntityId Int;

		DECLARE AuditTableCursor CURSOR FOR
		SELECT * FROM #tmpTableForAudit 

		OPEN AuditTableCursor

		FETCH NEXT FROM AuditTableCursor INTO @cur_Id,@cur_Namespace,@cur_Action,@cur_Description,@cur_From,@cur_To,@cur_EntityId
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
		--Insert individual Record to audit log
			EXEC uspSMAuditLog
				@keyValue = @cur_Id,
				@screenName = @cur_Namespace,
				@entityId = @cur_EntityId,
				@actionType = @cur_Action,
				@changeDescription  = @cur_Description,
				@fromValue = @cur_From,
				@toValue = @cur_To

			FETCH NEXT FROM AuditTableCursor INTO @cur_Id,@cur_Namespace,@cur_Action,@cur_Description,@cur_From,@cur_To,@cur_EntityId
		END
		CLOSE AuditTableCursor
		DEALLOCATE AuditTableCursor

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTableForAudit')) DROP TABLE #tmpTableForAudit
END
GO