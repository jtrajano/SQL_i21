/*
	 
*/
CREATE PROCEDURE [dbo].[uspAPCreateVoucherPODetail]
	@billId INT,
	@voucherPODetails AS VoucherPODetail READONLY
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

	EXEC uspAPValidatePODetailData @billId, @voucherPODetails

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intItemId]						,
		[strMiscDescription]			,
		[intPurchaseDetailId]			,
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
		[intAccountId]					=	ISNULL(dbo.fnGetItemGLAccount(B.intItemId, B2.intItemLocationId, 'General'),D.intGLAccountExpenseId),
		[intItemId]						=	B.[intItemId]					,
		[strMiscDescription]			=	B.strMiscDescription,
		[intPurchaseDetailId]			=	A.[intPurchaseDetailId]			,
		[dblTotal]						=	ISNULL(A.dblCost, B.dblCost) * dbo.fnAPValidatePODetailQtyToReceive(A.intPurchaseDetailId, ISNULL(A.dblQtyReceived, 1))
											- (
												(ISNULL(A.dblCost, B.dblCost)  * (dbo.fnAPValidatePODetailQtyToReceive(A.intPurchaseDetailId, ISNULL(A.dblQtyReceived,1)))) 
												* (ISNULL(A.dblDiscount,0) / 100)
											),
		[dblQtyOrdered]					=	dbo.fnAPValidatePODetailQtyToReceive(A.intPurchaseDetailId, ISNULL(A.dblQtyReceived,1)),
		[dblQtyReceived]				=	dbo.fnAPValidatePODetailQtyToReceive(A.intPurchaseDetailId, ISNULL(A.dblQtyReceived,1)),
		[dblDiscount]					=	ISNULL(A.[dblDiscount],0),
		[dblCost]						=	ISNULL(A.[dblCost],B.dblCost),
		[int1099Form]					=	(CASE WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	F.int1099CategoryId,
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
		[intTaxGroupId]					=	A.[intTaxGroupId]					
	FROM @voucherPODetails A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseDetailId = B.intPurchaseDetailId
	INNER JOIN tblPOPurchase C ON B.intPurchaseId = C.intPurchaseId
	LEFT JOIN tblICItemLocation B2 ON B.intItemId = B2.intItemId AND B2.intLocationId = C.intShipToId
	INNER JOIN tblAPVendor D ON C.intEntityVendorId = D.[intEntityId]
	INNER JOIN tblEMEntity E ON D.[intEntityId] = E.intEntityId
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	WHERE B.dblQtyOrdered != B.dblQtyReceived --EXCLUDE FULLY BILLED PURCHASE DETAIL ITEM

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