CREATE PROCEDURE [dbo].[uspGLDeleteAccount]
@intAccountId INT
AS

DECLARE @intLegacyReferenceId INT  = 0
DECLARE @strSQL NVARCHAR(500)
SELECT @intLegacyReferenceId = intLegacyReferenceId  
FROM tblGLCOACrossReference  WHERE inti21Id = @intAccountId 
IF @intLegacyReferenceId > 0
BEGIN
	INSERT INTO tblGLDeletedAccount (
		intAccountGroupId, intAccountId, intAccountUnitId, intCurrencyExchangeRateTypeId,intCurrencyID, intEntityIdLastModified, strAccountId, strCashFlow, strComments, strDescription, strNote, ysnActive, ysnIsUsed, ysnRevalue,ysnSystem,intConcurrencyId)
	SELECT 
		intAccountGroupId, intAccountId, intAccountUnitId, intCurrencyExchangeRateTypeId, intCurrencyID, intEntityIdLastModified, strAccountId, strCashFlow, strComments, strDescription, strNote, ysnActive, ysnIsUsed, ysnRevalue,ysnSystem,intConcurrencyId
	FROM tblGLAccount WHERE intAccountId = @intAccountId

	IF EXISTS (SELECT TOP 1 1 FROM tblGLCOACrossReference WHERE intLegacyReferenceId = @intLegacyReferenceId AND ysnOrigin = 1)
	BEGIN
		DECLARE @strAccountId NVARCHAR(50)
		SELECT TOP 1 @strAccountId = strAccountId  FROM tblGLAccount WHERE intAccountId = @intAccountId 
		RAISERROR (60014, 11,1,@strAccountId);
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