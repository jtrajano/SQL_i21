CREATE PROCEDURE [dbo].[uspARTransferInvoiceStgData]
	@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblARIntrCompanyInvoiceStg
	WHERE intMultiCompanyId = @intToCompanyId AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblARIntrCompanyInvoiceStg SET strFeedStatus='Awt Ack' WHERE intMultiCompanyId = @intToCompanyId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH