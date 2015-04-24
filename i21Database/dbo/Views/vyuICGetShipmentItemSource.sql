CREATE VIEW [dbo].[vyuICGetShipmentItemSource]
	AS 

SELECT 
	ShipmentItem.intInventoryShipmentItemId,
	ShipmentItem.intSourceId,
	strSourceId = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN NULL
			WHEN Shipment.intOrderType = 2
				THEN (SELECT ISNULL(strSalesOrderNumber, 'SO Number not found!') FROM tblSOSalesOrder WHERE intSalesOrderId = ShipmentItem.intSourceId)
			WHEN Shipment.intOrderType = 3
				THEN NULL
			ELSE NULL
			END
		)
FROM tblICInventoryShipmentItem ShipmentItem
LEFT JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
