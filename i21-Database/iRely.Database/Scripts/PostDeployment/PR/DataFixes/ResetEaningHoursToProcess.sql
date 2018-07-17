/*
* Resets Earning Hours to Process to Default 
*/

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPREmployeeEarning') AND name = 'dblHoursToProcess')
BEGIN
	EXEC ('UPDATE tblPREmployeeEarning SET dblHoursToProcess = dblDefaultHours')
END


/*
* Resets Rate Amount to Default 
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPREmployeeEarning') AND name = 'dblRateAmount')
BEGIN
	EXEC ('UPDATE tblPREmployeeEarning 
			SET dblRateAmount = CASE WHEN (strCalculationType IN (''Rate Factor'', ''Overtime''))
								THEN 
									dblAmount * ISNULL((SELECT dblAmount FROM tblPREmployeeEarning X 
														WHERE X.intTypeEarningId = tblPREmployeeEarning.intEmployeeEarningLinkId 
														  AND X.intEntityEmployeeId = tblPREmployeeEarning.intEntityEmployeeId), 0)
								ELSE
									dblAmount
								END')
END