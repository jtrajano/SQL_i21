/**
	@billDetailId - bill detail id to update the cost
	@costAdjustment - update the cost using cost adjustment feature http://inet.irelyserver.com/display/~rufil.cabangal/Cost+Adjustment
*/
CREATE PROCEDURE [dbo].[uspAPUpdateCost]
	@billDetailId INT,
	@cost DECIMAL(38,20),
	@costAdjustment BIT = 0
AS

BEGIN TRY
DECLARE @newCost DECIMAL(38,20) = @cost;
DECLARE @receiptCost DECIMAL(38,20) = 0;
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
	,@receiptCost = CASE WHEN CD.intContractDetailId IS NULL THEN receiptItem.dblUnitCost ELSE
						dbo.fnMFConvertCostToTargetItemUOM(ISNULL(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId),CD.intPriceItemUOMId,receiptItem.dblUnitCost)
					END
FROM tblAPBill voucher
INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
LEFT JOIN tblICInventoryReceiptItem receiptItem ON receiptItem.intInventoryReceiptItemId = voucherDetail.intInventoryReceiptItemId
LEFT JOIN (tblCTContractHeader CH INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId)  ON CH.intEntityId = voucher.intEntityVendorId 
																															AND CH.intContractHeaderId = receiptItem.intOrderId 
																															AND CD.intContractDetailId = receiptItem.intLineNo 
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
--DELETE ONLY IF DETAIL IS ASSOCIATED TO RECEIPT
--IC-7609 consideration
IF (SELECT A.intInventoryReceiptItemId FROM tblAPBillDetail A
		LEFT JOIN tblICInventoryReceiptItemTax B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		WHERE intBillDetailId = @billDetailId AND B.intInventoryReceiptItemTaxId IS NOT NULL) > 0
BEGIN 
	DELETE A
	FROM tblAPBillDetailTax A
	WHERE A.intBillDetailId = @billDetailId

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
		[dblTax]				=	CASE WHEN @differentCost = 1 AND @costAdjustment = 1 THEN C.dblTax  --cost adjustment
										ELSE CAST(((C.dblTax * B.dblTotal) / (D.dblLineTotal)) AS DECIMAL(18,2))  --normal cost update
									END,
		[dblAdjustedTax]		=	CAST(CASE WHEN @costAdjustment = 1 AND C.strCalculationMethod = 'UNIT' THEN ((C.dblTax * D.dblLineTotal) / (D.dblLineTotal))
											ELSE ((C.dblTax * B.dblTotal) / (D.dblLineTotal)) END AS DECIMAL(18,2)), 
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
		SELECT SUM(ISNULL(NULLIF(dblAdjustedTax,0), dblTax)) dblTax FROM tblAPBillDetailTax WHERE intBillDetailId = voucherDetails.intBillDetailId
	) taxes
	WHERE voucherDetails.intBillDetailId = @billDetailId

	EXEC uspAPUpdateVoucherTotal @billIds

	--UPDATE DISCOUNT
	UPDATE Voucher
		SET Voucher.dblDiscount = dbo.fnGetDiscountBasedOnTerm(GETDATE(), Voucher.dtmBillDate, Voucher.intTermsId, Voucher.dblTotal)
	FROM tblAPBill Voucher
	WHERE Voucher.intBillId = @voucherId

END

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
