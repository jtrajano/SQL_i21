CREATE PROCEDURE [dbo].[uspFAAddGLAccountChangeLog]
	@intAssetId INT,
	@strChange NVARCHAR(255),
	@intEntityId INT = NULL,
	@intSuccessfulCount INT = 0 OUTPUT
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	INSERT INTO [dbo].[tblFAGLAccountChangeLog](intAssetId, dtmDate, strDescription, intEntityId)
	VALUES(@intAssetId, GETDATE(), @strChange, @intEntityId)

	SELECT @intSuccessfulCount = @@ROWCOUNT

