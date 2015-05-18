CREATE PROCEDURE testi21Database.[test fnGetItemLotType for Yes Manual]
AS 
BEGIN

	-- Arrange
	EXEC testi21Database.[Fake data for inventory receipt table]
	
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
	
	DECLARE @result AS INT

	-- Act
	SELECT @result = dbo.fnGetItemLotType(@ManualLotGrains);

	-- Assert the NULL item is NULL lot type 
	EXEC tSQLt.AssertEquals 1, @result;
END 
