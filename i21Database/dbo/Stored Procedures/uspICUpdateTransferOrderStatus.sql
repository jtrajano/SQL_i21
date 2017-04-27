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
		RAISERROR('Cannot post this Inventory Receipt. The transfer order "%s" was already posted in "%s".', 11, 1, @PostedTransferOrder, @PostedTransferOrderReceipt)
		GOTO Post_Exit
	END
END

-- Update the status of the transfer order
UPDATE t
SET t.intStatusId = @intStatusId
FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem i ON i.intInventoryReceiptId = r.intInventoryReceiptId
	INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = i.intOrderId
WHERE r.intInventoryReceiptId = @ReceiptId
	AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

Post_Exit: