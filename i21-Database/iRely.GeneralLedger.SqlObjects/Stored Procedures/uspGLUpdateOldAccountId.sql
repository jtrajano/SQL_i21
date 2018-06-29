CREATE PROCEDURE [dbo].[uspGLUpdateOldAccountId]
@intAccountSystemId INT
AS
BEGIN
	UPDATE account 
	SET strOldAccountId = mapping.strOldAccountId 
	FROM tblGLAccount account join tblGLCrossReferenceMapping mapping
	ON account.intAccountId = mapping.intAccountId
	WHERE intAccountSystemId = @intAccountSystemId
END