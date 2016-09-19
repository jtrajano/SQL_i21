GO
	PRINT 'BEGIN PR 1630'
GO

/* Clean-up tblPRPaycheckEarning.intEmployeeDepartmentId */
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEmployeeDepartmentId' AND OBJECT_ID = OBJECT_ID(N'tblPRPaycheckEarning')) 
BEGIN
    UPDATE tblPRPaycheckEarning SET intEmployeeDepartmentId = NULL 
	WHERE intEmployeeDepartmentId NOT IN (SELECT intDepartmentId FROM tblPRDepartment) AND intEmployeeDepartmentId IS NOT NULL
END
GO

/* Clean-up tblPRPayGroupDetail.intDepartmentId */
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDepartmentId' AND OBJECT_ID = OBJECT_ID(N'tblPRPayGroupDetail')) 
BEGIN
    UPDATE tblPRPayGroupDetail SET intDepartmentId = NULL 
	WHERE intDepartmentId NOT IN (SELECT intDepartmentId FROM tblPRDepartment) AND intEmployeeDepartmentId IS NOT NULL
END
GO

GO
	PRINT 'END PR 1630'
GO

