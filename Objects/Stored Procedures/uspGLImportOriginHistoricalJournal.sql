CREATE PROCEDURE  [dbo].[uspGLImportOriginHistoricalJournal]
@intEntityId		INT
AS
IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	RAISERROR('Import Historical Procedure is not available', 16, 1);