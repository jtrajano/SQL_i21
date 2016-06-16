PRINT '*** Start Fill in Phone and Mobile***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Fill in Phone and Mobile')
BEGIN
	PRINT '*** EXECUTE ***'

	
	insert into tblEMEntityPhoneNumber(intEntityId, intCountryId)
	select intEntityContactId, null from tblEMEntityToContact where intEntityContactId not in ( select intEntityId from tblEMEntityPhoneNumber)

	insert into tblEMEntityMobileNumber(intEntityId, intCountryId)
	select intEntityContactId, null from tblEMEntityToContact where intEntityContactId not in ( select intEntityId from tblEMEntityMobileNumber)

	insert into tblEMEntityContactNumber(intContactDetailId, intCountryId)
	select intContactDetailId, null from tblEMContactDetail where intContactDetailId not in ( select intContactDetailId from tblEMEntityContactNumber)

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Fill in Phone and Mobile', 1)
END
PRINT '*** End Fill in Phone and Mobile***'