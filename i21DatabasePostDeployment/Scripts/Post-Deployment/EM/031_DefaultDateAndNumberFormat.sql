PRINT '*** Start Default Date And Num Format***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Default Date And Num Format')
BEGIN
	PRINT '***Execute***'
	
	UPDATE tblSMUserSecurity set strDateFormat = 'M/d/yyyy' where strDateFormat is null or strDateFormat = ''	

	UPDATE tblSMUserSecurity set strNumberFormat = '1,234,567.89' where strNumberFormat is null or strNumberFormat = ''	

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Default Date And Num Format', 1)
END
PRINT '*** End Default Date And Num Format***'
