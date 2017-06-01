CREATE PROCEDURE [dbo].[uspGLDeleteAccount]
@intAccountId INT
AS
BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @intLegacyReferenceId INT  = 0
		SELECT @intLegacyReferenceId = intLegacyReferenceId  
		FROM tblGLCOACrossReference  WHERE inti21Id = @intAccountId 
			AND ISNULL(ysnOrigin,0) = 0
		IF @intLegacyReferenceId > 0
		BEGIN
			DELETE FROM tblGLCOACrossReference where intLegacyReferenceId = @intLegacyReferenceId
			IF EXISTS (SELECT TOP 1 1 FROM sys.tables where tables.name = 'glactmst')
				DELETE FROM glactmst where A4GLIdentity = @intLegacyReferenceId 
			DELETE FROM tblGLCrossReferenceMapping WHERE intAccountId = @intAccountId
			DELETE FROM tblGLAccountSegmentMapping WHERE intAccountId = @intAccountId
			DELETE FROM tblGLAccount where intAccountId = @intAccountId
		END
	IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  
	SELECT   
	@ErrorMessage = ERROR_MESSAGE(),  
	@ErrorSeverity = ERROR_SEVERITY(),  
	@ErrorState = ERROR_STATE();  
	RAISERROR (@ErrorMessage, -- Message text.  
	@ErrorSeverity, -- Severity.  
	@ErrorState -- State.  
	);  
END CATCH