GO
PRINT('/*******************  BEGIN UPDATING ADDON COMPONENTS *******************/')

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Multi-Language')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Multi-Language'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Transaction Traceability')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Transaction Traceability'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Report Hierarchy')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Report Hierarchy'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Automated Quoting')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Automated Quoting'
END

IF EXISTS (SELECT 1 FROM tblSMModule WHERE strModule = 'Power BI')
BEGIN
	UPDATE		tblSMModule
	SET			ysnAddonComponent = 1
	WHERE		strModule = 'Power BI'
END

PRINT('/*******************  END UPDATING ADDON COMPONENTS  *******************/')

GO