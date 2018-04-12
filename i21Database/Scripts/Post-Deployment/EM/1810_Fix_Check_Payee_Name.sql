PRINT '*** ----  Checking Fix Check Payee Name  ---- ***'

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Fix Check Payee Name')
BEGIN

PRINT '*** ----  Start Fix Check Payee Name  ---- ***'

	update tblEMEntityLocation set strCheckPayeeName = strLocationName where strCheckPayeeName is null

INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Fix Check Payee Name', 1)

PRINT '*** ----  End Check Payee Name ---- ***'

END