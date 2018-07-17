CREATE PROCEDURE [dbo].[uspAPUpdateQty]
	@detailCreated AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @posted BIT;
DECLARE @shipToId INT;

IF @transCount = 0 BEGIN TRANSACTION

	IF (SELECT TOP 1 ysnPosted FROM tblAPBillDetail A INNER JOIN tblAPBill B ON A.intBillId = B.intBillId  WHERE A.intBillId IN (@detailCreated)) = 1
	BEGIN
		RAISERROR('Data contains posted vouchers', 16, 1);
	END

	UPDATE  dtl
	SET 
		dtl.[dblQtyOrdered]	 = CASE WHEN E1.intContractDetailId > 0 AND SD.intContractDetailId > 0 THEN ROUND(B.dblOrderQty,2) ELSE ISNULL(dtl.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)) END
		,dtl.[dblQtyReceived] = CASE WHEN E1.intContractDetailId > 0 AND SD.intContractDetailId > 0 THEN ROUND(B.dblOrderQty,2) ELSE ISNULL(dtl.dblQtyReceived, ABS(B.dblOpenReceive - B.dblBillQty)) END
	from tblAPBillDetail dtl
		INNER JOIN tblICInventoryReceiptItem B
			ON dtl.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		INNER JOIN  tblICInventoryReceipt A 
			ON B.intInventoryReceiptId = A.intInventoryReceiptId
		INNER JOIN tblICItemLocation D
			ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
		LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId) 
			ON E.intEntityId = A.intEntityVendorId 
					AND E.intContractHeaderId = B.intOrderId 
					AND E1.intContractDetailId = B.intLineNo
		LEFT JOIN vyuSCGetScaleDistribution SD ON SD.intInventoryReceiptItemId = B.intInventoryReceiptItemId					
		WHERE A.ysnPosted = 1 and dtl.intContractDetailId > 0 and dtl.intScaleTicketId > 0 and intBillDetailId = @detailCreated

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
