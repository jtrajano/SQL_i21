CREATE PROCEDURE [dbo].[uspGLUpdateOldAccountId]
@intAccountSystemId INT 
AS
BEGIN
	IF @intAccountSystemId = 0
		UPDATE tblGLAccount set strOldAccountId = ''
	ELSE
		UPDATE account 
		SET strOldAccountId = mapping.strOldAccountId 
		FROM tblGLAccount account join tblGLCrossReferenceMapping mapping
		ON account.intAccountId = mapping.intAccountId
		WHERE intAccountSystemId = @intAccountSystemId
END