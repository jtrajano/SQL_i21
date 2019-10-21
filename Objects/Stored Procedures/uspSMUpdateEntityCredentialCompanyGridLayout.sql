CREATE PROCEDURE [dbo].[uspSMUpdateEntityCredentialCompanyGridLayout]
AS
BEGIN
	DECLARE @intMaxCompanyGridLayoutConcurrencyId INT

	SELECT @intMaxCompanyGridLayoutConcurrencyId = MAX(intCompanyGridLayoutConcurrencyId) 
	FROM tblEMEntityCredential

	UPDATE tblEMEntityCredential SET intCompanyGridLayoutConcurrencyId = @intMaxCompanyGridLayoutConcurrencyId + 1
END