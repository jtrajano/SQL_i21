﻿CREATE PROCEDURE [dbo].[uspICAddSalesOrderToInventoryShipment]
	@SalesOrderId AS INT
	,@intEntitySecurityUserId AS INT
	,@InventoryShipmentId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryShipment AS INT = 31;
DECLARE @ShipmentNumber AS NVARCHAR(20)

DECLARE @SALES_CONTRACT AS INT = 1
		,@SALES_ORDER AS INT = 2
		,@TRANSFER_ORDER AS INT = 3

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT 

IF @ShipmentNumber IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	RAISERROR(50030, 11, 1);
	RETURN;
END 

-- Insert the Inventory Shipment header 
BEGIN 
		INSERT INTO dbo.tblICInventoryShipment (
				strShipmentNumber
				,dtmShipDate
				,intOrderType
				,strReferenceNumber
				,dtmRequestedArrivalDate
				,intShipFromLocationId
				,intEntityCustomerId
				,intShipToLocationId
				,intFreightTermId
				,strBOLNumber
				,intShipViaId
				,strVessel
				,strProNumber
				,strDriverId
				,strSealNumber
				,strDeliveryInstruction
				,dtmAppointmentTime
				,dtmDepartureTime
				,dtmArrivalTime
				,dtmDeliveredDate
				,dtmFreeTime
				,strReceivedBy
				,strComment
				,ysnPosted
				,intEntityId
				,intConcurrencyId
		)
		SELECT	strShipmentNumber			= @ShipmentNumber
				,dtmShipDate				= SO.dtmDate
				,intOrderType				= @SALES_ORDER
				,strReferenceNumber			= SO.strSalesOrderNumber
				,dtmRequestedArrivalDate	= NULL -- TODO
				,intShipFromLocationId		= SO.intCompanyLocationId
				,intEntityCustomerId		= SO.intEntityCustomerId
				,intShipToLocationId		= SO.intShipToLocationId
				,intFreightTermId			= SO.intFreightTermId
				,strBOLNumber				= SO.strBOLNumber
				,intShipViaId				= SO.intShipViaId
				,strVessel					= NULL -- TODO
				,strProNumber				= NULL 
				,strDriverId				= NULL
				,strSealNumber				= NULL 
				,strDeliveryInstruction		= NULL 
				,dtmAppointmentTime			= NULL 
				,dtmDepartureTime			= NULL 
				,dtmArrivalTime				= NULL 
				,dtmDeliveredDate			= NULL 
				,dtmFreeTime				= NULL 
				,strReceivedBy				= NULL 
				,strComment					= SO.strComments
				,ysnPosted					= 0 
				,intEntityId				= @intEntitySecurityUserId
				,intConcurrencyId			= 1
		FROM	dbo.tblSOSalesOrder SO
		WHERE	SO.intSalesOrderId = @SalesOrderId
END 

-- Get the identity value from tblICInventoryShipment
SELECT @InventoryShipmentId = SCOPE_IDENTITY()

IF @InventoryShipmentId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.
	RAISERROR(80029, 11, 1);
	RETURN;
END

-- Insert the Inventory Shipment detail items 
BEGIN 
	INSERT INTO dbo.tblICInventoryShipmentItem (
			intInventoryShipmentId
			,intOrderId
			,intLineNo
			,intItemId
			,intSubLocationId
			,dblQuantity
			,intItemUOMId
			,dblUnitPrice
			,intTaxCodeId
			,intDockDoorId
			,strNotes
			,intSort
			,intConcurrencyId
	)
	SELECT			
			intInventoryShipmentId	= @InventoryShipmentId
			,intOrderId				= SODetail.intSalesOrderId
			,intLineNo				= SODetail.intSalesOrderDetailId
			,intItemId				= SODetail.intItemId
			,intSubLocationId		= NULL
			,dblQuantity			= SODetail.dblQtyOrdered - SODetail.dblQtyShipped
			,intItemUOMId			= SODetail.intItemUOMId
			,dblUnitPrice			= SODetail.dblPrice
			,intTaxCodeId			= SODetail.intTaxId
			,intDockDoorId			= NULL
			,strNotes				= SODetail.strComments
			,intSort				= SODetail.intSalesOrderDetailId
			,intConcurrencyId		= 1
	FROM	dbo.tblSOSalesOrderDetail SODetail INNER JOIN dbo.tblICItemUOM ItemUOM			
				ON ItemUOM.intItemId = SODetail.intItemId
				AND ItemUOM.intItemUOMId = SODetail.intItemUOMId
			INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE	SODetail.intSalesOrderId = @SalesOrderId
			AND dbo.fnIsStockTrackingItem(SODetail.intItemId) = 1
			AND (SODetail.dblQtyOrdered - SODetail.dblQtyShipped) > 0
END 
