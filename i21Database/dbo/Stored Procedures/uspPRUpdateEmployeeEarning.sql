CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeEarning]
	@intTypeEarningId INT
AS
BEGIN

	--Update Earning 
	UPDATE tblPREmployeeEarning
		SET strCalculationType = Earning.strCalculationType,
			dblAmount = Earning.dblAmount,
			dblDefaultHours = Earning.dblDefaultHours,
			strW2Code = Earning.strW2Code,
			intAccountId = Earning.intAccountId
		FROM tblPRTypeEarning Earning INNER JOIN tblPREmployeeEarning EmpEarning
		ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId

	--Insert Employee Earnings to Temp Table
	SELECT intEmployeeEarningId 
	  INTO #tmpEmployeeEarning
	  FROM tblPREmployeeEarning 
	  WHERE intTypeEarningId = @intTypeEarningId

	--Delete Earning Taxes
	DELETE FROM tblPREmployeeEarningTax 
		 WHERE intEmployeeEarningId IN (SELECT intEmployeeEarningId 
										     FROM #tmpEmployeeEarning)

	DECLARE @intEmployeeEarningId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEmployeeEarning)
	BEGIN
		SELECT TOP 1 @intEmployeeEarningId = intEmployeeEarningId FROM #tmpEmployeeEarning

		--Reinsert Earning Taxes
		INSERT INTO tblPREmployeeEarningTax
					(intEmployeeEarningId,
					intTypeTaxId,
					intSort,
					intConcurrencyId)
			 SELECT
					@intEmployeeEarningId,
					intTypeTaxId,
					intSort,
					intConcurrencyId
			  FROM tblPRTypeEarningTax
			 WHERE intTypeEarningId = @intTypeEarningId

		DELETE FROM #tmpEmployeeEarning WHERE intEmployeeEarningId = @intEmployeeEarningId
	END


	--Update Template Earning 
	UPDATE tblPRTemplateEarning
		SET strCalculationType = Earning.strCalculationType,
			dblAmount = Earning.dblAmount,
			dblDefaultHours = Earning.dblDefaultHours,
			strW2Code = Earning.strW2Code,
			intAccountId = Earning.intAccountId
		FROM tblPRTypeEarning Earning INNER JOIN tblPRTemplateEarning EmpEarning
		ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
		WHERE EmpEarning.intTypeEarningId = @intTypeEarningId

	--Insert Template Earnings to Temp Table
	SELECT intTemplateEarningId 
	  INTO #tmpTemplateEarning
	  FROM tblPRTemplateEarning 
	  WHERE intTypeEarningId = @intTypeEarningId

	--Delete Template Earning Taxes
	DELETE FROM tblPRTemplateEarningTax 
		 WHERE intTemplateEarningId IN (SELECT intTemplateEarningId 
										     FROM #tmpTemplateEarning)

	DECLARE @intTemplateEarningId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTemplateEarning)
	BEGIN
		SELECT TOP 1 @intTemplateEarningId = intTemplateEarningId FROM #tmpTemplateEarning

		--Reinsert Template Earning Taxes
		INSERT INTO tblPRTemplateEarningTax
					(intTemplateEarningId,
					intTypeTaxId,
					intSort,
					intConcurrencyId)
			 SELECT
					@intTemplateEarningId,
					intTypeTaxId,
					intSort,
					intConcurrencyId
			  FROM tblPRTypeEarningTax
			 WHERE intTypeEarningId = @intTypeEarningId

		DELETE FROM #tmpTemplateEarning WHERE intTemplateEarningId = @intTemplateEarningId
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEmployeeEarning')) DROP TABLE #tmpEmployeeEarning
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpTemplateEarning')) DROP TABLE #tmpTemplateEarning
END
GO