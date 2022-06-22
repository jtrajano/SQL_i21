GO
PRINT('/*******************  BEGIN DELETING OLD POWER BI DATA *******************/')

IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ISNULL(strPowerBIAdminUsername, '') != '' AND ISNULL(strPowerBIAdminPassword, '') != '' AND
			ISNULL(strPowerBIClientId, '') = '' AND ISNULL(strPowerBIWorkspaceId, '') = '' AND ISNULL(strPowerBISecretId, '') = '' AND ISNULL(strPowerBITenantId, '') = '')
BEGIN
	DELETE FROM tblSMPowerBIUserRoleReport
	DELETE FROM tblSMPowerBIScheduleRunTime
	DELETE FROM tblSMPowerBIScheduleHistory
	DELETE FROM tblSMPowerBIDataset
	DELETE FROM tblSMPowerBIReport
END

PRINT('/*******************  END DELETING OLD POWER BI DATA *******************/')

GO