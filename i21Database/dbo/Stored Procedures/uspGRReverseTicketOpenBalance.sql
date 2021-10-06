CREATE PROCEDURE [dbo].[uspGRReverseTicketOpenBalance]
   @strSourceType NVARCHAR(30)
  ,@IntSourceKey INT
  ,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]
	DECLARE @intStorageHistoryId INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	--DECLARE @strUserName NVARCHAR(40)
	DECLARE @strType NVARCHAR(100)
	DECLARE @intTransactionTypeId AS INT
	DECLARE @ItemCostingTableType AS ItemCostingTableType

	SELECT @intTransactionTypeId = intTransactionTypeId
	FROM dbo.tblICInventoryTransactionType
	WHERE strName = 'Inventory Adjustment - Quantity'

	-- SELECT @strUserName=strUserName
	-- FROM tblSMUserSecurity
	-- WHERE [intEntityId] = @intUserId

	SELECT @strType= CASE 
							 WHEN @strSourceType = 'Invoice' THEN 'Reduced By Invoice' 
							 WHEN @strSourceType = 'InventoryShipment' THEN 'Reduced By Inventory Shipment'
							 WHEN @strSourceType = 'Scale'      THEN 'Reduced By Scale'
					 END

    IF @strType='Reduced By Inventory Shipment'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInventoryShipmentId=@IntSourceKey AND SH.strType=@strType AND SH.intInventoryReceiptId IS NULL

		INSERT INTO @StorageHistoryStagingTable
		(
			intCustomerStorageId
			, intUserId
			, ysnPost
			, intTransactionTypeId
			, strType
			, dblUnits
			, intInvoiceId
			, dtmHistoryDate
			, intInventoryShipmentId
			, intTicketId
		)
		SELECT
			  intCustomerStorageId
			, @intUserId
			, 0
			, 8--10 -- Transaction Type Id for Inventory Adjustment - Quantity
			, 'Reverse By Inventory Shipment'
			, dblUnits
			, intInvoiceId
			, GETDATE()
			, intInventoryShipmentId
			, intTicketId
		FROM tblGRStorageHistory
		WHERE intInventoryShipmentId = @IntSourceKey
			AND strType = @strType
			AND intInventoryReceiptId IS NULL
		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT
		
		-- INSERT INTO [dbo].[tblGRStorageHistory] 
		-- (
		-- 	 [intConcurrencyId]
		-- 	,[intCustomerStorageId]
		-- 	,[intTicketId]
		-- 	,[intInvoiceId]
		-- 	,[intInventoryShipmentId]
		-- 	,[dblUnits]
		-- 	,[dtmHistoryDate]
		-- 	,[dblPaidAmount]
		-- 	,[strType]
		-- 	,[strUserName]
		-- 	,[intUserId]
		-- )
		-- SELECT 
		-- 	 [intConcurrencyId] = 1
		-- 	,[intCustomerStorageId] = intCustomerStorageId
		-- 	,[intTicketId] = intTicketId
		-- 	,[intInvoiceId]=intInvoiceId
		-- 	,[intInventoryShipmentId] = intInventoryShipmentId
		-- 	,[dblUnits] = dblUnits
		-- 	,[dtmHistoryDate] = GetDATE()
		-- 	,[dblPaidAmount] = NULL 
		-- 	,[strType] = 'Reverse By Inventory Shipment'
		-- 	,[strUserName] = NULL
		-- 	,[intUserId] = @intUserId
		-- FROM tblGRStorageHistory WHERE intInventoryShipmentId=@IntSourceKey AND strType=@strType AND intInventoryReceiptId IS NULL

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
			 [intItemId] = CS.intItemId
			,[intItemLocationId] = (SELECT TOP 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = CS.intItemId AND intLocationId = CS.intCompanyLocationId)
			,[intItemUOMId] = (SELECT  intItemUOMId FROM dbo.tblICItemUOM WHERE intItemId =  CS.intItemId AND ysnStockUnit = 1)
			,[dtmDate] = GetDate()
			,[dblQty] = SH.dblUnits
			,[dblCost] = 0
			,[dblValue] = 0
			,[dblSalesPrice] = 0
			,[intCurrencyId] = NULL
			,[dblExchangeRate] = 1
			,[intTransactionId] = CS.intCustomerStorageId
			,[strTransactionId] = CS.[strStorageTicketNumber]
			,[intTransactionTypeId] = @intTransactionTypeId
			,[intSubLocationId] = CS.intCompanyLocationSubLocationId
			FROM tblGRCustomerStorage CS
			JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInventoryShipmentId=@IntSourceKey AND SH.strType=@strType AND SH.intInventoryReceiptId IS NULL
			JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=CS.intStorageTypeId AND St.ysnDPOwnedType=0

		UPDATE tblGRStorageHistory SET intInventoryReceiptId = 0 WHERE intInventoryShipmentId=@IntSourceKey AND strType=@strType AND intInventoryReceiptId IS NULL

	END
	ELSE IF  @strType='Reduced By Scale'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intTicketId=@IntSourceKey AND SH.strType=@strType AND SH.intInventoryReceiptId IS NULL 

		INSERT INTO @StorageHistoryStagingTable
		(
			intCustomerStorageId
			, intUserId
			, ysnPost
			, intTransactionTypeId
			, strType
			, dblUnits
			, intInventoryShipmentId
			, dtmHistoryDate
			, intInvoiceId
			, intTicketId
		)
		SELECT
			  intCustomerStorageId
			, @intUserId
			, 0
			, 1 -- Transaction Type Id for Invoice
			, 'Reverse By Scale'
			, dblUnits
			, intInventoryShipmentId
			, GETDATE()
			, intInvoiceId
			, intTicketId
		FROM tblGRStorageHistory
		WHERE intTicketId = @IntSourceKey
			AND strType = @strType
			AND intInventoryReceiptId IS NULL
		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT
		-- INSERT INTO [dbo].[tblGRStorageHistory] 
		-- (
		-- 	 [intConcurrencyId]
		-- 	,[intCustomerStorageId]
		-- 	,[intTicketId]
		-- 	,[intInvoiceId]
		-- 	,[intInventoryShipmentId]
		-- 	,[dblUnits]
		-- 	,[dtmHistoryDate]
		-- 	,[dblPaidAmount]
		-- 	,[strType]
		-- 	,[strUserName]
		-- 	,[intUserId]
		-- )
		-- SELECT 
		-- 	 [intConcurrencyId] = 1
		-- 	,[intCustomerStorageId] = intCustomerStorageId
		-- 	,[intTicketId] = intTicketId
		-- 	,[intInvoiceId]=intInvoiceId
		-- 	,[intInventoryShipmentId] = intInventoryShipmentId
		-- 	,[dblUnits] = dblUnits
		-- 	,[dtmHistoryDate] = GetDATE()
		-- 	,[dblPaidAmount] = NULL 
		-- 	,[strType] = 'Reverse By Scale'
		-- 	,[strUserName] = NULL
		-- 	,[intUserId] = @intUserId
		-- FROM tblGRStorageHistory WHERE intTicketId=@IntSourceKey AND strType=@strType AND intInventoryReceiptId IS NULL

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
			 [intItemId] = CS.intItemId
			,[intItemLocationId] = (SELECT TOP 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = CS.intItemId AND intLocationId = CS.intCompanyLocationId)
			,[intItemUOMId] = (SELECT  intItemUOMId FROM dbo.tblICItemUOM WHERE intItemId =  CS.intItemId AND ysnStockUnit = 1)
			,[dtmDate] = GetDate()
			,[dblQty] = SH.dblUnits
			,[dblCost] = 0
			,[dblValue] = 0
			,[dblSalesPrice] = 0
			,[intCurrencyId] = NULL
			,[dblExchangeRate] = 1
			,[intTransactionId] = CS.intCustomerStorageId
			,[strTransactionId] = CS.[strStorageTicketNumber]
			,[intTransactionTypeId] = @intTransactionTypeId
			,[intSubLocationId] = CS.intCompanyLocationSubLocationId
			FROM tblGRCustomerStorage CS
			JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInventoryShipmentId=@IntSourceKey AND SH.strType=@strType AND SH.intInventoryReceiptId IS NULL
			JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=CS.intStorageTypeId AND St.ysnDPOwnedType=0
		
		UPDATE tblGRStorageHistory SET intInventoryReceiptId=0 WHERE intTicketId=@IntSourceKey AND strType=@strType AND intInventoryReceiptId IS NULL

	END
	ELSE IF  @strType='Reduced By Invoice'
	BEGIN
		UPDATE CS
		SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnits
		FROM tblGRCustomerStorage CS
		JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInvoiceId=@IntSourceKey AND SH.strType=@strType AND SH.intInventoryReceiptId IS NULL

		INSERT INTO @StorageHistoryStagingTable
		(
			intCustomerStorageId
			, intUserId
			, ysnPost
			, intTransactionTypeId
			, strType
			, dblUnits
			, intInventoryShipmentId
			, dtmHistoryDate
			, intInvoiceId
			, intTicketId
		)
		SELECT
			  intCustomerStorageId
			, @intUserId
			, 0
			, 6 -- Transaction Type Id for Invoice
			, 'Reverse By Invoice'
			, dblUnits
			, intInventoryShipmentId
			, GETDATE()
			, intInvoiceId
			, intTicketId
		FROM tblGRStorageHistory
		WHERE intInvoiceId = @IntSourceKey
			AND strType = @strType
			AND intInventoryReceiptId IS NULL
		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT
		-- INSERT INTO [dbo].[tblGRStorageHistory] 
		-- (
		-- 	 [intConcurrencyId]
		-- 	,[intCustomerStorageId]
		-- 	,[intTicketId]
		-- 	,[intInvoiceId]
		-- 	,[intInventoryShipmentId]
		-- 	,[dblUnits]
		-- 	,[dtmHistoryDate]
		-- 	,[dblPaidAmount]
		-- 	,[strType]
		-- 	,[strUserName]
		-- 	,[intUserId]
		-- )
		-- SELECT 
		-- 	 [intConcurrencyId] = 1
		-- 	,[intCustomerStorageId] = intCustomerStorageId
		-- 	,[intTicketId] = intTicketId
		-- 	,[intInvoiceId]=intInvoiceId
		-- 	,[intInventoryShipmentId] = intInventoryShipmentId
		-- 	,[dblUnits] = dblUnits
		-- 	,[dtmHistoryDate] = GetDATE()
		-- 	,[dblPaidAmount] = NULL 
		-- 	,[strType] = 'Reverse By Invoice'
		-- 	,[strUserName] = NULL
		-- 	,[intUserId] = @intUserId
		-- FROM tblGRStorageHistory WHERE intInvoiceId=@IntSourceKey AND strType=@strType AND intInventoryReceiptId IS NULL

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
			 [intItemId] = CS.intItemId
			,[intItemLocationId] = (SELECT TOP 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = CS.intItemId AND intLocationId = CS.intCompanyLocationId)
			,[intItemUOMId] = (SELECT  intItemUOMId FROM dbo.tblICItemUOM WHERE intItemId =  CS.intItemId AND ysnStockUnit = 1)
			,[dtmDate] = GetDate()
			,[dblQty] = SH.dblUnits
			,[dblCost] = 0
			,[dblValue] = 0
			,[dblSalesPrice] = 0
			,[intCurrencyId] = NULL
			,[dblExchangeRate] = 1
			,[intTransactionId] = CS.intCustomerStorageId
			,[strTransactionId] = CS.[strStorageTicketNumber]
			,[intTransactionTypeId] = @intTransactionTypeId
			,[intSubLocationId] = CS.intCompanyLocationSubLocationId
			FROM tblGRCustomerStorage CS
			JOIN tblGRStorageHistory SH  ON SH.intCustomerStorageId = CS.intCustomerStorageId AND SH.intInventoryShipmentId=@IntSourceKey AND SH.strType=@strType AND SH.intInventoryReceiptId IS NULL
			JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=CS.intStorageTypeId AND St.ysnDPOwnedType=0

		UPDATE tblGRStorageHistory SET intInventoryReceiptId=0 WHERE intInvoiceId=@IntSourceKey AND strType=@strType AND intInventoryReceiptId IS NULL

	END

	--BEGIN--------------------------------------------------------------------------------------------------------------------
		-- Commented out: 
		-- 1. @strSourceType = 'Invoice'
		--		uspARPostInvoice is already calling uspICPostStorage. No need to call uspICIncreaseOnStorageQty. 
		-- 2. @strSourceType = 'Scale'
		--		This does not impact the storage stock. No need to call uspICIncreaseOnStorageQty.
		-- 3. @strSourceType = 'InventoryShipment'
		--		uspICPostShipment is already calling uspICPostStorage. No need to call uspICIncreaseOnStorageQty. 
		----------------------------------------------------------------------------------------------------------------------
		--IF @strSourceType < > 'InventoryShipment'
		--BEGIN
		--		EXEC dbo.uspICIncreaseOnStorageQty @ItemCostingTableType
		--END
	--END--------------------------------------------------------------------------------------------------------------------
	 
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
