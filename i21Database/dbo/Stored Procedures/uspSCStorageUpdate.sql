CREATE PROCEDURE [dbo].[uspSCStorageUpdate]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@intEntityId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@intDPContractId AS INT
	,@intStorageScheduleId AS INT = NULL
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
DECLARE @intCommodityUOMId INT
DECLARE @intCommodityUnitMeasureId INT
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
DECLARE @strUserName AS NVARCHAR (50)
DECLARE @ysnDPStorage BIT
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @dblRemainingUnits AS DECIMAL (13,3)
DECLARE @intDefaultStorageSchedule AS INT
DECLARE @intCommodityId AS INT
DECLARE @matchStorageType AS INT
DECLARE @ysnIsStorage AS INT
DECLARE @intContractHeaderId INT
DECLARE @strLotTracking NVARCHAR(4000)

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @PostShipment INT = 1;
DECLARE @total AS INT;

DECLARE @ItemsForItemShipment AS ItemCostingTableType 
DECLARE @ItemsForItemShipmentContract AS ItemCostingTableType

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

	SELECT @strUserName = US.strUserName FROM tblSMUserSecurity US
	WHERE US.[intEntityUserSecurityId] = @intUserId
	
	SELECT @intContractHeaderId=intContractHeaderId FROM vyuCTContractDetailView Where intContractDetailId=@intDPContractId
	
	SELECT @intDefaultStorageSchedule = TIC.intStorageScheduleId, @intCommodityId = TIC.intCommodityId FROM tblSCTicket TIC
	WHERE TIC.intTicketId = @intTicketId

	IF @intStorageScheduleId IS NOT NULL
	BEGIN
		SET @intDefaultStorageSchedule = @intStorageScheduleId
	END

	IF @intDefaultStorageSchedule is NULL
	BEGIN
	   	SELECT	@intDefaultStorageSchedule = COM.intScheduleStoreId
		FROM	dbo.tblICCommodity COM	        
		WHERE	COM.intCommodityId = @intCommodityId
	END

    BEGIN
	IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		SET @ysnIsStorage = 0
	ELSE
		SET @ysnIsStorage = 1
	IF @dblNetUnits < 0
	BEGIN
		SET @PostShipment = 2
		BEGIN 
			SELECT	@intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
			FROM	dbo.tblSCTicket SC	        
					INNER JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
			WHERE	SC.intTicketId = @intTicketId AND CommodityUOM.ysnStockUnit = 1		
		END
		BEGIN 
			SELECT	@intCommodityUOMId = UM.intItemUOMId
				FROM dbo.tblICItemUOM UM	
				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
			WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intTicketId = @intTicketId
		END
		IF @intCommodityUOMId IS NULL 
		BEGIN 
			-- Raise the error:
			RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
			RETURN;
		END

		SET @dblUnits = @dblNetUnits * -1
		SELECT @intStorageEntityId = SC.intEntityId, @intStorageCommodityId = SC.intCommodityId,
		@intStorageLocationId =  SC.intProcessingLocationId , @intItemId = SC.intItemId
		FROM dbo.tblSCTicket SC
		WHERE SC.intTicketId = @intTicketId

		SELECT  @intTicketItemUOMId = ItemUOM.intItemUOMId
		FROM    dbo.tblICItemUOM ItemUOM
		WHERE   ItemUOM.intItemId = @intItemId AND ItemUOM.ysnStockUnit = 1

		SELECT @intStorageTypeId = ST.intStorageScheduleTypeId
		FROM dbo.tblGRStorageType ST
		WHERE ST.strStorageTypeCode = @strDistributionOption

		DECLARE @StorageTicketInfoByFIFO AS TABLE 
		(
			[intCustomerStorageId] INT
			,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
			,[dblOpenBalance] NUMERIC(18, 6)
			,[intUnitMeasureId] INT
			,[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,[strItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS ---'Inventory','Storage Charge','Fee','Discount'
			,[intItemId] INT
			,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
			,[dblCharge] DECIMAL(24, 10)
			)

		INSERT INTO @StorageTicketInfoByFIFO 
		(
			[intCustomerStorageId]
			,[strStorageTicketNumber]
			,[dblOpenBalance]
			,[intUnitMeasureId]
			,[strUnitMeasure]
			,[strItemType]
			,[intItemId]
			,[strItem]
			,[dblCharge]
		)
		EXEC uspGRUpdateGrainOpenBalanceByFIFO @strDistributionOption,'Scale',@intEntityId,@intItemId,@intStorageTypeId, @dblUnits, @intTicketId , @intUserId
		SELECT @total = COUNT(*) FROM @StorageTicketInfoByFIFO;
		IF (@total >= 1)
			BEGIN
				DECLARE @intLoopCustomerStorageId INT,
				 @dblLoopdblOpenBalance NUMERIC(12,4)
				,@dblLoopstrItemType NVARCHAR(50);
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intCustomerStorageId, dblOpenBalance , strItemType
				FROM @StorageTicketInfoByFIFO WHERE strItemType = 'Inventory';

				OPEN intListCursor;

				FETCH NEXT FROM intListCursor INTO @intLoopCustomerStorageId, @dblLoopdblOpenBalance, @dblLoopstrItemType;
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @intStorageTicketId = @intLoopCustomerStorageId;
					SET @dblRunningBalance = @dblLoopdblOpenBalance;
					IF	ISNULL(@intLoopCustomerStorageId,0) != 0 
					BEGIN
					IF @dblRunningBalance >= @dblUnits
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
							,ysnIsStorage
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
								,strTransactionId = ScaleTicket.strTicketNumber
								,intTransactionTypeId = @intDirectType 
								,intLotId = NULL 
								,intSubLocationId = ScaleTicket.intSubLocationId
								,intStorageLocationId = ScaleTicket.intStorageLocationId
								,ysnIsStorage = 1
						FROM	dbo.tblSCTicket ScaleTicket
								INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
								INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId 
								AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
						WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
						SET @dblUnits = 0
						GOTO CONTINUEISH
						END
					IF @dblRunningBalance <= @dblUnits
						BEGIN
						SET @dblUnits = @dblUnits - @dblRunningBalance
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
							,ysnIsStorage
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
								,strTransactionId = ScaleTicket.strTicketNumber
								,intTransactionTypeId = @intDirectType 
								,intLotId = NULL 
								,intSubLocationId = ScaleTicket.intSubLocationId
								,intStorageLocationId = ScaleTicket.intStorageLocationId
								,ysnIsStorage = 1
						FROM	dbo.tblSCTicket ScaleTicket
								INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
								INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
						WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
						END
					END
					-- Attempt to fetch next row from cursor
					FETCH NEXT FROM intListCursor INTO @intLoopCustomerStorageId, @dblLoopdblOpenBalance, @dblLoopstrItemType;
				END;

				CLOSE intListCursor;
				DEALLOCATE intListCursor;
			END
		BEGIN
			INSERT INTO @LineItems (
			intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost)
			EXEC dbo.uspCTUpdationFromTicketDistribution 
				@intTicketId
				,@intEntityId
				,@dblUnits
				,NULL
				,@intUserId
				,0
			BEGIN
				DECLARE @intLoopContractId INT;
				DECLARE @dblLoopContractUnits NUMERIC(12,4);
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intContractDetailId, dblUnitsDistributed
				FROM @LineItems;

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;

				WHILE @@FETCH_STATUS = 0
				BEGIN
				   -- Here we do some kind of action that requires us to 
				   -- process the table variable row-by-row. This example simply
				   -- uses a PRINT statement as that action (not a very good
				   -- example).
				   IF	ISNULL(@intLoopContractId,0) != 0
				   --EXEC uspCTUpdateScheduleQuantity @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale'
				   EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
				   
				   -- Attempt to fetch next row from cursor
				   FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;
				END;

				CLOSE intListCursor;
				DEALLOCATE intListCursor;
			END
			SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
			IF(@dblRemainingUnits IS NULL)
			BEGIN
			SET @dblRemainingUnits = @dblUnits
			END
			IF(@dblRemainingUnits != @dblUnits)
			BEGIN
				UPDATE @LineItems set intTicketId = @intTicketId
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
					,intTransactionDetailId
					,intLotId
					,intSubLocationId
					,intStorageLocationId 
					,ysnIsStorage
				)
				EXEC dbo.uspSCGetScaleItemForItemShipment
					@intTicketId
					,@strSourceType
					,@intUserId
					,@dblRemainingUnits
					,0
					,@intEntityId
					,NULL
					,'CNT'
					,@LineItems
			END
			IF(@dblRemainingUnits > 0)
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
				,ysnIsStorage
				)
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = @dblRemainingUnits 
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = ScaleTicket.dblUnitBasis + dblUnitPrice
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,strTransactionId = ScaleTicket.strTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsStorage = 0
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
						INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId 
						AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
				WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
			END
			SET @dblUnits = 0
			GOTO CONTINUEISH
		END
		--WHILE @dblUnits > 0
		--BEGIN
		--	--SELECT TOP 1 @intStorageTicketId = CS.intCustomerStorageId, @dblRunningBalance = CS.dblOpenBalance
		--	--FROM dbo.tblGRCustomerStorage CS
		--	--WHERE CS.dblOpenBalance > 0 and CS.intCommodityId = @intStorageCommodityId
		--	--and CS.intEntityId = @intStorageEntityId and CS.intCompanyLocationId = @intStorageLocationId
		--	--and CS.intStorageTypeId = @intStorageTypeId 
		--	--ORDER BY CS.intCustomerStorageId ASC
		--	IF	ISNULL(@intStorageTicketId,0) = 0 AND @dblUnits > 0
		--	BEGIN
		--		INSERT INTO @LineItems (
		--				 intContractDetailId,
		--				 dblUnitsDistributed,
		--				 dblUnitsRemaining,
		--				 dblCost)
		--			EXEC dbo.uspCTUpdationFromTicketDistribution 
		--				 @intTicketId
		--				,@intEntityId
		--				,@dblUnits
		--				,NULL
		--				,@intUserId
		--				,0
		--		UPDATE @LineItems set intTicketId = @intTicketId
		--		SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
		--		IF(@dblRemainingUnits IS NULL)
		--		BEGIN
		--		SET @dblRemainingUnits = @dblUnits
		--		END
		--		IF(@dblRemainingUnits != @dblUnits)
		--		BEGIN
		--				INSERT INTO @ItemsForItemShipmentContract (
		--					intItemId
		--					,intItemLocationId
		--					,intItemUOMId
		--					,dtmDate
		--					,dblQty
		--					,dblUOMQty
		--					,dblCost
		--					,dblSalesPrice
		--					,intCurrencyId
		--					,dblExchangeRate
		--					,intTransactionId
		--					,strTransactionId
		--					,intTransactionTypeId
		--					,intTransactionDetailId
		--					,intLotId
		--					,intSubLocationId
		--					,intStorageLocationId 
		--					,ysnIsStorage
		--				)
		--				EXEC dbo.uspSCGetScaleItemForItemShipment
		--					 @intTicketId
		--					,@strSourceType
		--					,@intUserId
		--					,@dblRemainingUnits
		--					,0
		--					,@intEntityId
		--					,NULL
		--					,'CNT'
		--					,@LineItems

		--					--select * from @ItemsForItemShipment

		--				-- Validate the items to shipment 
		--				EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipmentContract; 

		--				---- Add the items into inventory shipment > sales order type. 
		--				BEGIN 
		--					EXEC dbo.uspSCAddScaleTicketToItemShipment 
		--						  @intTicketId
		--						 ,@intUserId
		--						 ,@ItemsForItemShipmentContract
		--						 ,@intEntityId
		--						 ,1
		--						 ,@InventoryShipmentId OUTPUT;
		--				END

		--				BEGIN 
		--				SELECT	@strTransactionId = ship.strShipmentNumber
		--				FROM	dbo.tblICInventoryShipment ship	        
		--				WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
		--				END

		--				EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intEntityId;
		--			END
		--		IF(@dblRemainingUnits > 0)
		--		BEGIN
		--				INSERT INTO @ItemsForItemShipment (
		--					 intItemId
		--					,intItemLocationId
		--					,intItemUOMId
		--					,dtmDate
		--					,dblQty
		--					,dblUOMQty
		--					,dblCost
		--					,dblSalesPrice
		--					,intCurrencyId
		--					,dblExchangeRate
		--					,intTransactionId
		--					,strTransactionId
		--					,intTransactionTypeId
		--					,intLotId
		--					,intSubLocationId
		--					,intStorageLocationId 
		--					,ysnIsStorage
		--					)
		--					SELECT	intItemId = ScaleTicket.intItemId
		--							,intLocationId = ItemLocation.intItemLocationId 
		--							,intItemUOMId = ItemUOM.intItemUOMId
		--							,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		--							,dblQty = @dblRemainingUnits 
		--							,dblUOMQty = ItemUOM.dblUnitQty
		--							,dblCost = ScaleTicket.dblUnitBasis + dblUnitPrice
		--							,dblSalesPrice = 0
		--							,intCurrencyId = ScaleTicket.intCurrencyId
		--							,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
		--							,intTransactionId = ScaleTicket.intTicketId
		--							,strTransactionId = ScaleTicket.strTicketNumber
		--							,intTransactionTypeId = @intDirectType 
		--							,intLotId = NULL 
		--							,intSubLocationId = ScaleTicket.intSubLocationId
		--							,intStorageLocationId = ScaleTicket.intStorageLocationId
		--							,ysnIsStorage = @ysnIsStorage
		--					FROM	dbo.tblSCTicket ScaleTicket
		--							INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
		--							INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId 
		--							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
		--					WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
		--			END
		--		SET @dblUnits = 0
		--		GOTO CONTINUEISH
		--	END
		--	IF @dblRunningBalance >= @dblUnits
		--		BEGIN
		--		UPDATE tblGRCustomerStorage 
		--		SET dblOpenBalance = @dblRunningBalance - @dblUnits
		--		WHERE intCustomerStorageId = @intStorageTicketId
		--		INSERT INTO [dbo].[tblGRStorageHistory]
		--		   ([intConcurrencyId]
		--		   ,[intCustomerStorageId]
		--		   ,[intTicketId]
		--		   ,[intInventoryReceiptId]
		--		   ,[intInvoiceId]
		--		   ,[intContractHeaderId]
		--		   ,[dblUnits]
		--		   ,[dtmHistoryDate]
		--		   ,[dblPaidAmount]
		--		   ,[strPaidDescription]
		--		   ,[dblCurrencyRate]
		--		   ,[strType]
		--		   ,[strUserName])
		--	   VALUES
		--		   (1
		--		   ,@intStorageTicketId
		--		   ,@intTicketId
		--		   ,NULL
		--		   ,NULL
		--		   ,NULL
		--		   ,@dblUnits
		--		   ,dbo.fnRemoveTimeOnDate(GETDATE())
		--		   ,0
		--		   ,'TakeOut From Scale'
		--		   ,1
		--		   ,'TakeOut'
		--		   ,@strUserName)
		--		INSERT INTO @ItemsForItemShipment (
		--		 intItemId
		--		,intItemLocationId
		--		,intItemUOMId
		--		,dtmDate
		--		,dblQty
		--		,dblUOMQty
		--		,dblCost
		--		,dblSalesPrice
		--		,intCurrencyId
		--		,dblExchangeRate
		--		,intTransactionId
		--		,strTransactionId
		--		,intTransactionTypeId
		--		,intLotId
		--		,intSubLocationId
		--		,intStorageLocationId 
		--		,ysnIsStorage
		--		)
		--		SELECT	intItemId = ScaleTicket.intItemId
		--				,intLocationId = ItemLocation.intItemLocationId 
		--				,intItemUOMId = ItemUOM.intItemUOMId
		--				,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		--				,dblQty = @dblUnits 
		--				,dblUOMQty = ItemUOM.dblUnitQty
		--				,dblCost = 0
		--				,dblSalesPrice = 0
		--				,intCurrencyId = ScaleTicket.intCurrencyId
		--				,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
		--				,intTransactionId = ScaleTicket.intTicketId
		--				,strTransactionId = ScaleTicket.strTicketNumber
		--				,intTransactionTypeId = @intDirectType 
		--				,intLotId = NULL 
		--				,intSubLocationId = ScaleTicket.intSubLocationId
		--				,intStorageLocationId = ScaleTicket.intStorageLocationId
		--				,ysnIsStorage = 1
		--		FROM	dbo.tblSCTicket ScaleTicket
		--				INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
		--				INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId 
		--				AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
		--		WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
		--		SET @dblUnits = 0
		--		GOTO CONTINUEISH
		--		END
		--	IF @dblRunningBalance <= @dblUnits
		--		BEGIN
		--		UPDATE tblGRCustomerStorage 
		--		SET dblOpenBalance = 0
		--		WHERE intCustomerStorageId = @intStorageTicketId
		--		SELECT dblOpenBalance FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intStorageTicketId
		--		SET @dblUnits = @dblUnits - @dblRunningBalance
		--		INSERT INTO [dbo].[tblGRStorageHistory]
		--		   ([intConcurrencyId]
		--		   ,[intCustomerStorageId]
		--		   ,[intTicketId]
		--		   ,[intInventoryReceiptId]
		--		   ,[intInvoiceId]
		--		   ,[intContractHeaderId]
		--		   ,[dblUnits]
		--		   ,[dtmHistoryDate]
		--		   ,[dblPaidAmount]
		--		   ,[strPaidDescription]
		--		   ,[dblCurrencyRate]
		--		   ,[strType]
		--		   ,[strUserName])
		--	   VALUES
		--		   (1
		--		   ,@intStorageTicketId
		--		   ,@intTicketId
		--		   ,NULL
		--		   ,NULL
		--		   ,NULL
		--		   ,@dblRunningBalance
		--		   ,dbo.fnRemoveTimeOnDate(GETDATE())
		--		   ,0
		--		   ,'TakeOut From Scale'
		--		   ,1
		--		   ,'TakeOut'
		--		   ,@strUserName)
		--		INSERT INTO @ItemsForItemShipment (
		--		 intItemId
		--		,intItemLocationId
		--		,intItemUOMId
		--		,dtmDate
		--		,dblQty
		--		,dblUOMQty
		--		,dblCost
		--		,dblSalesPrice
		--		,intCurrencyId
		--		,dblExchangeRate
		--		,intTransactionId
		--		,strTransactionId
		--		,intTransactionTypeId
		--		,intLotId
		--		,intSubLocationId
		--		,intStorageLocationId 
		--		,ysnIsStorage
		--		)
		--		SELECT	intItemId = ScaleTicket.intItemId
		--				,intLocationId = ItemLocation.intItemLocationId 
		--				,intItemUOMId = ItemUOM.intItemUOMId
		--				,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		--				,dblQty = @dblRunningBalance 
		--				,dblUOMQty = ItemUOM.dblUnitQty
		--				,dblCost = 0
		--				,dblSalesPrice = 0
		--				,intCurrencyId = ScaleTicket.intCurrencyId
		--				,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
		--				,intTransactionId = ScaleTicket.intTicketId
		--				,strTransactionId = ScaleTicket.strTicketNumber
		--				,intTransactionTypeId = @intDirectType 
		--				,intLotId = NULL 
		--				,intSubLocationId = ScaleTicket.intSubLocationId
		--				,intStorageLocationId = ScaleTicket.intStorageLocationId
		--				,ysnIsStorage = 1
		--		FROM	dbo.tblSCTicket ScaleTicket
		--				INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
		--				INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
		--		WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
		--		END
		--		SET @intStorageTicketId = 0
		--END
		GOTO CONTINUEISH
	END

	BEGIN 
		SELECT @intScaleStationId = SC.intScaleSetupId, @intItemId = SC.intItemId
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
		--RAISERROR('Invalid Default Storage Setup - uspSCStorageUpdate', 16, 1);
		RETURN;
	END

	IF @intDefaultStorageSchedule IS NULL 
	BEGIN 
		-- Raise the error:
		--RAISERROR('Invalid Default Schedule Storage in Inventory Commodity - uspSCStorageUpdate', 16, 1);
		RETURN;
	END

	BEGIN 
		SELECT	@matchStorageType = SSR.intStorageType
		FROM	dbo.tblGRStorageScheduleRule SSR	        
		WHERE	SSR.intStorageScheduleRuleId = @intDefaultStorageSchedule		
	END
	IF @matchStorageType !=  @intGRStorageId
	BEGIN 
		-- Raise the error:
		--RAISERROR('Storage type / Storage Schedule Mismatch - uspSCStorageUpdate', 16, 1);
		RETURN;
	END

	BEGIN 
		SELECT	@intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
		FROM	dbo.tblSCTicket SC	        
				INNER JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
		WHERE	SC.intTicketId = @intTicketId AND CommodityUOM.ysnStockUnit = 1		
	END
	BEGIN 
		SELECT	@intCommodityUOMId = UM.intItemUOMId
			FROM dbo.tblICItemUOM UM	
				JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
		WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intTicketId = @intTicketId
	END
	IF @intCommodityUOMId IS NULL 
	BEGIN 
		-- Raise the error:
		RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
		RETURN;
	END

	BEGIN 
		SELECT  @intTicketItemUOMId = ItemUOM.intItemUOMId
		FROM    dbo.tblICItemUOM ItemUOM
		WHERE   ItemUOM.intItemId = @intItemId AND ItemUOM.ysnStockUnit = 1
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
	           ,[dblCurrencyRate]
			   ,[intCurrencyId]
			   ,[strStorageTicketNumber]
			   ,[intItemId]
			   ,[intCompanyLocationSubLocationId]
			   ,[intStorageLocationId]
			   ,[intUnitMeasureId])
	SELECT 	[intConcurrencyId]		= 1
			,[intEntityId]			= @intEntityId
			,[intCommodityId]		= SC.intCommodityId
			,[intStorageScheduleId]	= @intDefaultStorageSchedule -- TODO Storage Schedule
			,[intStorageTypeId]		= @intGRStorageId
			,[intCompanyLocationId]= SC.intProcessingLocationId
			,[intTicketId]= SC.intTicketId
			,[intDiscountScheduleId]= SC.intDiscountId
			,[dblTotalPriceShrink]= 0
			,[dblTotalWeightShrink]= 0 
			,[dblOriginalBalance]= @dblNetUnits
			,[dblOpenBalance]= @dblNetUnits
			,[dtmDeliveryDate]= GETDATE()
			,[dtmZeroBalanceDate]= NULL
			,[strDPARecieptNumber]= NULL
			,[dtmLastStorageAccrueDate]= NULL 
			,[dblStorageDue]= 0 
			,[dblStoragePaid]= 0
			,[dblInsuranceRate]= 0 
			,[strOriginState]= NULL 
			,[strInsuranceState]= NULL
			,[dblFeesDue]= 0 
			,[dblFeesPaid]= 0 
			,[dblFreightDueRate]= 0 
			,[ysnPrinted]= 0 
			,[dblCurrencyRate]= 1
			,[intCurrencyId] = SC.intCurrencyId
			,[intStorageTicketNumber] = SC.strTicketNumber
			,SC.[intItemId]
			,SC.[intSubLocationId]
			,SC.[intStorageLocationId]
			,(SELECT intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intTicketItemUOMId)
	FROM	dbo.tblSCTicket SC
	WHERE	SC.intTicketId = @intTicketId

		-- Get the identity value from tblGRCustomerStorage
	SELECT @intCustomerStorageId = SCOPE_IDENTITY()
	
	IF @intCustomerStorageId IS NULL 
	BEGIN 
		-- Raise the error:
		RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
		RETURN;
	END

	INSERT INTO [dbo].[tblGRStorageHistory]
		   ([intConcurrencyId]
		   ,[intCustomerStorageId]
		   ,[intTicketId]
		   ,[intInventoryReceiptId]
		   ,[intInvoiceId]
		   ,[intContractHeaderId]
		   ,[dblUnits]
		   ,[dtmHistoryDate]
		   ,[dblPaidAmount]
		   ,[strPaidDescription]
		   ,[dblCurrencyRate]
		   ,[strType]
		   ,[strUserName]
		   ,[intTransactionTypeId])
	VALUES
		   (1
		   ,@intCustomerStorageId
		   ,@intTicketId
		   ,NULL
		   ,NULL
		   ,@intContractHeaderId
		   ,@dblNetUnits
		   ,dbo.fnRemoveTimeOnDate(GETDATE())
		   ,0
		   ,'Generated From Scale'
		   ,1
		   ,'From Scale'
		   ,@strUserName
		   ,1)
	
	BEGIN
		SET @intHoldCustomerStorageId = NULL
		select @intHoldCustomerStorageId = SD.intTicketFileId from tblQMTicketDiscount SD 
		where SD.intTicketFileId = @intCustomerStorageId and SD.[strSourceType]= 'Storage'
	END
	
	if @intHoldCustomerStorageId is NULL
	BEGIN
		INSERT INTO [dbo].[tblQMTicketDiscount]
           ([intConcurrencyId]         
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
           ,[strSourceType]
		   ,[intSort]
		   ,[strDiscountChargeType])
		SELECT	 
			[intConcurrencyId]= 1       
           ,[dblGradeReading]= SD.[dblGradeReading]
           ,[strCalcMethod]= SD.[strCalcMethod]
           ,[strShrinkWhat]= SD.[strShrinkWhat]			
           ,[dblShrinkPercent]= SD.[dblShrinkPercent]
           ,[dblDiscountAmount]= SD.[dblDiscountAmount]
           ,[dblDiscountDue]= SD.[dblDiscountAmount]
           ,[dblDiscountPaid]= ISNULL(SD.[dblDiscountPaid],0)
           ,[ysnGraderAutoEntry]= SD.[ysnGraderAutoEntry]
           ,[intDiscountScheduleCodeId]= SD.[intDiscountScheduleCodeId]
           ,[dtmDiscountPaidDate]= SD.[dtmDiscountPaidDate]
           ,[intTicketId]= NULL
           ,[intTicketFileId]= @intCustomerStorageId
           ,[strSourceType]= 'Storage'
		   ,[intSort]=SD.[intSort]
		   ,[strDiscountChargeType]=SD.[strDiscountChargeType]
		FROM	dbo.[tblQMTicketDiscount] SD
		WHERE	SD.intTicketId = @intTicketId AND SD.strSourceType = 'Scale'
		
		UPDATE CS
		SET  CS.dblDiscountsDue=QM.dblDiscountsDue
			,CS.dblDiscountsPaid=QM.dblDiscountsPaid
		FROM tblGRCustomerStorage CS
		JOIN (SELECT intTicketFileId,SUM(dblDiscountDue) dblDiscountsDue ,SUM(dblDiscountPaid)dblDiscountsPaid FROM dbo.[tblQMTicketDiscount] WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage' GROUP BY intTicketFileId)QM
		ON CS.intCustomerStorageId=QM.intTicketFileId     


	END
	
	BEGIN
			IF @intGRStorageId > 0
			BEGIN
				SELECT @strDistributionOption = GR.strStorageTypeCode FROM tblGRStorageType GR WHERE intStorageScheduleTypeId = @intGRStorageId
			END

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
					,intTransactionDetailId =
					CASE 
						WHEN ISNULL(@intDPContractId,0) > 0 THEN @intDPContractId
						WHEN ISNULL(@intDPContractId,0) = 0 THEN NULL
					END
					,strTransactionId = ScaleTicket.strTicketNumber
					,intTransactionTypeId = @intDirectType 
					,intLotId = NULL 
					,intSubLocationId = ScaleTicket.intSubLocationId
					,intStorageLocationId = ScaleTicket.intStorageLocationId
					,ysnIsStorage = 
					CASE 
						WHEN ISNULL(@intDPContractId,0) > 0 THEN 0
						WHEN ISNULL(@intDPContractId,0) = 0 THEN 1
					END
					,strSourceTransactionId  = @strDistributionOption
			FROM	dbo.tblSCTicket ScaleTicket
					INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
					INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
			WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
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
					 ,4
					 ,@InventoryShipmentId OUTPUT;
			END
			BEGIN 
			SELECT	@strTransactionId = ship.strShipmentNumber
			FROM	dbo.tblICInventoryShipment ship	        
			WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
			END
			SELECT @strLotTracking = strLotTracking FROM tblICItem WHERE intItemId = @intItemId
			IF @strLotTracking = 'No'
			BEGIN
				EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;
			END
		
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