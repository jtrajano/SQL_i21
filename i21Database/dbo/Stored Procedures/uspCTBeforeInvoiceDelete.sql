CREATE PROCEDURE [dbo].[uspCTBeforeInvoiceDelete]
	@intInvoiceId	 INT,
	@intUserId		 INT, -- User Who is deleting the Invoice.
	@intInvoiceDetailId INT null
AS

BEGIN TRY

	DECLARE	@ErrMsg	NVARCHAR(MAX)

	if (isnull(@intInvoiceDetailId,0) < 1)
	begin
		UPDATE tblCTPriceFixationDetail SET intInvoiceId = NULL, intInvoiceDetailId = NULL WHERE intInvoiceId = @intInvoiceId  
		DELETE FROM  tblCTPriceFixationDetailAPAR  WHERE intInvoiceId = @intInvoiceId  
	end
	else
	begin
		UPDATE tblCTPriceFixationDetail SET intInvoiceId = NULL, intInvoiceDetailId = NULL WHERE intInvoiceId = @intInvoiceId    and intInvoiceDetailId = @intInvoiceDetailId
		DELETE FROM  tblCTPriceFixationDetailAPAR  WHERE intInvoiceId = @intInvoiceId  and intInvoiceDetailId = @intInvoiceDetailId
	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
