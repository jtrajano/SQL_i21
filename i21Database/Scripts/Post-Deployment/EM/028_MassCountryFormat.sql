PRINT '*** Start Mass update country format***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Mass update country format')
BEGIN
	PRINT '*** EXECUTE ***'

	 UPDATE tblSMCountry 
		set strCountryFormat = 'Space',
		strAreaCityFormat = 'Parentheses + Space',
		strLocalNumberFormat = '3 + Dash'		
		where strCountryCode = '1' and (strCountryFormat is null OR strCountryFormat = '' )

	  UPDATE tblSMCountry 
		set strCountryFormat = 'Dash',
		strAreaCityFormat = 'Dash',
		strLocalNumberFormat = '3 + Dash'		
	 where strCountryCode <> '1'  and (strCountryFormat is null OR strCountryFormat = '' )


	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Mass update country format', 1)
END
PRINT '*** End Mass update country format***'