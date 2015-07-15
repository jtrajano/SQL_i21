CREATE PROCEDURE [dbo].[uspPRUpdateEmployeeEarning]
	@intTypeEarningId INT
AS
BEGIN

	--Update Earning 
	UPDATE tblPREmployeeEarning
	SET strCalculationType = Earning.strCalculationType
		,dblAmount = Earning.dblAmount
		,dblDefaultHours = Earning.dblDefaultHours
		,strW2Code = Earning.strW2Code
		,intAccountId = Earning.intAccountId
	FROM tblPRTypeEarning Earning INNER JOIN tblPREmployeeEarning EmpEarning
		ON Earning.intTypeEarningId = EmpEarning.intTypeEarningId
	WHERE EmpEarning.intTypeEarningId = @intTypeEarningId

	--Delete Earning Taxes
	DELETE FROM tblPREmployeeEarningTax 
	WHERE intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId 
									FROM tblPREmployeeEarning 
									WHERE intTypeEarningId = @intTypeEarningId)

	--Reinsert Earning Taxes
	INSERT INTO tblPREmployeeEarningTax
		(intEmployeeEarningId
		,intEmployeeTaxId
		,intTypeTaxId
		,intSort
		,intConcurrencyId)
	SELECT
		(SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intTypeEarningId = @intTypeEarningId)
		,(SELECT TOP 1 intEmployeeTaxId FROM tblPREmployeeTax WHERE intTypeTaxId = tblPRTypeEarningTax.intTypeTaxId)
		,intTypeTaxId
		,intSort
		,intConcurrencyId
	FROM tblPRTypeEarningTax
	WHERE intTypeEarningId = @intTypeEarningId

END
GO