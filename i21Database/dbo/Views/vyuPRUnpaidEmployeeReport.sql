CREATE VIEW [dbo].[vyuPRUnpaidEmployeeReport]
AS
SELECT
	EMP.intEntityEmployeeId
	,EMP.strFirstName
	,EMP.strLastName
	,EMP.strMiddleName
	,PG.intPayGroupId
	,PG.strPayGroup
	,PG.dtmPayDate
	,PCLP.dtmLastPaid
	,ysnPaid = ISNULL((SELECT TOP 1 1 FROM 
						tblPRPaycheck PC1
						INNER JOIN tblPRPaycheckEarning PE1 ON PC1.intPaycheckId = PE1.intPaycheckId
						INNER JOIN tblPREmployeeEarning EE1 ON PE1.intEmployeeEarningId = PE1.intEmployeeEarningId
					   WHERE PC1.ysnPosted = 1 AND PC1.ysnVoid = 0 AND EE1.intPayGroupId = [PG].intPayGroupId AND PC1.dtmPayDate = [PG].dtmPayDate), 0)
FROM 
	tblPREmployee [EMP]
	LEFT JOIN (SELECT 
				PC.intEntityEmployeeId
				,EE.intPayGroupId
				,dtmLastPaid = MAX(PC.dtmPayDate)
			   FROM 
				tblPRPaycheck PC
				LEFT JOIN tblPRPaycheckEarning PE ON PC.intPaycheckId = PE.intPaycheckId
				INNER JOIN tblPREmployeeEarning EE ON PE.intEmployeeEarningId = PE.intEmployeeEarningId
			   WHERE ysnPosted = 1 AND ysnVoid = 0 
			   GROUP BY PC.intEntityEmployeeId, EE.intPayGroupId) [PCLP] ON EMP.intEntityEmployeeId = PCLP.intEntityEmployeeId
	INNER JOIN tblPRPayGroup [PG] ON PCLP.intPayGroupId = PG.intPayGroupId
WHERE EMP.ysnActive = 1