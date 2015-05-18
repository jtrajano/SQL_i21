CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for the transaction type]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @strTransactionTypeName AS NVARCHAR(50) = 'Inventory Adjustment'
				,@intTransactionTypeId AS INT 
				,@ExpectedTransactionTypeId AS INT = 10
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