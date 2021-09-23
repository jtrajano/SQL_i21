PRINT '********************** BEGIN - CHECK FOR MISSING COLUMNS IN tblARCustomer **********************'
GO

IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer'
	AND COLUMN_NAME = N'intInterCompanyId'))
	BEGIN
		ALTER TABLE tblARCustomer ADD intInterCompanyId INT NULL;
	END

PRINT ' ********************** END - CHECK FOR MISSING COLUMNS IN tblARCustomer  **********************'
GO