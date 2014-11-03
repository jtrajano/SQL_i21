CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for bad inputs]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intLocationId AS INT

		DECLARE @actual AS INT;
		DECLARE @expected AS INT;

		-- GL Account types used in inventory costing
		DECLARE @InventoryDescription AS NVARCHAR(50) = 'Inventory';
		DECLARE @CostOfGoodsDescription AS NVARCHAR(50) = 'Cost of Goods';
		DECLARE @PurchasesDescription AS NVARCHAR(50) = 'Purchase Account';
				
		-- Generate the fake data. 
		EXEC testi21Database.[Fake data for simple Items]
	END

	-- Act
	-- Test for bad inputs
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		-- If item and location is null, expected is also NULL. 
		SET @expected = NULL;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END
END 