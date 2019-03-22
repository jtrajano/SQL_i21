CREATE PROCEDURE [dbo].[uspAPFixVoucherStatus]
AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @startingRecordId INT;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	UPDATE A
		SET A.dblPayment = ISNULL(billPayment.dblPayment,0)
		,A.dblDiscount = ISNULL(billPayment.dblDiscount,0)
		,A.dblInterest = ISNULL(billPayment.dblInterest,0)
	FROM tblAPBill A
	CROSS APPLY (
		SELECT SUM(dblPayment) dblPayment, SUM(dblDiscount) dblDiscount, SUM(dblInterest) dblInterest FROM (
			SELECT
				SUM(payDetail.dblPayment) dblPayment
				,SUM(payDetail.dblDiscount) dblDiscount
				,SUM(payDetail.dblInterest) dblInterest
			FROM tblAPPayment pay
			INNER JOIN tblAPPaymentDetail payDetail ON pay.intPaymentId = payDetail.intPaymentId 
														AND ISNULL(payDetail.intBillId, payDetail.intOrigBillId) = A.intBillId
			WHERE pay.ysnPosted = 1
			UNION ALL --Voucher have been paid using prepaid and debit memo tab (payment use is the offset of DM/VPRE)
			SELECT
				SUM(dblAmountApplied)
				,0
				,0
			FROM tblAPAppliedPrepaidAndDebit appliedTab
			WHERE appliedTab.intBillId = A.intBillId AND appliedTab.ysnApplied = 1
			UNION ALL --DM/Basis/Prepaid have been paid using prepaid and debit memo tab (DM/VPRE have been paid by offset to voucher)
			SELECT
				SUM(dblAmountApplied)
				,0
				,0
			FROM tblAPAppliedPrepaidAndDebit appliedTab
			WHERE appliedTab.intTransactionId = A.intBillId AND appliedTab.ysnApplied = 1
			UNION ALL --Voucher have been used in AR side
			SELECT
				SUM(dblPayment)
				,SUM(arPaymentDetail.dblDiscount)
				,SUM(arPaymentDetail.dblInterest)
			FROM dbo.tblARPayment arPayment
			INNER JOIN dbo.tblARPaymentDetail arPaymentDetail ON arPayment.intPaymentId = arPaymentDetail.intPaymentId
									AND arPaymentDetail.intBillId = A.intBillId
			WHERE arPayment.ysnPosted = 1  
		) allPayment
	) billPayment
	WHERE billPayment.dblPayment != A.dblPayment OR billPayment.dblDiscount != A.dblDiscount OR billPayment.dblInterest != A.dblInterest

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
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

