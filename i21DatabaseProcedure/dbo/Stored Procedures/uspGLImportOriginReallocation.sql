CREATE PROCEDURE [dbo].[uspGLImportOriginReallocation]
AS
IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	RAISERROR('Import Reallocation Procedure is not available', 16, 1);
