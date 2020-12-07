﻿CREATE PROCEDURE uspIPInterCompanyPreStageTest @intTestId INT
	,@strTestName NVARCHAR(50) = NULL
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMTestPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intTestId = @intTestId

	INSERT INTO tblQMTestPreStage (
		intTestId
		,strTestName
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intTestId
		,@strTestName
		,@strRowState
		,@intUserId
		,''
		,''
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
