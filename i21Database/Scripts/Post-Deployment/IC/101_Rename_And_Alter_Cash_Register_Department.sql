PRINT 'Checking tblICCategoryLocation for intRegisterDepartmentId'
GO
IF(EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICCategoryLocation'  and [COLUMN_NAME] = 'intRegisterDepartmentId' ))
BEGIN
	PRINT 'EXECUTE'
	GO
	
	UPDATE tblICCategoryLocation SET strCashRegisterDepartment = CAST(intRegisterDepartmentId AS NVARCHAR)
	GO

	-- EXEC('
	-- 	ALTER TABLE tblICCategoryLocation
	-- 	DROP COLUMN intRegisterDepartmentId
	-- ')
	-- GO
END
GO
PRINT 'Done checking tblICCategoryLocation for intRegisterDepartmentId'
GO