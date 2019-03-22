PRINT '*** ----  Checking Fix Check Payee Name  ---- ***'

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Fix Check Payee Name')
BEGIN

PRINT '*** ----  Start Fix Check Payee Name  ---- ***'

	UPDATE tblEMEntityLocation SET strCheckPayeeName = strLocationName WHERE strCheckPayeeName IS NULL OR strCheckPayeeName = ''

INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Fix Check Payee Name', 1)

PRINT '*** ----  End Check Payee Name ---- ***'

END