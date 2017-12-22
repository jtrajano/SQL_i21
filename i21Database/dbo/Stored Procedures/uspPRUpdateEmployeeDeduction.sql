CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeDeduction]
	@intTypeDeductionId INT
AS
BEGIN

	--Update Deduction 
	UPDATE tblPREmployeeDeduction
	SET strCalculationType = Deduction.strCalculationType
		,intAccountId = Deduction.intAccountId
		,intExpenseAccountId = Deduction.intExpenseAccountId
		,strDeductFrom = Deduction.strDeductFrom
		,dblAmount = Deduction.dblAmount
		,dblLimit = Deduction.dblLimit
		,strPaidBy = Deduction.strPaidBy
	FROM tblPRTypeDeduction Deduction INNER JOIN tblPREmployeeDeduction EmpDeduction
		ON Deduction.intTypeDeductionId = EmpDeduction.intTypeDeductionId
	WHERE EmpDeduction.intTypeDeductionId = @intTypeDeductionId

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

	--Update Template Deduction 
	UPDATE tblPRTemplateDeduction
	SET strCalculationType = Deduction.strCalculationType
		,intAccountId = Deduction.intAccountId
		,intExpenseAccountId = Deduction.intExpenseAccountId
		,strDeductFrom = Deduction.strDeductFrom
		,dblAmount = Deduction.dblAmount
		,dblLimit = Deduction.dblLimit
		,strPaidBy = Deduction.strPaidBy
	FROM tblPRTypeDeduction Deduction INNER JOIN tblPRTemplateDeduction EmpDeduction
		ON Deduction.intTypeDeductionId = EmpDeduction.intTypeDeductionId
	WHERE EmpDeduction.intTypeDeductionId = @intTypeDeductionId

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
GO