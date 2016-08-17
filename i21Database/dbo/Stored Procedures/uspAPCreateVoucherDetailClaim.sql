﻿CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailClaim]
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
		[intItemId]						,
		[dblTotal]						,
		[dblQtyOrdered]					,
		[dblQtyReceived]				,
		[dblCost]						,
		[dblNetShippedWeight]			,
		[dblFranchiseWeight]			,
		[dblWeightLoss]					,
		[dblClaimAmount]				,
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
		[intItemId]						=	A.[intItemId]					,
		[dblTotal]						=	A.dblClaim						,
		[dblNetShippedWeight]			=	A.dblNetShippedWeight			,
		[dblFranchiseWeight]			=	A.dblFranchiseWeight			,
		[dblWeightLoss]					=	A.dblWeightLoss					,
		[dblClaimAmount]				=	A.dblClaim						,
		[dblQtyOrdered]					=	1,
		[dblQtyReceived]				=	1,
		[dblCost]						=	A.dblCost,
		[int1099Form]					=	(CASE WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	ISNULL(F.int1099CategoryId, 0),
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))			
	FROM @voucherDetailClaim A
	CROSS APPLY tblAPBill B
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.intEntityVendorId
	INNER JOIN tblEMEntity E ON D.intEntityVendorId = E.intEntityId
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	WHERE B.intBillId = @voucherId
	
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