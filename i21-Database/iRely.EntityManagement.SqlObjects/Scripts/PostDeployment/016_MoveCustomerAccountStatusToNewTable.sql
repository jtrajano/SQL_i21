
PRINT '*** Start Moving Customer Account Status***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerAccountStatus' and [COLUMN_NAME] = 'intEntityCustomerId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerAccountStatus' and [COLUMN_NAME] = 'intAccountStatusId')
	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'intEntityCustomerId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'intAccountStatusId')

	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARAccountStatus' and [COLUMN_NAME] = 'intAccountStatusId')

	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Moving Customer Account Status')

BEGIN
	PRINT '*** EXECUTING  Moving Customer Account Status***'
	Exec('
			insert into tblARCustomerAccountStatus(intEntityCustomerId, intAccountStatusId)
			select intEntityCustomerId, a.intAccountStatusId from tblARCustomer a
				join tblARAccountStatus b
					on a.intAccountStatusId = b.intAccountStatusId
				where a.intEntityCustomerId not in ( select intEntityCustomerId from tblARCustomerAccountStatus)	
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Moving Customer Account Status', 1)

END
PRINT '*** End Moving Customer Account Status***'



