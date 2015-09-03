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

	--Delete Deduction Taxes
	DELETE FROM tblPREmployeeDeductionTax 
	WHERE intEmployeeDeductionId = (SELECT TOP 1 intEmployeeDeductionId 
									FROM tblPREmployeeDeduction 
									WHERE intTypeDeductionId = @intTypeDeductionId)

	IF EXISTS(SELECT intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intTypeDeductionId = @intTypeDeductionId)
	BEGIN
		--Reinsert Deduction Taxes
		INSERT INTO tblPREmployeeDeductionTax
			(intEmployeeDeductionId
			,intEmployeeTaxId
			,intTypeTaxId
			,intSort
			,intConcurrencyId)
		SELECT
			(SELECT TOP 1 intEmployeeDeductionId FROM tblPREmployeeDeduction WHERE intTypeDeductionId = @intTypeDeductionId)
			,(SELECT TOP 1 intEmployeeTaxId FROM tblPREmployeeTax WHERE intTypeTaxId = tblPRTypeDeductionTax.intTypeTaxId)
			,intTypeTaxId
			,intSort
			,intConcurrencyId
		FROM tblPRTypeDeductionTax
		WHERE intTypeDeductionId = @intTypeDeductionId
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

	--Delete Template Deduction Taxes
	DELETE FROM tblPRTemplateDeductionTax 
	WHERE intTemplateDeductionId = (SELECT TOP 1 intTemplateDeductionId 
									FROM tblPRTemplateDeduction 
									WHERE intTypeDeductionId = @intTypeDeductionId)

	IF EXISTS(SELECT intTemplateDeductionId FROM tblPRTemplateDeduction WHERE intTypeDeductionId = @intTypeDeductionId)
	BEGIN
		--Reinsert Template Deduction Taxes
		INSERT INTO tblPRTemplateDeductionTax
			(intTemplateDeductionId
			,intTypeTaxId
			,intSort
			,intConcurrencyId)
		SELECT
			(SELECT TOP 1 intTemplateDeductionId FROM tblPRTemplateDeduction WHERE intTypeDeductionId = @intTypeDeductionId)
			,intTypeTaxId
			,intSort
			,intConcurrencyId
		FROM tblPRTypeDeductionTax
		WHERE intTypeDeductionId = @intTypeDeductionId
	END
END
GO