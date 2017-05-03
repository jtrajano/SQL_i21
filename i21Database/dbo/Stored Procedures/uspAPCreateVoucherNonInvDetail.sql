/*
	 
*/
CREATE PROCEDURE [dbo].[uspAPCreateVoucherNonInvDetail]
	@billId INT,
	@voucherNonInvDetails AS VoucherDetailNonInventory READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @detailCreated AS Id
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intItemId]						,
		[strMiscDescription]			,
		[dblTotal]						,
		[dblQtyOrdered]					,
		[dblQtyReceived]				,
		[dblDiscount]					,
		[dblCost]						,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						,
		[intTaxGroupId]					
	)
	OUTPUT inserted.intBillDetailId INTO @detailCreated
	SELECT
		[intBillId]						=	@billId							,
		[intAccountId]					=	ISNULL(A.intAccountId ,ISNULL(C2.intAccountId,D.intGLAccountExpenseId)),
		[intItemId]						=	C.[intItemId]					,
		[strMiscDescription]			=	ISNULL(A.strMiscDescription, C.strDescription),
		[dblTotal]						=	CAST((ISNULL(A.dblCost, C.dblReceiveLastCost) * A.dblQtyReceived) 
												- ((ISNULL(A.dblCost, C.dblReceiveLastCost) * A.dblQtyReceived) * (A.dblDiscount / 100)) AS DECIMAL(18,2)),
		[dblQtyOrdered]					=	A.dblQtyReceived,
		[dblQtyReceived]				=	A.dblQtyReceived,
		[dblDiscount]					=	A.[dblDiscount],
		[dblCost]						=	ISNULL(A.dblCost, ISNULL(C.dblReceiveLastCost,0)),
		[int1099Form]					=	(CASE WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	ISNULL(F.int1099CategoryId, 0),
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
		[intTaxGroupId]					=	A.[intTaxGroupId]					
	FROM @voucherNonInvDetails A
	CROSS APPLY tblAPBill B
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.intEntityVendorId
	INNER JOIN tblEMEntity E ON D.intEntityVendorId = E.intEntityId
	LEFT JOIN vyuICGetItemStock C ON C.intItemId = A.intItemId AND B.intShipToId = C.intLocationId
	LEFT JOIN vyuICGetItemAccount C2 ON C.intItemId = C2.intItemId AND C2.strAccountCategory = 'General'
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	WHERE B.intBillId = @billId

	EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

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
