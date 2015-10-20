CREATE PROCEDURE [dbo].[uspAPUpdateVoucherDetailContract]
	@voucherDetail AS VoucherDetailData
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF (EXISTS(SELECT 1 FROM tblAPBill A 
				INNER JOIN @voucherDetail B ON A.intBillId = B.intBillId
				WHERE A.ysnPosted = 1)) 
BEGIN
	RAISERROR('There are voucher details associated on posted bills. Make sure bills were unposted.', 16, 1);
END

UPDATE A
	SET A.dblQtyContract = B.dblBalance, A.dblContractCost = B.dblCashPrice
FROM @voucherDetail A
INNER JOIN tblCTContractDetail B ON A.intContractDetailId = B.intContractDetailId

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH