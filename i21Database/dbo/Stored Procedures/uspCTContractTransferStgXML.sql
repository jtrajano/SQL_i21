CREATE PROCEDURE [dbo].[uspCTContractTransferStgXML]
	@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblCTContractStage
	WHERE intMultiCompanyId = @intToCompanyId AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblCTContractStage SET strFeedStatus='Awt Ack' WHERE intMultiCompanyId = @intToCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH