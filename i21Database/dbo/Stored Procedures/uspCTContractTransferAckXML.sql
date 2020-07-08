CREATE PROCEDURE [dbo].[uspCTContractTransferAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	SELECT *
	FROM tblCTContractAcknowledgementStage
	WHERE strFeedStatus IS NULL --intMultiCompanyId = @intToCompanyId

	UPDATE tblCTContractAcknowledgementStage SET strFeedStatus='Ack Sent' WHERE strFeedStatus IS NULL --intMultiCompanyId = @intToCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH