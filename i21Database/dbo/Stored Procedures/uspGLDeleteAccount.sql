CREATE PROCEDURE [dbo].[uspGLDeleteAccount]
@intAccountId INT
AS

DECLARE @intLegacyReferenceId INT  = 0
DECLARE @strSQL NVARCHAR(500)
SELECT @intLegacyReferenceId = intLegacyReferenceId  
FROM tblGLCOACrossReference  WHERE inti21Id = @intAccountId 
IF @intLegacyReferenceId > 0
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblGLCOACrossReference WHERE intLegacyReferenceId = @intLegacyReferenceId AND ysnOrigin = 1)
	BEGIN
		RAISERROR('Origin Accounts are not allowed to be deleted.',16,1)
		RETURN
	END

	DELETE FROM tblGLCOACrossReference where intLegacyReferenceId = @intLegacyReferenceId
	IF EXISTS (SELECT TOP 1 1 FROM sys.tables where tables.name = 'glactmst')
	BEGIN
				
		SELECT @strSQL = 'DELETE FROM glactmst where A4GLIdentity = ' + CAST( @intLegacyReferenceId AS NVARCHAR(10))
		EXEC(@strSQL)
	END
END
DELETE FROM tblGLCrossReferenceMapping WHERE intAccountId = @intAccountId
DELETE FROM tblGLAccountSegmentMapping WHERE intAccountId = @intAccountId
DELETE FROM tblGLAccount where intAccountId = @intAccountId
	
