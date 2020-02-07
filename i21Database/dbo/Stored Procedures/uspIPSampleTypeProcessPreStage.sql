﻿CREATE PROCEDURE uspIPSampleTypeProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intSampleTypeId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intSampleTypePreStageId INT
	DECLARE @tblQMSampleTypePreStage TABLE (intSampleTypePreStageId INT)

	INSERT INTO @tblQMSampleTypePreStage (intSampleTypePreStageId)
	SELECT intSampleTypePreStageId
	FROM tblQMSampleTypePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intSampleTypePreStageId = MIN(intSampleTypePreStageId)
	FROM @tblQMSampleTypePreStage

	WHILE @intSampleTypePreStageId IS NOT NULL
	BEGIN
		SELECT @intSampleTypeId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intSampleTypeId = intSampleTypeId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMSampleTypePreStage
		WHERE intSampleTypePreStageId = @intSampleTypePreStageId

		EXEC uspIPSampleTypePopulateStgXML @intSampleTypeId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMSampleTypePreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intSampleTypePreStageId = @intSampleTypePreStageId

		SELECT @intSampleTypePreStageId = MIN(intSampleTypePreStageId)
		FROM @tblQMSampleTypePreStage
		WHERE intSampleTypePreStageId > @intSampleTypePreStageId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
