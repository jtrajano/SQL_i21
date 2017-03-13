CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeEarning]
	@intTypeEarningId INT
	,@ysnUpdateCalcType BIT = 0
	,@ysnUpdateAmount BIT = 0
	,@ysnUpdateHours BIT = 0
	,@ysnUpdateAccount BIT = 0
	,@ysnUpdateW2Code BIT = 0
	,@ysnUpdateTaxCalc BIT = 0
	,@ysnUpdateTaxes BIT = 0
AS
BEGIN

	--Update Earning 
	UPDATE tblPREmployeeEarning
		SET strCalculationType = CASE WHEN (@ysnUpdateCalcType = 1) THEN Earning.strCalculationType ELSE EmpEarning.strCalculationType END,
			dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Earning.dblAmount ELSE EmpEarning.dblAmount END,
			dblDefaultHours = CASE WHEN (@ysnUpdateHours = 1) THEN Earning.dblDefaultHours ELSE EmpEarning.dblDefaultHours END,
			strW2Code = CASE WHEN (@ysnUpdateW2Code = 1) THEN Earning.strW2Code ELSE EmpEarning.strW2Code END,
			intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Earning.intAccountId ELSE EmpEarning.intAccountId END,
			intTaxCalculationType = CASE WHEN (@ysnUpdateTaxCalc = 1) THEN Earning.intTaxCalculationType ELSE EmpEarning.intTaxCalculationType END,
			dblRateAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN
									Earning.dblAmount * (CASE WHEN Earning.strCalculationType IN ('Rate Factor', 'Overtime') THEN ISNULL(Link.dblAmount, 1) ELSE 1 END)
								 ELSE 
									EmpEarning.dblAmount * (CASE WHEN EmpEarning.strCalculationType IN ('Rate Factor', 'Overtime') THEN ISNULL(Link.dblAmount, 1) ELSE 1 END)
								 END,
			intEmployeeEarningLinkId = CASE WHEN (@ysnUpdateCalcType = 1 AND Earning.strCalculationType NOT IN ('Rate Factor', 'Overtime')) THEN NULL 
										ELSE EmpEarning.intEmployeeEarningLinkId END
		FROM tblPRTypeEarning Earning 
			INNER JOIN tblPREmployeeEarning EmpEarning
				ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
			LEFT JOIN (SELECT intTypeEarningId, intEntityEmployeeId, dblAmount FROM tblPREmployeeEarning) Link
				ON EmpEarning.intEmployeeEarningLinkId = Link.intTypeEarningId
				AND EmpEarning.intEntityEmployeeId = Link.intEntityEmployeeId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId

	--Update Template Earning
	UPDATE tblPRTemplateEarning
		SET strCalculationType = CASE WHEN (@ysnUpdateCalcType = 1) THEN Earning.strCalculationType ELSE EmpEarning.strCalculationType END,
			dblAmount = CASE WHEN (@ysnUpdateAmount = 1) THEN Earning.dblAmount ELSE EmpEarning.dblAmount END,
			dblDefaultHours = CASE WHEN (@ysnUpdateHours = 1) THEN Earning.dblDefaultHours ELSE EmpEarning.dblDefaultHours END,
			strW2Code = CASE WHEN (@ysnUpdateW2Code = 1) THEN Earning.strW2Code ELSE EmpEarning.strW2Code END,
			intAccountId = CASE WHEN (@ysnUpdateAccount = 1) THEN Earning.intAccountId ELSE EmpEarning.intAccountId END,
			intTaxCalculationType = CASE WHEN (@ysnUpdateTaxCalc = 1) THEN Earning.intTaxCalculationType ELSE EmpEarning.intTaxCalculationType END,
			intTemplateEarningLinkId = CASE WHEN (@ysnUpdateCalcType = 1 AND Earning.strCalculationType NOT IN ('Rate Factor', 'Overtime')) THEN NULL 
										ELSE EmpEarning.intTemplateEarningLinkId END
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

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeEarning')) DROP TABLE #tmpEmployeeEarning
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTemplateEarning')) DROP TABLE #tmpTemplateEarning
	END
END
GO