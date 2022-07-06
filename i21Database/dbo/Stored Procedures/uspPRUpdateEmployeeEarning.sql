CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeEarning]
	@intTypeEarningId INT
	,@intUserId INT
	,@ysnUpdateCalcType BIT = 0
	,@ysnUpdateAmount BIT = 0
	,@ysnUpdateHours BIT = 0
	,@ysnUpdateAccount BIT = 0
	,@ysnUpdateTaxCalc BIT = 0
	,@ysnUpdateTaxes BIT = 0
AS
BEGIN     --start

	CREATE TABLE #tmpTableEmpId(
		[Id] Int,
		[Namespace] VARCHAR(max),
		[Action] VARCHAR(30),
		[Description] VARCHAR(100),	
		[From] VARCHAR(100),
		[To] VARCHAR(100),
		[EntityId] Int
	)

	-- temporary Table for inserted tax type
	CREATE TABLE #tmpInsertedTaxEarning(
		intEmployeeEarningId int
	)
	

if (@ysnUpdateCalcType =1)
BEGIN
	UPDATE tblPREmployeeEarning
		SET strCalculationType = CASE WHEN (@ysnUpdateCalcType = 1) THEN Earning.strCalculationType ELSE EmpEarning.strCalculationType END,				
			intEmployeeEarningLinkId = CASE WHEN (@ysnUpdateCalcType = 1 AND Earning.strCalculationType NOT IN ('Rate Factor', 'Overtime')) THEN NULL 
										ELSE EmpEarning.intEmployeeEarningLinkId END,
			strW2Code = Earning.strW2Code
		OUTPUT deleted.intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Calculation Type(Updated in Update Employees)',deleted.strCalculationType,inserted.strCalculationType,@intUserId INTO #tmpTableEmpId
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPREmployeeEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intEntityEmployeeId, dblAmount, strCalculationType, dblDefaultHours FROM tblPREmployeeEarning) Link
				ON EmpEarning.intEmployeeEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intEntityEmployeeId = Link.intEntityEmployeeId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId
			
END

if (@ysnUpdateAmount = 1)
BEGIN
	UPDATE tblPREmployeeEarning
		SET dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Earning.dblAmount ELSE EmpEarning.dblAmount END,	
			strW2Code = Earning.strW2Code
		OUTPUT deleted.intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Rate Factor(Updated in Update Employees)',deleted.dblAmount,inserted.dblAmount,@intUserId INTO #tmpTableEmpId
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPREmployeeEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intEntityEmployeeId, dblAmount, strCalculationType, dblDefaultHours FROM tblPREmployeeEarning) Link
				ON EmpEarning.intEmployeeEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intEntityEmployeeId = Link.intEntityEmployeeId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId
END

if(@ysnUpdateHours =1)
BEGIN
	UPDATE tblPREmployeeEarning
		SET dblDefaultHours = CASE WHEN (@ysnUpdateHours = 1) THEN Earning.dblDefaultHours ELSE EmpEarning.dblDefaultHours END,	
			strW2Code = Earning.strW2Code
		OUTPUT deleted.intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Default Hours(Updated in Update Employees)',deleted.dblDefaultHours,inserted.dblDefaultHours,@intUserId INTO #tmpTableEmpId
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPREmployeeEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intEntityEmployeeId, dblAmount, strCalculationType, dblDefaultHours FROM tblPREmployeeEarning) Link
				ON EmpEarning.intEmployeeEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intEntityEmployeeId = Link.intEntityEmployeeId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId

END
if(@ysnUpdateAccount=1)
BEGIN
	--Staging table of edited account
	CREATE TABLE #tmpAccInfo(
		[tmpacc_Id] Int,
		[tmpacc_Namespace] VARCHAR(max),
		[tmpacc_Action] VARCHAR(30),
		[tmpacc_Description] VARCHAR(100),	
		[tmpacc_From] VARCHAR(100),
		[tmpacc_To] VARCHAR(100),
		[tmpacc_EntityId] Int
	)
	
	UPDATE tblPREmployeeEarning
		SET intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Earning.intAccountId ELSE EmpEarning.intAccountId END,
			dblRateAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN
									Earning.dblAmount * (CASE WHEN (CASE WHEN (@ysnUpdateCalcType = 1) 
																		THEN Earning.strCalculationType 
																		ELSE EmpEarning.strCalculationType END) IN ('Rate Factor', 'Overtime') 
															THEN
																CASE WHEN (Link.strCalculationType IN ('Fixed Amount', 'Salary') AND Link.dblDefaultHours <> 0)
																	THEN ROUND(ISNULL(Link.dblAmount, 0) / ISNULL(Link.dblDefaultHours, 1), 2)
																	ELSE ISNULL(Link.dblAmount, 0) END
														ELSE 1 END)
								 ELSE 
									EmpEarning.dblRateAmount
								 END,
			strW2Code = Earning.strW2Code
		OUTPUT deleted.intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Acount Id(Updated in Update Employees)',deleted.intAccountId,inserted.intAccountId,@intUserId INTO #tmpAccInfo
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPREmployeeEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intEntityEmployeeId, dblAmount, strCalculationType, dblDefaultHours FROM tblPREmployeeEarning) Link
				ON EmpEarning.intEmployeeEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intEntityEmployeeId = Link.intEntityEmployeeId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId


		--Insert Temporary to main staging table
		INSERT INTO #tmpTableEmpId([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
		SELECT tmpacc_Id,tmpacc_Namespace,[tmpacc_Action],[tmpacc_Description],
		(SELECT TOP 1 strAccountId from tblGLAccount where intAccountId= [tmpacc_From]),
		(SELECT TOP 1 strAccountId from tblGLAccount where intAccountId= [tmpacc_To]),
		[tmpacc_EntityId]
		from #tmpAccInfo

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAccInfo')) DROP TABLE #tmpAccInfo

END

if( @ysnUpdateTaxCalc =1)
BEGIN
	UPDATE tblPREmployeeEarning
		SET intTaxCalculationType = CASE WHEN (@ysnUpdateTaxCalc = 1) THEN Earning.intTaxCalculationType ELSE EmpEarning.intTaxCalculationType END,	
			strW2Code = Earning.strW2Code
		OUTPUT deleted.intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Tax Calculation(Updated in Update Employees)',deleted.intTaxCalculationType,inserted.intTaxCalculationType,@intUserId INTO #tmpTableEmpId
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPREmployeeEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intEntityEmployeeId, dblAmount, strCalculationType, dblDefaultHours FROM tblPREmployeeEarning) Link
				ON EmpEarning.intEmployeeEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intEntityEmployeeId = Link.intEntityEmployeeId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId
END


	--Update Template Earning
	UPDATE tblPRTemplateEarning
		SET strCalculationType = CASE WHEN (@ysnUpdateCalcType = 1) THEN Earning.strCalculationType ELSE EmpEarning.strCalculationType END,
			dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Earning.dblAmount ELSE EmpEarning.dblAmount END,
			dblDefaultHours = CASE WHEN (@ysnUpdateHours = 1) THEN Earning.dblDefaultHours ELSE EmpEarning.dblDefaultHours END,
			intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Earning.intAccountId ELSE EmpEarning.intAccountId END,
			intTaxCalculationType = CASE WHEN (@ysnUpdateTaxCalc = 1) THEN Earning.intTaxCalculationType ELSE EmpEarning.intTaxCalculationType END,
			intTemplateEarningLinkId = CASE WHEN (@ysnUpdateCalcType = 1 AND Earning.strCalculationType NOT IN ('Rate Factor', 'Overtime')) THEN NULL 
										ELSE EmpEarning.intTemplateEarningLinkId END,
			strW2Code = Earning.strW2Code
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPRTemplateEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intTemplateId, dblAmount FROM tblPRTemplateEarning) Link
				ON EmpEarning.intTemplateEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intTemplateId = Link.intTemplateId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId

	IF (@ysnUpdateTaxes = 1 OR @ysnUpdateAccount = 1)
		BEGIN
		--Insert Employee Earnings to Temp Table
		SELECT intEmployeeEarningId 
			INTO #tmpEmployeeEarning
			FROM tblPREmployeeEarning 
			WHERE intTypeEarningId = @intTypeEarningId

		--Insert Deleted Employee Earning in temp Audit log table 
		if(@ysnUpdateTaxes=1)
		BEGIN
			INSERT INTO #tmpTableEmpId([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
				SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Deleted Earning Taxes in Update Employees',TT.strDescription,NULL,@intUserId
				from tblPREmployeeEarning EE
				inner join tblPREmployeeEarningTax EET ON EET.intEmployeeEarningId=EE.intEmployeeEarningId
				inner join tblPRTypeTax TT ON TT.intTypeTaxId = EET.intTypeTaxId
				WHERE intTypeEarningId = @intTypeEarningId
		END

		--Delete Earning Taxes
		IF (@ysnUpdateTaxes = 1)
		DELETE FROM tblPREmployeeEarningTax 
				WHERE intEmployeeEarningId IN (SELECT intEmployeeEarningId FROM #tmpEmployeeEarning)

		--Delete Earning Distribution
		IF (@ysnUpdateAccount = 1)
		DELETE FROM tblPREmployeeEarningDistribution 
				WHERE intEmployeeEarningId IN (SELECT intEmployeeEarningId FROM #tmpEmployeeEarning)

		DECLARE @intEmployeeEarningId INT
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeEarning)
		BEGIN
			SELECT TOP 1 @intEmployeeEarningId = intEmployeeEarningId FROM #tmpEmployeeEarning

			--Reinsert Earning Taxes
			IF (@ysnUpdateTaxes = 1)
			INSERT INTO tblPREmployeeEarningTax (intEmployeeEarningId, intTypeTaxId, intSort, intConcurrencyId)
			OUTPUT inserted.intEmployeeEarningId INTO #tmpInsertedTaxEarning  --Added
				SELECT @intEmployeeEarningId, intTypeTaxId, intSort, intConcurrencyId 
				FROM tblPRTypeEarningTax
				WHERE intTypeEarningId = @intTypeEarningId

			--Reinsert Earning Distribution
			IF (@ysnUpdateAccount = 1)
			INSERT INTO tblPREmployeeEarningDistribution (intEmployeeEarningId, intAccountId, dblPercentage, intConcurrencyId)
				SELECT @intEmployeeEarningId, intAccountId, 100, 1 
				FROM tblPRTypeEarning
				WHERE intTypeEarningId = @intTypeEarningId

			DELETE FROM #tmpEmployeeEarning WHERE intEmployeeEarningId = @intEmployeeEarningId
		END

		--Insert Template Earnings to Temp Table
		SELECT intTemplateEarningId 
			INTO #tmpTemplateEarning
			FROM tblPRTemplateEarning 
			WHERE intTypeEarningId = @intTypeEarningId

		--Delete Template Earning Taxes
		IF (@ysnUpdateTaxes = 1)
		DELETE FROM tblPRTemplateEarningTax 
				WHERE intTemplateEarningId IN (SELECT intTemplateEarningId FROM #tmpTemplateEarning)

		--Delete Template Earning Distribution
		IF (@ysnUpdateAccount = 1)
		DELETE FROM tblPRTemplateEarningDistribution 
				WHERE intTemplateEarningId IN (SELECT intTemplateEarningId FROM #tmpTemplateEarning)

		DECLARE @intTemplateEarningId INT
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTemplateEarning)
		BEGIN
			SELECT TOP 1 @intTemplateEarningId = intTemplateEarningId FROM #tmpTemplateEarning

			--Reinsert Template Earning Taxes
			IF (@ysnUpdateTaxes = 1)
			INSERT INTO tblPRTemplateEarningTax (intTemplateEarningId, intTypeTaxId, intSort, intConcurrencyId)
				SELECT @intTemplateEarningId, intTypeTaxId, intSort, intConcurrencyId
				FROM tblPRTypeEarningTax
				WHERE intTypeEarningId = @intTypeEarningId

			--Reinsert Earning Distribution
			IF (@ysnUpdateAccount = 1)
			INSERT INTO tblPRTemplateEarningDistribution (intTemplateEarningId, intAccountId, dblPercentage, intConcurrencyId)
				SELECT @intTemplateEarningId, intAccountId, 100, 1 
				FROM tblPRTypeEarning
				WHERE intTypeEarningId = @intTypeEarningId

			DELETE FROM #tmpTemplateEarning WHERE intTemplateEarningId = @intTemplateEarningId
		END


		--Add all the inserted Earning Type to value to Audit Log
		--Insert Deleted Employee Earning in temp Audit log table 
		IF (@ysnUpdateTaxes = 1)
		BEGIN
			INSERT INTO #tmpTableEmpId([Id],[Namespace],[Action],[Description],[From],[To],[EntityId])
				SELECT intEntityEmployeeId,'EntityManagement.view.Entity','Updated','Inserted Earning Taxes in Update Employees',NULL,TT.strDescription,@intUserId
				from tblPREmployeeEarning EE
				inner join tblPREmployeeEarningTax EET ON EET.intEmployeeEarningId=EE.intEmployeeEarningId
				inner join tblPRTypeTax TT ON TT.intTypeTaxId = EET.intTypeTaxId
				WHERE intTypeEarningId = @intTypeEarningId
				AND EE.intEmployeeEarningId IN (SELECT Distinct(intEmployeeEarningId) FROM #tmpInsertedTaxEarning)
		END
	END


	DECLARE @cur_Id INT;
	DECLARE @cur_Namespace VARCHAR(max);
	DECLARE @cur_Action VARCHAR(30);
	DECLARE @cur_Description VARCHAR(100);
	DECLARE @cur_From VARCHAR(100);
	DECLARE @cur_To VARCHAR(100);
	DECLARE @cur_EntityId Int;

	DECLARE AuditTableCursor CURSOR FOR
	SELECT * FROM #tmpTableEmpId 

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

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeEarning')) DROP TABLE #tmpEmployeeEarning
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTemplateEarning')) DROP TABLE #tmpTemplateEarning

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTableEmpId')) DROP TABLE #tmpTableEmpId 
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInsertedTaxEarning')) DROP TABLE #tmpInsertedTaxEarning
	
END
GO