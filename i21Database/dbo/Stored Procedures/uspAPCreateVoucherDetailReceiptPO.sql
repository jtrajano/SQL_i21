CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailReceiptPO]
	@voucherId INT,
	@voucherDetailReceiptPO AS [VoucherDetailReceipt] READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @voucherIds AS Id;
DECLARE @detailCreated AS TABLE(intBillDetailId INT, intInventoryReceiptItemId INT)
DECLARE @error NVARCHAR(200);
IF @transCount = 0 BEGIN TRANSACTION

	EXEC uspAPValidateVoucherDetailReceiptPO @voucherId, @voucherDetailReceiptPO

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intItemId]						,
		[intInventoryReceiptItemId]		,
		[intPurchaseDetailId]			,
		[intContractDetailId]			,
		[intContractHeaderId]			,
		[dblTotal]						,
		[dblTax]						,
		[dblQtyOrdered]					,
		[dblQtyReceived]				,
		[dblDiscount]					,
		[dblCost]						,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						,
		[intTaxGroupId]					
	)
	OUTPUT inserted.intBillDetailId, inserted.intInventoryReceiptItemId INTO @detailCreated
	SELECT
		[intBillId]						=	@voucherId,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
		[intItemId]						=	B.intItemId,
		[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId,
		[intPurchaseDetailId]			=	CASE WHEN A.strReceiptType = 'Purchase Order' THEN (CASE WHEN B.intLineNo <= 0 THEN NULL ELSE B.intLineNo END) ELSE NULL END,
		[intContractDetailId]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN E1.intContractDetailId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractDetailId
											ELSE NULL END,
		[intContractHeaderId]			=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN E.intContractHeaderId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractHeaderId
											ELSE NULL END,
		[dblTotal]						=	CAST(ISNULL(detail.dblQtyReceived,(B.dblOpenReceive - B.dblBillQty)) * B.dblUnitCost AS DECIMAL(18,2)),
		[dblTax]						=	B.dblTax,
		[dblQtyOrdered]					=	ISNULL(detail.dblQtyReceived,(B.dblOpenReceive - B.dblBillQty)),
		[dblQtyReceived]				=	ISNULL(detail.dblQtyReceived,(B.dblOpenReceive - B.dblBillQty)),
		[dblDiscount]					=	0,
		[dblCost]						=	B.dblUnitCost,
		[int1099Form]					=	(CASE WHEN F2.str1099Form = '1099-MISC' THEN 1
													WHEN F2.str1099Form = '1099-INT' THEN 2
													WHEN F2.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	G.int1099CategoryId,
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
		[intTaxGroupId]					=	NULL
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN @voucherDetailReceiptPO detail 
		ON B.intInventoryReceiptItemId = detail.intInventoryReceiptItemId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
	INNER JOIN (tblAPVendor F INNER JOIN tblEMEntity F2 ON F.[intEntityId] = F2.intEntityId)
		ON F.[intEntityId] = A.intEntityVendorId
	LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId) 
		ON E.intEntityId = A.intEntityVendorId 
				AND E.intContractHeaderId = B.intOrderId 
				AND E1.intContractDetailId = B.intLineNo
	LEFT JOIN tblAP1099Category G ON F2.str1099Type = G.strCategory
	OUTER APPLY (
		SELECT
			PODetails.intContractDetailId
			,PODetails.intContractHeaderId
		FROM tblPOPurchaseDetail PODetails
		WHERE intPurchaseDetailId = B.intLineNo
	) POContractItems
	WHERE A.ysnPosted = 1 AND B.dblOpenReceive != B.dblBillQty
	--SELECT
	--	[intBillId]						=	@voucherId,
	--	[intAccountId]					=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
	--	[intItemId]						=	B.intItemId,
	--	[intInventoryReceiptItemId]		=	B.intInventoryReceiptItemId,
	--	[intPurchaseDetailId]			=	B.intLineNo,
	--	[intContractDetailId]			=	G.intContractDetailId,
	--	[intContractHeaderId]			=	G.intContractHeaderId,
	--	[dblTotal]						=	(ISNULL(A.dblQtyReceived, (B.dblOpenReceive - B.dblBillQty)) * B.dblUnitCost),
	--	[dblTax]						=	B.dblTax,
	--	[dblQtyOrdered]					=	B.dblOpenReceive,
	--	[dblQtyReceived]				=	ISNULL(A.dblQtyReceived, (B.dblOpenReceive - B.dblBillQty)),
	--	[dblDiscount]					=	0,
	--	[dblCost]						=	B.dblUnitCost,
	--	[int1099Form]					=	(CASE WHEN E2.str1099Form = '1099-MISC' THEN 1
	--												WHEN E2.str1099Form = '1099-INT' THEN 2
	--												WHEN E2.str1099Form = '1099-B' THEN 3
	--											ELSE 0 END),
	--	[int1099Category]				=	F.int1099CategoryId,
	--	[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
	--	[intTaxGroupId]					=	B.intTaxGroupId
	--FROM @voucherDetailReceiptPO A
	--INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	--INNER JOIN tblICInventoryReceipt C ON B.intInventoryReceiptId = C.intInventoryReceiptId
	--LEFT JOIN tblICItemLocation D ON C.intLocationId = D.intLocationId AND D.intItemId = B.intItemId
	--INNER JOIN (tblAPVendor E INNER JOIN tblEMEntity E2 ON E.intEntityVendorId = E2.intEntityId ) ON C.intEntityVendorId = E.intEntityVendorId
	--LEFT JOIN tblAP1099Category F ON E2.str1099Type = F.strCategory
	--LEFT JOIN tblPOPurchaseDetail G ON B.intLineNo = G.intPurchaseDetailId
	--WHERE C.ysnPosted = 1 AND B.dblOpenReceive != B.dblBillQty AND C.strReceiptType = 'Purchase Order'

	--ADD TAXES
	--CREATE TAXES FOR FULL BILLING OF QUANTITY ONLY
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
		--[intTaxGroupMasterId]	=	A.intTaxGroupMasterId, 
		[intTaxGroupId]			=	A.intTaxGroupId, 
		[intTaxCodeId]			=	A.intTaxCodeId, 
		[intTaxClassId]			=	A.intTaxClassId, 
		[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	A.strCalculationMethod, 
		[dblRate]				=	A.dblRate, 
		[intAccountId]			=	A.intTaxAccountId, 
		[dblTax]				=	A.dblTax, 
		[dblAdjustedTax]		=	A.dblAdjustedTax, 
		[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	A.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	A.ysnCheckoffTax
	FROM tblICInventoryReceiptItemTax A
	INNER JOIN @detailCreated B ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	INNER JOIN @voucherDetailReceiptPO C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceiptItem D ON C.intInventoryReceiptItemId = D.intInventoryReceiptItemId
	WHERE ISNULL(C.dblQtyReceived, D.dblOpenReceive) = D.dblOpenReceive

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