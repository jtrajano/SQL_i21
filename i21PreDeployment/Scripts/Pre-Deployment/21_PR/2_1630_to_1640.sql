GO
	PRINT 'BEGIN PR 1640'
GO

/* 
   tblPREmployeeEarning.intPayGroupId NULL to NOT NULL 
   Attempts to update null tblPREmployeeEarning.intPayGroupId with values from logical sources
*/
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPayGroupId' AND OBJECT_ID = OBJECT_ID(N'tblPREmployeeEarning')) 
BEGIN

--Try to use employee pay group with similar name or description as employee's pay period
EXEC('UPDATE tblPREmployeeEarning
		SET intPayGroupId = (SELECT TOP 1 intPayGroupId FROM tblPRPayGroup 
							 WHERE LOWER(strPayGroup) LIKE ''%'' + LOWER(tblPREmployee.strPayPeriod) + ''%''
								OR LOWER(strDescription) LIKE ''%'' + LOWER(tblPREmployee.strPayPeriod) + ''%'')
		FROM tblPREmployeeEarning 
			LEFT JOIN tblPREmployee ON tblPREmployeeEarning.intEntityEmployeeId = tblPREmployee.intEntityEmployeeId
		WHERE tblPREmployeeEarning.intPayGroupId IS NULL')

--Try to use top pay group used by employee
EXEC('UPDATE tblPREmployeeEarning
		SET intPayGroupId = (SELECT TOP 1 intPayGroupId FROM tblPREmployeeEarning WHERE intEntityEmployeeId = tblPREmployeeEarning.intEntityEmployeeId)
		WHERE intPayGroupId IS NULL')

--Try to use top pay group associated to the earning
EXEC('UPDATE tblPREmployeeEarning
		SET intPayGroupId = (SELECT TOP 1 intPayGroupId FROM tblPREmployeeEarning WHERE intTypeEarningId = tblPREmployeeEarning.intTypeEarningId)
		WHERE intPayGroupId IS NULL')

--Try to use top pay group from pay groups table
EXEC('UPDATE tblPREmployeeEarning
		SET intPayGroupId = (SELECT TOP 1 intPayGroupId FROM tblPRPayGroup)
		WHERE intPayGroupId IS NULL')

END

GO
	PRINT 'END PR 1640'
GO