GO
PRINT('/*******************  BEGIN UPDATING ADDON COMPONENTS *******************/')

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Language Translation')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Language Translation'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Sub Ledger Traceability')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Sub Ledger Traceability'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Report Hierarchy')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Report Hierarchy'
END

PRINT('/*******************  END UPDATING ADDON COMPONENTS  *******************/')

GO