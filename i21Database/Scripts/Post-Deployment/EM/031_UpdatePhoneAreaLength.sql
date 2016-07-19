PRINT '*** Start Update Phone Area Length***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update Phone Area Length')
BEGIN
	PRINT '***Execute***'
	
	UPDATE  a set intAreaCityLength = b.intAreaCityLength
	from tblEMEntityPhoneNumber a
		join tblSMCountry b
			on a.intCountryId = b.intCountryID 

	UPDATE  a set intAreaCityLength = b.intAreaCityLength
	from tblEMEntityMobileNumber a
		join tblSMCountry b
			on a.intCountryId = b.intCountryID 


	UPDATE  a set intAreaCityLength = b.intAreaCityLength
	from tblEMEntityContactNumber a
		join tblSMCountry b
			on a.intCountryId = b.intCountryID 

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update Phone Area Length', 1)
END
PRINT '*** End Update Phone Area Length***'
