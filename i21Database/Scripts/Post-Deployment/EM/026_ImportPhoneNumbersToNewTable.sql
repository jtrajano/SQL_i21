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
					strCountryCode + '' '' + strPhone, strCountryFormat, strAreaCityFormat, strLocalNumberFormat, intCountryID, intEntityId, strCountryCode
				from tblEMEntity a
					join tblSMCountry b
						on a.intDefaultCountryId = b.intCountryID
				where strPhone is not null and strPhone <> '''' and a.intDefaultCountryId is not null')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Import phone to new table', 1)
END
PRINT '*** End Import phone to new table***'









PRINT '*** Start Import mobile to new table***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityMobileNumber')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strCountryFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strAreaCityFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strLocalNumberFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'intCountryID')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strMobile')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intDefaultCountryId')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intEntityId')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Import mobile to new table')
BEGIN
	PRINT '*** EXECUTE ***'

	EXEC('	insert into tblEMEntityMobileNumber(strPhone, strFormatCountry, strFormatArea, strFormatLocal, intCountryId, intEntityId, strPhoneCountry)
				select 
					strCountryCode + '' '' + strMobile, strCountryFormat, strAreaCityFormat, strLocalNumberFormat, intCountryID, intEntityId, strCountryCode
				from tblEMEntity a
					join tblSMCountry b
						on a.intDefaultCountryId = b.intCountryID
				where strMobile is not null and strMobile <> '''' and a.intDefaultCountryId is not null')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Import mobile to new table', 1)
END
PRINT '*** End Import mobile to new table***'



PRINT '*** Start Import contact phone to new table***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityContactNumber')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strCountryFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strAreaCityFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'strLocalNumberFormat')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry'  AND [COLUMN_NAME] = 'intCountryID')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strMobile')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intDefaultCountryId')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intEntityId')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetail' AND [COLUMN_NAME] = 'strValue')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetail' AND [COLUMN_NAME] = 'intContactDetailId')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetail' AND [COLUMN_NAME] = 'intContactDetailTypeId')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetailType' AND [COLUMN_NAME] = 'strType')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetailType' AND [COLUMN_NAME] = 'intContactDetailTypeId')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Import contact phone to new table')
BEGIN
	PRINT '*** EXECUTE ***'

	EXEC('	insert into tblEMEntityContactNumber(strPhone, strFormatCountry, strFormatArea, strFormatLocal, intCountryId, intContactDetailId, strPhoneCountry)
				select 
				strCountryCode + '' '' + a.strValue, strCountryFormat, strAreaCityFormat, strLocalNumberFormat, intCountryID, a.intContactDetailId, strCountryCode
					from tblEMContactDetail a
				join tblEMContactDetailType b
					on a.intContactDetailTypeId = b.intContactDetailTypeId
				join tblEMEntity c
					on a.intEntityId = c.intEntityId
				join tblSMCountry d
					on c.intDefaultCountryId = d.intCountryID
				where strType = ''Phone'' and strValue is not null and strValue <> '''' and c.intDefaultCountryId is not null ')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Import contact phone to new table', 1)
END
PRINT '*** End Import contact phone to new table***'