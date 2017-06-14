CREATE PROCEDURE [dbo].[uspGRUpdateGrainOpenBalanceByFIFO]
	 @strOptionType NVARCHAR(30)
	,@strSourceType NVARCHAR(30)---[InventoryShipment,Invoice,Scale]
	,@intEntityId INT
	,@intItemId INT
	,@intStorageTypeId INT
	,@dblUnitsConsumed NUMERIC(24, 10) = 0
	,@IntSourceKey INT
	,@intUserId INT
	
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dblAvailableGrainOpenBalance DECIMAL(24, 10)
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @StorageChargeDate DATETIME
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @intStorageChargeItemId INT
	DECLARE @strStorageChargeItemNo NVARCHAR(MAX)
	DECLARE @IntCommodityId INT
	DECLARE @FeeItemId INT
	DECLARE @strFeeItem NVARCHAR(40)
	DECLARE @strUserName NVARCHAR(40)
	DECLARE @strInventoryItem NVARCHAR(40)
	DECLARE @intItemUOMId AS INT
	DECLARE @intTransactionTypeId AS INT
	DECLARE @ItemCostingTableType AS ItemCostingTableType

	SELECT @intItemUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId AND ysnStockUnit = 1

	SELECT @intTransactionTypeId = intTransactionTypeId
	FROM dbo.tblICInventoryTransactionType
	WHERE strName = 'Inventory Adjustment - Quantity Change'
	
	DECLARE @StorageTicketInfoByFIFO AS TABLE 
	(
		 [intCustomerStorageId] INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblOpenBalance] NUMERIC(18, 6)
		,[intUnitMeasureId] INT
		,[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,[strItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS ---'Storage Charge','Fee','Discount'
		,[intItemId] INT
		,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblCharge] DECIMAL(24, 10)
	)

	SET @strUpdateType = 'estimate'
	SET @strProcessType = 'calculate'
	SET @StorageChargeDate = GetDATE()

	SELECT @FeeItemId = intItemId
	FROM tblGRCompanyPreference

	SELECT @strFeeItem = strItemNo
	FROM tblICItem
	WHERE intItemId = @FeeItemId
	
	SELECT @strInventoryItem = strItemNo
	FROM tblICItem
	WHERE intItemId = @intItemId
	
	SELECT @strUserName=strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityUserSecurityId] = @intUserId

	SELECT @dblAvailableGrainOpenBalance = SUM(dblOpenBalance)
	FROM vyuGRGetStorageTransferTicket
	WHERE intEntityId = @intEntityId
		AND intItemId = @intItemId
		AND intStorageTypeId = @intStorageTypeId
		AND ysnDPOwnedType = 0
		AND ysnCustomerStorage = 0

	IF @strOptionType = 'Inquiry'
	BEGIN
		SELECT @dblAvailableGrainOpenBalance
	END
	ELSE IF @dblUnitsConsumed > 0 AND @dblAvailableGrainOpenBalance > 0
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM vyuGRGetStorageTransferTicket WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intStorageTypeId = @intStorageTypeId AND dblOpenBalance > 0)
		BEGIN
			RAISERROR ('There is no available grain balance for this Entity,Item and Storage Type.',16,1);
		END
		
		SELECT @IntCommodityId = C.intCommodityId
		FROM tblICCommodity C
		JOIN tblICItem Item ON Item.intCommodityId = C.intCommodityId
		WHERE  Item.intItemId = @intItemId
		
		IF EXISTS (SELECT 1 FROM tblICItem WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId = @IntCommodityId)
		BEGIN
			SELECT TOP 1 @intStorageChargeItemId = intItemId
			FROM tblICItem
			WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId = @IntCommodityId
		END
		ELSE IF EXISTS (SELECT 1 FROM tblICItem WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId IS NULL)
		BEGIN
			SELECT TOP 1 @intStorageChargeItemId = intItemId
			FROM tblICItem
			WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId IS NULL
		END
		
		SELECT @strStorageChargeItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intStorageChargeItemId
				
		---1.Choosing the Grain Tickets Based ON FIFO(Delivery Date).
		WHILE @dblUnitsConsumed > 0
		BEGIN
			SET @intCustomerStorageId = NULL
			SET @dblStorageDuePerUnit = NULL
			SET @dblStorageDueAmount = NULL
			SET @dblStorageDueTotalPerUnit = NULL
			SET @dblStorageDueTotalAmount = NULL
			SET @dblStorageBilledPerUnit = NULL
			SET @dblStorageBilledAmount = NULL
			SET @dblStorageUnits = NULL

			SELECT TOP 1 @intCustomerStorageId = intCustomerStorageId
				,@dblStorageUnits = dblOpenBalance
			FROM vyuGRGetStorageTransferTicket
			WHERE intEntityId = @intEntityId
				AND intItemId = @intItemId
				AND intStorageTypeId = @intStorageTypeId
				AND ysnDPOwnedType = 0
				AND ysnCustomerStorage = 0
				AND dtmDeliveryDate IS NOT NULL
				AND intCustomerStorageId NOT IN (SELECT intCustomerStorageId FROM @StorageTicketInfoByFIFO)
			ORDER BY dtmDeliveryDate,intCustomerStorageId

			IF @intCustomerStorageId IS NULL
				BREAK

			IF @dblStorageUnits > @dblUnitsConsumed
				SET @dblStorageUnits = @dblUnitsConsumed

			EXEC uspGRCalculateStorageCharge 
				 @strProcessType
				,@strUpdateType
				,@intCustomerStorageId
				,NULL
				,NULL
				,1
				,@StorageChargeDate
				,@intUserId
				,0
				,NULL	
				,@dblStorageDuePerUnit OUTPUT
				,@dblStorageDueAmount OUTPUT
				,@dblStorageDueTotalPerUnit OUTPUT
				,@dblStorageDueTotalAmount OUTPUT
				,@dblStorageBilledPerUnit OUTPUT
				,@dblStorageBilledAmount OUTPUT
			
		 --1.Inventory	
			IF NOT EXISTS (
					SELECT 1
					FROM @StorageTicketInfoByFIFO
					WHERE [intCustomerStorageId] = @intCustomerStorageId AND [strItemType] = 'Inventory'
					)
			 BEGIN
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
				SELECT 
					 @intCustomerStorageId
					,a.[strStorageTicketNumber]
					,@dblStorageUnits
					,a.[intUnitMeasureId]
					,b.[strUnitMeasure]
					,'Inventory'
					,@intItemId
					,@strInventoryItem
					,0
				FROM tblGRCustomerStorage a
				JOIN tblICUnitMeasure b ON a.[intUnitMeasureId] = b.[intUnitMeasureId]
				WHERE [intCustomerStorageId] = @intCustomerStorageId
			END

		 --2. Storage Charge Item
		 
			IF @dblStorageDueAmount + @dblStorageDueTotalAmount > 0 
			BEGIN
									
				IF @intStorageChargeItemId IS NULL
				RAISERROR ('There should be atleast One Storage charge Cost Type Item.',16,1);
							
			IF NOT EXISTS (
						SELECT 1
						FROM @StorageTicketInfoByFIFO
						WHERE [intCustomerStorageId] = @intCustomerStorageId AND [strItemType] = 'Storage Charge'
						)
				BEGIN
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
					SELECT 
						 @intCustomerStorageId
						,a.[strStorageTicketNumber]
						,@dblStorageUnits
						,a.[intUnitMeasureId]
						,b.[strUnitMeasure]
						,'Storage Charge'
						,@intStorageChargeItemId
						,@strStorageChargeItemNo
						,@dblStorageDueAmount + @dblStorageDueTotalAmount --(Unpaid:@dblStorageDueAmount+ Additional :@dblStorageDueTotalAmount)				
					FROM tblGRCustomerStorage a
					JOIN tblICUnitMeasure b ON a.[intUnitMeasureId] = b.[intUnitMeasureId]
					WHERE [intCustomerStorageId] = @intCustomerStorageId
				END
			END

			--3. Fee Item
			IF NOT EXISTS (
					SELECT 1
					FROM @StorageTicketInfoByFIFO
					WHERE intCustomerStorageId = @intCustomerStorageId AND [strItemType] = 'Fee'
					)
				AND EXISTS (
					SELECT 1
					FROM tblGRCustomerStorage
					WHERE intCustomerStorageId = @intCustomerStorageId AND ISNULL(dblFeesDue, 0) < > ISNULL(dblFeesPaid, 0)
					)
			BEGIN
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
				SELECT 
					 @intCustomerStorageId
					,a.[strStorageTicketNumber]
					,@dblStorageUnits
					,a.[intUnitMeasureId]
					,b.[strUnitMeasure]
					,'Fee'
					,@FeeItemId
					,@strFeeItem
					,ISNULL(a.dblFeesDue, 0) - ISNULL(a.dblFeesPaid, 0)
				FROM tblGRCustomerStorage a
				JOIN tblICUnitMeasure b ON a.[intUnitMeasureId] = b.[intUnitMeasureId]
				WHERE [intCustomerStorageId] = @intCustomerStorageId				
			END

			--4. Discount Information
			IF NOT EXISTS (
					SELECT 1
					FROM @StorageTicketInfoByFIFO
					WHERE intCustomerStorageId = @intCustomerStorageId AND [strItemType] = 'Discount'
					)
				AND EXISTS (
					SELECT 1
					FROM tblQMTicketDiscount
					WHERE intTicketFileId = @intCustomerStorageId AND ISNULL(dblDiscountDue, 0) <> ISNULL(dblDiscountPaid, 0) AND strSourceType = 'Storage'
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
				SELECT 
					 @intCustomerStorageId
					,a.[strStorageTicketNumber]
					,@dblStorageUnits
					,a.[intUnitMeasureId]
					,b.[strUnitMeasure]
					,'Discount'
					,DItem.intItemId
					,DItem.strItemNo
					,ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)
				FROM tblGRCustomerStorage a
				JOIN tblICUnitMeasure b ON a.[intUnitMeasureId] = b.[intUnitMeasureId]
				JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = a.intCustomerStorageId AND QM.strSourceType = 'Storage'
				JOIN tblGRDiscountScheduleCode DC ON DC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				JOIN tblICItem DItem ON DItem.intItemId = DC.intItemId
				WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
					AND QM.intTicketFileId = @intCustomerStorageId

			SET @dblUnitsConsumed = @dblUnitsConsumed - @dblStorageUnits
		END

		INSERT INTO @ItemCostingTableType 
		(
			 [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intSubLocationId]
		)
		SELECT 
			 [intItemId] = @intItemId
			,[intItemLocationId] = (SELECT TOP 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = CS.intCompanyLocationId)
			,[intItemUOMId] = @intItemUOMId
			,[dtmDate] = GetDate()
			,[dblQty] = - tblFIFO.[dblOpenBalance]
			,[dblCost] = 0
			,[dblValue] = 0
			,[dblSalesPrice] = 0
			,[intCurrencyId] = NULL
			,[dblExchangeRate] = 1
			,[intTransactionId] = tblFIFO.intCustomerStorageId
			,[strTransactionId] = tblFIFO.[strStorageTicketNumber]
			,[intTransactionTypeId] = @intTransactionTypeId
			,[intSubLocationId] = CS.intCompanyLocationSubLocationId
			FROM @StorageTicketInfoByFIFO tblFIFO 
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=tblFIFO.intCustomerStorageId
			WHERE strItemType = 'Inventory'
        
		--1.Invoice Calls uspICPostStorage to Update Inventory.
		--2.GRN-616- Since Load Out Scale Ticket Update OnStore Inventory
		IF @strSourceType NOT IN ('Invoice','InventoryShipment')
		BEGIN
			EXEC dbo.uspICIncreaseOnStorageQty @ItemCostingTableType
		END

		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance - tblFIFO.dblOpenBalance
		FROM tblGRCustomerStorage CS
		JOIN @StorageTicketInfoByFIFO tblFIFO ON CS.intCustomerStorageId = tblFIFO.intCustomerStorageId AND tblFIFO.strItemType = 'Inventory'

		INSERT INTO [dbo].[tblGRStorageHistory] 
		(
			[intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intInvoiceId]
			,[intInventoryShipmentId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strType]
			,[strUserName]
		)
		SELECT 
			 [intConcurrencyId] = 1
			,[intCustomerStorageId] = intCustomerStorageId
			,[intTicketId] = CASE WHEN @strSourceType = 'Scale' THEN @IntSourceKey ELSE NULL END
			,[intInvoiceId] = CASE WHEN @strSourceType = 'Invoice' THEN @IntSourceKey ELSE NULL END
			,[intInventoryShipmentId] = CASE WHEN @strSourceType = 'InventoryShipment' THEN @IntSourceKey ELSE NULL END
			,[dblUnits] = dblOpenBalance
			,[dtmHistoryDate] = GetDATE()
			,[dblPaidAmount] = [dblCharge] * dblOpenBalance
			,[strType] = CASE
							 WHEN @strSourceType = 'Invoice' THEN 'Reduced By Invoice' 
							 WHEN @strSourceType = 'InventoryShipment' THEN 'Reduced By Inventory Shipment'
							 WHEN @strSourceType = 'Scale'      THEN 'Reduced By Scale'
					     END
			,[strUserName] = @strUserName
		FROM @StorageTicketInfoByFIFO
		WHERE strItemType = 'Inventory'

		SELECT 
			 [intCustomerStorageId]
			,[strStorageTicketNumber]
			,[dblOpenBalance]
			,[intUnitMeasureId]
			,[strUnitMeasure]
			,[strItemType]
			,[intItemId]
			,[strItem]
			,[dblCharge]			
		FROM @StorageTicketInfoByFIFO
		
	END
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
