﻿GO
print('/*******************  BEGIN INSERTING LANGUAGES *******************/')


IF NOT EXISTS (SELECT 1 FROM tblSMLanguage WHERE strLanguage = 'Spanish')
BEGIN
	INSERT INTO tblSMLanguage (strLanguage, ysnDefault, intConcurrencyId)
	VALUES ('Spanish', 0, 1)
END

print('/*******************  END INSERTING LANGUAGES  *******************/')

GO