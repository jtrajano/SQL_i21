CREATE PROCEDURE [dbo].[uspPOReceivedMiscItem]
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	--UPDATE MISC RECEIVED QTY
	UPDATE A
		SET A.dblQtyReceived = CASE WHEN voucherQty.dblQtyReceived > A.dblQtyReceived
									THEN A.dblQtyOrdered
									ELSE ISNULL(voucherQty.dblQtyReceived, 0)
								END
	FROM tblPOPurchaseDetail A
	LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
	OUTER APPLY
	(
		SELECT
			SUM(B.dblQtyReceived) dblQtyReceived
		FROM tblAPBillDetail B
		WHERE A.intPurchaseDetailId = B.intPurchaseDetailId
	) voucherQty
	WHERE
	(dbo.fnIsStockTrackingItem(A.intItemId) = 0 OR item.intItemId IS NULL)

END