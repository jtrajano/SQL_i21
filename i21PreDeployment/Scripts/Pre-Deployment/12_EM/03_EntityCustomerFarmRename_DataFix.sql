PRINT '*** Update Customer Farm Id ***'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerFarm' AND [COLUMN_NAME] = 'intCustomerId') 
	AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerFarm' AND [COLUMN_NAME] = 'intEntityCustomerId') 
BEGIN
	PRINT '*** Begin updating Customer Farm Id ***'
	EXEC('ALTER TABLE tblARCustomerFarm  add [intEntityCustomerId] INT NULL')
	EXEC('update tblARCustomerFarm  set intEntityCustomerId = intCustomerId')
END

PRINT '*** End Update Customer Farm Id ***'

