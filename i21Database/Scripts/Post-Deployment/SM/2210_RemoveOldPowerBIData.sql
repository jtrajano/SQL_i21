GO
PRINT('/*******************  BEGIN DELETING POWER BI DATA USER CREDENTIAL *******************/')

IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ISNULL(strPowerBIAdminUsername, '') != '' AND ISNULL(strPowerBIAdminPassword, '') != '' AND
			ISNULL(strPowerBIClientId, '') = '' AND ISNULL(strPowerBIWorkspaceId, '') = '' AND ISNULL(strPowerBISecretId, '') = '' AND ISNULL(strPowerBITenantId, '') = '')
BEGIN
	DELETE FROM tblSMPowerBIUserRoleReport
	DELETE FROM tblSMPowerBIScheduleRunTime
	DELETE FROM tblSMPowerBIScheduleHistory
	DELETE FROM tblSMPowerBIDataset
	DELETE FROM tblSMPowerBIReport

	UPDATE tblSMCompanyPreference set strPowerBIAdminUsername = NULL, strPowerBIAdminPassword = NULL
END

PRINT('/*******************  END DELETING POWER BI DATA USER CREDENTIAL  *******************/')



--PRINT('/*******************  BEGIN UPDATING POWER BI EMPTY SCHEDULE *******************/')
--IF EXISTS(SELECT TOP 1 1 FROM tblSMPowerBIDataset WHERE ISNULL(dtmNextRefresh, '') = '')
--BEGIN
--	UPDATE tblSMPowerBIDataset SET strFrequency = 'None'
--	WHERE ISNULL(dtmNextRefresh, '') = ''
--END
--PRINT('/*******************  END UPDATING POWER BI EMPTY SCHEDULE *******************/')


PRINT('/*******************  BEGIN UPDATING POWER BI DEFAULT DATA *******************/')
IF EXISTS(SELECT TOP 1 1 FROM tblSMPowerBIDataset WHERE ISNULL(dtmNextRefresh, '') = '')
BEGIN
	UPDATE tblSMPowerBIDataset SET strFrequency = 'None'
	WHERE ISNULL(dtmNextRefresh, '') = ''
END

IF EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnPowerBIProfilePipeline = NULL)
BEGIN
	UPDATE tblSMCompanyPreference SET ysnPowerBIProfilePipeline = 1
END


--INSERT NEW LINE HERE


PRINT('/*******************  END UPDATING POWER BI DEFAULT DATA *******************/')

GO