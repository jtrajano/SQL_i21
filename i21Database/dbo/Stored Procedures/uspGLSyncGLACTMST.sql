CREATE procedure uspGLSyncGLACTMST
@ysnActive BIT,
@ysnSystem BIT,
@intAccountId INT,
@strAccountId NVARCHAR(20),
@strDescription NVARCHAR(30),
@strDescriptionLookup NVARCHAR(8),
@strUnit NVARCHAR(20)
AS
IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	RAISERROR('Sync GLACTMST Procedure is not available', 16, 1);