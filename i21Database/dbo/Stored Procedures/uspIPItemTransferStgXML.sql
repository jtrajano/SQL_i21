CREATE PROCEDURE [dbo].[uspIPItemTransferStgXML]
	@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblICItemStage
	WHERE intMultiCompanyId = @intToCompanyId AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblICItemStage SET strFeedStatus='Awt Ack' WHERE intMultiCompanyId = @intToCompanyId AND ISNULL(strFeedStatus, '') = ''

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
