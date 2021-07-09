GO
print('/*******************  BEGIN INSERTING LANGUAGES *******************/')


IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Spanish')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Spanish', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'German')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('German', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Portuguese')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Portuguese', 0, 1)
END


IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'French')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('French', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Russian')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Russian', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Vietnamese')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Vietnamese', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Indonesian')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Indonesian', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Polish')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Polish', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Italian')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Italian', 0, 1)
END

print('/*******************  END INSERTING LANGUAGES  *******************/')

GO