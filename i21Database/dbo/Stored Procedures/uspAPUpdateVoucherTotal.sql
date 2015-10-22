CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTotal]
	@voucherId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @posted BIT;
DECLARE @shipToId INT;

IF @transCount = 0 BEGIN TRANSACTION

	IF (SELECT ysnPosted FROM tblAPBill WHERE intBillId = @voucherId) = 1
	BEGIN
		RAISERROR('Voucher was already posted.', 16, 1);
	END

	--UPDATE DETAIL TOTAL
	UPDATE A
		SET A.dblTotal = (A.dblCost * A.dblQtyReceived) - ((A.dblCost * A.dblQtyReceived) * (A.dblDiscount / 100))
	FROM tblAPBillDetail A
	WHERE A.intBillId = @voucherId

	--UPDATE HEADER TOTAL
	UPDATE A
		SET A.dblPayment = PrePayment.dblTotalPrePayment
		,A.dblTotal = (DetailTotal.dblTotal + DetailTotal.dblTotalTax) - PrePayment.dblTotalPrePayment
	FROM tblAPBill A
	CROSS APPLY (
		SELECT SUM(dblTax) dblTotalTax, SUM(dblTotal) dblTotal FROM tblAPBillDetail B WHERE B.intBillId = A.intBillId
	) DetailTotal
	OUTER APPLY (
		SELECT SUM(dblAmountApplied) dblTotalPrePayment FROM tblAPAppliedPrepaidAndDebit C WHERE A.intBillId = C.intBillId
	) PrePayment
	WHERE A.intBillId = @voucherId

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