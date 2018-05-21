/*
	 
*/
CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailLoadNonInv]
	@voucherId INT,
	@voucherDetailLoadNonInv AS VoucherDetailLoadNonInv READONLY
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
		[intItemId]						,
		[intUnitOfMeasureId]			,
		[intContractSeq]				,
		[intLoadDetailId]				,
		[dblTotal]						,
		[dblQtyOrdered]					,
		[dblQtyReceived]				,
		[dblCost]						,
		[intCostUOMId]					,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						
	)
	OUTPUT inserted.intBillDetailId INTO @detailCreated
	SELECT
		[intBillId]						=	@voucherId							,
		[intAccountId]					=	A.intAccountId,
		[intContractDetailId]			=	A.intContractDetailId,
		[intContractHeaderId]			=	A.intContractHeaderId,
		[intItemId]						=	A.[intItemId]					,
		[intUnitOfMeasureId]			=	A.[intItemUOMId]					,
		[intContractSeq]				=	G.intContractSeq,
		[intLoadDetailId]				=	A.intLoadDetailId,
		[dblTotal]						=	CAST(A.dblCost * A.dblQtyReceived  AS DECIMAL(18,2)),
		[dblQtyOrdered]					=	A.dblQtyReceived,
		[dblQtyReceived]				=	A.dblQtyReceived,
		[dblCost]						=	A.dblCost,
		[intCostUOMId]					=	A.intCostUOMId,
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
	FROM @voucherDetailLoadNonInv A
	CROSS APPLY tblAPBill B
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.[intEntityId]
	INNER JOIN tblEMEntity E ON D.[intEntityId] = E.intEntityId
	INNER JOIN tblCTContractDetail G ON A.intContractDetailId = G.intContractDetailId
	INNER JOIN tblICItem item ON A.intItemId = item.intItemId
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
