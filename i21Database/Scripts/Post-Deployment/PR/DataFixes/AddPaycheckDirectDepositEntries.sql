/*
* Adds corresponding entries to tblPRPaycheckDirectDeposit table  
* for all Direct Deposit Paychecks that are already posted
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[uspPRPaycheckEFTDistribution]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  
EXEC ('
DECLARE @intPaycheckId INT
WHILE EXISTS (SELECT TOP 1 1 FROM tblPRPaycheck WHERE ysnDirectDeposit = 1 
				AND ysnPosted = 1 AND intPaycheckId NOT IN (SELECT intPaycheckId FROM tblPRPaycheckDirectDeposit)
				AND intPaycheckId NOT IN (
					SELECT intPaycheckId FROM tblPRPaycheck WHERE intEntityEmployeeId IN (
						SELECT intEntityEmployeeId FROM tblPREmployee 
						WHERE intEntityEmployeeId NOT IN (SELECT DISTINCT intEntityId FROM tblEMEntityEFTInformation))))
BEGIN
	SELECT TOP 1 @intPaycheckId = intPaycheckId FROM tblPRPaycheck 
	WHERE ysnDirectDeposit = 1 AND ysnPosted = 1 
	AND intPaycheckId NOT IN (SELECT intPaycheckId FROM tblPRPaycheckDirectDeposit)
	AND intPaycheckId NOT IN (SELECT intPaycheckId FROM tblPRPaycheck 
								WHERE intEntityEmployeeId IN (SELECT intEntityEmployeeId FROM tblPREmployee 
															WHERE intEntityEmployeeId NOT IN (SELECT DISTINCT intEntityId FROM tblEMEntityEFTInformation)))

	EXEC uspPRPaycheckEFTDistribution @intPaycheckId
END
')

END