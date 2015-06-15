CREATE PROCEDURE [testi21Database].[Inventory Shipment expected tables]
AS
BEGIN	

	-- Header table (tblICInventoryShipment)
	BEGIN 
		CREATE TABLE expected_tblICInventoryShipment (
			intInventoryShipmentId		INT NULL 
			,strShipmentNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,dtmShipDate				DATETIME NULL
			,intOrderType				INT NULL
			,strReferenceNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,dtmRequestedArrivalDate	DATETIME NULL
			,intShipFromLocationId		INT NULL
			,intEntityCustomerId		INT NULL
			,intShipToLocationId		INT NULL
			,intFreightTermId			INT NULL
			,strBOLNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,intShipViaId				INT NULL
			,strVessel					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strProNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strDriverId				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strSealNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strDeliveryInstruction		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
			,dtmAppointmentTime			DATETIME NULL
			,dtmDepartureTime			DATETIME NULL
			,dtmArrivalTime				DATETIME NULL
			,dtmDeliveredDate			DATETIME NULL
			,dtmFreeTime				DATETIME NULL
			,strReceivedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
			,ysnPosted					BIT DEFAULT((0))
			,intEntityId				INT NULL
			,intCreatedUserId			INT NULL
			,intConcurrencyId			INT NULL DEFAULT ((0))
		)

		CREATE TABLE actual_tblICInventoryShipment (
			intInventoryShipmentId		INT NULL 
			,strShipmentNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,dtmShipDate				DATETIME NULL
			,intOrderType				INT NULL
			,strReferenceNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,dtmRequestedArrivalDate	DATETIME NULL
			,intShipFromLocationId		INT NULL
			,intEntityCustomerId		INT NULL
			,intShipToLocationId		INT NULL
			,intFreightTermId			INT NULL
			,strBOLNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,intShipViaId				INT NULL
			,strVessel					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strProNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strDriverId				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strSealNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strDeliveryInstruction		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
			,dtmAppointmentTime			DATETIME NULL
			,dtmDepartureTime			DATETIME NULL
			,dtmArrivalTime				DATETIME NULL
			,dtmDeliveredDate			DATETIME NULL
			,dtmFreeTime				DATETIME NULL
			,strReceivedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
			,ysnPosted					BIT DEFAULT((0))
			,intEntityId				INT NULL
			,intCreatedUserId			INT NULL
			,intConcurrencyId			INT NULL DEFAULT ((0))
		)
	END 

	-- Detail Item table (tblICInventoryShipmentItem)
	BEGIN 
		CREATE TABLE expected_tblICInventoryShipmentItem (
			intInventoryShipmentItemId INT NULL 
			,intInventoryShipmentId INT NULL
			,intOrderId INT NULL
			,intLineNo INT NULL
			,intItemId INT NULL 
			,intSubLocationId INT NULL 
			,dblQuantity NUMERIC(18, 6) NULL DEFAULT ((0)) 
			,intItemUOMId INT NULL 
			,dblUnitPrice NUMERIC(18, 6) NULL DEFAULT ((0)) 
			,intTaxCodeId INT NULL
			,intDockDoorId INT NULL 
			,strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
			,intSort INT NULL 
			,intConcurrencyId INT NULL DEFAULT ((0)) 		
		)
		
		CREATE TABLE actual_tblICInventoryShipmentItem (
			intInventoryShipmentItemId INT NULL 
			,intInventoryShipmentId INT NULL
			,intOrderId INT NULL
			,intLineNo INT NULL
			,intItemId INT NULL 
			,intSubLocationId INT NULL 
			,dblQuantity NUMERIC(18, 6) NULL DEFAULT ((0)) 
			,intItemUOMId INT NULL 
			,dblUnitPrice NUMERIC(18, 6) NULL DEFAULT ((0)) 
			,intTaxCodeId INT NULL
			,intDockDoorId INT NULL 
			,strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
			,intSort INT NULL 
			,intConcurrencyId INT NULL DEFAULT ((0)) 		
		)
	END 
END