CREATE VIEW [dbo].[vyuPRUnpaidEmployeeReport]
AS
SELECT
	PG.intPayGroupId
	,PG.strPayGroup
	,PG.dtmPayDate
	,EMP.[intEntityId]
	,EMP.strEmployeeId
	,EMP.strFirstName
	,EMP.strLastName
	,EMP.strMiddleName
	,EMP.strPayPeriod
	,PCLP.dtmLastPaid
	,strLastPaycheckId = ISNULL((SELECT TOP 1 strPaycheckId FROM tblPRPaycheck WHERE dtmPayDate = PCLP.dtmLastPaid AND intEntityEmployeeId = EMP.[intEntityId]), '')
	,ysnPosted = ISNULL((SELECT TOP 1 ysnPosted FROM tblPRPaycheck WHERE dtmPayDate = PCLP.dtmLastPaid AND intEntityEmployeeId = EMP.[intEntityId]), '')
	,ysnPaid = ISNULL((SELECT TOP 1 1 FROM 
						tblPRPaycheck PC1
						INNER JOIN tblPRPaycheckEarning PE1 ON PC1.intPaycheckId = PE1.intPaycheckId AND PC1.dtmPayDate = [PG].dtmPayDate AND PC1.intEntityEmployeeId = [EMP].[intEntityId]
						INNER JOIN tblPREmployeeEarning EE1 ON PE1.intEmployeeEarningId = PE1.intEmployeeEarningId AND EE1.intPayGroupId = [PG].intPayGroupId
					   WHERE PC1.ysnPosted = 1 AND PC1.ysnVoid = 0) , 0)
FROM 
	tblPRPayGroup [PG]
	LEFT JOIN (SELECT 
				PC.intEntityEmployeeId
				,EE.intPayGroupId
				,dtmLastPaid = MAX(PC.dtmPayDate)
			   FROM 
				tblPRPaycheck PC
				LEFT JOIN tblPRPaycheckEarning PE ON PC.intPaycheckId = PE.intPaycheckId
				INNER JOIN tblPREmployeeEarning EE ON PE.intEmployeeEarningId = PE.intEmployeeEarningId
			   WHERE ysnVoid = 0
			   GROUP BY PC.intEntityEmployeeId, EE.intPayGroupId) [PCLP] ON PCLP.intPayGroupId = PG.intPayGroupId
	LEFT JOIN (SELECT 
				[intEntityId]
				,strEmployeeId
				,strFirstName
				,strLastName
				,strMiddleName
				,strPayPeriod 
			   FROM
				tblPREmployee
			   WHERE ysnActive = 1) [EMP] ON EMP.[intEntityId] = PCLP.intEntityEmployeeId
WHERE 0 = ISNULL((SELECT TOP 1 1 FROM 
						tblPRPaycheck PC1
						INNER JOIN tblPRPaycheckEarning PE1 ON PC1.intPaycheckId = PE1.intPaycheckId AND PC1.dtmPayDate = [PG].dtmPayDate AND PC1.intEntityEmployeeId = [EMP].[intEntityId]
						INNER JOIN tblPREmployeeEarning EE1 ON PE1.intEmployeeEarningId = PE1.intEmployeeEarningId AND EE1.intPayGroupId = [PG].intPayGroupId
					   WHERE PC1.ysnPosted = 1 AND PC1.ysnVoid = 0) , 0)