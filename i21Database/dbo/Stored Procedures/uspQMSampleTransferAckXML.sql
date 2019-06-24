CREATE PROCEDURE [dbo].[uspQMSampleTransferAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblQMSampleAcknowledgementStage
	WHERE ISNULL(strFeedStatus, '') = '' --intMultiCompanyId = @intToCompanyId

	UPDATE tblQMSampleAcknowledgementStage
	SET strFeedStatus = 'Ack Sent'
	WHERE ISNULL(strFeedStatus, '') = '' --intMultiCompanyId = @intToCompanyId
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
