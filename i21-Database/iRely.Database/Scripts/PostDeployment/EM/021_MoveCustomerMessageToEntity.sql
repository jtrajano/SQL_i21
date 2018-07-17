
PRINT '*** Start Move Customer Message To Entity***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityMessage' and [COLUMN_NAME] = 'intEntityId')	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerMessage' and [COLUMN_NAME] = 'intEntityCustomerId')	
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Move Customer Message To Entity')

BEGIN
	PRINT '*** EXECUTING  Move Customer Message To Entity***'
	Exec('
		INSERT INTO tblEMEntityMessage(intEntityId, strMessageType, strAction, strMessage, intConcurrencyId)
		select intEntityCustomerId, strMessageType, strAction, strMessage, intConcurrencyId 
			from tblARCustomerMessage where intEntityCustomerId in (select intEntityId from tblEMEntity)
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Move Customer Message To Entity', 1)

END
PRINT '*** End Move Customer Message To Entity***'