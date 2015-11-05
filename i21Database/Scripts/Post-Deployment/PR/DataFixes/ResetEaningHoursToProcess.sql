/*
* Resets Earning Hours to Process to Default 
*/

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPREmployeeEarning') AND name = 'dblHoursToProcess')
BEGIN
	EXEC ('UPDATE tblPREmployeeEarning SET dblHoursToProcess = dblDefaultHours')
END