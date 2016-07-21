CREATE PROCEDURE [dbo].[uspAPUpdateVoucherTax]
	@billId INT
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

	IF (SELECT ysnPosted FROM tblAPBill WHERE intBillId = @billId) = 1
	BEGIN
		RAISERROR('Voucher was already posted.', 16, 1);
	END

	--DELETE EXISTING TAXES
	DELETE A
	FROM tblAPBillDetailTax A
	INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId
	WHERE B.intBillId = @billId

	--CREATE TAXES FOR ITEM WHICH DON'T HAVE TAXES
	INSERT INTO tblAPBillDetailTax(
		[intBillDetailId]		, 
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
		[intTaxGroupId]			=	Taxes.intTaxGroupId, 
		[intTaxCodeId]			=	Taxes.intTaxCodeId, 
		[intTaxClassId]			=	Taxes.intTaxClassId, 
		[strTaxableByOtherTaxes]=	Taxes.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	Taxes.strCalculationMethod, 
		[dblRate]				=	Taxes.dblRate, 
		[intAccountId]			=	Taxes.intTaxAccountId, 
		[dblTax]				=	Taxes.dblTax, 
		[dblAdjustedTax]		=	Taxes.dblAdjustedTax, 
		[ysnTaxAdjusted]		=	Taxes.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	Taxes.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	Taxes.ysnCheckoffTax
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	CROSS APPLY (
		SELECT * FROM fnGetItemTaxComputationForVendor(B.intItemId, A.intEntityVendorId, A.dtmDate, B.dblCost, B.dblQtyReceived, B.intTaxGroupId, A.intShipToId, A.intShipFromId, 0)
	) Taxes
	WHERE (intInventoryReceiptItemId IS NULL AND intInventoryReceiptChargeId IS NULL)
	--OR NOT EXISTS(
	--	--EXCLUDE ITEM WITH INVENTORY RECEIPT ITEM AND WITH TAX, WE WILL GET THOSE TAX BELOW
	--	SELECT 1 FROM tblICInventoryReceiptItem C
	--	WHERE C.intInventoryReceiptItemId = B.intInventoryReceiptItemId AND C.dblTax > 0
	--)

	--GET TAXES FOR THOSE FROM INVENTORY RECEIPT
	INSERT INTO tblAPBillDetailTax(
		[intBillDetailId]		, 
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
		[intBillDetailId]		=	B.intBillDetailId			,
		[intTaxGroupId]			=	D.[intTaxGroupId]			,		
		[intTaxCodeId]			=	D.[intTaxCodeId]			,
		[intTaxClassId]			=	D.[intTaxClassId]			,
		[strTaxableByOtherTaxes]=	D.[strTaxableByOtherTaxes]	,
		[strCalculationMethod]	=	D.[strCalculationMethod]	,
		[dblRate]				=	D.[dblRate]					,
		[intAccountId]			=	D.[intTaxAccountId]			,
		[dblTax]				=	D.[dblTax]					,
		[dblAdjustedTax]		=	D.[dblAdjustedTax]			,
		[ysnTaxAdjusted]		=	D.[ysnTaxAdjusted]			,
		[ysnSeparateOnBill]		=	D.[ysnSeparateOnInvoice]	,
		[ysnCheckOffTax]		=	D.[ysnCheckoffTax]			
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN tblICInventoryReceiptItem C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceiptItemTax D ON C.intInventoryReceiptItemId = D.intInventoryReceiptItemId
	WHERE C.dblTax > 0

	UPDATE A
		SET A.dblTax = TaxAmount.dblTax
	FROM tblAPBillDetail A
	CROSS APPLY (
		SELECT 
			SUM(CASE WHEN B.ysnTaxAdjusted = 1 THEN B.dblAdjustedTax ELSE B.dblTax END) dblTax
		FROM tblAPBillDetailTax B WHERE B.intBillDetailId = A.intBillDetailId
	) TaxAmount
	WHERE A.intBillId = @billId AND TaxAmount.dblTax IS NOT NULL

	UPDATE A
		SET A.dblTax = TaxAmount.dblTax
	FROM tblAPBill A
	CROSS APPLY (
		SELECT 
			SUM(dblTax) AS dblTax, SUM(dblTotal) dblTotal 
		FROM tblAPBillDetail WHERE intBillId = A.intBillId
	) TaxAmount
	WHERE intBillId = @billId AND TaxAmount.dblTax IS NOT NULL

	EXEC uspAPUpdateVoucherTotal @billId

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