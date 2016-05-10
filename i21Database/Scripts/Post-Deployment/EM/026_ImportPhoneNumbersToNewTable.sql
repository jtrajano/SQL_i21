PRINT '*** Start Import phone to new table***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityPhoneNumber')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strCountryFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strAreaCityFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strLocalNumberFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'intCountryID')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strPhone')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intDefaultCountryId')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intEntityId')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Import phone to new table')
BEGIN
	PRINT '*** EXECUTE ***'

	EXEC('	insert into tblEMEntityPhoneNumber(strPhone, strFormatCountry, strFormatArea, strFormatLocal, intCountryId, intEntityId, strPhoneCountry)
				select 
					strCountryCode + strPhone, strCountryFormat, strAreaCityFormat, strLocalNumberFormat, intCountryID, intEntityId, strCountryCode
				from tblEMEntity a
					join tblSMCountry b
						on a.intDefaultCountryId = b.intCountryID
				where strPhone is not null and strPhone <> '''' and a.intDefaultCountryId is not null')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Import phone to new table', 1)
END
PRINT '*** End Import phone to new table***'