CREATE procedure uspGLSyncGLACTMST
@intAccountId INT
AS
IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	RAISERROR('Sync GLACTMST Procedure is not available', 16, 1);