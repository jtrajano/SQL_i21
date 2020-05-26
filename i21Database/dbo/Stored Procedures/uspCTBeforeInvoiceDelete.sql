CREATE PROCEDURE [dbo].[uspCTBeforeInvoiceDelete]
	@intInvoiceId	 INT,
	@intUserId		 INT -- User Who is deleting the Invoice.
AS

BEGIN TRY

	DECLARE	@ErrMsg	NVARCHAR(MAX)

	UPDATE	tblCTPriceFixationDetail SET intInvoiceId = NULL, intInvoiceDetailId = NULL WHERE intInvoiceId = @intInvoiceId
	--DELETE FROM  tblCTPriceFixationDetailAPAR  WHERE intInvoiceId = @intInvoiceId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
