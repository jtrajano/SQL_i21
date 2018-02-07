﻿CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailReceiptCharge]
	@voucherId INT,
	@voucherDetailReceiptCharge AS [VoucherDetailReceiptCharge] READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @voucherIds AS Id;
DECLARE @error NVARCHAR(200);
DECLARE @voucherCurrency INT;
DECLARE @voucherVendor INT;
DECLARE @defaultCurrency INT;
DECLARE @currentDateFilter DATETIME = (SELECT CONVERT(char(10), GETDATE(),126));
DECLARE @detailCreated AS TABLE(intBillDetailId INT, intInventoryReceiptChargeId INT);
DECLARE @receiptChargeItems AS VoucherDetailReceiptCharge;

SELECT TOP 1
	@voucherCurrency = voucher.intCurrencyId
	,@voucherVendor = voucher.intEntityVendorId
FROM tblAPBill voucher
WHERE voucher.intBillId = @voucherId

SELECT TOP 1 
	@defaultCurrency = intDefaultCurrencyId
FROM dbo.tblSMCompanyPreference

--Filter the records per vendor and currency
INSERT INTO @receiptChargeItems
SELECT A.*
FROM @voucherDetailReceiptCharge A
INNER JOIN vyuICChargesForBilling B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
WHERE B.intEntityVendorId = @voucherVendor AND B.intCurrencyId = @voucherCurrency

IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[intItemId],
		[intInventoryReceiptItemId],
		[intInventoryReceiptChargeId],
		[intPurchaseDetailId],
		[dblQtyOrdered],
		[dblQtyReceived],
		[dblTax],
		[dblRate],
		[intCurrencyExchangeRateTypeId],
		[ysnSubCurrency],
		[intTaxGroupId],
		[intAccountId],
		[dblTotal],
		[dblCost],
		[dblOldCost],
		[dblClaimAmount],
		[dblNetWeight],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblUnitQty],
		[intCurrencyId],
		[intStorageLocationId],
		[int1099Form],
		[int1099Category]
	)
	OUTPUT inserted.intBillDetailId, inserted.intInventoryReceiptChargeId INTO @detailCreated(intBillDetailId, intInventoryReceiptChargeId)
	SELECT DISTINCT
		[intBillId]						=	@voucherId,
		[intItemId]						=	A.intItemId,
		[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]	=	A.[intInventoryReceiptChargeId],
		[intPODetailId]					=	NULL,
		[dblQtyOrdered]					=	A.dblOrderQty,
		[dblQtyReceived]				=	A.dblQuantityToBill,
		[dblTax]						=	ISNULL((CASE WHEN ISNULL(A.intEntityVendorId, IR.intEntityVendorId) != IR.intEntityVendorId
																		THEN (CASE WHEN IRCT.ysnCheckoffTax = 0 THEN ABS(A.dblTax) 
																				ELSE A.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
																	 ELSE (CASE WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 1 THEN A.dblTax * -1 ELSE A.dblTax END ) END),0), -- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN 
											--(CASE WHEN A.ysnPrice = 1 THEN ISNULL(A.dblTax,0) * -1 ELSE ISNULL(A.dblTax,0) END), -- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN AND NOT CHECK OFF (OR NEGATIVE AMOUNT)
		[dblForexRate]					=	ISNULL(A.dblForexRate,1),
		[intForexRateTypeId]			=   A.intForexRateTypeId,
		[ysnSubCurrency]				=	ISNULL(A.ysnSubCurrency,0),
		[intTaxGroupId]					=	NULL,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](A.intItemId,D.intItemLocationId, 'AP Clearing'),
		[dblTotal]						=	CASE WHEN A.ysnPrice > 0 THEN  (CASE WHEN A.ysnSubCurrency > 0 THEN A.dblUnitCost / A.intSubCurrencyCents ELSE A.dblUnitCost END) * -1 
													ELSE (CASE WHEN A.ysnSubCurrency > 0 THEN A.dblUnitCost / A.intSubCurrencyCents ELSE A.dblUnitCost END)
											END * A.dblQuantityToBill / (CASE WHEN A.ysnSubCurrency > 0 THEN ISNULL(A.intSubCurrencyCents,1) ELSE 1 END)  ,
		[dblCost]						=	CASE WHEN charges.dblCost > 0 THEN charges.dblCost ELSE ABS((A.dblUnitCost /  ISNULL(A.intSubCurrencyCents,1))) END,
		[dblOldCost]					=	CASE WHEN charges.dblCost != A.dblUnitCost THEN A.dblUnitCost ELSE NULL END,
		[dblClaimAmount]				=	0,
		[dblNetWeight]					=	0,
		[dblNetShippedWeight]			=	0,
		[dblWeightLoss]					=	0,
		[dblFranchiseWeight]			=	0,
		[intContractDetailId]			=	A.intContractDetailId,
		[intContractHeaderId]			=	A.intContractHeaderId,
		[intUnitOfMeasureId]			=	A.intCostUnitMeasureId,
		[intCostUOMId]              	=    A.intCostUnitMeasureId,
		[intWeightUOMId]				=	NULL,
		[intLineNo]						=	1,
		[dblWeightUnitQty]				=	1,
		[dblCostUnitQty]				=	1,
		[dblUnitQty]					=	1,
		[intCurrencyId]					=	ISNULL(A.intCurrencyId,0),
		[intStorageLocationId]			=	NULL,
		[int1099Form]					=	0,
		[int1099Category]				=	0       
	FROM [vyuICChargesForBilling] A
	INNER JOIN @voucherDetailReceiptCharge charges
		ON A.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
	LEFT JOIN dbo.tblICInventoryReceipt IR ON IR.intInventoryReceiptId = A.intInventoryReceiptId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND A.intItemId = D.intItemId
	LEFT JOIN tblSMCurrencyExchangeRate F 
		ON  (F.intFromCurrencyId = @defaultCurrency AND F.intToCurrencyId = A.intCurrencyId) 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G 
		ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = @currentDateFilter
	OUTER APPLY
	(
		SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
		WHERE IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	)  IRCT
	WHERE A.intEntityVendorId = @voucherVendor --PARAMETER TO DISTINGUISH CORRECT CHARGES PER VENDOR
	-- OUTER APPLY(
	-- 	SELECT ysnPrice FROM #tmpReceiptChargeData RC
	-- 	WHERE RC.intInventoryReceiptId = A.intInventoryReceiptId AND RC.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	-- ) C   

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
		[intBillDetailId]		=	D.intBillDetailId, 
		[intTaxGroupId]			=	A.intTaxGroupId, 
		[intTaxCodeId]			=	A.intTaxCodeId, 
		[intTaxClassId]			=	A.intTaxClassId, 
		[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	A.strCalculationMethod, 
		[dblRate]				=	A.dblRate, 
		[intAccountId]			=	A.intTaxAccountId, 
		[dblTax]				=	A.dblTax,
		[dblAdjustedTax]		=	ISNULL(NULLIF(A.dblAdjustedTax,0), A.dblTax),
		[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	0, 
		[ysnCheckOffTax]		=	A.ysnCheckoffTax
	FROM tblICInventoryReceiptChargeTax A
	INNER JOIN dbo.tblICInventoryReceiptCharge B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	INNER JOIN dbo.tblAPBillDetail D ON D.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	INNER JOIN @detailCreated E 
		ON A.intInventoryReceiptChargeId = E.intInventoryReceiptChargeId AND 
		D.intBillDetailId = E.intBillDetailId

	UPDATE voucherDetails
		SET voucherDetails.dblTax = ISNULL(taxes.dblTax,0)
		,voucherDetails.dbl1099 = CASE WHEN voucherDetails.int1099Form > 0 THEN voucherDetails.dblTotal ELSE 0 END
	FROM tblAPBillDetail voucherDetails
	OUTER APPLY (
		SELECT SUM(ISNULL(dblTax,0)) dblTax FROM tblAPBillDetailTax WHERE intBillDetailId = voucherDetails.intBillDetailId
	) taxes
	WHERE voucherDetails.intBillDetailId IN (SELECT intBillDetailId FROM @detailCreated)
	
	INSERT INTO @voucherIds
	SELECT @voucherId
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