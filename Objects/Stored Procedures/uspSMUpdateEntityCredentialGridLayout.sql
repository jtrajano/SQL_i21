CREATE PROCEDURE [dbo].[uspSMUpdateEntityCredentialGridLayout]
  @entityId INT
AS
BEGIN
	DECLARE @intMaxGridLayoutConcurrencyId INT

	SELECT @intMaxGridLayoutConcurrencyId = MAX(intGridLayoutConcurrencyId) 
	FROM tblEMEntityCredential
	WHERE intEntityId = @entityId

	UPDATE tblEMEntityCredential SET intGridLayoutConcurrencyId = @intMaxGridLayoutConcurrencyId + 1
	WHERE intEntityId = @entityId
 
END