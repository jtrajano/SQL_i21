CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailReceiptCharge]
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
		[strMiscDescription],
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
		[intContractSeq],
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
		[int1099Category],
		[intScaleTicketId],
		[intLocationId],
		[ysnStage]
	)
	OUTPUT inserted.intBillDetailId, inserted.intInventoryReceiptChargeId INTO @detailCreated(intBillDetailId, intInventoryReceiptChargeId)
	SELECT DISTINCT
		[intBillId]						=	@voucherId,
		[intItemId]						=	A.intItemId,
		[strMiscDescription]			=	item.strDescription,
		[intInventoryReceiptItemId]  	= 	J.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]	=	A.[intInventoryReceiptChargeId],
		[intPODetailId]					=	NULL,
		[dblQtyOrdered]					=	A.dblOrderQty,
		[dblQtyReceived]				=	A.dblOrderQty, --ISNULL(charges.dblQtyReceived, A.dblQuantityToBill),
		[dblTax]						=	ISNULL((CASE WHEN ISNULL(A.intEntityVendorId, IR.intEntityVendorId) != IR.intEntityVendorId
																		THEN (CASE WHEN IRCT.ysnCheckoffTax = 0 THEN ABS(A.dblTax) 
																				ELSE A.dblTax END) --THIRD PARTY TAX SHOULD RETAIN NEGATIVE IF CHECK OFF
																	 ELSE (CASE WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 1 THEN A.dblTax * -1 
																	 		WHEN A.ysnPrice = 1 AND IRCT.ysnCheckoffTax = 0 THEN -A.dblTax --negate, inventory receipt will bring postive tax
																	 		ELSE A.dblTax END ) END),0),
											--(CASE WHEN A.ysnPrice = 1 THEN ISNULL(A.dblTax,0) * -1 ELSE ISNULL(A.dblTax,0) END), -- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN AND NOT CHECK OFF (OR NEGATIVE AMOUNT)
		[dblForexRate]					=	ISNULL(A.dblForexRate,1),
		[intForexRateTypeId]			=   A.intForexRateTypeId,
		[ysnSubCurrency]				=	ISNULL(A.ysnSubCurrency,0),
		[intTaxGroupId]					=	charges.intTaxGroupId,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](A.intItemId,D.intItemLocationId, 'AP Clearing'),
		[dblTotal]						=	((CASE WHEN A.ysnSubCurrency > 0 
													THEN A.dblUnitCost / A.intSubCurrencyCents 
													ELSE A.dblUnitCost END)
												* A.dblQuantityToBill) 
											/ (CASE WHEN A.ysnSubCurrency > 0 THEN ISNULL(A.intSubCurrencyCents,1) ELSE 1 END)  ,
		[dblCost]						=	CASE WHEN charges.dblCost > 0 THEN charges.dblCost ELSE ABS((A.dblUnitCost /  ISNULL(A.intSubCurrencyCents,1))) END,
		[dblOldCost]					=	NULL, --CONTRACT IS ONLY USING THIS SP FOR PRO RATED
		[dblClaimAmount]				=	0,
		[dblNetWeight]					=	0,
		[dblNetShippedWeight]			=	0,
		[dblWeightLoss]					=	0,
		[dblFranchiseWeight]			=	0,
		[intContractDetailId]			=	A.intContractDetailId,
		[intContractSeq]				=	A.intContractSeq,
		[intContractHeaderId]			=	A.intContractHeaderId,
		[intUnitOfMeasureId]			=	A.intCostUnitMeasureId,  --CASE WHEN A.intContractDetailId IS NOT NULL THEN cd.intItemUOMId ELSE A.intCostUnitMeasureId END),
		[intCostUOMId]              	=   A.intCostUnitMeasureId,
		[intWeightUOMId]				=	NULL,
		[intLineNo]						=	1,
		[dblWeightUnitQty]				=	1,
		[dblCostUnitQty]				=	1,
		[dblUnitQty]					=	1,
		[intCurrencyId]					=	ISNULL(A.intCurrencyId,0),
		[intStorageLocationId]			=	NULL,
		[int1099Form]					=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND A.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN entity.str1099Form = '1099-MISC' THEN 1
													WHEN entity.str1099Form = '1099-INT' THEN 2
													WHEN entity.str1099Form = '1099-B' THEN 3
											ELSE 0
											END,
		[int1099Category]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
													AND A.intItemId > 0
													AND item.ysn1099Box3 = 1
													AND patron.ysnStockStatusQualified = 1 
													THEN 3
										ELSE
											ISNULL(H.int1099CategoryId,0)
										END,
		[intScaleTicketId]				=	CASE WHEN IR.intSourceType = 1 THEN A.intScaleTicketId ELSE NULL END,
		[intLocationId]					=	IR.intLocationId,
		[ysnStage] = 0
	FROM [vyuICChargesForBilling] A
	INNER JOIN @voucherDetailReceiptCharge charges
		ON A.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId
	INNER JOIN dbo.tblICInventoryReceipt IR ON IR.intInventoryReceiptId = A.intInventoryReceiptId
	INNER JOIN tblEMEntity entity ON A.intEntityVendorId = entity.intEntityId
	INNER JOIN tblICItem item ON A.intItemId = item.intItemId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND A.intItemId = D.intItemId
	LEFT JOIN tblSMCurrencyExchangeRate F 
		ON  (F.intFromCurrencyId = @defaultCurrency AND F.intToCurrencyId = A.intCurrencyId) 
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G 
		ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = @currentDateFilter
	LEFT JOIN vyuPATEntityPatron patron ON IR.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblAP1099Category H ON entity.str1099Type = H.strCategory
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = A.intContractDetailId 
	OUTER APPLY
	(
		SELECT TOP 1 ysnCheckoffTax FROM tblICInventoryReceiptChargeTax IRCT
		WHERE IRCT.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	)  IRCT
	OUTER APPLY
	(
		SELECT TOP 1 intInventoryReceiptItemId FROM [vyuICChargesForBilling] B
		WHERE B.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	) J
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
		[dblTax]				=	CAST(ABS((ISNULL(A.dblTax,0) * D.dblTotal) / B.dblAmount) AS DECIMAL(18,2)) --make all positive first
										* (CASE WHEN A.ysnCheckoffTax = 1 OR B.ysnPrice = 1 THEN -1 
											WHEN A.ysnCheckoffTax = 1 AND B.ysnPrice = 1 THEN 1
											ELSE 1 END), --check off and price down should be negative
		[dblAdjustedTax]		=	CAST(ABS((ISNULL(A.dblTax,0) * D.dblTotal) / B.dblAmount) AS DECIMAL(18,2))
										* (CASE WHEN A.ysnCheckoffTax = 1 OR B.ysnPrice = 1 THEN -1 
											WHEN A.ysnCheckoffTax = 1 AND B.ysnPrice = 1 THEN 1
											ELSE 1 END), --check off and price down should be negative
		[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	0, 
		[ysnCheckOffTax]		=	A.ysnCheckoffTax
	FROM tblICInventoryReceiptChargeTax A
	INNER JOIN dbo.tblICInventoryReceiptCharge B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	INNER JOIN dbo.tblAPBillDetail D ON D.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	INNER JOIN @detailCreated E 
		ON A.intInventoryReceiptChargeId = E.intInventoryReceiptChargeId AND 
		D.intBillDetailId = E.intBillDetailId

	--recalculate tax if partial
	UPDATE voucherDetails
		--BILL DETAIL TAX SHOULD BE POSSITIVE IF PRICE DOWN AND CHECKOFF 
		SET voucherDetails.dblTax =( CASE WHEN D.ysnPrice = 1 AND taxes.ysnCheckOffTax = 1 THEN  ISNULL(taxes.dblTax,0) * -1 ELSE  ISNULL(taxes.dblTax,0) END)
		-- ,voucherDetails.dbl1099 = CASE WHEN voucherDetails.int1099Form > 0 THEN voucherDetails.dblTotal ELSE 0 END
	FROM tblAPBillDetail voucherDetails
	OUTER APPLY (
		SELECT SUM(ISNULL(dblTax,0)) dblTax, ysnCheckOffTax FROM tblAPBillDetailTax WHERE intBillDetailId = voucherDetails.intBillDetailId
		GROUP BY ysnCheckOffTax , dblTax
	) taxes
	INNER JOIN tblICInventoryReceiptCharge D ON D.intInventoryReceiptChargeId = voucherDetails.intInventoryReceiptChargeId
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
