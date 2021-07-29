GO
PRINT('/*******************  BEGIN UPDATING ADDON COMPONENTS *******************/')

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Language Translation')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1, strModule = 'Multi-Language'
	WHERE		strModule = 'Language Translation'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Transaction Traceability')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Transaction Traceability'
END

PRINT('/*******************  END UPDATING ADDON COMPONENTS  *******************/')

GO