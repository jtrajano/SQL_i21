/*
* Adds data to tblPREmployeeEarningDistribution table based on the currently 
* selected Expense Account for each Earning, if none exists. This table must
* always have at least 1 row for each Employee Earning Id
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeEarningDistribution'))
BEGIN
	EXEC ('
	INSERT INTO tblPREmployeeEarningDistribution 
	(intEmployeeEarningId
	,intAccountId
	,dblPercentage
	,intConcurrencyId)
	SELECT 
	tblPREmployeeEarning.intEmployeeEarningId
	,tblPREmployeeEarning.intAccountId
	,100
	,1
	FROM tblPREmployeeEarning
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarningDistribution WHERE intEmployeeEarningId = tblPREmployeeEarning.intEmployeeEarningId)
	')
END

/*
* Adds data to tblPRTemplateEarningDistribution table based on the currently 
* selected Expense Account for each Earning, if none exists. This table must
* always have at least 1 row for each Template Earning Id
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTemplateEarningDistribution'))
BEGIN
	EXEC ('
	INSERT INTO tblPRTemplateEarningDistribution 
	(intTemplateEarningId
	,intAccountId
	,dblPercentage
	,intConcurrencyId)
	SELECT 
	tblPRTemplateEarning.intTemplateEarningId
	,tblPRTemplateEarning.intAccountId
	,100
	,1
	FROM tblPRTemplateEarning
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblPRTemplateEarningDistribution WHERE intTemplateEarningId = tblPRTemplateEarning.intTemplateEarningId)
	')
END