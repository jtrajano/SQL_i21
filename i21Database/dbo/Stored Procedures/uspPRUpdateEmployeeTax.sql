CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTax]
	@intTypeTaxId INT
	,@ysnUpdateAmount BIT = 0
	,@ysnUpdateLimit BIT = 0
	,@ysnUpdateState BIT = 0
	,@ysnUpdateLocal BIT = 0
	,@ysnUpdateAccount BIT = 0
	,@ysnUpdateExpense BIT = 0
	,@ysnUpdateSupplemental BIT = 0
	,@intUserId INT
AS
BEGIN
	CREATE TABLE #tmpTableForAuditEmpTax(
		[Id] Int,
		intTypeTaxStateIdOld INT,
		intTypeTaxStateIdNew INT,
		intTypeTaxLocalIdOld INT,
		intTypeTaxLocalIdNew INT,
		dblAmountOld NUMERIC(18, 6),
		dblAmountNew NUMERIC(18, 6),
		dblLimitOld NUMERIC(18, 6),
		dblLimitNew NUMERIC(18, 6),
		intAccountIdOld Int,
		intAccountIdNew Int,
		intExpenseAccountIdOld Int,
		intExpenseAccountIdNew Int,
		intSupplementalCalcOld Int,
		intSupplementalCalcNew Int,
		
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

	UPDATE tblPREmployeeTax
	SET strCalculationType = Tax.strCalculationType
		,intTypeTaxStateId = CASE WHEN (@ysnUpdateState = 1) THEN Tax.intTypeTaxStateId ELSE EmpTax.intTypeTaxStateId END
		,intTypeTaxLocalId = CASE WHEN (@ysnUpdateLocal = 1) THEN Tax.intTypeTaxLocalId ELSE EmpTax.intTypeTaxLocalId END
		,dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Tax.dblAmount ELSE EmpTax.dblAmount END
		,dblLimit = CASE WHEN (@ysnUpdateLimit = 1) THEN Tax.dblLimit ELSE EmpTax.dblLimit END
		,intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Tax.intAccountId ELSE EmpTax.intAccountId END
		,intExpenseAccountId = CASE WHEN (@ysnUpdateExpense = 1) THEN Tax.intExpenseAccountId ELSE EmpTax.intExpenseAccountId END
		,intSupplementalCalc = CASE WHEN (@ysnUpdateSupplemental = 1) THEN Tax.intSupplementalCalc ELSE EmpTax.intSupplementalCalc END
		,strPaidBy = Tax.strPaidBy
		,intSort = Tax.intSort
	OUTPUT
		inserted.intEntityEmployeeId,
		deleted.intTypeTaxStateId, inserted.intTypeTaxStateId,
		deleted.intTypeTaxLocalId,inserted.intTypeTaxLocalId,
		deleted.dblAmount, inserted.dblAmount,
		deleted.dblLimit, inserted.dblLimit,
		deleted.intAccountId, inserted.intAccountId,
		deleted.intExpenseAccountId, inserted.intExpenseAccountId,
		deleted.intSupplementalCalc, inserted.intSupplementalCalc
	INTO #tmpTableForAuditEmpTax
	FROM tblPRTypeTax Tax INNER JOIN tblPREmployeeTax EmpTax
		ON Tax.intTypeTaxId = EmpTax.intTypeTaxId
	WHERE EmpTax.intTypeTaxId = @intTypeTaxId

	IF(@ysnUpdateAmount = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Amount(Updated in Update Employees)',CAST(CAST(dblAmountOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblAmountNew AS FLOAT) AS NVARCHAR(20)),@intUserId
		FROM #tmpTableForAuditEmpTax
	END

	IF(@ysnUpdateLimit = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Limit(Updated in Update Employees)',CAST(CAST(dblLimitOld AS FLOAT) AS NVARCHAR(20)),CAST(CAST(dblLimitNew AS FLOAT) AS NVARCHAR(20)),@intUserId
		FROM #tmpTableForAuditEmpTax
	END

	IF(@ysnUpdateState = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Tax State(Updated in Update Employees)',CAST(intTypeTaxStateIdOld as varchar(10)),CAST(intTypeTaxStateIdNew as varchar(10)),@intUserId
		FROM #tmpTableForAuditEmpTax
	END

	IF(@ysnUpdateLocal = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Tax Local(Updated in Update Employees)', CAST(intTypeTaxLocalIdOld as varchar(10)),CAST(intTypeTaxLocalIdNew as varchar(10)),@intUserId
		FROM #tmpTableForAuditEmpTax
	END

	IF(@ysnUpdateAccount = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Account(Updated in Update Employees)',
		(SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdOld),
		(SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intAccountIdNew),
		@intUserId
		FROM #tmpTableForAuditEmpTax
	END
	IF(@ysnUpdateExpense = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Expenses(Updated in Update Employees)',
		(SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdOld),
		(SELECT TOP 1 strAccountId COLLATE Latin1_General_CI_AS FROM tblGLAccount WHERE intAccountId = intExpenseAccountIdNew),
		@intUserId
		FROM #tmpTableForAuditEmpTax
	END
	
	IF(@ysnUpdateSupplemental = 1)
	BEGIN
		INSERT INTO #tmpTableForAudit([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		Select [Id],'EntityManagement.view.Entity', 'Updated','Supplemental(Updated in Update Employees)', CAST(intSupplementalCalcOld as varchar(10)),CAST(intSupplementalCalcNew as varchar(10)),@intUserId
		FROM #tmpTableForAuditEmpTax
	END


	UPDATE tblPRTemplateTax
	SET strCalculationType = Tax.strCalculationType
		,intTypeTaxStateId = CASE WHEN (@ysnUpdateState = 1) THEN Tax.intTypeTaxStateId ELSE EmpTax.intTypeTaxStateId END
		,intTypeTaxLocalId = CASE WHEN (@ysnUpdateLocal = 1) THEN Tax.intTypeTaxLocalId ELSE EmpTax.intTypeTaxLocalId END
		,dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Tax.dblAmount ELSE EmpTax.dblAmount END
		,dblLimit = CASE WHEN (@ysnUpdateLimit = 1) THEN Tax.dblLimit ELSE EmpTax.dblLimit END
		,intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Tax.intAccountId ELSE EmpTax.intAccountId END
		,intExpenseAccountId = CASE WHEN (@ysnUpdateExpense = 1) THEN Tax.intExpenseAccountId ELSE EmpTax.intExpenseAccountId END
		,intSupplementalCalc = CASE WHEN (@ysnUpdateSupplemental = 1) THEN Tax.intSupplementalCalc ELSE EmpTax.intSupplementalCalc END
		,strPaidBy = Tax.strPaidBy
		,intSort = Tax.intSort
	FROM tblPRTypeTax Tax INNER JOIN tblPRTemplateTax EmpTax
		ON Tax.intTypeTaxId = EmpTax.intTypeTaxId
	WHERE EmpTax.intTypeTaxId = @intTypeTaxId

	
	------------CREATE AUDIT ENTRY
		DECLARE @cur_Id INT;
		DECLARE @cur_Namespace VARCHAR(max);
		DECLARE @cur_Action VARCHAR(30);
		DECLARE @cur_Description VARCHAR(100);
		DECLARE @cur_From VARCHAR(100);
		DECLARE @cur_To VARCHAR(100);
		DECLARE @cur_EntityId Int;


		Select * from #tmpTableForAudit

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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTableForAuditEmpTax')) DROP TABLE #tmpTableForAuditEmpTax


END
GO