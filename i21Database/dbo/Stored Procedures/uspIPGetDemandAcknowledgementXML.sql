CREATE PROCEDURE [dbo].[uspIPGetDemandAcknowledgementXML]
(@intCompanyId int)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblMFDemandAcknowledgementStage
	WHERE ISNULL(strFeedStatus, '') = ''
	AND intCompanyId=@intCompanyId

	UPDATE tblMFDemandAcknowledgementStage
	SET strFeedStatus = 'Ack Sent'
	WHERE ISNULL(strFeedStatus, '') = ''
	AND intCompanyId=@intCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH