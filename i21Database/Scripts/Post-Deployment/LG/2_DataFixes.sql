/*
* Move Custom User Layouts from Load/Shipment Schedule to the respective Report Menus
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblSMGridLayout'))
BEGIN

	--Inventory View
	EXEC ('
		UPDATE tblSMGridLayout 
		SET strScreen = ''Logistics.view.InventoryViewReport''
		WHERE strScreen = ''Logistics.view.ShipmentSchedule6'' AND strGrid = ''grdSearch''
	')

	--Delivered Not Invoiced
	EXEC ('
		UPDATE tblSMGridLayout 
		SET strScreen = ''Logistics.view.DeliveredNotInvoicedReport''
		WHERE strScreen = ''Logistics.view.ShipmentSchedule7'' AND strGrid = ''grdSearch''
	')
END
GO

/*
* Fix Shipment Status of Load/Shipment Schedule processed to Posted Provisional Invoice with GL Impact
*/
IF (EXISTS (SELECT 1 from tblARCompanyPreference WHERE ysnImpactForProvisional = 1)
	AND EXISTS(SELECT 1 FROM tblLGLoad L WHERE L.intShipmentStatus = 6 
				AND EXISTS (SELECT 1 from tblARInvoice iv where iv.ysnPosted = 1 
							and intLoadId = L.intLoadId and strTransactionType = 'Invoice' and iv.strType = 'Provisional')))
BEGIN
	UPDATE L
	SET intShipmentStatus = 11
	FROM tblLGLoad L
	WHERE L.intShipmentStatus = 6 
	AND EXISTS (SELECT 1 from tblARInvoice iv where iv.ysnPosted = 1 and intLoadId = L.intLoadId and strTransactionType = 'Invoice' and iv.strType = 'Provisional')
END
GO

/*
* Populate Order Type, Order Ids, and Order Detail Ids on Route Orders table for Source Type Sales/Transfer Orders
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGRouteOrder') AND name = 'strOrderType')
BEGIN
	EXEC ('
		UPDATE RO
			SET intSalesOrderId = SalesOrder.intSalesOrderId
				,intSalesOrderDetailId = SalesOrder.intSalesOrderDetailId
				,intInventoryTransferId = TransferOrder.intInventoryTransferId
				,intInventoryTransferDetailId = TransferOrder.intInventoryTransferDetailId
				,strOrderType = CASE WHEN (SalesOrder.intSalesOrderId IS NOT NULL) THEN ''Sales''
									 WHEN (TransferOrder.intInventoryTransferId IS NOT NULL) THEN ''Transfer''
									 ELSE '''' END
			FROM tblLGRouteOrder RO
			INNER JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
			OUTER APPLY 
				(SELECT SOD.intSalesOrderId
						,SOD.intSalesOrderDetailId 
					FROM tblSOSalesOrderDetail SOD
					INNER JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SOD.intSalesOrderId
					INNER JOIN tblICItem I ON I.intItemId = SOD.intItemId
				WHERE SO.strSalesOrderNumber = RO.strOrderNumber
					AND I.strItemNo = RO.strItemNo
				) SalesOrder
			OUTER APPLY 
				(SELECT ITD.intInventoryTransferId
						,ITD.intInventoryTransferDetailId 
					FROM tblICInventoryTransferDetail ITD
					INNER JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = ITD.intInventoryTransferId
					INNER JOIN tblICItem I ON I.intItemId = ITD.intItemId
				WHERE IT.strTransferNo = RO.strOrderNumber
					AND I.strItemNo = RO.strItemNo
				) TransferOrder
			WHERE R.intSourceType = 6
			AND RO.strOrderType IS NULL
	')
END
GO