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

	--Delete Earning Taxes
	DELETE FROM tblPREmployeeEarningTax 
		 WHERE intEmployeeEarningId = (SELECT TOP 1 intEmployeeEarningId 
										     FROM tblPREmployeeEarning 
										    WHERE intTypeEarningId = @intTypeEarningId)

	IF EXISTS(SELECT intEmployeeEarningId FROM tblPREmployeeEarning WHERE intTypeEarningId = @intTypeEarningId)
	BEGIN
		--Reinsert Earning Taxes
		INSERT INTO tblPREmployeeEarningTax
					(intEmployeeEarningId,
					intEmployeeTaxId,
					intTypeTaxId,
					intSort,
					intConcurrencyId)
			 SELECT
					(SELECT TOP 1 intEmployeeEarningId FROM tblPREmployeeEarning WHERE intTypeEarningId = @intTypeEarningId),
					(SELECT TOP 1 intEmployeeTaxId FROM tblPREmployeeTax WHERE intTypeTaxId = tblPRTypeEarningTax.intTypeTaxId),
					intTypeTaxId,
					intSort,
					intConcurrencyId
			  FROM tblPRTypeEarningTax
			 WHERE intTypeEarningId = @intTypeEarningId
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

	--Delete Template Earning Taxes
	DELETE FROM tblPRTemplateEarningTax 
		 WHERE intTemplateEarningId = (SELECT TOP 1 intTemplateEarningId 
										     FROM tblPRTemplateEarning 
										    WHERE intTypeEarningId = @intTypeEarningId)

	IF EXISTS(SELECT intTemplateEarningId FROM tblPRTemplateEarning WHERE intTypeEarningId = @intTypeEarningId)
	BEGIN
		--Reinsert Template Earning Taxes
		INSERT INTO tblPRTemplateEarningTax
					(intTemplateEarningId,
					intTypeTaxId,
					intSort,
					intConcurrencyId)
			 SELECT
					(SELECT TOP 1 intTemplateEarningId FROM tblPRTemplateEarning WHERE intTypeEarningId = @intTypeEarningId),
					intTypeTaxId,
					intSort,
					intConcurrencyId
			  FROM tblPRTypeEarningTax
			 WHERE intTypeEarningId = @intTypeEarningId
	END
END
GO