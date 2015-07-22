CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeDeduction]
	@intTypeDeductionId INT
AS
BEGIN

	--Update Deduction 
	UPDATE tblPREmployeeDeduction
	SET strCalculationType = Deduction.strCalculationType
		,intAccountId = Deduction.intAccountId
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
GO