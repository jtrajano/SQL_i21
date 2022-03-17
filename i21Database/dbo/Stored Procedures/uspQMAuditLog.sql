﻿CREATE PROCEDURE [dbo].[uspQMAuditLog]
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
			@intId	INT

	DECLARE @ids TABLE (intId INT)

	INSERT INTO @ids SELECT * FROM dbo.fnSplitStringWithTrim(@strIds,',') WHERE LTRIM(RTRIM(ISNULL(Item,''))) <> ''
	SELECT @intId = MIN(intId) FROM @ids

	WHILE ISNULL(@intId,0) > 0
	BEGIN
		IF @strScreenName = 'ContractManagement.view.Contract'
		BEGIN
			SELECT @intId = intSampleId
			FROM tblQMSample
			WHERE intContractDetailId = @intId

			SET @strScreenName = 'Quality.view.QualitySample'
		END

		EXEC	dbo.uspSMAuditLog
					 @keyValue = @intId				
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