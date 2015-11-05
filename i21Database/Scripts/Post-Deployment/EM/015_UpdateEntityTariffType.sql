
PRINT '*** Start Updating Tariff Type***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityTariffType' and [COLUMN_NAME] = 'strTariffType')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityTariffType' and [COLUMN_NAME] = 'intEntityTariffTypeId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityTariff' and [COLUMN_NAME] = 'strDescription')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityTariff' and [COLUMN_NAME] = 'intEntityTariffTypeId')
	AND NOT EXISTS(SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Update Tariff Type')

BEGIN
	PRINT '*** EXECUTING Updating Tariff Type***'
	Exec('
		INSERT INTO tblEntityTariffType(strTariffType)
		select distinct strDescription from tblEntityTariff where strDescription not in (select strTariffType from tblEntityTariffType)

		UPDATE a set a.intEntityTariffTypeId = b.intEntityTariffTypeId 
			from tblEntityTariff a
				join tblEntityTariffType b
					on a.strDescription = b.strTariffType
	')

	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Update Tariff Type', 1)

END
PRINT '*** End Updating Tariff Type***'



