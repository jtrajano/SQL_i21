﻿/**
	@billDetailId - bill detail id to update the cost
	@costAdjustment - update the cost using cost adjustment feature http://inet.irelyserver.com/display/~rufil.cabangal/Cost+Adjustment
*/
CREATE PROCEDURE [dbo].[uspAPUpdateCost]
	@billDetailId INT,
	@cost DECIMAL(18,6),
	@costAdjustment BIT = 0
AS

BEGIN TRY
DECLARE @newCost DECIMAL(18,6) = @cost;
DECLARE @receiptCost DECIMAL(18,6) = 0;
DECLARE @posted BIT = 0;
DECLARE @voucherId INT;
DECLARE @hasReceipt BIT = 0;
DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @billDetailIds AS Id;
DECLARE @billIds AS Id;
DECLARE @contractDetailId INT;
DECLARE @differentCost BIT = 0; --this will track if cost adjustment is really happening

INSERT INTO @billDetailIds
SELECT @billDetailId

SELECT
	@voucherId = voucher.intBillId
	,@posted = voucher.ysnPosted
	,@hasReceipt = CASE WHEN voucherDetail.intInventoryReceiptItemId > 0 THEN 1 ELSE 0 END
	,@differentCost = CASE WHEN receiptItem.dblUnitCost != @newCost THEN 1 ELSE 0 END
	,@contractDetailId =  voucherDetail.intContractDetailId
	,@receiptCost = receiptItem.dblUnitCost
FROM tblAPBill voucher
INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
LEFT JOIN tblICInventoryReceiptItem receiptItem ON receiptItem.intInventoryReceiptItemId = voucherDetail.intInventoryReceiptItemId
WHERE voucherDetail.intBillDetailId = @billDetailId

--DO NOT ALLOW TO UPDATE COST IF POSTED
IF @posted = 1
BEGIN
	RAISERROR('You cannot adjust cost when voucher already posted.', 16, 1);
END

--IF COST ADJUSTMENT ENABLED, IT SHOULD ONLY VALID IF IT HAS RECEIPT ASSOCATION
IF @costAdjustment = 1 AND @hasReceipt = 0
BEGIN
	RAISERROR('You cannot adjust cost when voucher detail do not associate with receipt.', 16, 1);
END

IF @costAdjustment = 0 AND @hasReceipt = 1
BEGIN
	RAISERROR('You cannot normally adjust cost when voucher detail associated with receipt.', 16, 1);
END

INSERT INTO @billIds
SELECT @voucherId

IF @transCount = 0 BEGIN TRANSACTION

IF @costAdjustment = 1
BEGIN
	UPDATE voucherDetail
		SET voucherDetail.dblOldCost = @receiptCost
		,voucherDetail.dblCost = @newCost
	FROM tblAPBillDetail voucherDetail
	WHERE voucherDetail.intBillDetailId = @billDetailId 
END
ELSE
BEGIN
	UPDATE voucherDetail
		SET voucherDetail.dblCost = @newCost
	FROM tblAPBillDetail voucherDetail
	WHERE voucherDetail.intBillDetailId = @billDetailId 
END

--UPDATE THE TAX
--EXEC uspAPUpdateVoucherDetailTax @billDetailIds
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
	[intTaxGroupId]			=	C.intTaxGroupId, 
	[intTaxCodeId]			=	C.intTaxCodeId, 
	[intTaxClassId]			=	C.intTaxClassId, 
	[strTaxableByOtherTaxes]=	C.strTaxableByOtherTaxes, 
	[strCalculationMethod]	=	C.strCalculationMethod, 
	[dblRate]				=	C.dblRate, 
	[intAccountId]			=	C.intTaxAccountId, 
	[dblTax]				=	CASE WHEN @differentCost = 1 AND @costAdjustment = 1 THEN C.dblTax 
									ELSE CAST(((C.dblTax * B.dblTotal) / (D.dblLineTotal)) AS DECIMAL(18,2)) 
								END,
	[dblAdjustedTax]		=	CAST(((C.dblTax * B.dblTotal) / (D.dblLineTotal)) AS DECIMAL(18,2)), 
	[ysnTaxAdjusted]		=	CASE WHEN @differentCost = 1 AND @costAdjustment = 1 THEN 1 ELSE 0 END, 
	[ysnSeparateOnBill]		=	C.ysnSeparateOnInvoice, 
	[ysnCheckOffTax]		=	C.ysnCheckoffTax
FROM tblAPBillDetail B
INNER JOIN tblICInventoryReceiptItemTax C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceiptItem D ON B.intInventoryReceiptItemId = D.intInventoryReceiptItemId
WHERE B.intBillDetailId = @billDetailId

UPDATE voucherDetails
	SET voucherDetails.dblTax = ISNULL(taxes.dblTax,0)
FROM tblAPBillDetail voucherDetails
OUTER APPLY (
	SELECT SUM(ISNULL(dblTax,0)) dblTax FROM tblAPBillDetailTax WHERE intBillDetailId = voucherDetails.intBillDetailId
) taxes
WHERE voucherDetails.intBillDetailId = @billDetailId

EXEC uspAPUpdateVoucherTotal @billIds

--UPDATE DISCOUNT
UPDATE Voucher
	SET Voucher.dblDiscount = dbo.fnGetDiscountBasedOnTerm(GETDATE(), Voucher.dtmDate, Voucher.intTermsId, Voucher.dblTotal)
FROM tblAPBill Voucher
WHERE Voucher.intBillId = @voucherId

COMMIT TRANSACTION

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
