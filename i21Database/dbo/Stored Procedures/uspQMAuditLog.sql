CREATE PROCEDURE [dbo].[uspQMAuditLog]
	@strIds				NVARCHAR(MAX),
	@strScreenName		NVARCHAR(100),
	@intEntityId		INT,
	@strActionType		NVARCHAR(100),
	@strDescription		NVARCHAR(MAX) = '',
	@strFromValue		NVARCHAR(MAX) = '',
	@strToValue			NVARCHAR(MAX) = ''
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX),
			@intId	INT,
			@intKey	INT

	DECLARE @ids TABLE (intId INT)

	INSERT INTO @ids SELECT * FROM dbo.fnSplitStringWithTrim(@strIds,',') WHERE LTRIM(RTRIM(ISNULL(Item,''))) <> ''
	SELECT @intId = MIN(intId) FROM @ids

	WHILE ISNULL(@intId,0) > 0
	BEGIN
		IF @strActionType = 'Sample Instruction'
		BEGIN
			SELECT @intKey = intSampleId
			FROM tblQMSample
			WHERE intContractDetailId = @intId
		END
		ELSE
		BEGIN
			SET @intKey = @intId
		END

		EXEC	dbo.uspSMAuditLog
					 @keyValue = @intKey				
					,@screenName = @strScreenName   
					,@entityId = @intEntityId		
					,@actionType = @strActionType          
					,@changeDescription = @strDescription		
					,@fromValue = @strFromValue
					,@toValue = @strToValue

		DELETE FROM @ids WHERE intId = @intId 
		SELECT @intId = MIN(intId) FROM @ids
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH