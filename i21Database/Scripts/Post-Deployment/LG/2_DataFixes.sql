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