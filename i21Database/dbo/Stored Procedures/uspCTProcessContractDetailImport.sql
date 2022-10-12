CREATE PROCEDURE [dbo].[uspCTProcessContractDetailImport]
	@intUserId INT,
	@strFileName NVARCHAR(100),
	@guiUniqueId UNIQUEIDENTIFIER
AS

BEGIN

	INSERT INTO tblCTContractDetailImportHeader(intUserId, dtmImportDate, guiUniqueId, strFileName)
	SELECT @intUserId, GETDATE(), @guiUniqueId, @strFileName

	DECLARE @intContractDetailImportHeaderId INT

	SET @intContractDetailImportHeaderId = SCOPE_IDENTITY()

	IF ISNULL(@intContractDetailImportHeaderId, 0) = 0
	BEGIN
		UPDATE tblCTContractDetailImport
		SET intContractDetailImportHeaderId = @intContractDetailImportHeaderId
		WHERE guiUniqueId = @guiUniqueId


	END
END 