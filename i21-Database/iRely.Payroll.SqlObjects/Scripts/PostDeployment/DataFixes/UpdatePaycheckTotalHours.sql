/*
* Recalculates Paycheck Total Hours 
* Only affects entries whose total hours does not 
* correpond to the paycheck earning hours
*/

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblPRPaycheck'))
BEGIN

EXEC ('UPDATE tblPRPaycheck
		SET dblTotalHours = ISNULL((SELECT SUM(dblHours) FROM tblPRPaycheckEarning WHERE intPaycheckId = tblPRPaycheck.intPaycheckId), 0)
		WHERE dblTotalHours = 0 AND dblTotalHours <> ISNULL((SELECT SUM(dblHours) FROM tblPRPaycheckEarning WHERE intPaycheckId = tblPRPaycheck.intPaycheckId), 0)
	  ')
END