CREATE PROCEDURE [dbo].[uspFADeleteImportedAssets]
	@intCount INT = 0 OUTPUT
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION;
	
	DELETE tblFAFixedAsset
	WHERE 
		ISNULL(ysnImported, 0) = 1
		AND ISNULL(ysnAcquired, 0) = 0
		AND ISNULL(ysnDepreciated, 0) = 0
		AND ISNULL(ysnDisposed, 0) = 0

	SELECT @intCount = @@ROWCOUNT;

	IF @@ERROR <> 0	GOTO Post_Rollback;
	ELSE GOTO Post_Commit;

	Post_Commit:
		COMMIT TRANSACTION
		GOTO Post_Exit

	Post_Rollback:
		ROLLBACK TRANSACTION	
		SET @intCount = 0
		GOTO Post_Exit

	Post_Exit:
