CREATE VIEW [dbo].[vyuICGetShipmentItemSource]
	AS 

SELECT 
	ShipmentItem.intInventoryShipmentItemId,
	ShipmentItem.intOrderId,
	strOrderNumber = 
		(
			CASE WHEN Shipment.intOrderType = 1 -- Sales Contract
				THEN ContractView.strContractNumber
			WHEN Shipment.intOrderType = 2 -- Sales Order
				THEN SODetail.strSalesOrderNumber
			WHEN Shipment.intOrderType = 3 -- Transfer Order
				THEN NULL
			ELSE NULL
			END
		),
	strSourceNumber =
		CASE WHEN Shipment.intSourceType = 1 -- Scale
				THEN ScaleView.strTicketNumber
			WHEN Shipment.intSourceType = 2 -- Inbound Shipment
				THEN CONVERT(NVARCHAR(100), LogisticView.intTrackingNumber)
			WHEN Shipment.intSourceType = 3 -- Pick Lot
				THEN CONVERT(NVARCHAR(100), PickLot.intReferenceNumber)
			ELSE NULL
			END,
	strOrderUOM = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (
					CASE WHEN Shipment.intSourceType = 0 -- None
						THEN ContractView.strItemUOM
					WHEN Shipment.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						THEN NULL
					WHEN Shipment.intSourceType = 3 -- Transport
						THEN ItemPricing.strUnitMeasure
					ELSE NULL
					END
				)
			WHEN Shipment.intOrderType = 2
				THEN SODetail.strUnitMeasure
			WHEN Shipment.intOrderType = 3
				THEN NULL
			ELSE NULL
			END
		),
	dblQtyOrdered = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (
					CASE WHEN Shipment.intSourceType = 0 -- None
						THEN ISNULL(ContractView.dblDetailQuantity, 0)
					WHEN Shipment.intSourceType = 1 -- Scale
						THEN 0
					WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						THEN 0
					WHEN Shipment.intSourceType = 3 -- Transport
						THEN ISNULL(TransportView.dblOrderedQuantity, 0)
					ELSE NULL
					END
				)
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblQtyOrdered, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblQtyAllocated = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblQtyAllocated, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblUnitPrice = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblPrice, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblDiscount = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblDiscount, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblTotal = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblTotal, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblCost = ItemPricing.dblLastCost
FROM	tblICInventoryShipmentItem ShipmentItem LEFT JOIN tblICInventoryShipment Shipment 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		LEFT JOIN vyuICGetItemPricing ItemPricing 
			ON ItemPricing.intUnitMeasureId = ShipmentItem.intItemUOMId 
			AND ItemPricing.intItemId = ShipmentItem.intItemId
			AND ItemPricing.intLocationId = Shipment.intShipFromLocationId			
		LEFT JOIN vyuSOSalesOrderDetail SODetail
			ON SODetail.intSalesOrderId = ShipmentItem.intOrderId 
			AND SODetail.intSalesOrderDetailId = ShipmentItem.intLineNo
			AND Shipment.intOrderType = 2
		LEFT JOIN vyuCTContractDetailView ContractView
			-- ON ContractView.intContractDetailId = ShipmentItem.intLineNo
			ON ContractView.intContractHeaderId = ShipmentItem.intOrderId
			AND Shipment.intOrderType = 1
			-- AND Shipment.intSourceType IN (0, 1) 
		LEFT JOIN vyuTRTransportReceipt TransportView
			ON TransportView.intTransportReceiptId = ShipmentItem.intSourceId
			AND Shipment.intSourceType = 3
		LEFT JOIN tblSCTicket ScaleView
			ON ScaleView.intTicketId = ShipmentItem.intSourceId
			AND Shipment.intSourceType = 1
		LEFT JOIN tblLGShipment LogisticView
			ON LogisticView.intShipmentId = ShipmentItem.intSourceId
			AND Shipment.intSourceType = 2
		LEFT JOIN tblLGPickLotHeader PickLot
			ON PickLot.intPickLotHeaderId = ShipmentItem.intSourceId
			 AND Shipment.intSourceType = 3