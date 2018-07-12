CREATE PROCEDURE [dbo].[uspCTBeforeVoucherDelete]

	@intBillId	 INT,
	@intUserId	 INT -- User Who is deleting the voucher.
AS

BEGIN TRY

	DECLARE	@ErrMsg	NVARCHAR(MAX)

	UPDATE	tblCTPriceFixationDetail SET intBillId = NULL, intBillDetailId = NULL WHERE intBillId = @intBillId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH

