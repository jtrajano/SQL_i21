
PRINT '*** Start Updating Tariff Type***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityTariffType' and [COLUMN_NAME] = 'strTariffType')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityTariffType' and [COLUMN_NAME] = 'intEntityTariffTypeId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityTariff' and [COLUMN_NAME] = 'strDescription')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityTariff' and [COLUMN_NAME] = 'intEntityTariffTypeId')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update Tariff Type')

BEGIN
	PRINT '*** EXECUTING Updating Tariff Type***'
	Exec('
		INSERT INTO tblEMEntityTariffType(strTariffType)
		select distinct strDescription from tblEMEntityTariff where strDescription not in (select strTariffType from tblEMEntityTariffType)

		UPDATE a set a.intEntityTariffTypeId = b.intEntityTariffTypeId 
			from tblEMEntityTariff a
				join tblEMEntityTariffType b
					on a.strDescription = b.strTariffType
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update Tariff Type', 1)

END
PRINT '*** End Updating Tariff Type***'



