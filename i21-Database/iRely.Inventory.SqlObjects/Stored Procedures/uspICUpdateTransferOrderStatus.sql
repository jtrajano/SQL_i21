CREATE PROCEDURE [dbo].[uspICUpdateTransferOrderStatus]
	@ReceiptId INT,
	@intStatusId INT
AS

DECLARE @RECEIPT_TYPE_TRANSFER_ORDER VARCHAR(50) = 'Transfer Order'

-- Validate if any of the transfer orders was already closed in other transactions.
IF @intStatusId = 3
	BEGIN
	DECLARE @PostedTransferOrder VARCHAR(50) = NULL
	DECLARE @PostedTransferOrderReceipt VARCHAR(50) = NULL

	SELECT TOP 1 @PostedTransferOrder = rt.strTransferNo, @PostedTransferOrderReceipt = rr.strReceiptNumber
	FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem i ON i.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = i.intOrderId
		LEFT OUTER JOIN tblICInventoryTransfer rt ON rt.intInventoryTransferId = t.intInventoryTransferId
			AND rt.ysnShipmentRequired = 1
			AND rt.intStatusId = 3
			AND rt.ysnPosted = 1
		LEFT OUTER JOIN tblICInventoryReceipt rr ON rr.intInventoryReceiptId <> r.intInventoryReceiptId
			AND rr.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
			AND rr.ysnPosted = 1
	WHERE r.intInventoryReceiptId = @ReceiptId
		AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

	IF @PostedTransferOrder IS NOT NULL
	BEGIN
		EXEC uspICRaiseError 80086, @PostedTransferOrder, @PostedTransferOrderReceipt;
		GOTO Post_Exit
	END
END

-- IF Status is updated in Posting
-- t.intStatusId = CASE WHEN ri.dblOrderQty = (ISNULL(tf.dblReceiptQty, 0) + ri.dblOpenReceive) THEN @intStatusId ELSE 2 END
UPDATE t
SET t.intStatusId = CASE WHEN ri.dblOrderQty = (ISNULL(tf.dblReceiptQty, 0) ) THEN @intStatusId ELSE 2 END
FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = ri.intOrderId
	LEFT OUTER JOIN (
		SELECT st.intInventoryTransferId, SUM(ISNULL(st.dblReceiptQty, 0)) dblReceiptQty 
		FROM vyuICGetItemStockTransferred st
		GROUP BY st.intInventoryTransferId
	) tf ON tf.intInventoryTransferId = t.intInventoryTransferId
WHERE r.intInventoryReceiptId = @ReceiptId
	AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

DECLARE @Count INT
SELECT @Count = COUNT(*)
FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = ri.intOrderId
WHERE r.intInventoryReceiptId = @ReceiptId
	AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
	
IF(@Count = 0)
BEGIN

	DECLARE @TransferId INT
	SELECT TOP 1 @TransferId = ar.intOrderId
	FROM #tmpBeforeSaveReceiptItems ar
	WHERE ar.intInventoryReceiptId = @ReceiptId

	UPDATE t
	SET t.intStatusId = 2
	FROM tblICInventoryTransfer t
	WHERE t.intInventoryTransferId = @TransferId

	-- UPDATE t
	-- SET t.intStatusId = CASE WHEN ISNULL(tf.dblReceiptQty, 0) > 0 THEN 2 ELSE 1 END
	-- FROM tblICInventoryTransfer t
	-- 	LEFT OUTER JOIN (
	-- 		SELECT st.intInventoryTransferId, SUM(ISNULL(st.dblReceiptQty, 0)) dblReceiptQty 
	-- 		FROM vyuICGetItemStockTransferred st
	-- 		GROUP BY st.intInventoryTransferId
	-- 	) tf ON tf.intInventoryTransferId = t.intInventoryTransferId
	-- WHERE t.intInventoryTransferId = @TransferId
END


Post_Exit: