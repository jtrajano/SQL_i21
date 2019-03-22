GO
	PRINT ('*****Begin Setting Default Language*****')

	IF EXISTS(SELECT TOP 1 1 FROM tblSMLanguage WHERE strLanguage = 'English')
	BEGIN
		UPDATE t SET intLanguageId = (SELECT TOP 1 intLanguageId FROM tblSMLanguage WHERE strLanguage = 'English')
		FROM tblEMEntity t
		WHERE intLanguageId IS NULL
	END

	PRINT ('*****End Setting Default Language*****')
GO