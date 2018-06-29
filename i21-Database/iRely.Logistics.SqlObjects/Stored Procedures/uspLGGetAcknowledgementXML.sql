CREATE PROCEDURE [dbo].[uspLGGetAcknowledgementXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblLGIntrCompLogisticsAck
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblLGIntrCompLogisticsAck
	SET strFeedStatus = 'Ack Sent'
	WHERE ISNULL(strFeedStatus, '') = ''
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH