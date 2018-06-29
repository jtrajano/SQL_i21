CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailClaim]
	@voucherId INT,
	@voucherDetailClaim AS VoucherDetailClaim READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @detailCreated AS Id;
DECLARE @voucherIds AS Id;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intContractDetailId]			,
		[intContractHeaderId]			,
		[intInventoryReceiptItemId]		,
		[intPrepayTransactionId]		,
		[intItemId]						,
		[intWeightUOMId]				,
		[intCostUOMId]					,
		[intUnitOfMeasureId]			,
		[dblCostUnitQty]				,
		[dblWeightUnitQty]				,
		[dblUnitQty]					,
		[dblTotal]						,
		[dblNetShippedWeight]			,
		[dblFranchiseWeight]			,
		[dblFranchiseAmount]			,
		[dblWeightLoss]					,
		[dblClaimAmount]				,
		[dblQtyOrdered]					,
		[dblQtyReceived]				,
		[dblCost]						,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						
	)
	OUTPUT inserted.intBillDetailId INTO @detailCreated
	SELECT
		[intBillId]						=	@voucherId						,
		[intAccountId]					=	D.intGLAccountExpenseId			,
		[intContractDetailId]			=	A.intContractDetailId			,
		[intContractHeaderId]			=	A.intContractHeaderId			,
		[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId		,
		[intPrepayTransactionId]		=	prepayTransaction.intBillId		,
		[intItemId]						=	A.[intItemId]					,
		[intWeightUOMId]				=	A.intWeightUOMId				,
		[intCostUOMId]					=	A.intCostUOMId					,
		[intUnitOfMeasureId]			=	A.intUOMId						,
		[dblCostUnitQty]				=	A.dblCostUnitQty				,
		[dblWeightUnitQty]				=	A.dblWeightUnitQty				,
		[dblUnitQty]					=	A.dblUnitQty					,
		[dblTotal]						=	CAST(A.dblCost * A.dblQtyReceived AS DECIMAL(18,2)),
		[dblNetShippedWeight]			=	A.dblNetShippedWeight			,
		[dblFranchiseWeight]			=	A.dblFranchiseWeight			,
		[dblFranchiseAmount]			=	A.dblFranchiseAmount			,
		[dblWeightLoss]					=	A.dblWeightLoss					,
		[dblClaimAmount]				=	CAST(A.dblCost * A.dblQtyReceived AS DECIMAL(18,2)),
		[dblQtyOrdered]					=	A.dblQtyReceived,
		[dblQtyReceived]				=	A.dblQtyReceived,
		[dblCost]						=	A.dblCost,
		[int1099Form]					=	(CASE WHEN patron.intEntityId IS NOT NULL 
														AND item.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND item.intItemId > 0
														AND item.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 3
											ELSE ISNULL(F.int1099CategoryId, 0) END,
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))			
	FROM @voucherDetailClaim A
	CROSS APPLY tblAPBill B
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.[intEntityId]
	INNER JOIN tblEMEntity E ON D.[intEntityId] = E.intEntityId
	LEFT JOIN (tblAPBill prepayTransaction 
					INNER JOIN tblAPBillDetail prepayDetail ON prepayTransaction.intBillId = prepayDetail.intBillId AND prepayTransaction.intTransactionType = 2)
			ON prepayDetail.intContractDetailId = A.intContractDetailId
	LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	LEFT JOIN vyuPATEntityPatron patron ON B.intEntityVendorId = patron.intEntityId
	WHERE B.intBillId = @voucherId

	--UPDATE VOUCHER AP ACCOUNT WITH THE CORRECT PREPAID ACCOUNT USED ON THE PREPAYMENT
	UPDATE A
		SET A.intAccountId = ISNULL(prepay.intAccountId, A.intAccountId)
	FROM tblAPBill A
	CROSS APPLY (
		SELECT TOP 1
			B.intAccountId
		FROM tblAPBill B
		INNER JOIN tblAPBillDetail C ON C.intPrepayTransactionId = B.intBillId
		WHERE C.intBillId = A.intBillId
	) prepay

	WHERE A.intBillId = @voucherId
	
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