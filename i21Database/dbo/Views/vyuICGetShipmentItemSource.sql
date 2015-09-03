CREATE VIEW [dbo].[vyuICGetShipmentItemSource]
	AS 

SELECT 
	ShipmentItem.intInventoryShipmentItemId,
	ShipmentItem.intOrderId,
	strOrderNumber = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (SELECT CAST(ISNULL(strContractNumber, 'PO Number not found!') AS NVARCHAR) FROM tblCTContractHeader WHERE intContractHeaderId = ShipmentItem.intOrderId)
			WHEN Shipment.intOrderType = 2
				THEN (SELECT ISNULL(strSalesOrderNumber, 'SO Number not found!') FROM tblSOSalesOrder WHERE intSalesOrderId = ShipmentItem.intOrderId)
			WHEN Shipment.intOrderType = 3
				THEN NULL
			ELSE NULL
			END
		),
	strSourceNumber =
		(
			CASE WHEN Shipment.intSourceType = 1 -- Scale
				THEN (SELECT CAST(ISNULL(intTicketNumber, 'Ticket Number not found!')AS NVARCHAR(50)) FROM tblSCTicket WHERE intTicketId = ShipmentItem.intSourceId)
			WHEN Shipment.intSourceType = 2 -- Inbound Shipment
				THEN (SELECT CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!')AS NVARCHAR(50)) FROM tblLGShipment WHERE intShipmentId = ShipmentItem.intSourceId)
			ELSE NULL
			END
		),
	strOrderUOM = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (
					CASE WHEN Shipment.intSourceType = 0 -- None
						THEN (SELECT ISNULL(strItemUOM, 'Ticket Number not found!') FROM vyuCTContractDetailView
							WHERE intContractDetailId = ShipmentItem.intLineNo)
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
				THEN (SELECT strUnitMeasure FROM tblSOSalesOrderDetail 
						LEFT JOIN tblICItemUOM ON tblICItemUOM.intItemUOMId = tblSOSalesOrderDetail.intItemUOMId
						LEFT JOIN tblICUnitMeasure ON tblICUnitMeasure.intUnitMeasureId = tblICItemUOM.intUnitMeasureId
						WHERE intSalesOrderId = ShipmentItem.intOrderId AND intSalesOrderDetailId = ShipmentItem.intLineNo)
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
						THEN (SELECT ISNULL(dblDetailQuantity, 0) FROM vyuCTContractDetailView
							WHERE intContractDetailId = ShipmentItem.intLineNo)
					WHEN Shipment.intSourceType = 1 -- Scale
						THEN 0
					WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						THEN NULL
					WHEN Shipment.intSourceType = 3 -- Transport
						THEN (SELECT ISNULL(dblOrderedQuantity, 0) FROM vyuTRTransportReceipt
						WHERE intTransportReceiptId = ShipmentItem.intSourceId)
					ELSE NULL
					END
				)
			WHEN Shipment.intOrderType = 2
				THEN ISNULL((SELECT ISNULL(dblQtyOrdered, 0.00) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = ShipmentItem.intOrderId AND intSalesOrderDetailId = ShipmentItem.intLineNo), 0.00)
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
				THEN ISNULL((SELECT ISNULL(dblQtyAllocated, 0.00) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = ShipmentItem.intOrderId AND intSalesOrderDetailId = ShipmentItem.intLineNo), 0.00)
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
				THEN ISNULL((SELECT ISNULL(dblPrice, 0.00) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = ShipmentItem.intOrderId AND intSalesOrderDetailId = ShipmentItem.intLineNo), 0.00)
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
				THEN ISNULL((SELECT ISNULL(dblDiscount, 0.00) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = ShipmentItem.intOrderId AND intSalesOrderDetailId = ShipmentItem.intLineNo), 0.00)
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
				THEN ISNULL((SELECT ISNULL(dblTotal, 0.00) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = ShipmentItem.intOrderId AND intSalesOrderDetailId = ShipmentItem.intLineNo), 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		)
FROM tblICInventoryShipmentItem ShipmentItem
LEFT JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId