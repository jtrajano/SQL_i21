CREATE PROCEDURE [dbo].[uspGRUpdateOnStoreInventory]
	 @intCustomerStorageId INT
	,@dblOpenBalance NUMERIC(24, 10)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intItemLocationId INT
	DECLARE @intItemUOMId AS INT
	DECLARE @intTransactionTypeId AS INT
	DECLARE @dblCurrentOpenBalance NUMERIC(24, 10)
	DECLARE @intItemId AS INT
	DECLARE @intCompanyLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @strStorageTicketNumber Nvarchar(40)

	IF EXISTS ( SELECT 1 FROM [tblGRCustomerStorage] WHERE intCustomerStorageId = @intCustomerStorageId AND dblOpenBalance <> @dblOpenBalance)
	BEGIN
		SELECT 
			 @intItemId = intItemId
			,@dblCurrentOpenBalance = dblOpenBalance
			,@intCompanyLocationId = intCompanyLocationId
			,@strStorageTicketNumber = strStorageTicketNumber
			,@intSubLocationId=intCompanyLocationSubLocationId
		FROM [tblGRCustomerStorage]
		WHERE intCustomerStorageId = @intCustomerStorageId

		SELECT TOP 1 @intItemLocationId = intItemLocationId
		FROM tblICItemLocation
		WHERE intItemId = @intItemId AND intLocationId = @intCompanyLocationId

		SELECT @intItemUOMId = intItemUOMId
		FROM dbo.tblICItemUOM
		WHERE intItemId = @intItemId AND ysnStockUnit = 1

		SELECT @intTransactionTypeId = intTransactionTypeId
		FROM dbo.tblICInventoryTransactionType
		WHERE strName = 'Inventory Adjustment - Quantity Change'

		DECLARE @ItemCostingTableType AS ItemCostingTableType

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
		SELECT [intItemId] = @intItemId
			,[intItemLocationId] = @intItemLocationId
			,[intItemUOMId] = @intItemUOMId
			,[dtmDate] = GetDate()
			,[dblQty] = (@dblCurrentOpenBalance - @dblOpenBalance)
			,[dblCost] = 0
			,[dblValue] = 0
			,[dblSalesPrice] = 0
			,[intCurrencyId] = NULL
			,[dblExchangeRate] = 1
			,[intTransactionId] = @intCustomerStorageId
			,[strTransactionId] = LTRIM(@strStorageTicketNumber)
			,[intTransactionTypeId] = @intTransactionTypeId
			,[intSubLocationId]=@intSubLocationId

		--TODO: Use uspICInventoryAdjustment_CreatePostQtyChange to adjust the storage stocks instead of uspICIncreaseOnStorageQty. 
		--Commented the code below: 
		--EXEC dbo.uspICIncreaseOnStorageQty @ItemCostingTableType
	END
END TRY

BEGIN CATCH

	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH