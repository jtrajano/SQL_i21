CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetailStorage]
	@voucherId INT,
	@voucherDetailStorage AS [VoucherDetailStorage] READONLY
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
IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intItemId]						,
		[intCustomerStorageId]			,
		[strMiscDescription]				,
		[dblTotal]						,
		[dblQtyOrdered]					,
		[dblQtyReceived]					,
		[dblCost]						,
		[int1099Form]					,
		[int1099Category]				,
		[intContractDetailId]			,
		[intContractHeaderId]			,
		[intLineNo]						
	)
	SELECT
		[intBillId]						=	@voucherId,
		[intAccountId]					=	ISNULL(A.intAccountId , ISNULL(dbo.[fnGetItemGLAccount](A.intItemId, loc.intItemLocationId, 'AP Clearing'), D.intGLAccountExpenseId)),
		[intItemId]						=	A.intItemId,
		[intCustomerStorageId]			=	A.intCustomerStorageId,
		[strMiscDescription]				=	ISNULL(A.strMiscDescription, A2.strDescription),
		[dblTotal]						=	CAST(A.dblCost * A.dblQtyReceived  AS DECIMAL(18,2)),
		[dblQtyOrdered]					=	A.dblQtyReceived,
		[dblQtyReceived]					=	A.dblQtyReceived,
		[dblCost]						=	A.dblCost,
		[int1099Form]					=	(CASE WHEN E.str1099Form = '1099-MISC' THEN 1
													WHEN E.str1099Form = '1099-INT' THEN 2
													WHEN E.str1099Form = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	ISNULL(F.int1099CategoryId, 0),
		[intContractDetailId]			=	A.intContractDetailId,
		[intContractHeaderId]			=	A.intContractHeaderId,
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))			
	FROM @voucherDetailStorage A
	INNER JOIN tblICItem A2 ON A.intItemId = A2.intItemId
	CROSS APPLY tblAPBill B
	INNER JOIN tblAPVendor D ON B.intEntityVendorId = D.intEntityVendorId
	INNER JOIN tblEMEntity E ON D.intEntityVendorId = E.intEntityId
	LEFT JOIN tblICItemLocation loc ON loc.intLocationId = B.intShipToId AND loc.intItemId = A.intItemId
	LEFT JOIN tblAP1099Category F ON E.str1099Type = F.strCategory
	--LEFT JOIN vyuICGetItemAccount G ON G.intItemId = A2.intItemId AND G.strAccountCategory = 'AP Clearing'
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
