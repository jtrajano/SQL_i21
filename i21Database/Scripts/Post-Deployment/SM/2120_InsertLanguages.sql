GO
print('/*******************  BEGIN INSERTING LANGUAGES *******************/')


IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Español')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Español', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Deutsch')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Deutsch', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Português')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Português', 0, 1)
END


IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Français')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Français', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Русский')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Русский', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = '㗂越')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('㗂越', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Bahasa Indonesia')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Bahasa Indonesia', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Polski')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Polski', 0, 1)
END

IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Italiano')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Italiano', 0, 1)
END

print('/*******************  END INSERTING LANGUAGES  *******************/')

GO