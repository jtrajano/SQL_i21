CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for the transaction type  - expiry date change]
AS
BEGIN
	DECLARE @INVENTORY_ADJUSTMENT_QuantityChange AS INT = 10
			,@INVENTORY_ADJUSTMENT_UOMChange AS INT = 14
			,@INVENTORY_ADJUSTMENT_ItemChange AS INT = 15
			,@INVENTORY_ADJUSTMENT_LotStatusChange AS INT = 16
			,@INVENTORY_ADJUSTMENT_SplitLot AS INT = 17
			,@INVENTORY_ADJUSTMENT_ExpiryDateChange AS INT = 18
			,@INVENTORY_ADJUSTMENT_LotMerge AS INT = 19
			,@INVENTORY_ADJUSTMENT_LotMove AS INT = 20

	-- Arrange 
	BEGIN 
		DECLARE @strTransactionTypeName AS NVARCHAR(50) = 'Inventory Adjustment - Expiry Date Change'
				,@intTransactionTypeId AS INT 
				,@ExpectedTransactionTypeId AS INT = @INVENTORY_ADJUSTMENT_ExpiryDateChange
	END 

	-- Act
	BEGIN 
		SELECT	@intTransactionTypeId = intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType
		WHERE	strName = @strTransactionTypeName
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals @ExpectedTransactionTypeId, @intTransactionTypeId;
	END
END