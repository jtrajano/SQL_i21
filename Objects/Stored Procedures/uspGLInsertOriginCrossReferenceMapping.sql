CREATE PROCEDURE dbo.[uspGLInsertOriginCrossReferenceMapping]
AS
IF EXISTS (SELECT TOP 1 1 FROM dbo.tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	RAISERROR( 'Insert Origin Cross Reference Mapping functionality is not available ', 16,1)

