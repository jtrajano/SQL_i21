CREATE PROCEDURE uspIPInterCompanyPreStageSettlementPrice @intFutureSettlementPriceId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKFuturesSettlementPricePreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intFutureSettlementPriceId = @intFutureSettlementPriceId

	INSERT INTO tblRKFuturesSettlementPricePreStage (
		intFutureSettlementPriceId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intFutureSettlementPriceId
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
