﻿/*
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
