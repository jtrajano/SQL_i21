CREATE VIEW [dbo].[vyuLGWeightLoss]
	AS

SELECT intInventoryReceiptId
	, dblClaimableWt = (CASE WHEN ((dblNetShippedWt - dblNetReceivedWt) - (dblNetShippedWt * dblFranchise)) > 0.0 
		THEN ((dblNetShippedWt - dblNetReceivedWt) - (dblNetShippedWt * dblFranchise))
		ELSE 0.0 END)
	FROM (
		SELECT ReceiptItem.intInventoryReceiptId
			, dblFranchise = (CASE WHEN Shipment.dblFranchise > 0 
				THEN Shipment.dblFranchise / 100 
				ELSE 0 END)
			, SUM(ReceiptItemSource.dblOrdered * Shipment.dblContainerWeightPerQty) as dblNetShippedWt
			, SUM(ReceiptItem.dblNet) as dblNetReceivedWt
	FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	JOIN vyuLGInboundShipmentView Shipment ON Shipment.intShipmentContractQtyId = ReceiptItem.intSourceId and Shipment.intShipmentBLContainerId = ReceiptItem.intContainerId
	WHERE ReceiptItemSource.strSourceType = 'Inbound Shipment'
	GROUP BY ReceiptItem.intInventoryReceiptId, Shipment.intShipmentId, Shipment.intTrackingNumber, Shipment.dblFranchise, ReceiptItem.intItemId
	) t1