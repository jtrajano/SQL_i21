GO
print('/*******************  BEGIN INSERTING LANGUAGES *******************/')


IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Spain')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Español'
	WHERE strLanguage = 'Spain'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Español')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Español', 0, 1)
END

IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'German')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Deutsch'
	WHERE strLanguage = 'German'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Deutsch')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Deutsch', 0, 1)
END

IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Portuguese')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Português'
	WHERE strLanguage = 'Portuguese'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Português')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Português', 0, 1)
END

IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'French')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Français'
	WHERE strLanguage = 'French'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Français')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Français', 0, 1)
END


IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Russian')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = N'Русский'
	WHERE strLanguage = 'Russian'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = N'Русский')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES (N'Русский', 0, 1)
END

IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Vietnamese')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = N'㗂越'
	WHERE strLanguage = 'Vietnamese'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = N'㗂越')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES (N'㗂越', 0, 1)
END

IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Indonesian')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Bahasa Indonesia'
	WHERE strLanguage = 'Indonesian'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Bahasa Indonesia')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Bahasa Indonesia', 0, 1)
END

IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Polish')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Polski'
	WHERE strLanguage = 'Polish'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Polski')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Polski', 0, 1)
END


IF EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Italian')
BEGIN
	UPDATE tblSMLanguage
	SET strLanguage = 'Italiano'
	WHERE strLanguage = 'Italian'
END
ELSE IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Italiano')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Italiano', 0, 1)
END

UPDATE tblSMUserSecurity
SET intLanguageId = (SELECT TOP 1 intLanguageId FROM tblSMLanguage WHERE strLanguage = 'English')
WHERE ISNULL(intLanguageId, 0) = 0

print('/*******************  END INSERTING LANGUAGES  *******************/')

GO