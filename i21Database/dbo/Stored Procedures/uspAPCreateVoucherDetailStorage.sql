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
DECLARE @detailCreated AS Id
DECLARE @voucherIds AS Id;
DECLARE @error NVARCHAR(200);
DECLARE @expense INT;
DECLARE @int1099 INT;
DECLARE @str1099 NVARCHAR(50);
	
IF @transCount = 0 BEGIN TRANSACTION

	SELECT 
	@expense = intGLAccountExpenseId,
	@str1099 = B2.str1099Type,
	@int1099 = C.int1099CategoryId
	FROM tblAPBill A
	INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityVendorId = B2.intEntityId) ON A.intEntityVendorId = B.intEntityVendorId
	LEFT JOIN tblAP1099Category C ON B2.str1099Type = C.strCategory
	WHERE A.intBillId = @voucherId

	INSERT INTO tblAPBillDetail(
		[intBillId]						,
		[intAccountId]					,
		[intItemId]						,
		[intCustomerStorageId]			,
		[intContractHeaderId]			,
		[intContractDetailId]			,
		[strMiscDescription]			,
		[dblTotal]						,
		[dblQtyOrdered]					,
		[dblQtyReceived]				,
		[dblCost]						,
		[int1099Form]					,
		[int1099Category]				,
		[intLineNo]						
	)
	OUTPUT inserted.intBillDetailId INTO @detailCreated
	SELECT
		[intBillId]						=	@voucherId,
		[intAccountId]					=	ISNULL(A.intAccountId , ISNULL(G.intAccountId, @expense)),
		[intItemId]						=   A.intItemId,
		[intCustomerStorageId]			=	A.intCustomerStorageId,
		[intContractHeaderId]			=	A.intContractHeaderId,
		[intContractDetailId]			=	A.intContractDetailId,
		[strMiscDescription]				=	ISNULL(A.strMiscDescription, A2.strDescription),
		[dblTotal]						=	A.dblCost * A.dblQtyReceived,
		[dblQtyOrdered]					=	A.dblQtyReceived,
		[dblQtyReceived]					=	A.dblQtyReceived,
		[dblCost]						=	A.dblCost,
		[int1099Form]					=	(CASE WHEN @str1099 = '1099-MISC' THEN 1
													WHEN @str1099 = '1099-INT' THEN 2
													WHEN @str1099 = '1099-B' THEN 3
												ELSE 0 END),
		[int1099Category]				=	ISNULL(@int1099, 0),
		[intLineNo]						=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))			
	FROM @voucherDetailStorage A
	INNER JOIN tblICItem A2 ON A.intItemId = A2.intItemId
	LEFT JOIN tblICItemAccount G ON G.intItemId = A2.intItemId 
	LEFT JOIN tblGLAccountCategory GLAccountCategory ON GLAccountCategory.intAccountCategoryId = G.intAccountCategoryId
	WHERE GLAccountCategory.strAccountCategory = 'General' 
	
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
