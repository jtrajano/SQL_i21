/*
	Usage
	1. Create taxes for voucher detail.
	2. If there are changes made on voucher detail (except on purchase detail and IR Receipt), use this to recreate the taxes.
*/
CREATE PROCEDURE [dbo].[uspAPUpdateVoucherDetailTax]
	@billDetailIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @voucherIds AS Id;

IF @transCount = 0 BEGIN TRANSACTION

	IF (SELECT TOP 1 ysnPosted FROM tblAPBill A INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId 
				WHERE intBillDetailId IN (SELECT intId FROM @billDetailIds)) = 1
	BEGIN
		RAISERROR('Voucher was already posted.', 16, 1);
	END

	--DELETE EXISTING TAXES
	DELETE A
		FROM tblAPBillDetailTax A
	WHERE intBillDetailId IN (SELECT intId FROM @billDetailIds)

	INSERT INTO tblAPBillDetailTax(
		[intBillDetailId]		, 
		--[intTaxGroupMasterId]	, 
		[intTaxGroupId]			, 
		[intTaxCodeId]			, 
		[intTaxClassId]			, 
		[strTaxableByOtherTaxes], 
		[strCalculationMethod]	, 
		[dblRate]				, 
		[intAccountId]			, 
		[dblTax]				, 
		[dblAdjustedTax]		, 
		[ysnTaxAdjusted]		, 
		[ysnSeparateOnBill]		, 
		[ysnCheckOffTax]
	)
	SELECT
		[intBillDetailId]		=	B.intBillDetailId, 
		--[intTaxGroupMasterId]	=	NULL, 
		[intTaxGroupId]			=	Taxes.intTaxGroupId, 
		[intTaxCodeId]			=	Taxes.intTaxCodeId, 
		[intTaxClassId]			=	Taxes.intTaxClassId, 
		[strTaxableByOtherTaxes]=	Taxes.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	Taxes.strCalculationMethod, 
		[dblRate]				=	Taxes.dblRate, 
		[intAccountId]			=	Taxes.intTaxAccountId, 
		[dblTax]				=	ISNULL(Taxes.dblTax,0), 
		[dblAdjustedTax]		=	ISNULL(Taxes.dblAdjustedTax,0), 
		[ysnTaxAdjusted]		=	Taxes.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	Taxes.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	Taxes.ysnCheckoffTax
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @billDetailIds C ON B.intBillDetailId = C.intId
	--LEFT JOIN tblICInventoryReceiptCharge D ON B.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
	CROSS APPLY fnGetItemTaxComputationForVendor(B.intItemId, A.intEntityVendorId, A.dtmDate, B.dblCost, CASE WHEN B.intWeightUOMId > 0 THEN B.dblNetWeight ELSE B.dblQtyReceived END, B.intTaxGroupId,A.intShipToId,A.intShipFromId, 0, NULL, 0) Taxes
	WHERE Taxes.dblTax IS NOT NULL

	UPDATE A
		SET A.dblTax = CASE WHEN D.intInventoryReceiptChargeId IS NOT NULL AND D.intInventoryReceiptChargeId > 0 AND D.ysnPrice = 1
								THEN TaxAmount.dblTax * -1 
							ELSE TaxAmount.dblTax
						END
	FROM tblAPBillDetail A
	INNER JOIN @billDetailIds B ON A.intBillDetailId = B.intId
	CROSS APPLY (
		SELECT 
			SUM(CASE WHEN B.ysnTaxAdjusted = 1 THEN B.dblAdjustedTax ELSE B.dblTax END) dblTax
		FROM tblAPBillDetailTax B WHERE B.intBillDetailId = A.intBillDetailId
	) TaxAmount
	LEFT JOIN tblICInventoryReceiptCharge D ON A.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
	WHERE TaxAmount.dblTax IS NOT NULL

	UPDATE A
		SET A.dblTax = TaxAmount.dblTax
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @billDetailIds C ON B.intBillDetailId = C.intId
	CROSS APPLY (
		SELECT 
			SUM(dblTax) AS dblTax, SUM(dblTotal) dblTotal 
		FROM tblAPBillDetail WHERE intBillId = A.intBillId
	) TaxAmount
	WHERE TaxAmount.dblTax IS NOT NULL

	INSERT INTO @voucherIds
	SELECT DISTINCT
		A.intBillId 
	FROM tblAPBill A 
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId 
	INNER JOIN @billDetailIds C ON B.intBillDetailId = C.intId
	EXEC uspAPUpdateVoucherTotal @voucherIds

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