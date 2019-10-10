﻿CREATE PROCEDURE uspIPFutureMonthProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intFutureMonthId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intFutureMonthPreStageId INT
	DECLARE @tblRKFuturesMonthPreStage TABLE (intFutureMonthPreStageId INT)

	INSERT INTO @tblRKFuturesMonthPreStage (intFutureMonthPreStageId)
	SELECT intFutureMonthPreStageId
	FROM tblRKFuturesMonthPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutureMonthPreStageId = MIN(intFutureMonthPreStageId)
	FROM @tblRKFuturesMonthPreStage

	WHILE @intFutureMonthPreStageId IS NOT NULL
	BEGIN
		SELECT @intFutureMonthId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intFutureMonthId = intFutureMonthId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKFuturesMonthPreStage
		WHERE intFutureMonthPreStageId = @intFutureMonthPreStageId

		EXEC uspIPFutureMonthPopulateStgXML @intFutureMonthId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblRKFuturesMonthPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intFutureMonthPreStageId = @intFutureMonthPreStageId

		SELECT @intFutureMonthPreStageId = MIN(intFutureMonthPreStageId)
		FROM @tblRKFuturesMonthPreStage
		WHERE intFutureMonthPreStageId > @intFutureMonthPreStageId
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
