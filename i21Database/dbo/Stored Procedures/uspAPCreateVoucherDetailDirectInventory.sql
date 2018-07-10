CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailDirectInventory]
	@voucherId INT,
	@voucherDetailDirect AS [VoucherDetailDirectInventory] READONLY
AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @detailCreated AS Id
DECLARE @voucherIds AS Id;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intItemId]						,
		[strMiscDescription]			,
		-- [dblTotal]						,
		[intUnitOfMeasureId]			,
		[dblQtyOrdered]					,
		[dblUnitQty]					,
		[dblQtyReceived]				,
		[dblDiscount]					,
		[intCostUOMId]					,
		[dblCost]						,
		[dblCostUnitQty]				,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						,
		[intTaxGroupId]					,
		[intContractDetailId]			,
		[intContractHeaderId]			,
		[intLoadDetailId]				,
		[intLoadId]						,
		[intScaleTicketId]
	)
	OUTPUT inserted.intBillDetailId INTO @detailCreated
	SELECT
		[intBillId]						=	@voucherId							,
		[intAccountId]					=	dbo.[fnGetItemGLAccount](A.intItemId, loc.intItemLocationId, 'AP Clearing'),
		[intItemId]						=	C.[intItemId],					
		[strMiscDescription]			=	ISNULL(A.strMiscDescription, C.strDescription),
		-- [dblTotal]						=	CAST((ISNULL(A.dblCost, C.dblReceiveLastCost) * A.dblQtyReceived) 
		-- 										- ((ISNULL(A.dblCost, C.dblReceiveLastCost) * A.dblQtyReceived) * (A.dblDiscount / 100)) AS DECIMAL(18,2)),
		[intUnitOfMeasureId]			=	CASE WHEN ctd.intItemUOMId > 0 
												THEN ctd.intItemUOMId
												ELSE A.intUnitOfMeasureId
											END,
		[dblQtyOrdered]					=	dbo.fnCalculateQtyBetweenUOM(A.intUnitOfMeasureId
																			,CASE WHEN ctd.intItemUOMId > 0 THEN ctd.intItemUOMId ELSE A.intUnitOfMeasureId END
																			,A.dblQtyReceived),
		[dblUnitQty]					=	CASE WHEN ctd.intItemUOMId > 0 THEN ctd.dblUnitQty ELSE A.dblUnitQty END,
		[dblQtyReceived]				=	dbo.fnCalculateCostBetweenUOM(A.intUnitOfMeasureId
																			,CASE WHEN ctd.intItemUOMId > 0 THEN ctd.intItemUOMId ELSE A.intUnitOfMeasureId END
																			,A.dblQtyReceived),
		[dblDiscount]					=	A.[dblDiscount],
		[intCostUOMId]					=	CASE WHEN ctd.intCostUOMId > 0 THEN ctd.intCostUOMId ELSE A.intCostUOMId END,
		[dblCost]						=	dbo.fnCalculateCostBetweenUOM(A.intCostUOMId
																		,CASE WHEN ctd.intCostUOMId > 0 THEN ctd.intCostUOMId ELSE A.intCostUOMId END
																		,ISNULL(A.dblCost, ISNULL(C.dblReceiveLastCost,0))),
		[dblCostUnitQty]				=	CASE WHEN ctd.intCostUOMId > 0 THEN ctd.dblCostUnitQty ELSE A.dblCostUnitQty END,
		[int1099Form]					=	(CASE WHEN patron.intEntityId IS NOT NULL 
														AND C.intItemId > 0
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 4
													WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	CASE 	WHEN patron.intEntityId IS NOT NULL 
														AND C.intItemId > 0
														AND C.ysn1099Box3 = 1
														AND patron.ysnStockStatusQualified = 1 
														THEN 3
											ELSE ISNULL(F.int1099CategoryId, 0) END,
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
		[intTaxGroupId]					=	A.[intTaxGroupId],
		[intContractDetailId]			=	ctd.intContractDetailId,
		[intContractHeaderId]			=	ctd.intContractHeaderId,
		[intLoadDetailId]				=	A.intLoadDetailId,
		[intLoadId]						=	lgLoad.intLoadId,
		[intScaleTicketId]				=	A.[intScaleTicketId]										
	FROM @voucherDetailDirect A
	CROSS APPLY tblAPBill B
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.[intEntityId]
	INNER JOIN tblEMEntity E ON D.[intEntityId] = E.intEntityId
	LEFT JOIN vyuCTContractDetailView ctd ON A.intContractDetailId = ctd.intContractDetailId
	LEFT JOIN tblLGLoad lgLoad ON A.intLoadDetailId = lgLoad.intLoadDetailId
	LEFT JOIN vyuICGetItemStock C ON C.intItemId = A.intItemId AND B.intShipToId = C.intLocationId
	LEFT JOIN tblICItemLocation loc ON loc.intItemId = A.intItemId AND loc.intLocationId = B.intShipToId
	LEFT JOIN vyuPATEntityPatron patron ON B.intEntityVendorId = patron.intEntityId
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	WHERE B.intBillId = @voucherId

	EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

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
