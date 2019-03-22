PRINT '*** ----  Checking Default Location Payee Name  ---- ***'

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Default Location Payee Name')
BEGIN

PRINT '*** ----  Start Default Location Payee Name  ---- ***'

	update tblEMEntityLocation set strCheckPayeeName = strLocationName

INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Default Location Payee Name', 1)

PRINT '*** ----  End Default Location Payee Name ---- ***'

END