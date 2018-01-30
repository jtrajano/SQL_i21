/***********************
* UPDATING OLD DATA
************************/

/*
* Employee Workers Compensation 
* 1. Change Rate Type from "Amount" to "Per Dollar"
* 2..
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRWorkersCompensation'))
BEGIN
	EXEC ('
	UPDATE tblPRWorkersCompensation 
		SET strCalculationType = ''Per Dollar''
	WHERE strCalculationType IS NULL OR strCalculationType = ''Amount''
	')
END

/*
* Deduction Types
* 1. Remove Expense Account from Deduction Types that are Paid By Employee
* 2...
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTypeDeduction'))
BEGIN
	EXEC ('UPDATE tblPRTypeDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTemplateDeduction'))
BEGIN
	EXEC ('UPDATE tblPRTemplateDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeDeduction'))
BEGIN
	EXEC ('UPDATE tblPREmployeeDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRPaycheckDeduction'))
BEGIN
	EXEC ('UPDATE tblPRPaycheckDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

/*
* Employee Ranks
* 1. Populate Employee Rank table with existing employee Ranks
* 2...
*/
IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeRank'))
BEGIN
	EXEC ('
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeRank WHERE intRank = 0)
	INSERT INTO tblPREmployeeRank (intRank, strDescription, intConcurrencyId) SELECT 0, ''(unranked)'', 1 

	INSERT INTO tblPREmployeeRank
		(intRank
		,strDescription
		,intConcurrencyId
		)
	SELECT DISTINCT
		intRank = intRank
		,strDescription = ''Rank '' + CAST(intRank AS NVARCHAR(5))
		,intConcurrencyId = 1
	FROM tblPREmployee
	WHERE intRank <> 0 AND
		intRank NOT IN (SELECT DISTINCT intRank FROM tblPREmployeeRank)
	')
END

/*
* Time Off Requests
* 1. Update Time Off Request Calendar entries with Time Off System Calendar Id
* 2. Remove time part of Date From and To, change Common Calendar Entry to All Day event
* 3....
*/
IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTimeOffRequest'))
BEGIN
	EXEC ('
	UPDATE tblSMEvents 
	SET intCalendarId = (SELECT TOP 1 intCalendarId FROM tblSMCalendars 
						WHERE strCalendarName = ''Time Off'' AND strCalendarType = ''System'')
	WHERE intEventId IN (SELECT intEventId FROM tblPRTimeOffRequest)
	')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTimeOffRequest'))
	AND EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblSMEvents'))
BEGIN
EXEC('UPDATE tblSMEvents 
		SET dtmStart = tblPRTimeOffRequest.dtmDateFrom,
			dtmEnd = tblPRTimeOffRequest.dtmDateTo,
			strJsonData = REPLACE(strJsonData, ''{"drillDown":'', ''{"allDay":"true","drillDown":'')
		FROM tblSMEvents 
			INNER JOIN tblPRTimeOffRequest
			ON tblSMEvents.intEventId = tblPRTimeOffRequest.intEventId')
END

/*
* Employee Earnings
* 1. Add default sorting to Employee Earnings
* 2...
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeEarning'))
BEGIN

EXEC('
	--Check if Sorting has never been applied (no intSort greater than 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE intSort > 1)

	UPDATE tblPREmployeeEarning
		SET intSort = intRank
	FROM 
		tblPREmployeeEarning
		INNER JOIN (SELECT intEmployeeEarningId, 
						DENSE_RANK() OVER(PARTITION BY intEntityEmployeeId ORDER BY intTypeEarningId) intRank 
					FROM tblPREmployeeEarning) tblPREmployeeEarning_Ranked
						ON tblPREmployeeEarning.intEmployeeEarningId = tblPREmployeeEarning_Ranked.intEmployeeEarningId')

END

/*
* Tax Types
* 1. Add default Employer State Tax ID to USA State and USA Local types
* 2...
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTypeTax'))
BEGIN

EXEC('
	UPDATE tblPRTypeTax
	SET strEmployerStateTaxID = ISNULL((SELECT TOP 1 strStateTaxID FROM tblSMCompanySetup), '''')
	WHERE strCalculationType IN (''USA State'', ''USA Local'') AND ISNULL(strEmployerStateTaxID, '''') = ''''
')

END