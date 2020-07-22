CREATE PROCEDURE dbo.uspIPProcessPreStageLoad
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intLoadPreStageId INT
		,@intLoadId INT
		,@strRowState NVARCHAR(50)
		,@intToCompanyLocationId INT
		,@intToBookId INT
		,@intToCompanyId INT
		,@intToEntityId INT
		,@strToTransactionType NVARCHAR(100)
	DECLARE @tblLGIntrCompLogisticsPreStg TABLE (
		intLoadPreStageId INT
		,intLoadId INT
		,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmFeedDate DATETIME
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strToTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intToCompanyId INT
		,intToCompanyLocationId INT
		,intToBookId INT
		)

	INSERT INTO @tblLGIntrCompLogisticsPreStg (
		intLoadPreStageId
		,intLoadId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		,strToTransactionType
		,intToCompanyId
		,intToCompanyLocationId
		,intToBookId
		)
	SELECT intLoadPreStageId
		,intLoadId
		,strFeedStatus
		,dtmFeedDate
		,strRowState
		,strToTransactionType
		,intToCompanyId
		,intToCompanyLocationId
		,intToBookId
	FROM dbo.tblLGIntrCompLogisticsPreStg
	WHERE strFeedStatus IS NULL

	SELECT @intLoadPreStageId = MIN(intLoadPreStageId)
	FROM @tblLGIntrCompLogisticsPreStg

	IF @intLoadPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblLGIntrCompLogisticsPreStg
	SET strFeedStatus = 'In-Progress'
	WHERE intLoadPreStageId IN (
			SELECT PS.intLoadPreStageId
			FROM @tblLGIntrCompLogisticsPreStg PS
			)

	WHILE @intLoadPreStageId IS NOT NULL
	BEGIN
		SELECT @intLoadId = NULL
			,@strRowState = NULL
			,@intToCompanyId = NULL
			,@strToTransactionType = NULL
			,@intToCompanyLocationId = NULL
			,@intToBookId = NULL

		SELECT @intLoadId = intLoadId
			,@strRowState = strRowState
			,@intToCompanyId = intToCompanyId
			,@strToTransactionType = strToTransactionType
			,@intToCompanyLocationId = intToCompanyLocationId
			,@intToBookId = intToBookId
		FROM @tblLGIntrCompLogisticsPreStg
		WHERE intLoadPreStageId = @intLoadPreStageId

		EXEC dbo.uspLGPopulateLoadXML @intLoadId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,@intToCompanyLocationId
			,@intToBookId
			,0

		UPDATE dbo.tblLGIntrCompLogisticsPreStg
		SET strFeedStatus = 'Processed'
		WHERE intLoadPreStageId = @intLoadPreStageId

		SELECT @intLoadPreStageId = MIN(intLoadPreStageId)
		FROM @tblLGIntrCompLogisticsPreStg
		WHERE intLoadPreStageId > @intLoadPreStageId
	END

	UPDATE tblLGIntrCompLogisticsPreStg
	SET strFeedStatus = NULL
	WHERE intLoadPreStageId IN (
			SELECT PS.intLoadPreStageId
			FROM @tblLGIntrCompLogisticsPreStg PS
			)
		AND strFeedStatus = 'In-Progress'
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
