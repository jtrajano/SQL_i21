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

	SELECT @intLoadPreStageId = MIN(intLoadPreStageId)
	FROM dbo.tblLGIntrCompLogisticsPreStg
	WHERE strFeedStatus IS NULL

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
		FROM dbo.tblLGIntrCompLogisticsPreStg
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
		FROM dbo.tblLGIntrCompLogisticsPreStg
		WHERE strFeedStatus IS NULL
			AND intLoadPreStageId > @intLoadPreStageId
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
