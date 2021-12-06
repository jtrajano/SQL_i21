PRINT 'Checking tblICCategoryLocation for intRegisterDepartmentId'
IF(EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICCategoryLocation'  and [COLUMN_NAME] = 'intRegisterDepartmentId' ))
BEGIN
	PRINT 'EXECUTE'
	
	UPDATE tblICCategoryLocation SET strCashRegisterDepartment = CAST(intRegisterDepartmentId AS NVARCHAR)

	-- EXEC('
	-- 	ALTER TABLE tblICCategoryLocation
	-- 	DROP COLUMN intRegisterDepartmentId
	-- ')
END
PRINT 'Done checking tblICCategoryLocation for intRegisterDepartmentId'