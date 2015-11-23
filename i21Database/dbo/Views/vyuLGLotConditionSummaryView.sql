CREATE VIEW vyuLGLotConditionSummaryView
	AS
SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intShipmentId)) as intKeyColumn, *, 
	(dblNetShippedWt - dblNetReceivedWt) as dblWeightLoss,
	CASE WHEN strCondition = 'Sound/Full' THEN
			(dblNetShippedWt * dblFranchisePercent)
		ELSE 
			0.0
		END as dblFranchiseWt,
	CASE WHEN strCondition = 'Sound/Full' THEN
			CASE WHEN ((dblNetShippedWt - dblNetReceivedWt) - (dblNetShippedWt * dblFranchisePercent)) > 0.0 THEN
					((dblNetShippedWt - dblNetReceivedWt) - (dblNetShippedWt * dblFranchisePercent))
				ELSE
					0.0
				END
		ELSE 
			CASE WHEN strCondition = 'Damaged' THEN
				 (dblNetShippedWt - dblNetReceivedWt)
				 ELSE
				 (dblNetShippedWt - dblNetReceivedWt)
			END
		END as dblClaimableWt
FROM (
	SELECT
	Shipment.intShipmentId,
	Shipment.intTrackingNumber,
	dblFranchisePercent = Shipment.dblFranchise / 100,
	ReceiptItem.intItemId,
	CASE WHEN ReceiptLot.strCondition = 'Sound/Full' THEN
			1
		ELSE 
			CASE WHEN ReceiptLot.strCondition = 'Damaged' THEN
				2
			END
		END as intSequence,
	ReceiptLot.strCondition,
	sum(ReceiptLot.dblQuantity) as dblQuantity, 
	sum(ReceiptLot.dblQuantity * Shipment.dblContainerWeightPerQty) as dblNetShippedWt,
	sum(ReceiptLot.dblGrossWeight-ReceiptLot.dblTareWeight) as dblNetReceivedWt
FROM tblICInventoryReceiptItemLot ReceiptLot
LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
LEFT JOIN vyuLGInboundShipmentView Shipment ON Shipment.intShipmentContractQtyId = ReceiptItem.intSourceId and Shipment.intShipmentBLContainerId = ReceiptItem.intContainerId
GROUP BY Shipment.intShipmentId, Shipment.intTrackingNumber, Shipment.dblFranchise, ReceiptLot.strCondition, ReceiptItem.intItemId) t1