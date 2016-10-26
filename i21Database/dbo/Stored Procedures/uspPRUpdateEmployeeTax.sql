CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTax]
	@intTypeTaxId INT
AS
BEGIN

	UPDATE tblPREmployeeTax
	SET strCalculationType = Tax.strCalculationType
		,intTypeTaxStateId = Tax.intTypeTaxStateId
		,intTypeTaxLocalId = Tax.intTypeTaxLocalId
		,dblAmount = Tax.dblAmount
		,dblLimit = Tax.dblLimit
		,intAccountId = Tax.intAccountId 
		,intExpenseAccountId = Tax.intExpenseAccountId
		,intSupplementalCalc = Tax.intSupplementalCalc
		,strPaidBy = Tax.strPaidBy
		,intSort = Tax.intSort
	FROM tblPRTypeTax Tax INNER JOIN tblPREmployeeTax EmpTax
		ON Tax.intTypeTaxId = EmpTax.intTypeTaxId
	WHERE EmpTax.intTypeTaxId = @intTypeTaxId

	UPDATE tblPRTemplateTax
	SET strCalculationType = Tax.strCalculationType
		,intTypeTaxStateId = Tax.intTypeTaxStateId
		,intTypeTaxLocalId = Tax.intTypeTaxLocalId
		,dblAmount = Tax.dblAmount
		,dblLimit = Tax.dblLimit
		,intAccountId = Tax.intAccountId 
		,intExpenseAccountId = Tax.intExpenseAccountId
		,intSupplementalCalc = Tax.intSupplementalCalc
		,strPaidBy = Tax.strPaidBy
		,intSort = Tax.intSort
	FROM tblPRTypeTax Tax INNER JOIN tblPRTemplateTax EmpTax
		ON Tax.intTypeTaxId = EmpTax.intTypeTaxId
	WHERE EmpTax.intTypeTaxId = @intTypeTaxId

END
GO