GO
PRINT('/*******************  BEGIN UPDATING ADDON COMPONENTS *******************/')

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Language Translation')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Language Translation'
END

PRINT('/*******************  END UPDATING ADDON COMPONENTS  *******************/')

GO