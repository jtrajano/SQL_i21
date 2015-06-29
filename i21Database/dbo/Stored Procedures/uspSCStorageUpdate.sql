CREATE PROCEDURE [dbo].[uspSCStorageUpdate]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@intEntityId AS INT
	,@strDistributionOption AS NVARCHAR(3)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intCustomerStorageId AS INT
DECLARE @ysnAddDiscount BIT
DECLARE @intHoldCustomerStorageId AS INT
DECLARE @intGRStorageId AS INT
DECLARE @intScaleStationId AS INT
DECLARE @strGRStorage AS nvarchar(3)
DECLARE @ItemsForItemReceipt AS ItemCostingTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @InventoryReceiptId AS INT
DECLARE @dblUnits AS DECIMAL (13,3)
DECLARE @intStorageTicketId AS INT
DECLARE @intStorageEntityId AS INT
DECLARE @intStorageCommodityId AS INT
DECLARE @intStorageTypeId AS INT
DECLARE @intStorageLocationId AS INT
DECLARE @dblRunningBalance AS DECIMAL (13,3)


DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @PostShipment INT = 1;

DECLARE @ItemsForItemShipment AS ItemCostingTableType 

DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@SALES_ORDER AS NVARCHAR(50) = 'SalesOrder'
		,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@strSourceType AS NVARCHAR(100) = 'SalesOrder'
		,@InventoryShipmentId AS INT

DECLARE @ErrMsg                    NVARCHAR(MAX),
              @dblBalance          NUMERIC(12,4),                    
              @intItemId           INT,
              @dblNewBalance       NUMERIC(12,4),
              @strInOutFlag        NVARCHAR(4),
              @dblQuantity         NUMERIC(12,4),
              @strAdjustmentNo     NVARCHAR(50)

BEGIN TRY

    BEGIN
	IF @dblNetUnits < 0
	BEGIN
		SET @PostShipment = 2
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
		SET @dblUnits = @dblNetUnits * -1
		SELECT @intStorageEntityId = SC.intEntityId, @intStorageCommodityId = SC.intCommodityId,
		@intStorageLocationId =  SC.intProcessingLocationId
		FROM dbo.tblSCTicket SC
		WHERE SC.intTicketId = @intTicketId
		SELECT @intStorageTypeId = ST.intStorageScheduleTypeId
		FROM dbo.tblGRStorageType ST
		WHERE ST.strStorageTypeCode = @strDistributionOption
		WHILE @dblUnits > 0
		BEGIN
			SELECT TOP 1 @intStorageTicketId = CS.intCustomerStorageId, @dblRunningBalance = CS.dblOpenBalance
			FROM dbo.tblGRCustomerStorage CS
			WHERE CS.dblOpenBalance > 0 and CS.intCommodityId = @intStorageCommodityId
			and CS.intEntityId = @intStorageEntityId and CS.intCompanyLocationId = @intStorageLocationId
			and CS.intStorageTypeId = @intStorageTypeId 
			ORDER BY CS.intCustomerStorageId ASC
			IF	ISNULL(@intStorageTicketId,0) = 0 AND @dblUnits > 0
			BEGIN
				INSERT INTO @ItemsForItemShipment (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId 
				,ysnIsCustody
				)
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = @dblUnits 
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = ScaleTicket.dblUnitPrice + ScaleTicket.dblUnitBasis
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsCustody = 0
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM
							ON ScaleTicket.intItemId = ItemUOM.intItemId
							AND @intTicketItemUOMId = ItemUOM.intItemUOMId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ScaleTicket.intItemId = ItemLocation.intItemId
							-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
						AND TicketCommodityUOM.ysnStockUnit = 1
				WHERE	ScaleTicket.intTicketId = @intTicketId;
				SET @dblUnits = 0
				GOTO CONTINUEISH
			END
			IF @dblRunningBalance > @dblUnits
				BEGIN
				UPDATE tblGRCustomerStorage 
				SET dblOpenBalance = @dblRunningBalance - @dblUnits
				WHERE intCustomerStorageId = @intStorageTicketId
				INSERT INTO [dbo].[tblGRStorageHistory]
				   ([intConcurrencyId]
				   ,[intCustomerStorageId]
				   ,[intTicketId]
				   ,[intInventoryReceiptId]
				   ,[intInvoiceId]
				   ,[intContractDetailId]
				   ,[dblUnits]
				   ,[dtmHistoryDate]
				   ,[dblStoragePaid]
				   ,[dblFeesPaid]
				   ,[dblCurrencyRate])
			   VALUES
				   (1
				   ,@intStorageTicketId
				   ,@intTicketId
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@dblUnits
				   ,dbo.fnRemoveTimeOnDate(GETDATE())
				   ,0
				   ,0
				   ,1)
				INSERT INTO @ItemsForItemShipment (
				 intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId 
				,ysnIsCustody
				)
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = @dblUnits 
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = 0
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsCustody = 1
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM
							ON ScaleTicket.intItemId = ItemUOM.intItemId
							AND @intTicketItemUOMId = ItemUOM.intItemUOMId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ScaleTicket.intItemId = ItemLocation.intItemId
							-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
						AND TicketCommodityUOM.ysnStockUnit = 1
				WHERE	ScaleTicket.intTicketId = @intTicketId
				SET @dblUnits = 0
				GOTO CONTINUEISH
				END
			IF @dblRunningBalance < @dblUnits
				BEGIN
				UPDATE tblGRCustomerStorage 
				SET dblOpenBalance = 0
				WHERE intCustomerStorageId = @intStorageTicketId
				SELECT dblOpenBalance FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intStorageTicketId
				SET @dblUnits = @dblUnits - @dblRunningBalance
				INSERT INTO [dbo].[tblGRStorageHistory]
				   ([intConcurrencyId]
				   ,[intCustomerStorageId]
				   ,[intTicketId]
				   ,[intInventoryReceiptId]
				   ,[intInvoiceId]
				   ,[intContractDetailId]
				   ,[dblUnits]
				   ,[dtmHistoryDate]
				   ,[dblStoragePaid]
				   ,[dblFeesPaid]
				   ,[dblCurrencyRate])
			   VALUES
				   (1
				   ,@intStorageTicketId
				   ,@intTicketId
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@dblRunningBalance
				   ,dbo.fnRemoveTimeOnDate(GETDATE())
				   ,0
				   ,0
				   ,1)
				INSERT INTO @ItemsForItemShipment (
				 intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId 
				,ysnIsCustody
				)
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = @dblRunningBalance 
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = 0
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsCustody = 1
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM
							ON ScaleTicket.intItemId = ItemUOM.intItemId
							AND @intTicketItemUOMId = ItemUOM.intItemUOMId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ScaleTicket.intItemId = ItemLocation.intItemId
							-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
						AND TicketCommodityUOM.ysnStockUnit = 1
				WHERE	ScaleTicket.intTicketId = @intTicketId
				END
				SET @intStorageTicketId = 0
		END
		GOTO CONTINUEISH
	END
	BEGIN 
		SELECT @intScaleStationId = SC.intScaleSetupId
		FROM	dbo.tblSCTicket SC	        
		WHERE	SC.intTicketId = @intTicketId		
	END
	
	BEGIN 
		SELECT	@intGRStorageId = ST.intStorageScheduleTypeId
		FROM	dbo.tblGRStorageType ST	        
		WHERE	ST.strStorageTypeCode = @strDistributionOption		
	END
	
	IF @intGRStorageId is NULL
	BEGIN
	   	SELECT	@intGRStorageId = ST.intDefaultStorageTypeId
		FROM	dbo.tblSCScaleSetup ST	        
		WHERE	ST.intScaleSetupId = @intScaleStationId
	END
	
	IF @intGRStorageId IS NULL 
	BEGIN 
		-- Raise the error:
		RAISERROR('Invalid Default Storage Setup - uspSCStorageUpdate', 16, 1);
		RETURN;
	END
	
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
	
	-- Insert the Customer Storage Record 
	INSERT INTO [dbo].[tblGRCustomerStorage]
	           ([intConcurrencyId]
	           ,[intEntityId]
	           ,[intCommodityId]
	           ,[intStorageScheduleId]
	           ,[intStorageTypeId]
	           ,[intCompanyLocationId]
	           ,[intTicketId]
	           ,[intDiscountScheduleId]
	           ,[dblTotalPriceShrink]
	           ,[dblTotalWeightShrink]
	           ,[dblOriginalBalance]
	           ,[dblOpenBalance]
	           ,[dtmDeliveryDate]
	           ,[dtmZeroBalanceDate]
	           ,[strDPARecieptNumber]
	           ,[dtmLastStorageAccrueDate]
	           ,[dblStorageDue]
	           ,[dblStoragePaid]
	           ,[dblInsuranceRate]
	           ,[strOriginState]
	           ,[strInsuranceState]
	           ,[dblFeesDue]
	           ,[dblFeesPaid]
	           ,[dblFreightDueRate]
	           ,[ysnPrinted]
	           ,[dblCurrencyRate])
	SELECT 	[intConcurrencyId]		= 1
			,[intEntityId]			= @intEntityId
			,[intCommodityId]		= SC.intCommodityId
			,[intStorageScheduleId]	= NULL -- TODO Storage Schedule
			,[intStorageTypeId]		= @intGRStorageId
			,[intCompanyLocationId]= SC.intProcessingLocationId
			,[intTicketId]= SC.intTicketId
			,[intDiscountScheduleId]= SC.intDiscountSchedule
			,[dblTotalPriceShrink]= 0
			,[dblTotalWeightShrink]= 0 
			,[dblOriginalBalance]= @dblNetUnits 
			,[dblOpenBalance]= @dblNetUnits
			,[dtmDeliveryDate]= NULL
			,[dtmZeroBalanceDate]= NULL
			,[strDPARecieptNumber]= NULL
			,[dtmLastStorageAccrueDate]= NULL 
			,[dblStorageDue]= NULL 
			,[dblStoragePaid]= 0
			,[dblInsuranceRate]= 0 
			,[strOriginState]= NULL 
			,[strInsuranceState]= NULL
			,[dblFeesDue]= 0 
			,[dblFeesPaid]= 0 
			,[dblFreightDueRate]= 0 
			,[ysnPrinted]= 0 
			,[dblCurrencyRate]= 1 
	FROM	dbo.tblSCTicket SC
	WHERE	SC.intTicketId = @intTicketId
	
	INSERT INTO @ItemsForItemReceipt (
				 intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
				,ysnIsCustody 
			)
			SELECT intItemId = ScaleTicket.intItemId
							,intLocationId = ItemLocation.intItemLocationId 
							,intItemUOMId = ItemUOM.intItemUOMId
							,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
							,dblQty = @dblNetUnits 
							,dblUOMQty = ItemUOM.dblUnitQty
							,dblCost = 0
							,dblSalesPrice = 0
							,intCurrencyId = ScaleTicket.intCurrencyId
							,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
							,intTransactionId = ScaleTicket.intTicketId
							,intTransactionDetailId = ScaleTicket.intTicketId
							,strTransactionId = ScaleTicket.intTicketNumber
							,intTransactionTypeId = @intDirectType 
							,intLotId = NULL 
							,intSubLocationId = ScaleTicket.intSubLocationId
							,intStorageLocationId = ScaleTicket.intStorageLocationId
							,ysnIsCustody = 1
					FROM	dbo.tblSCTicket ScaleTicket
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ScaleTicket.intItemId = ItemUOM.intItemId
								AND @intTicketItemUOMId = ItemUOM.intItemUOMId
							INNER JOIN dbo.tblICItemLocation ItemLocation
								ON ScaleTicket.intItemId = ItemLocation.intItemId
								-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
								AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
								INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
							AND TicketCommodityUOM.ysnStockUnit = 1
					WHERE	ScaleTicket.intTicketId = @intTicketId
	
		EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 
	
		-- Add the items to the item receipt 
		BEGIN 
			EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, @InventoryReceiptId OUTPUT; 
		END
	
		BEGIN 
		SELECT	@strTransactionId = IR.strReceiptNumber
		FROM	dbo.tblICInventoryReceipt IR	        
		WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		
		END
	
		EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId, @intEntityId;
		EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intUserId;
	
	-- Get the identity value from tblGRCustomerStorage
	SELECT @intCustomerStorageId = SCOPE_IDENTITY()
	
	IF @intCustomerStorageId IS NULL 
	BEGIN 
		-- Raise the error:
		RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
		RETURN;
	END
	
	BEGIN
		select @intHoldCustomerStorageId = SD.intCustomerStorageId from tblGRStorageDiscount SD 
		where intCustomerStorageId = @intCustomerStorageId
	END
	
	if @intHoldCustomerStorageId is NULL
	BEGIN
		INSERT INTO [dbo].[tblGRStorageDiscount]
	           ([intConcurrencyId]
	           ,[intCustomerStorageId]
	           ,[strDiscountCode]
	           ,[dblGradeReading]
	           ,[strCalcMethod]
	           ,[dblDiscountAmount]
	           ,[strShrinkWhat]
	           ,[dblShrinkPercent]
	           ,[dblDiscountDue]
	           ,[dblDiscountPaid]
	           ,[dtmDiscountPaidDate])
		SELECT	 [intConcurrencyId]= 1
			,[intCustomerStorageId]= @intCustomerStorageId
			,[strDiscountCode]= SD.strDiscountCode
			,[dblGradeReading]= SD.dblGradeReading
			,[strCalcMethod]= SD.strCalcMethod
			,[dblDiscountAmount]= SD.dblDiscountAmount
			,[strShrinkWhat]= SD.strShrinkWhat
			,[dblShrinkPercent]= SD.dblShrinkPercent
			,[dblDiscountDue]= SD.dblDiscountAmount
			,[dblDiscountPaid]=	0
			,[dtmDiscountPaidDate] = NULL
		FROM	dbo.tblSCTicketDiscount SD
		WHERE	SD.intTicketId = @intTicketId
	END
	CONTINUEISH:

	IF @PostShipment = 2
	BEGIN
			-- Validate the items to shipment 
		EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment; 

		---- Add the items into inventory shipment > sales order type. 
		IF @strSourceType = @SALES_ORDER
		BEGIN 
			EXEC dbo.uspSCAddScaleTicketToItemShipment 
				  @intTicketId
				 ,@intUserId
				 ,@ItemsForItemShipment
				 ,@intEntityId
				 ,@InventoryShipmentId OUTPUT;
		END
		BEGIN 
		SELECT	@strTransactionId = ship.strShipmentNumber
		FROM	dbo.tblICInventoryShipment ship	        
		WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
		END
		EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId, @intEntityId;
	END

	END

END TRY

BEGIN CATCH
BEGIN
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
	END
END CATCH

GO