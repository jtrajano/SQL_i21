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

	SELECT TOP 1 
		@PostedTransferOrder = t.strTransferNo
		, @PostedTransferOrderReceipt = postedReceipt.strReceiptNumber
	FROM 
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem i 
			ON i.intInventoryReceiptId = r.intInventoryReceiptId

		INNER JOIN tblICInventoryTransfer t 
			ON 
			r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
			AND (
				(t.intInventoryTransferId = i.intSourceId AND i.intSourceId IS NOT NULL)
				OR (t.intInventoryTransferId = i.intInventoryTransferId AND i.intInventoryTransferId IS NOT NULL) 
			)			
			AND t.ysnShipmentRequired = 1
			AND t.intStatusId = 3
			AND t.ysnPosted = 1

		LEFT JOIN (
			tblICInventoryReceipt postedReceipt INNER JOIN tblICInventoryReceiptItem postedReceiptItem
				ON postedReceipt.intInventoryReceiptId = postedReceiptItem.intInventoryReceiptId
		)
			ON postedReceipt.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER
			AND (
				(t.intInventoryTransferId = postedReceiptItem.intSourceId AND postedReceiptItem.intSourceId IS NOT NULL)
				OR (t.intInventoryTransferId = postedReceiptItem.intInventoryTransferId AND postedReceiptItem.intInventoryTransferId IS NOT NULL) 
			)						
			AND postedReceipt.ysnPosted = 1
			AND postedReceipt.intInventoryReceiptId <> r.intInventoryReceiptId

	WHERE 
		r.intInventoryReceiptId = @ReceiptId
		AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

	IF @PostedTransferOrder IS NOT NULL
	BEGIN
		-- 'Cannot post this Inventory Receipt. The transfer order "{Transfer No}" was already posted in "{Inventory Receipt}".'
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