PRINT '*** Start Mass update phone number***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Mass update phone number')
BEGIN
	PRINT '*** EXECUTE ***'

	update 
		a set a.strPhone = b.strPhoneBackUp 
	from tblEMEntityPhoneNumber a
	join tblEMEntity b
		on a.intEntityId = b.intEntityId

	update a 
	set		a.strPhoneArea		= [dbo].[fnEMGetNumberFromString](b.strArea),
			a.strPhoneCountry	= [dbo].[fnEMGetNumberFromString](b.strCountry),
			a.strPhoneLocal		= [dbo].[fnEMGetNumberFromString](b.strLocal),
			a.strPhoneExtension = [dbo].[fnEMGetNumberFromString](b.strExtension),
			a.strPhoneLookUp	= [dbo].[fnEMGetNumberFromString](b.strPhone)
	from
	tblEMEntityPhoneNumber a
		cross apply dbo.fnEMPhoneConvert(a.strPhone, isnull(a.intCountryId, 1)) b



	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Mass update phone number', 1)
END
PRINT '*** End Mass update phone number***'