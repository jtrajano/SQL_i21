CREATE PROCEDURE [dbo].[uspIPGetItemAcknowledgementXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblICItemAcknowledgementStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblICItemAcknowledgementStage
	SET strFeedStatus = 'Ack Sent'
	WHERE ISNULL(strFeedStatus, '') = ''
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
