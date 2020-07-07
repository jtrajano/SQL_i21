PRINT N'START - Populate the Transaction UOM in Inventory Valuation'
GO

IF	EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransaction t WHERE t.intTransactionItemUOMId IS NULL) 
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransaction t WHERE t.intTransactionItemUOMId IS NOT NULL) 
BEGIN 
	UPDATE t
	SET 
		t.intTransactionItemUOMId = 
			COALESCE(
				lot.intWeightUOMId
				, lot.intItemUOMId 
				, Receipt.intItemUOMId
				, Shipment.intItemUOMId
				, InventoryTransfer.intItemUOMId
				, InventoryAdjustment.intItemUOMId
				, InventoryCount.intItemUOMId 
				, AR.intItemUOMId 
				, t.intItemUOMId
			)
	FROM 
		tblICInventoryTransaction t 
		LEFT JOIN tblICLot lot
			ON t.intLotId = lot.intLotId
		OUTER APPLY (
			SELECT 
				intItemUOMId = ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId) 
			FROM
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			WHERE
				r.strReceiptNumber = t.strTransactionId 	
				AND r.intInventoryReceiptId = t.intTransactionId
				AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
				AND t.strTransactionForm = 'Inventory Receipt'
		) Receipt
		OUTER APPLY (
			SELECT 
				intItemUOMId = si.intItemUOMId
			FROM
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
			WHERE
				s.strShipmentNumber = t.strTransactionId
				AND s.intInventoryShipmentId = t.intTransactionId
				AND si.intInventoryShipmentItemId = t.intTransactionDetailId
				AND t.strTransactionForm = 'Inventory Shipment'			
		) Shipment
		OUTER APPLY (
			SELECT 
				intItemUOMId = tfd.intItemUOMId
			FROM
				tblICInventoryTransfer tf INNER JOIN tblICInventoryTransferDetail tfd
					ON tf.intInventoryTransferId = tfd.intInventoryTransferId
			WHERE
				tf.strTransferNo = t.strTransactionId
				AND tf.intInventoryTransferId = t.intTransactionId
				AND tfd.intInventoryTransferDetailId = t.intTransactionDetailId
				AND t.strTransactionForm = 'Inventory Transfer'			
		) InventoryTransfer
		OUTER APPLY (
			SELECT 
				intItemUOMId = ad.intItemUOMId
			FROM
				tblICInventoryAdjustment a INNER JOIN tblICInventoryAdjustmentDetail ad
					ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
			WHERE
				a.strAdjustmentNo = t.strTransactionId
				AND a.intInventoryAdjustmentId = t.intTransactionId
				AND ad.intInventoryAdjustmentDetailId = t.intTransactionDetailId
				AND t.strTransactionForm = 'Inventory Adjustment'			
		) InventoryAdjustment
		OUTER APPLY (
			SELECT 
				intItemUOMId = cd.intItemUOMId
			FROM
				tblICInventoryCount c INNER JOIN tblICInventoryCountDetail cd
					ON c.intInventoryCountId = cd.intInventoryCountId
			WHERE
				c.strCountNo = t.strTransactionId
				AND c.intInventoryCountId = t.intTransactionId
				AND cd.intInventoryCountDetailId = t.intTransactionDetailId
				AND t.strTransactionForm = 'Inventory Count'			
		) InventoryCount
		OUTER APPLY (
			SELECT 
				intItemUOMId = ard.intItemUOMId
			FROM
				tblARInvoice ar INNER JOIN tblARInvoiceDetail ard
					ON ar.intInvoiceId = ard.intInvoiceId
			WHERE
				ar.strInvoiceNumber = t.strTransactionId
				AND ar.intInvoiceId = t.intTransactionId
				AND ard.intInvoiceDetailId = t.intTransactionDetailId
				AND t.strTransactionForm IN ('Credit Memo', 'Invoice')
		) AR

	WHERE
		t.intTransactionItemUOMId IS NULL 
END 

GO

PRINT N'END - Populate the Transaction UOM in Inventory Valuation'
GO