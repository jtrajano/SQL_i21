﻿CREATE PROCEDURE [dbo].[uspGRUpdateGrainOpenBalanceByFIFO]
	 @strOptionType NVARCHAR(30)
	,@strSourceType NVARCHAR(30)---[InventoryShipment,Invoice,Scale]
	,@intEntityId INT
	,@intItemId INT
	,@intStorageTypeId INT
	,@dblUnitsConsumed NUMERIC(24, 10) = 0
	,@IntSourceKey INT
	,@intUserId INT
	,@intCompanyLocationId INT = 0
	
AS
SET ANSI_WARNINGS ON

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
	DECLARE @FeeItemId INT
	DECLARE @strFeeItem NVARCHAR(40)
	--DECLARE @strUserName NVARCHAR(40)
	DECLARE @strInventoryItem NVARCHAR(40)
	DECLARE @intItemUOMId AS INT
	DECLARE @intTransactionTypeId AS INT
	DECLARE @ItemCostingTableType AS ItemCostingTableType
	DECLARE @dblFlatFeeTotal		DECIMAL(24, 10)
	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]
	DECLARE @intStorageHistoryId INT

	SELECT @intItemUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId AND ysnStockUnit = 1

	SELECT @intTransactionTypeId = intTransactionTypeId
	FROM dbo.tblICInventoryTransactionType
	WHERE strName = 'Inventory Adjustment - Quantity'
	
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
		,[dblFlatFee] DECIMAL(24, 10)
		,[dtmDeliveryDate] DATETIME NULL
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
	
	-- SELECT @strUserName=strUserName
	-- FROM tblSMUserSecurity
	-- WHERE [intEntityId] = @intUserId

	SELECT @dblAvailableGrainOpenBalance = SUM(dblOpenBalance)
	FROM vyuGRGetStorageTickets
	WHERE intEntityId = @intEntityId
		AND intItemId = @intItemId
		AND intStorageTypeId = @intStorageTypeId
		AND ysnDPOwnedType = 0
		--AND ysnCustomerStorage = 0
		AND ysnShowInStorage = 1
		AND intCompanyLocationId = CASE 
										WHEN @intCompanyLocationId >0 THEN @intCompanyLocationId 
										ELSE intCompanyLocationId 
								   END

	IF @strOptionType = 'Inquiry'
	BEGIN
		SELECT @dblAvailableGrainOpenBalance
	END
	ELSE IF @dblUnitsConsumed > 0 AND @dblAvailableGrainOpenBalance > 0
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM vyuGRGetStorageTickets WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intStorageTypeId = @intStorageTypeId AND dblOpenBalance > 0 
																		AND intCompanyLocationId = CASE 
																										WHEN @intCompanyLocationId >0 THEN @intCompanyLocationId 
																										ELSE intCompanyLocationId 
																								   END
																		AND ysnShowInStorage = 1
				      )
		BEGIN
			RAISERROR ('There is no available grain balance for this Entity,Item and Storage Type.',16,1);
		END
				
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
			SET @dblFlatFeeTotal = NULL

			SELECT TOP 1 @intCustomerStorageId = intCustomerStorageId
				,@dblStorageUnits = dblOpenBalance
			FROM vyuGRGetStorageTickets
			WHERE intEntityId = @intEntityId
				AND intItemId = @intItemId
				AND intStorageTypeId = @intStorageTypeId
				AND intCompanyLocationId = CASE 
												WHEN @intCompanyLocationId >0 THEN @intCompanyLocationId 
												ELSE intCompanyLocationId 
										   END
				AND ysnDPOwnedType = 0
				--AND ysnCustomerStorage = 0
				AND ysnShowInStorage = 1
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
				,@dblFlatFeeTotal OUTPUT
			
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
					,[dtmDeliveryDate]
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
					,dtmDeliveryDate
				FROM tblGRCustomerStorage a
				JOIN tblICUnitMeasure b ON a.[intUnitMeasureId] = b.[intUnitMeasureId]
				WHERE [intCustomerStorageId] = @intCustomerStorageId
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
		--IF @strSourceType NOT IN ('Invoice','InventoryShipment')
		--BEGIN
		--	EXEC dbo.uspICIncreaseOnStorageQty @ItemCostingTableType
		--END

		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance - tblFIFO.dblOpenBalance
		FROM tblGRCustomerStorage CS
		JOIN @StorageTicketInfoByFIFO tblFIFO ON CS.intCustomerStorageId = tblFIFO.intCustomerStorageId AND tblFIFO.strItemType = 'Inventory'

		INSERT INTO @StorageHistoryStagingTable
		(
			[intCustomerStorageId]
			,[intTicketId]
			,[intInvoiceId]
			,[intInventoryShipmentId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[intTransactionTypeId]
			,[strType]
			,[strPaidDescription]
			,[intUserId]
		)
		SELECT 
			[intCustomerStorageId] 		= intCustomerStorageId
			,[intTicketId] 				= CASE 
											WHEN @strSourceType = 'Scale' THEN @IntSourceKey 
											--WHEN @strSourceType = 'InventoryShipment' THEN A.intSourceId
											ELSE NULL END
			,[intInvoiceId] 			= CASE WHEN @strSourceType = 'Invoice' THEN @IntSourceKey ELSE NULL END
			,[intInventoryShipmentId] 	= CASE WHEN @strSourceType = 'InventoryShipment' THEN @IntSourceKey ELSE NULL END
			,[dblUnits] 				= dblOpenBalance
			,[dtmHistoryDate] 			= dbo.fnRemoveTimeOnDate(dtmDeliveryDate)
										--CASE 
										--	WHEN @strSourceType = 'InventoryShipment' THEN A.dtmShipDate--dbo.fnRemoveTimeOnDate(dtmDeliveryDate)
										--	ELSE dbo.fnRemoveTimeOnDate(dtmDeliveryDate)
										--END										
			,[dblPaidAmount] 			= [dblCharge] * dblOpenBalance + ISNULL(dblFlatFee,0)
			,[intTransactionTypeId] 	= CASE
											WHEN @strSourceType = 'Invoice' THEN 6
											WHEN @strSourceType = 'InventoryShipment' THEN 8
											WHEN @strSourceType = 'Scale' THEN 1
										END
			,[strType] 					= CASE
											WHEN @strSourceType = 'Invoice' THEN 'Reduced By Invoice' 
											WHEN @strSourceType = 'InventoryShipment' THEN 'Reduced By Inventory Shipment'
											WHEN @strSourceType = 'Scale' THEN 'Reduced By Scale'
										END
			,[strPaidDescription] 		= CASE
											WHEN @strSourceType = 'Invoice' THEN 'Reduced By Invoice' 
											WHEN @strSourceType = 'InventoryShipment' THEN 'Reduced By Inventory Shipment'
											WHEN @strSourceType = 'Scale' THEN 'Reduced By Scale'
										END
			,[intUserId] 				= @intUserId
		FROM @StorageTicketInfoByFIFO
		CROSS APPLY (
			SELECT ShipmentItem.intSourceId
				,Shipment.dtmShipDate
			FROM tblICInventoryShipment Shipment
			JOIN tblICInventoryShipmentItem ShipmentItem
				ON ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
			JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = ShipmentItem.intStorageScheduleTypeId
			WHERE Shipment.intInventoryShipmentId = @IntSourceKey
				AND @strSourceType = 'InventoryShipment'
			--AND [strType]='Reduced By Inventory Shipment'
			--AND ShipmentItem.intStorageScheduleTypeId IS NOT NULL
		) A
		WHERE strItemType = 'Inventory'

		IF @strSourceType = 'Invoice'
		BEGIN
			UPDATE SH
			SET strInvoice = AR.strInvoiceNumber
			FROM @StorageHistoryStagingTable SH
			INNER JOIN tblARInvoice AR
				ON AR.intInvoiceId = SH.intInvoiceId
		END

		IF @strSourceType = 'InventoryShipment'
		BEGIN
		      IF EXISTS( SELECT 1
						FROM tblICInventoryShipment Shipment
						JOIN tblICInventoryShipmentItem ShipmentItem
							ON ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
						JOIN tblGRStorageType ST
							ON ST.intStorageScheduleTypeId = ShipmentItem.intStorageScheduleTypeId
						WHERE Shipment.intInventoryShipmentId = @IntSourceKey
				)
			 BEGIN
				 UPDATE SH 
				 SET intTicketId			  = A.intSourceId
					,dtmHistoryDate			= A.dtmShipDate
				--,SH.intTransactionTypeId  = 1
				FROM @StorageHistoryStagingTable SH
				CROSS APPLY (
					SELECT ShipmentItem.intSourceId
					,Shipment.dtmShipDate
				FROM tblICInventoryShipment Shipment
				JOIN tblICInventoryShipmentItem ShipmentItem
					ON ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
				JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = ShipmentItem.intStorageScheduleTypeId
				WHERE Shipment.intInventoryShipmentId = @IntSourceKey
					AND @strSourceType = 'InventoryShipment'
				) A
				WHERE SH.intInventoryShipmentId=@IntSourceKey 
				AND [strType]='Reduced By Inventory Shipment'
			 END
		END

		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT

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
			,[dblFlatFee]			
		FROM @StorageTicketInfoByFIFO
		
	END
END TRY

BEGIN CATCH	
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
