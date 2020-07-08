CREATE PROCEDURE [dbo].[uspMFDemandProcessAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intDemandAcknowledgementStageId INT
		,@intInvPlngReportMasterRefId INT
		,@intInvPlngReportMasterId INT

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
			,@intInvPlngReportMasterRefId = NULL
			,@intInvPlngReportMasterId = NULL

		SELECT @intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
			,@intInvPlngReportMasterRefId = intInvPlngReportMasterRefId
			,@intInvPlngReportMasterId = intInvPlngReportMasterId
		FROM tblMFDemandAcknowledgementStage
		WHERE intDemandAcknowledgementStageId = @intDemandAcknowledgementStageId

		Update tblMFDemandAcknowledgementStage
		Set strFeedStatus='Ack Processed'
		Where intDemandAcknowledgementStageId = @intDemandAcknowledgementStageId

		UPDATE tblCTInvPlngReportMaster
		SET intInvPlngReportMasterRefID = @intInvPlngReportMasterId
		WHERE intInvPlngReportMasterID = @intInvPlngReportMasterRefId
			AND intInvPlngReportMasterRefID IS NULL

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
