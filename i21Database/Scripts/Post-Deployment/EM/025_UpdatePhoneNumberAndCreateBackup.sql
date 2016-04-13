PRINT '*** Start Update phone and create a backup***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strPhone')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'strPhoneBackUp')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update phone and create a backup')
BEGIN
	PRINT '*** EXECUTE ***'

	IF EXISTS( SELECT TOP 1 1 FROM sys.objects where name = 'extractnumerictemp')
	BEGIN
		EXEC ('DROP FUNCTION extractnumerictemp')
	END
	EXEC('
	CREATE Function [dbo].[extractnumerictemp](@Temp VarChar(1000))
	Returns VarChar(1000)
	AS
	Begin

		While PatIndex(''%[^0-9]%'', @Temp) > 0
			Set @Temp = Stuff(@Temp, PatIndex(''%[^0-9]%'', @Temp), 1, '''')

		Return @Temp
	End
	')

	if exists(select top 1 1 from sys.objects where name = 'extractnumerictemp')
	begin
		EXEC('UPDATE tblEMEntity set strPhoneBackUp = strPhone where strPhone is not null and strPhone <> ''''')
		EXEC('UPDATE tblEMEntity set strPhone = dbo.extractnumerictemp(strPhone) where strPhone is not null and strPhone <> ''''')

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry' AND [COLUMN_NAME] = 'strCountry')
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCountry' AND [COLUMN_NAME] = 'intCountryID')
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCompanyPreference' AND [COLUMN_NAME] = 'intDefaultCountryId')
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' AND [COLUMN_NAME] = 'intDefaultCountryId')
		BEGIN
			DECLARE @intDefaultCountryId INT
			SELECT TOP 1 @intDefaultCountryId = intDefaultCountryId from tblSMCompanyPreference
			if @intDefaultCountryId <= 0 or @intDefaultCountryId is null
			begin
				select top 1  @intDefaultCountryId = intCountryID  FROM tblSMCountry where strCountry = 'United States'
			end
			if @intDefaultCountryId > 0
			begin
				UPDATE tblEMEntity set intDefaultCountryId = @intDefaultCountryId where strPhone is not null and strPhone <> ''
			end 

		END
	end

	IF EXISTS( SELECT TOP 1 1 FROM sys.objects where name = 'extractnumerictemp')
	BEGIN
		EXEC ('DROP FUNCTION extractnumerictemp')
	END

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update phone and create a backup', 1)
END
PRINT '*** End Update phone and create a backup***'