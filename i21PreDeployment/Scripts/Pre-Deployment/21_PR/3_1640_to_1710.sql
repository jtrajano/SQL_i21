GO
	PRINT 'BEGIN PR 1710'
GO

/* 
   Adding referential constraints to tblPRTemplate details  
   Removing orphan records in tblPRTemplateEarning, tblPRTemplateDeduction, tblPRTemplateTimeOff
*/
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tblPRTemplateEarning'))
	EXEC('DELETE FROM tblPRTemplateEarning WHERE intTemplateId NOT IN (SELECT intTemplateId FROM tblPRTemplate)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tblPRTemplateDeduction'))
	EXEC('DELETE FROM tblPRTemplateDeduction WHERE intTemplateId NOT IN (SELECT intTemplateId FROM tblPRTemplate)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tblPRTemplateTimeOff'))
	EXEC('DELETE FROM tblPRTemplateTimeOff WHERE intTemplateId NOT IN (SELECT intTemplateId FROM tblPRTemplate)')

GO
	PRINT 'BEGIN PR 1710'
GO