PRINT '*** Start Update UserSecurity Admins***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update UserSecurity Admins')
BEGIN
	PRINT '***Execute***'
	
	update a set a.ysnAdmin = 1
		from tblSMUserSecurity a
			join vyuEMUserAdmin b
				on a.[intEntityId] = b.[intEntityId]



	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update UserSecurity Admins', 1)
END
PRINT '*** End Update UserSecurity Admins***'
