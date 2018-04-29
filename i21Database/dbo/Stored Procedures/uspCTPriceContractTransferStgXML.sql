CREATE PROCEDURE [dbo].[uspCTPriceContractTransferStgXML]
	@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblCTPriceContractStage
	WHERE intMultiCompanyId = @intToCompanyId AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblCTPriceContractStage SET strFeedStatus='Awt Ack' WHERE intMultiCompanyId = @intToCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH