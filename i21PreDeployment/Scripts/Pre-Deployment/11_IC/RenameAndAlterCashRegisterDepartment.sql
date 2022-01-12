IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICCategoryLocation]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'strCashRegisterDepartment' AND OBJECT_ID = OBJECT_ID(N'tblICCategoryLocation')) 
    BEGIN
		EXEC('ALTER TABLE tblICCategoryLocation ADD strCashRegisterDepartment NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'strCashRegisterDepartment' AND OBJECT_ID = OBJECT_ID(N'tblICCategoryLocation')) 
    BEGIN
		EXEC('UPDATE tblICCategoryLocation SET strCashRegisterDepartment = CAST(intRegisterDepartmentId AS NVARCHAR)')

		EXEC('
			ALTER TABLE tblICCategoryLocation
			DROP COLUMN intRegisterDepartmentId
		')
    END
END