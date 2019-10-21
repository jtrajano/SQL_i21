CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeTax]
	@intTypeTaxId INT
	,@ysnUpdateAmount BIT = 0
	,@ysnUpdateLimit BIT = 0
	,@ysnUpdateState BIT = 0
	,@ysnUpdateLocal BIT = 0
	,@ysnUpdateAccount BIT = 0
	,@ysnUpdateExpense BIT = 0
	,@ysnUpdateSupplemental BIT = 0
AS
BEGIN

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
	FROM tblPRTypeTax Tax INNER JOIN tblPREmployeeTax EmpTax
		ON Tax.intTypeTaxId = EmpTax.intTypeTaxId
	WHERE EmpTax.intTypeTaxId = @intTypeTaxId

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

END
GO