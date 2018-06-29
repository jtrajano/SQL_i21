CREATE PROCEDURE [dbo].[uspCTContractTransferAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	SELECT *
	FROM tblCTContractAcknowledgementStage
	WHERE ISNULL(strFeedStatus,'')='' --intMultiCompanyId = @intToCompanyId

	UPDATE tblCTContractAcknowledgementStage SET strFeedStatus='Ack Sent' WHERE ISNULL(strFeedStatus,'')='' --intMultiCompanyId = @intToCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH