
PRINT '*** Start Updating Customer Pricing Level***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'intCompanyLocationPricingLevelId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'strLevel')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCompanyLocationPricingLevel' and [COLUMN_NAME] = 'intCompanyLocationPricingLevelId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCompanyLocationPricingLevel' and [COLUMN_NAME] = 'strPricingLevelName')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update ARCustomer Level')

BEGIN
	PRINT '*** EXECUTING Updating Customer Pricing Level***'
	Exec('
		update a set a.intCompanyLocationPricingLevelId = b.intCompanyLocationPricingLevelId from
		tblARCustomer  a
			JOIN tblSMCompanyLocationPricingLevel b
			on a.strLevel = b.strPricingLevelName
		where a.intCompanyLocationPricingLevelId is null
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update ARCustomer Level', 1)

END
PRINT '*** End Updating Customer Pricing Level***'

