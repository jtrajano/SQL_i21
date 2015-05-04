CREATE PROCEDURE [dbo].[uspPOUpdateReceivedQty]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE A
	SET A.dblQtyReceived = ISNULL(Received.dblTotalReceived, 0)
FROM tblPOPurchaseDetail A
OUTER APPLY
(
	SELECT 
		SUM(dblTotalReceived) dblTotalReceived
		,intLineNo
	FROM (
		SELECT 
			dbo.[fnCalculateQtyBetweenUOM](C.intUnitMeasureId, A.intUnitOfMeasureId, SUM(C.dblOpenReceive)) dblTotalReceived
			,C.intLineNo
		FROM tblICInventoryReceipt B
			INNER JOIN tblICInventoryReceiptItem C
				ON B.intInventoryReceiptId = C.intInventoryReceiptId
		WHERE B.ysnPosted = 1 
		AND C.intLineNo = A.intPurchaseDetailId
		GROUP BY C.intLineNo, C.intUnitMeasureId
	) TotalReceived
	GROUP BY intLineNo
) Received

END