CREATE PROCEDURE [dbo].[uspICUpdateTransferOrderStatus]
	@ReceiptId INT,
	@intStatusId INT
AS

DECLARE @RECEIPT_TYPE_TRANSFER_ORDER VARCHAR(50) = 'Transfer Order'

--1	Open
--2	In Transit
--3	Closed
--4	Short Closed

DECLARE @STATUS_OPEN AS TINYINT = 1
		,@STATUS_IN_TRANSIT AS TINYINT = 2
		,@STATUS_CLOSED AS TINYINT = 3
		,@STATUS_SHORT_CLOSED AS TINYINT = 4 

-- Validate if any of the transfer orders was already closed in other transactions.
IF @intStatusId = @STATUS_CLOSED
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
			AND t.intStatusId = @STATUS_CLOSED
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
		RETURN -80086;
		GOTO Post_Exit
	END
END

/*
	Check for partially received transfer orders. 
	If the received stock is partial, keep the transfer order status as 'In-Transit'
	Otherwise, update the status from the argument in @intStatusId
*/

BEGIN 
	DECLARE @tally_table TABLE( 
		ysnDone bit
		, intInventoryTransferId int
	)
	
	INSERT INTO @tally_table( 
		ysnDone
		,intInventoryTransferId
	)
	SELECT 
		ysnDone = 
			CASE 
				WHEN dbo.fnCalculateQtyBetweenUOM(receiptItems.intUnitMeasureId, transferItems.intItemUOMId, receiptItems.dblTotal) = transferItems.dblTransferQty THEN 1 
				ELSE 0
			END
		,transferItems.intInventoryTransferId 
	FROM 
		tblICInventoryReceipt r 
		CROSS APPLY (
			SELECT 
				intInventoryTransferDetailId = ISNULL(ri.intInventoryTransferDetailId, ri.intSourceId)
				,ri.intUnitMeasureId
				,dblTotal = SUM(ri.dblOpenReceive) 
			FROM 
				tblICInventoryReceiptItem ri
			WHERE
				r.intInventoryReceiptId = ri.intInventoryReceiptId
			GROUP BY
				ISNULL(ri.intInventoryTransferDetailId, ri.intSourceId)
				,ri.intUnitMeasureId
		) receiptItems 
		CROSS APPLY (
			SELECT 
				tf.intInventoryTransferId
				,tfd.intItemUOMId
				,dblTransferQty = tfd.dblQuantity
			FROM 
				tblICInventoryTransfer tf INNER JOIN tblICInventoryTransferDetail tfd
					ON tf.intInventoryTransferId = tfd.intInventoryTransferId
			WHERE
				tfd.intInventoryTransferDetailId = receiptItems.intInventoryTransferDetailId
		) transferItems
	WHERE
		r.intInventoryReceiptId = @ReceiptId
		AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

	UPDATE tf 
	SET 
		tf.intStatusId = 
			CASE 
				WHEN done_tally.dblGroupCount = total_tally.dblTotal THEN @intStatusId 
				ELSE @STATUS_IN_TRANSIT 
			END
	FROM 
		tblICInventoryTransfer tf 
		CROSS APPLY (
			SELECT DISTINCT intInventoryTransferId 
			FROM 
				@tally_table tally 
			WHERE 
				tf.intInventoryTransferId = tally.intInventoryTransferId
		) unique_tally
		OUTER APPLY (
			SELECT 
				dblGroupCount = COUNT(1) 
			FROM 
				@tally_table tally
			WHERE
				tally.intInventoryTransferId = tf.intInventoryTransferId
				AND ysnDone = 1
		) done_tally
		OUTER APPLY (
			SELECT 
				dblTotal = COUNT(1) 
			FROM 
				@tally_table tally
			WHERE
				tally.intInventoryTransferId = tf.intInventoryTransferId		
		) total_tally			
END 

Post_Exit: