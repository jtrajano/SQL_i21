CREATE PROCEDURE testi21Database.[test fnIsStockTrackingItem for non-stock keeping type]
AS 
BEGIN
	-- Arrange
	BEGIN 
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7		

		DECLARE @result AS BIT
		
		EXEC testi21Database.[Fake inventory items]

		UPDATE tblICItem
		SET strType = 'Non-Inventory'
	END 

	-- Act
	BEGIN 
		SELECT @result = dbo.fnIsStockTrackingItem(@WetGrains);
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals 0, @result;
	END
END 
