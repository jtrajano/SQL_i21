﻿CREATE PROCEDURE [dbo].[uspAPUpdateProvisionalTotal]
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
DECLARE @detailTotal DECIMAL(18,2);
DECLARE @qty DECIMAL(38,15);
DECLARE @unitQty DECIMAL(38,20);

IF @transCount = 0 BEGIN TRANSACTION

	-- IF (SELECT TOP 1 ysnPosted FROM tblAPBill WHERE intBillId IN (SELECT intId FROM @voucherIds)) = 1
	-- BEGIN
	-- 	RAISERROR('Data contains posted vouchers', 16, 1);
	-- END

	--UPDATE DETAIL TOTAL
	UPDATE A
		SET --A.dblTotal = CAST((A.dblCost * A.dblQtyReceived) - ((A.dblCost * A.dblQtyReceived) * (A.dblDiscount / 100)) AS DECIMAL (18,2)) 
		@qty							=	CASE WHEN A.intComputeTotalOption = 0 OR A.intComputeTotalOption IS NULL
											THEN (CASE WHEN A.dblNetWeight != 0 THEN A.dblNetWeight ELSE A.dblQtyReceived END)
											ELSE A.dblQtyReceived END,
		@unitQty						=	CASE WHEN A.intComputeTotalOption = 0 OR A.intComputeTotalOption IS NULL
											THEN (CASE WHEN A.dblNetWeight != 0 THEN A.dblWeightUnitQty ELSE A.dblUnitQty END)
											ELSE A.dblUnitQty END,
		@detailTotal					=	CASE WHEN WC.intWeightClaimDetailId IS NOT NULL--C.intTransactionType = 11
											THEN 
												--WEIGHT CLAIM ALWAYS USE THE QTY RECEIVED BECAUSE THAT IS THE CLAIM QTY CREATED BY LG, NET WEIGHT IS JUST FOR DISPLAY
												ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN
													CAST((A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
												ELSE 
													CAST((A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
												END),0)
											ELSE
												ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN (
													CAST(A.dblCost / ISNULL(C.intSubCurrencyCents,1)  * @qty * @unitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2))
												)
												ELSE (
													CAST(A.dblCost  * @qty * @unitQty / ISNULL(A.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
												)
												END),0)
											END,	
			[dblTotal]					=	@detailTotal,
			[dblClaimAmount]			=	CASE WHEN WC.intWeightClaimDetailId IS NOT NULL --C.intTransactionType = 11 
											THEN 
												ISNULL((CASE WHEN A.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												THEN
													CAST((A.dblQtyReceived) *  (A.dblCost / ISNULL(C.intSubCurrencyCents,1))  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
												ELSE 
													CAST((A.dblQtyReceived) *  (A.dblCost)  * (A.dblUnitQty/ ISNULL(A.dblCostUnitQty,1)) AS DECIMAL(18,2))
												END),0)
											ELSE 0 END,
			[dbl1099]					=	CASE WHEN C.intTransactionType = 9 
											THEN @detailTotal
											ELSE 0 END

	FROM tblAPProvisionalDetail A
	INNER JOIN @voucherIds B ON A.intBillId = B.intId
	INNER JOIN tblAPProvisional C ON A.intBillId = C.intBillId
	LEFT JOIN tblICInventoryReceiptCharge D ON D.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	LEFT JOIN tblLGWeightClaimDetail WC ON WC.intBillId = C.intBillId

	--UPDATE PAYMENT
	UPDATE A
		SET A.dblPayment = PrePayment.dblTotalPrePayment
	FROM tblAPBill A
	INNER JOIN @voucherIds B ON A.intBillId = B.intId
	OUTER APPLY (
		SELECT SUM(dblAmountApplied) dblTotalPrePayment FROM tblAPAppliedPrepaidAndDebit C WHERE C.intBillId = B.intId AND C.ysnApplied = 1
	) PrePayment
	WHERE PrePayment.dblTotalPrePayment IS NOT NULL

	--UPDATE HEADER TOTAL
	UPDATE A
		SET A.dblTotal = CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) AS DECIMAL(18,2)) 
		,A.dblTotalController = CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) AS DECIMAL(18,2))
		,A.dblSubtotal = CAST((DetailTotal.dblTotal)  AS DECIMAL(18,2)) 
		,A.dblAmountDue =  CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) - A.dblPayment AS DECIMAL(18,2)) 
		,A.dblTax = DetailTotal.dblTotalTax
		,A.dblAverageExchangeRate = DetailTotal.dblAverageExchangeRate
	FROM tblAPProvisional A
	INNER JOIN @voucherIds B ON A.intBillId = B.intId
	CROSS APPLY (
		SELECT SUM(dblTotal) dblTotal, SUM(dblTax) dblTotalTax, SUM(((dblTotal + dblTax) * dblRate) / (dblTotal + dblTax)) dblAverageExchangeRate FROM tblAPProvisionalDetail C WHERE C.intBillId = B.intId
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

