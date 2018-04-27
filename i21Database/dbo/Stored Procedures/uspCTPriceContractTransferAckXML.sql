CREATE PROCEDURE [dbo].[uspCTPriceContractTransferAckXML]
	@param1 int = 0,
	@param2 int
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	SELECT *
	FROM tblCTPriceContractAcknowledgementStage
	WHERE ISNULL(strFeedStatus,'')='' --intMultiCompanyId = @intToCompanyId

	UPDATE tblCTPriceContractAcknowledgementStage SET strFeedStatus='Ack Sent' WHERE ISNULL(strFeedStatus,'')='' --intMultiCompanyId = @intToCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
