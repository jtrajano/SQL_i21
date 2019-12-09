CREATE PROCEDURE [dbo].[uspMFDemandProcessAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intDemandAcknowledgementStageId int

	SELECT @intDemandAcknowledgementStageId = MIN(intDemandAcknowledgementStageId)
	FROM tblMFDemandAcknowledgementStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intDemandAcknowledgementStageId > 0
	BEGIN
		SELECT @intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblMFDemandAcknowledgementStage
		WHERE intDemandAcknowledgementStageId = @intDemandAcknowledgementStageId

		EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
			,@referenceTransactionId = @intTransactionRefId
			,@referenceCompanyId = @intCompanyRefId

		SELECT @intDemandAcknowledgementStageId = MIN(intDemandAcknowledgementStageId)
		FROM tblMFDemandAcknowledgementStage
		WHERE intDemandAcknowledgementStageId > @intDemandAcknowledgementStageId
			AND strMessage = 'Success'
			AND ISNULL(strFeedStatus, '') = ''
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
