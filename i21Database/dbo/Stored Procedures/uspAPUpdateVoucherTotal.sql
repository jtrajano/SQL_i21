CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTotal]
	@voucherIds AS Id READONLY
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

	IF (SELECT TOP 1 ysnPosted FROM tblAPBill WHERE intBillId IN (SELECT intId FROM @voucherIds)) = 1
	BEGIN
		RAISERROR('Data contains posted vouchers', 16, 1);
	END

	--UPDATE DETAIL TOTAL
	UPDATE A
		SET --A.dblTotal = CAST((A.dblCost * A.dblQtyReceived) - ((A.dblCost * A.dblQtyReceived) * (A.dblDiscount / 100)) AS DECIMAL (18,2)) 
			[dblTotal]					=	ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN (CASE 
														WHEN A.intWeightUOMId > 0 
															THEN CAST(A.dblCost / ISNULL(C.intSubCurrencyCents,1)  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
															THEN CAST(ABS(A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(ABS(A.dblQtyReceived) * (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
													END) 
												ELSE (CASE 
														WHEN A.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
															THEN CAST(A.dblCost  * A.dblNetWeight * A.dblWeightUnitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
														WHEN (A.intUnitOfMeasureId > 0 AND A.intCostUOMId > 0)
															THEN CAST(ABS(A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
														ELSE CAST(ABS(A.dblQtyReceived) * (A.dblCost)  AS DECIMAL(18,2))  --Orig Calculation
													END)
												END),0)	
	FROM tblAPBillDetail A
	INNER JOIN @voucherIds B ON A.intBillId = B.intId

	--UPDATE PAYMENT
	UPDATE A
		SET A.dblPayment = PrePayment.dblTotalPrePayment
	FROM tblAPBill A
	INNER JOIN @voucherIds B ON A.intBillId = B.intId
	OUTER APPLY (
		SELECT SUM(dblAmountApplied) dblTotalPrePayment FROM tblAPAppliedPrepaidAndDebit C WHERE C.intBillId = B.intId
	) PrePayment
	WHERE PrePayment.dblTotalPrePayment IS NOT NULL

	--UPDATE HEADER TOTAL
	UPDATE A
		SET A.dblTotal = CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) - A.dblPayment AS DECIMAL(18,2)) 
		,A.dblSubtotal = CAST((DetailTotal.dblTotal)  AS DECIMAL(18,2)) 
		,A.dblAmountDue =  CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) - A.dblPayment AS DECIMAL(18,2)) 
	FROM tblAPBill A
	INNER JOIN @voucherIds B ON A.intBillId = B.intId
	CROSS APPLY (
		SELECT SUM(dblTax) dblTotalTax, SUM(dblTotal) dblTotal FROM tblAPBillDetail C WHERE C.intBillId = B.intId
	) DetailTotal
	WHERE DetailTotal.dblTotal IS NOT NULL

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