/*
* Move Custom User Layouts from Load/Shipment Schedule to the respective Report Menus (upgrading from 18.3 only)
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblSMGridLayout'))
BEGIN
	IF (ISNULL((SELECT TOP 1 strVersionNo FROM tblSMBuildNumber 
	WHERE intVersionID < (SELECT MAX(intVersionID) FROM tblSMBuildNumber) ORDER BY dtmLastUpdate DESC), '') LIKE '18.3%')
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

/*
* Update Inbound and Outbound Company Locations for Trans. Used By Transport Loads
*/
IF EXISTS (SELECT 1 FROM tblLGLoadDetail LD INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
	WHERE L.intTransUsedBy = 3 AND L.intPurchaseSale = 1 AND LD.intSCompanyLocationId IS NULL)
BEGIN
	UPDATE LD
	SET intSCompanyLocationId = LD.intPCompanyLocationId
	FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
	WHERE L.intTransUsedBy = 3 AND L.intPurchaseSale = 1 AND LD.intSCompanyLocationId IS NULL
END
GO

IF EXISTS (SELECT 1 FROM tblLGLoadDetail LD INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
	WHERE L.intTransUsedBy = 3 AND L.intPurchaseSale = 2 AND LD.intPCompanyLocationId IS NULL)
BEGIN
	UPDATE LD
	SET intPCompanyLocationId = LD.intSCompanyLocationId
	FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
	WHERE L.intTransUsedBy = 3 AND L.intPurchaseSale = 2 AND LD.intPCompanyLocationId IS NULL
END
GO