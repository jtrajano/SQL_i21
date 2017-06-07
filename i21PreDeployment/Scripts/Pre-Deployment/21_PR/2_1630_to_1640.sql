GO
	PRINT 'BEGIN PR 1640'
GO

/* 
   tblPREmployeeEarning.intPayGroupId NULL to NOT NULL 
   Attempts to update null tblPREmployeeEarning.intPayGroupId with values from logical sources
*/
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPayGroupId' AND OBJECT_ID = OBJECT_ID(N'tblPREmployeeEarning')) 
AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEntityEmployeeId' AND OBJECT_ID = OBJECT_ID(N'tblPREmployee')) 
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
ELSE IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPayGroupId' AND OBJECT_ID = OBJECT_ID(N'tblPREmployeeEarning')) 
AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEntityId' AND OBJECT_ID = OBJECT_ID(N'tblPREmployee')) 
BEGIN

--Try to use employee pay group with similar name or description as employee's pay period
EXEC('UPDATE tblPREmployeeEarning
		SET intPayGroupId = (SELECT TOP 1 intPayGroupId FROM tblPRPayGroup 
							 WHERE LOWER(strPayGroup) LIKE ''%'' + LOWER(tblPREmployee.strPayPeriod) + ''%''
								OR LOWER(strDescription) LIKE ''%'' + LOWER(tblPREmployee.strPayPeriod) + ''%'')
		FROM tblPREmployeeEarning 
			LEFT JOIN tblPREmployee ON tblPREmployeeEarning.intEntityEmployeeId = tblPREmployee.intEntityId
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

/* 
   tblPRPayGroup.intBankAccountId NULL to NOT NULL 
   Attempts to update null tblPRPayGroup.intBankAccountId with values from logical sources
*/
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBankAccountId' AND OBJECT_ID = OBJECT_ID(N'tblPRPayGroup')) 
BEGIN

--Try to use the default bank account from payroll company configuration
EXEC('UPDATE tblPRPayGroup
		SET intBankAccountId = (SELECT TOP 1 intBankAccountId FROM tblPRCompanyPreference WHERE intBankAccountId IS NOT NULL)
		WHERE intBankAccountId IS NULL')

--Try to use top bank accounts from pay groups table
EXEC('UPDATE tblPRPayGroup
		SET intBankAccountId = (SELECT TOP 1 intBankAccountId FROM tblPRPayGroup WHERE intBankAccountId IS NOT NULL)
		WHERE intBankAccountId IS NULL')

--Try to use top bank account from the bank accounts table
EXEC('UPDATE tblPRPayGroup
		SET intBankAccountId = (SELECT TOP 1 intBankAccountId FROM tblCMBankAccount WHERE ysnActive = 1)
		WHERE intBankAccountId IS NULL')

END

GO
	PRINT 'END PR 1640'
GO