CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetail]
	@billId INT,
	@voucherPODetails AS VoucherPODetail READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

CREATE TABLE #tmpCreatedBillDetail (
	[intBillDetailId] [INT]
	UNIQUE ([intBillDetailId])
);

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	IF EXISTS(SELECT 1 FROM @voucherPODetails)
	BEGIN
		INSERT INTO tblAPBillDetail(
			[intBillId]						,
			[strMiscDescription]			,
			[strComment]					,
			[intAccountId]					,
			[intItemId]						,
			[intInventoryReceiptItemId]		,
			[intInventoryReceiptChargeId]   ,
			[intPurchaseDetailId]			,
			[intContractHeaderId]			,
			[intContractDetailId]			,
			[intPrepayTypeId]				,
			[dblTotal]						,
			[dblQtyContract]				,
			[dblContractCost]				,
			[dblQtyOrdered]					,
			[dblQtyReceived]				,
			[dblDiscount]					,
			[dblCost]						,
			[dblTax]						,
			[dblPrepayPercentage]			,
			[int1099Form]					,
			[int1099Category]				,
			[ysn1099Printed]				,
			[intLineNo]						,
			[intTaxGroupId]					
		)
		OUTPUT inserted.intBillDetailId INTO #tmpCreatedBillDetail
		SELECT
			[intBillId]						=	@billId							,
			[strMiscDescription]			=	A.[strMiscDescription]			,
			[strComment]					=	A.[strComment]					,
			[intAccountId]					=	ISNULL(A.[intAccountId], [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Inventory')),
			[intItemId]						=	A.[intItemId]					,
			[intPurchaseDetailId]			=	A.[intPurchaseDetailId]			,
			[dblTotal]						=	(A.dblCost * A.dblQtyReceived) - ((A.dblCost * A.dblQtyReceived) * (A.dblDiscount / 100)),
			[dblQtyOrdered]					=	A.[dblQtyReceived]				,
			[dblQtyReceived]				=	A.[dblQtyReceived]				,
			[dblDiscount]					=	A.[dblDiscount]					,
			[dblCost]						=	A.[dblCost]						,
			[intLineNo]						=	A.[intLineNo]					,
			[intTaxGroupId]					=	A.[intTaxGroupId]					
		FROM @voucherPODetails A
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
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH