PRINT '*** Cleaning Phone Number***'
IF (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intCountryId' and object_id = OBJECT_ID(N'tblEMEntityPhoneNumber')))
	AND (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intCountryID' and object_id = OBJECT_ID(N'tblSMCountry')))
BEGIN

	EXEC('
		update tblEMEntityPhoneNumber set intCountryId = null  where intCountryId not in (select intCountryID from tblSMCountry)
	')

END

PRINT '*** Cleaning Phone Number***'


PRINT '*** Cleaning Mobile Number***'
IF (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intCountryId' and object_id = OBJECT_ID(N'tblEMEntityMobileNumber')))
	AND (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intCountryID' and object_id = OBJECT_ID(N'tblSMCountry')))
BEGIN

	EXEC('
		update tblEMEntityMobileNumber set intCountryId = null  where intCountryId not in (select intCountryID from tblSMCountry)
	')

END

PRINT '*** Cleaning Mobile Number***'


PRINT '*** Cleaning Contact Number***'
IF (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intCountryId' and object_id = OBJECT_ID(N'tblEMEntityContactNumber')))
	AND (EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intCountryID' and object_id = OBJECT_ID(N'tblSMCountry')))
BEGIN

	EXEC('
		update tblEMEntityContactNumber set intCountryId = null  where intCountryId not in (select intCountryID from tblSMCountry)
	')

END

PRINT '*** Cleaning Contact Number***'



