CREATE PROCEDURE [dbo].[uspIPGetDemandAcknowledgementXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblMFDemandAcknowledgementStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblMFDemandAcknowledgementStage
	SET strFeedStatus = 'Ack Sent'
	WHERE ISNULL(strFeedStatus, '') = ''
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH