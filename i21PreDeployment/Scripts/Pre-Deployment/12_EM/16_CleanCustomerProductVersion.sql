GO
PRINT 'Start Checking Customer Product Version'

IF OBJECT_ID('FK_tblARCustomerProductVersion_tblARCustomer') IS NULL
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerProductVersion' and [COLUMN_NAME] = 'intCustomerId')
	 AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'intEntityCustomerId')
	BEGIN
		PRINT 'CLEAN CUSTOMER PRODUCT VERSION'
		EXEC('UPDATE tblARCustomerProductVersion set intCustomerId = null where intCustomerId not in (select intEntityCustomerId from tblARCustomer)')
	END

	
END

PRINT 'End Checking Customer Product Version'
GO