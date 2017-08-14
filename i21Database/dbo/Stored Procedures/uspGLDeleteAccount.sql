CREATE PROCEDURE [dbo].[uspGLDeleteAccount]
@intAccountId INT
AS
BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @intLegacyReferenceId INT  = 0
		DECLARE @strSQL NVARCHAR(500)
		SELECT @intLegacyReferenceId = intLegacyReferenceId  
		FROM tblGLCOACrossReference  WHERE inti21Id = @intAccountId 
		IF @intLegacyReferenceId > 0
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM sys.tables where tables.name = 'glactmst_bak')
			BEGIN
				DECLARE @ParmDefinition NVARCHAR(500)
				SET @strSQL = 'IF EXISTS (SELECT TOP 1 1 FROM glactmst a JOIN glactmst_bak b ON (CAST(a.glact_acct1_8 AS NVARCHAR(40)) + ''-'' + CAST( a.glact_acct9_16 AS NVARCHAR(40)))= (CAST(b.glact_acct1_8 AS NVARCHAR(40)) + ''-'' + CAST( b.glact_acct9_16 AS NVARCHAR(40))) WHERE a.A4GLIdentity=@id) THROW 51000, N''Origin Account cannot be deleted.'', 1'
				SET @ParmDefinition = N'@id INT'
				EXECUTE sp_executesql
				@strSQL,
				@ParmDefinition,
				@id= @intLegacyReferenceId
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