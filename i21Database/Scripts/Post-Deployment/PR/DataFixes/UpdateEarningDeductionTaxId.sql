

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheckEarning') AND name = 'intTypeEarningId')
BEGIN
	EXEC ('
	UPDATE tblPRPaycheckEarning 
	SET intTypeEarningId = (SELECT TOP 1 intTypeEarningId 
							FROM tblPREmployeeEarning 
							WHERE intEmployeeEarningId = tblPRPaycheckEarning.intEmployeeEarningId)
	WHERE intTypeEarningId IS NULL
	')
END

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheckDeduction') AND name = 'intTypeDeductionId')
BEGIN
	EXEC ('
	UPDATE tblPRPaycheckDeduction 
	SET intTypeDeductionId = (SELECT TOP 1 intTypeDeductionId 
							  FROM tblPREmployeeDeduction 
							  WHERE intEmployeeDeductionId = tblPRPaycheckDeduction.intEmployeeDeductionId)
	WHERE intTypeDeductionId IS NULL
	')
END

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheckEarningTax') AND name = 'intTypeTaxId')
BEGIN
	EXEC ('
	UPDATE tblPRPaycheckEarningTax 
	SET intTypeTaxId = (SELECT TOP 1 intTypeTaxId 
						FROM tblPREmployeeEarningTax 
						WHERE intEmployeeTaxId = tblPRPaycheckEarningTax.intEmployeeTaxId)
	WHERE intTypeTaxId IS NULL
	')
END

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheckDeductionTax') AND name = 'intTypeTaxId')
BEGIN
	EXEC ('
	UPDATE tblPRPaycheckDeductionTax 
	SET intTypeTaxId = (SELECT TOP 1 intTypeTaxId 
						FROM tblPREmployeeDeductionTax 
						WHERE intEmployeeTaxId = tblPRPaycheckDeductionTax.intEmployeeTaxId)
	WHERE intTypeTaxId IS NULL
	')
END

