GO
	PRINT ('*****Begin Activating Default Contact*****')

	UPDATE t SET ysnActive = 1
	FROM tblEMEntity t
	WHERE ysnActive = 0
	AND intEntityId IN (SELECT intEntityContactId FROM tblEMEntityToContact WHERE ysnDefaultContact = 1)

	PRINT ('*****End Activating Default Contact*****')
GO