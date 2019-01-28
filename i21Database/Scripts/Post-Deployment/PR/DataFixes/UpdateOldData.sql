﻿/***********************
* UPDATING OLD DATA
************************/

/*
* Payroll Company Preferences 
* 1. Insert initial row if table is empty
* 2..
*/
IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRCompanyPreference'))
BEGIN
	EXEC ('IF NOT EXISTS (SELECT TOP 1 1 FROM tblPRCompanyPreference) INSERT INTO tblPRCompanyPreference DEFAULT VALUES')
END

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
* Template Earnings
* 1. Add default sorting to Template Earnings
* 2...
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTemplateEarning'))
BEGIN

EXEC('
	--Check if Sorting has never been applied (no intSort greater than 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE intSort > 1)

	UPDATE tblPRTemplateEarning
		SET intSort = intRank
	FROM 
		tblPRTemplateEarning
		INNER JOIN (SELECT intTemplateEarningId, 
						DENSE_RANK() OVER(PARTITION BY intTemplateId ORDER BY intTypeEarningId) intRank 
					FROM tblPRTemplateEarning) tblPRTemplateEarning_Ranked
						ON tblPRTemplateEarning.intTemplateEarningId = tblPRTemplateEarning_Ranked.intTemplateEarningId')


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

/*
* Earning Types
* 1. Attempt to convert Fixed Salary earnings to 'Salary' Calculation Type
* 2...
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTypeEarning'))
BEGIN

EXEC('
	UPDATE tblPRTypeEarning 
	SET strCalculationType = ''Salary''
	WHERE LOWER(strEarning) LIKE ''sal%'' AND strCalculationType IN (''Fixed Amount'', ''Annual Salary'')
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblPRTypeEarning WHERE strCalculationType = ''Salary'')

	UPDATE E
	SET strCalculationType = ''Salary''
	FROM tblPREmployeeEarning E
	INNER JOIN tblPRTypeEarning T ON E.intTypeEarningId = T.intTypeEarningId
	WHERE T.strCalculationType = ''Salary'' AND E.strCalculationType <> ''Salary''
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarning WHERE strCalculationType = ''Salary'')

	UPDATE E
	SET strCalculationType = ''Salary''
	FROM tblPRTemplateEarning E
	INNER JOIN tblPRTypeEarning T ON E.intTypeEarningId = T.intTypeEarningId
	WHERE T.strCalculationType = ''Salary'' AND E.strCalculationType <> ''Salary''
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblPRTemplateEarning WHERE strCalculationType = ''Salary'')

	UPDATE E
	SET strCalculationType = ''Salary''
	FROM tblPRPaycheckEarning E
	INNER JOIN tblPRTypeEarning T ON E.intTypeEarningId = T.intTypeEarningId
	WHERE T.strCalculationType = ''Salary'' AND E.strCalculationType <> ''Salary''
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblPRPaycheckEarning WHERE strCalculationType = ''Salary'')
')

END

/*
* Employee Time Off
* 1. Reset Hours Used (run once)
* 2...
*/
IF EXISTS(SELECT * FROM sys.views WHERE object_id = object_id('vyuPREmployeeTimeOffUsedYTD'))
BEGIN

EXEC ('
	IF EXISTS(SELECT TOP 1 1 FROM tblPRCompanyPreference WHERE dtmLastTimeOffAdjustmentReset IS NULL)
	BEGIN
		UPDATE ETO
		SET 
			ETO.dblHoursUsed = CASE WHEN (ETO.dblHoursUsed >= ISNULL(YTD.dblHoursUsed, 0)) THEN
										ETO.dblHoursUsed - ISNULL(YTD.dblHoursUsed, 0)
									ELSE
										ETO.dblHoursUsed
									END
		FROM 
			tblPREmployeeTimeOff ETO
			LEFT JOIN vyuPREmployeeTimeOffUsedYTD YTD
				ON ETO.intEntityEmployeeId = YTD.intEntityEmployeeId
				AND ETO.intTypeTimeOffId = YTD.intTypeTimeOffId
				AND YTD.intYear = YEAR(GETDATE())

		UPDATE tblPRCompanyPreference SET dtmLastTimeOffAdjustmentReset = GETDATE()
	END
')

END

/*
* Employee Location Distribution
* 1. Attempt to Populate Location Distribution table with data from Earning Distribution table
* 2...
*/
IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeLocationDistribution'))
BEGIN
EXEC ('
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblPREmployeeLocationDistribution)
	BEGIN
		INSERT INTO tblPREmployeeLocationDistribution (
			intEntityEmployeeId
			,intProfitCenter
			,dblPercentage
			,intConcurrencyId
		)
		SELECT DISTINCT 
			intEntityEmployeeId, 
			intProfitCenter = ASM.intAccountSegmentId, 
			dblPercentage, 
			intConcurrencyId = 1 
		FROM tblPREmployeeEarningDistribution EED
		INNER JOIN tblPREmployeeEarning EE 
			ON EED.intEmployeeEarningId = EE.intEmployeeEarningId
		INNER JOIN 
			(SELECT * FROM tblGLAccountSegmentMapping WHERE intAccountSegmentId IN 
				(SELECT intAccountSegmentId FROM tblGLAccountSegment WHERE intAccountStructureId IN 
					(SELECT intAccountStructureId FROM tblGLAccountStructure 
						WHERE LOWER(strStructureName) IN (''location'', ''profit center'')))) ASM 
			ON EED.intAccountId = ASM.intAccountId
		WHERE dblPercentage <> 100
			AND intEntityEmployeeId IN (
				SELECT DISTINCT intEntityEmployeeId FROM tblPREmployeeEarning WHERE intEmployeeEarningId IN (
					SELECT DISTINCT intEmployeeEarningId FROM tblPREmployeeEarningDistribution 
					WHERE dblPercentage <> 100 
					GROUP BY intEmployeeEarningId HAVING SUM(dblPercentage) = 100))
	END
')
END

/*
* Paycheck Tax
* 1. Attempt to Populate Taxable Amount and Taxable Amount YTD fields (2015 and up)
* 2...
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheckTax') AND name = 'dblTaxableAmount')
BEGIN
	EXEC ('
	UPDATE PaycheckTax
	SET dblTaxableAmount = CASE WHEN (PaycheckTax.dblTotal > 0) THEN
						CASE WHEN (strCalculationType = ''USA Social Security'') THEN
								 CASE WHEN (Taxable.dblTaxableYTD > (CASE YEAR(PC.dtmPayDate) 
																		WHEN 2015 THEN 118500 
																		WHEN 2016 THEN 118500 
																		WHEN 2017 THEN 127200 
																		WHEN 2018 THEN 128400 
																		ELSE 0
																	END)) 
							  			THEN Taxable.dblTaxable - (dblTaxableYTD - (CASE YEAR(PC.dtmPayDate) 
																							WHEN 2015 THEN 118500 
																							WHEN 2016 THEN 118500 
																							WHEN 2017 THEN 127200 
																							WHEN 2018 THEN 128400 
																							ELSE 0
																						END)) 
								 ELSE Taxable.dblTaxable END
							 WHEN (strCalculationType IN (''USA FUTA'', ''USA SUTA'')) THEN
								CASE WHEN (Taxable.dblTaxableYTD > dblLimit) 
							  			THEN Taxable.dblTaxable - (dblTaxableYTD - dblLimit) 
								 ELSE Taxable.dblTaxable END
						 ELSE Taxable.dblTaxable END
					  ELSE 0 END
		,dblTaxableAmountYTD = CASE WHEN strCalculationType = ''USA Social Security'' THEN
								CASE WHEN (Taxable.dblTaxableYTD > (CASE YEAR(PC.dtmPayDate) 
																		WHEN 2015 THEN 118500 
																		WHEN 2016 THEN 118500 
																		WHEN 2017 THEN 127200 
																		WHEN 2018 THEN 128400 
																		ELSE 0
																	END)) THEN 
									(CASE YEAR(PC.dtmPayDate) 
										WHEN 2015 THEN 118500 
										WHEN 2016 THEN 118500 
										WHEN 2017 THEN 127200 
										WHEN 2018 THEN 128400 
										ELSE 0
									END) 
								ELSE Taxable.dblTaxableYTD END
							 WHEN (strCalculationType IN (''USA FUTA'', ''USA SUTA'')) THEN
								CASE WHEN (Taxable.dblTaxableYTD > dblLimit) THEN dblLimit 
								ELSE Taxable.dblTaxableYTD END
						 ELSE Taxable.dblTaxableYTD END
	FROM 
	tblPRPaycheckTax PaycheckTax
	INNER JOIN
		(SELECT
			PT.intPaycheckTaxId
			,dblTaxable = ISNULL(dblTotalEarning, 0) - ISNULL(dblTotalDeduction, 0)
			,dblTaxableYTD = ISNULL((SELECT dblTotalEarning = SUM(dblTotal)
									FROM tblPRPaycheckEarning E1
									LEFT JOIN tblPRPaycheck E3
										ON E1.intPaycheckId = E3.intPaycheckId
									LEFT JOIN (SELECT DISTINCT intPaycheckEarningId, intTypeTaxId FROM tblPRPaycheckEarningTax) E2 
										ON E1.intPaycheckEarningId = E2.intPaycheckEarningId
									WHERE E1.strCalculationType <> ''Reimbursement''
										AND E3.ysnPosted = 1 
										AND YEAR(E3.dtmPayDate) = YEAR(PC.dtmPayDate)
										AND E3.dtmPayDate <= PC.dtmPayDate
										AND E2.intTypeTaxId = PT.intTypeTaxId
										AND E3.intEntityEmployeeId = PC.intEntityEmployeeId), 0) 
							- ISNULL((SELECT dblTotalDeduction = SUM(dblTotal)
									FROM tblPRPaycheckDeduction D1 
									LEFT JOIN tblPRPaycheck D3
										ON D1.intPaycheckId = D3.intPaycheckId
									LEFT JOIN (SELECT DISTINCT intPaycheckDeductionId, intTypeTaxId FROM tblPRPaycheckDeductionTax) D2 
										ON D1.intPaycheckDeductionId = D2.intPaycheckDeductionId
									WHERE D1.strDeductFrom = ''Gross Pay'' AND D1.strPaidBy = ''Employee''
											AND D3.ysnPosted = 1
											AND YEAR(D3.dtmPayDate) = YEAR(PC.dtmPayDate)
											AND D3.dtmPayDate <= PC.dtmPayDate
											AND D2.intTypeTaxId = PT.intTypeTaxId
											AND D3.intEntityEmployeeId = PC.intEntityEmployeeId), 0)
			FROM tblPRPaycheckTax PT
			LEFT JOIN tblPRPaycheck PC
				ON PC.intPaycheckId = PT.intPaycheckId
			LEFT JOIN 
				(SELECT intPaycheckId, intTypeTaxId, dblTotalEarning = SUM(dblTotal)
					FROM tblPRPaycheckEarning E1 
					LEFT JOIN (SELECT DISTINCT intPaycheckEarningId, intTypeTaxId FROM tblPRPaycheckEarningTax) E2 
						ON E1.intPaycheckEarningId = E2.intPaycheckEarningId
					GROUP BY intPaycheckId, intTypeTaxId) PE
				ON PE.intTypeTaxId = PT.intTypeTaxId AND PT.intPaycheckId = PE.intPaycheckId
			LEFT JOIN
				(SELECT intPaycheckId, intTypeTaxId, dblTotalDeduction = SUM(dblTotal)
					FROM tblPRPaycheckDeduction D1 
					LEFT JOIN (SELECT DISTINCT intPaycheckDeductionId, intTypeTaxId FROM tblPRPaycheckDeductionTax) D2 
					ON D1.intPaycheckDeductionId = D2.intPaycheckDeductionId
					WHERE D1.strDeductFrom = ''Gross Pay'' AND D1.strPaidBy = ''Employee''
					GROUP BY intPaycheckId, intTypeTaxId) PD
				ON PD.intTypeTaxId = PT.intTypeTaxId AND PT.intPaycheckId = PD.intPaycheckId
			) Taxable
		ON PaycheckTax.intPaycheckTaxId = Taxable.intPaycheckTaxId
	INNER JOIN tblPRPaycheck PC
		ON PaycheckTax.intPaycheckId = PC.intPaycheckId
	WHERE dblTaxableAmount IS NULL OR dblTaxableAmountYTD IS NULL
	')
END

/*
* Timecards
* 1. Populate Timecard Workers Compensation Id
* 2...
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRTimecard') AND name = 'intWorkersCompensationId')
BEGIN
	EXEC ('
	UPDATE tblPRTimecard
	SET intWorkersCompensationId = (SELECT TOP 1 intWorkersCompensationId 
									FROM tblPREmployee WHERE intEntityId = tblPRTimecard.intEntityEmployeeId)
	WHERE intWorkersCompensationId IS NULL
	')
END