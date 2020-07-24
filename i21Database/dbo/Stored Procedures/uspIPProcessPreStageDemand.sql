CREATE PROCEDURE uspIPProcessPreStageDemand
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intDemandPreStageId INT
		,@intInvPlngReportMasterID INT
		,@strRowState NVARCHAR(50)
	DECLARE @tblMFDemandPreStage TABLE (
		intDemandPreStageId INT
		,intInvPlngReportMasterID INT
		,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmFeedDate DATETIME
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblMFDemandPreStage (
		intDemandPreStageId
		,intInvPlngReportMasterID
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		)
	SELECT intDemandPreStageId
		,intInvPlngReportMasterID
		,strFeedStatus
		,dtmFeedDate
		,strRowState
	FROM tblMFDemandPreStage
	WHERE strFeedStatus IS NULL

	SELECT @intDemandPreStageId = MIN(intDemandPreStageId)
	FROM @tblMFDemandPreStage

	IF @intDemandPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET strFeedStatus = 'In-Progress'
	FROM tblMFDemandPreStage S
	JOIN @tblMFDemandPreStage PS ON PS.intDemandPreStageId = S.intDemandPreStageId

	WHILE @intDemandPreStageId IS NOT NULL
	BEGIN
		SELECT @intInvPlngReportMasterID = NULL
			,@strRowState = NULL

		SELECT @intInvPlngReportMasterID = intInvPlngReportMasterID
			,@strRowState = strRowState
		FROM @tblMFDemandPreStage
		WHERE intDemandPreStageId = @intDemandPreStageId

		EXEC uspMFDemandPopulateStgXML @intInvPlngReportMasterID
			,@strRowState

		UPDATE tblMFDemandPreStage
		SET strFeedStatus = 'Processed'
		WHERE intDemandPreStageId = @intDemandPreStageId

		SELECT @intDemandPreStageId = MIN(intDemandPreStageId)
		FROM @tblMFDemandPreStage
		WHERE intDemandPreStageId > @intDemandPreStageId
	END

	UPDATE S
	SET S.strFeedStatus = NULL
	FROM tblMFDemandPreStage S
	JOIN @tblMFDemandPreStage PS ON PS.intDemandPreStageId = S.intDemandPreStageId
	WHERE S.strFeedStatus = 'In-Progress'
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
