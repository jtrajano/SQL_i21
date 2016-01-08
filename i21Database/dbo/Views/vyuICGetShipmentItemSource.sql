﻿CREATE VIEW [dbo].[vyuICGetShipmentItemSource]
	AS 

SELECT 
	ShipmentItem.intInventoryShipmentItemId,
	ShipmentItem.intOrderId,
	strOrderNumber = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN ISNULL(ContractView.strContractNumber, 'PO Number not found!')
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.strSalesOrderNumber, 'SO Number not found!')
			WHEN Shipment.intOrderType = 3
				THEN NULL
			ELSE NULL
			END
		),
	strSourceNumber =
		CAST (
			CASE WHEN Shipment.intSourceType = 1 -- Scale
				THEN ScaleView.strTicketNumber
			WHEN Shipment.intSourceType = 2 -- Inbound Shipment
				THEN ISNULL(LogisticView.intTrackingNumber, 'Inbound Shipment not found!')
			ELSE NULL
			END
		AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS,
	strOrderUOM = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (
					CASE WHEN Shipment.intSourceType = 0 -- None
						THEN ISNULL(ContractView.strItemUOM, 'Ticket Number not found!')
					WHEN Shipment.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						THEN NULL
					WHEN Shipment.intSourceType = 3 -- Transport
						THEN (SELECT ISNULL(strUnitMeasure, 'Transport not found!')  FROM tblICItemUOM LEFT JOIN tblICUnitMeasure ON tblICUnitMeasure.intUnitMeasureId = tblICItemUOM.intUnitMeasureId WHERE intItemUOMId = ShipmentItem.intItemUOMId)
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
						THEN NULL
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
		)
FROM tblICInventoryShipmentItem ShipmentItem
	LEFT JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	LEFT JOIN vyuSOSalesOrderDetail SODetail
		ON SODetail.intSalesOrderId = ShipmentItem.intOrderId AND SODetail.intSalesOrderDetailId = ShipmentItem.intLineNo
		AND Shipment.intOrderType = 2
	LEFT JOIN vyuCTContractDetailView ContractView
		ON ContractView.intContractDetailId = ShipmentItem.intLineNo
		AND Shipment.intOrderType = 1
		AND Shipment.intSourceType = 0
	LEFT JOIN vyuTRTransportReceipt TransportView
		ON TransportView.intTransportReceiptId = ShipmentItem.intSourceId
		AND Shipment.intSourceType = 3
	LEFT JOIN tblSCTicket ScaleView
		ON ScaleView.intTicketId = ShipmentItem.intSourceId
		AND Shipment.intSourceType = 1
	LEFT JOIN tblLGShipment LogisticView
		ON LogisticView.intShipmentId = ShipmentItem.intSourceId
		AND Shipment.intSourceType = 2