CREATE PROCEDURE [dbo].[uspIPItemProcessAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@ErrMsg NVARCHAR(MAX)
		,@intItemAcknowledgementStageId int

	SELECT @intItemAcknowledgementStageId = MIN(intItemAcknowledgementStageId)
	FROM tblICItemAcknowledgementStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intItemAcknowledgementStageId > 0
	BEGIN
		SELECT @intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblICItemAcknowledgementStage
		WHERE intItemAcknowledgementStageId = @intItemAcknowledgementStageId

		EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
			,@referenceTransactionId = @intTransactionRefId
			,@referenceCompanyId = @intCompanyRefId

		Update tblICItemAcknowledgementStage
		Set strFeedStatus='Ack Processed'
		Where intItemAcknowledgementStageId = @intItemAcknowledgementStageId

		SELECT @intItemAcknowledgementStageId = MIN(intItemAcknowledgementStageId)
		FROM tblICItemAcknowledgementStage
		WHERE intItemAcknowledgementStageId > @intItemAcknowledgementStageId
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

