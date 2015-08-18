CREATE PROCEDURE [dbo].[uspSCAddScaleTicketToItemShipment]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@Items ItemCostingTableType READONLY
	,@intEntityId AS INT
	,@intOrderType AS INT
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

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT


BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId
		FROM	dbo.tblICItemUOM UM	
	      JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.intUnitMeasureId =@intTicketUOM AND SC.intTicketId = @intTicketId
END

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
				,intCreatedUserId
				,intConcurrencyId
				,intSourceType
		)
		SELECT	strShipmentNumber			= @ShipmentNumber
				,dtmShipDate				= SC.dtmTicketDateTime
				,intOrderType				= @intOrderType
				,strReferenceNumber			= SC.strCustomerReference
				,dtmRequestedArrivalDate	= NULL -- TODO
				,intShipFromLocationId		= SC.intProcessingLocationId
				,intEntityCustomerId		= SC.intEntityId
				,intShipToLocationId		= NULL -- TODO
				,intFreightTermId			= 1 -- TODO
				,strBOLNumber				= SC.intTicketNumber -- TODO
				,intShipViaId				= NULL
				,strVessel					= SC.strTruckName -- TODO
				,strProNumber				= NULL 
				,strDriverId				= SC.strDriverName
				,strSealNumber				= NULL 
				,strDeliveryInstruction		= NULL 
				,dtmAppointmentTime			= NULL 
				,dtmDepartureTime			= NULL 
				,dtmArrivalTime				= NULL 
				,dtmDeliveredDate			= NULL 
				,dtmFreeTime				= NULL 
				,strReceivedBy				= NULL 
				,strComment					= SC.strTicketComment
				,ysnPosted					= 0 
				,intEntityId				= dbo.fnGetUserEntityId(@intUserId) 
				,intCreatedUserId			= @intUserId
				,intConcurrencyId			= 1
				,intSourceType				= 1
FROM	dbo.tblSCTicket SC
WHERE	SC.intTicketId = @intTicketId
END 

-- Get the identity value from tblICInventoryShipment
SELECT @InventoryShipmentId = SCOPE_IDENTITY()

IF @InventoryShipmentId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.
	RAISERROR(51117, 11, 1);
	RETURN;
END

-- Insert the Inventory Shipment detail items 
BEGIN 
	INSERT INTO dbo.tblICInventoryShipmentItem (
			intInventoryShipmentId
			,intSourceId
			,intLineNo
			,intOrderId
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
			,intOwnershipType
	)
	SELECT			
			intInventoryShipmentId	= @InventoryShipmentId
			,intSourceId			= @intTicketId
			,intLineNo				= ISNULL (LI.intTransactionDetailId, 1)
			,intOrderId				= CNT.intContractHeaderId
			,intItemId				= SC.intItemId
			,intSubLocationId		= SC.intSubLocationId
			,dblQuantity			= LI.dblQty
			,intItemUOMId			= ItemUOM.intItemUOMId
			,dblUnitPrice			= LI.dblCost
			,intTaxCodeId			= NULL
			,intDockDoorId			= NULL
			,strNotes				= SC.strTicketComment
			,intSort				= 1
			,intConcurrencyId		= 1
			,intOwnershipType       = CASE
									  WHEN LI.ysnIsCustody = 0
									  THEN 1
									  WHEN LI.ysnIsCustody = 1
									  THEN 2
									  END
FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = SC.intItemId
			AND ItemUOM.intItemUOMId = @intTicketItemUOMId
		INNER JOIN dbo.tblICUnitMeasure UOM
			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		LEFT JOIN dbo.tblCTContractDetail CNT
			ON CNT.intContractDetailId = LI.intTransactionDetailId
WHERE	SC.intTicketId = @intTicketId

END

BEGIN
	INSERT INTO [dbo].[tblQMTicketDiscount]
       ([intConcurrencyId]
       ,[strDiscountCode]
       ,[strDiscountCodeDescription]
       ,[dblGradeReading]
       ,[strCalcMethod]
       ,[strShrinkWhat]
       ,[dblShrinkPercent]
       ,[dblDiscountAmount]
       ,[dblDiscountDue]
       ,[dblDiscountPaid]
       ,[ysnGraderAutoEntry]
       ,[intDiscountScheduleCodeId]
       ,[dtmDiscountPaidDate]
       ,[intTicketId]
       ,[intTicketFileId]
       ,[strSourceType])
	SELECT	DISTINCT [intConcurrencyId]= 1
       ,[strDiscountCode] = SD.[strDiscountCode]
       ,[strDiscountCodeDescription]= SD.[strDiscountCodeDescription]
       ,[dblGradeReading]= SD.[dblGradeReading]
       ,[strCalcMethod]= SD.[strCalcMethod]
       ,[strShrinkWhat]= SD.[strShrinkWhat]
       ,[dblShrinkPercent]= SD.[dblShrinkPercent]
       ,[dblDiscountAmount]= SD.[dblDiscountAmount]
       ,[dblDiscountDue]= SD.[dblDiscountDue]
       ,[dblDiscountPaid]= SD.[dblDiscountPaid]
       ,[ysnGraderAutoEntry]= SD.[ysnGraderAutoEntry]
       ,[intDiscountScheduleCodeId]= SD.[intDiscountScheduleCodeId]
       ,[dtmDiscountPaidDate]= SD.[dtmDiscountPaidDate]
       ,[intTicketId]= NULL
       ,[intTicketFileId]= ISH.intInventoryShipmentItemId
       ,[strSourceType]= 'Inventory Shipment'
	FROM	dbo.tblICInventoryShipmentItem ISH join dbo.[tblQMTicketDiscount] SD
	ON ISH.intSourceId = SD.intTicketId AND SD.strSourceType = 'Scale' AND
	SD.intTicketFileId = @intTicketId WHERE	ISH.intSourceId = @intTicketId AND ISH.intInventoryShipmentId = @InventoryShipmentId
END
GO


