CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetail]
	@billId INT,
	@voucherDetails AS VoucherDetailData READONLY
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
		[intBillId]						=	@billId						,
		[strMiscDescription]			=	A.[strMiscDescription]			,
		[strComment]					=	A.[strComment]					,
		[intAccountId]					=	A.[intAccountId]					,
		[intItemId]						=	A.[intItemId]						,
		[intInventoryReceiptItemId]		=	A.[intInventoryReceiptItemId]		,
		[intInventoryReceiptChargeId]   =	A.[intInventoryReceiptChargeId]   ,
		[intPurchaseDetailId]			=	A.[intPurchaseDetailId]			,
		[intContractHeaderId]			=	A.[intContractHeaderId]			,
		[intContractDetailId]			=	A.[intContractDetailId]			,
		[intPrepayTypeId]				=	A.[intPrepayTypeId]				,
		[dblTotal]						=	A.[dblTotal]						,
		[dblQtyContract]				=	A.[dblQtyContract]				,
		[dblContractCost]				=	A.[dblContractCost]				,
		[dblQtyOrdered]					=	A.[dblQtyOrdered]					,
		[dblQtyReceived]				=	A.[dblQtyReceived]				,
		[dblDiscount]					=	A.[dblDiscount]					,
		[dblCost]						=	A.[dblCost]						,
		[dblTax]						=	A.[dblTax]						,
		[dblPrepayPercentage]			=	A.[dblPrepayPercentage]			,
		[int1099Form]					=	A.[int1099Form]					,
		[int1099Category]				=	A.[int1099Category]				,
		[ysn1099Printed]				=	A.[ysn1099Printed]				,
		[intLineNo]						=	A.[intLineNo]						,
		[intTaxGroupId]					=	A.[intTaxGroupId]					
	FROM dbo.fnAPCreateVoucherDetailData(@voucherDetails) A

	

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