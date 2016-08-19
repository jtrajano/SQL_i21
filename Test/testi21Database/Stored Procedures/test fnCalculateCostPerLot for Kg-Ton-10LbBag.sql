CREATE PROCEDURE testi21Database.[test fnCalculateCostPerLot for Kg-Ton-10LbBag]
AS 
BEGIN
	-- Setup the fake data
	EXEC [testi21Database].[Fake inventory items];

	DECLARE	@WetGrains_Lb AS INT = 8
			,@WetGrains_Kg AS INT = 15
			,@WetGrains_25KgBag AS INT = 22
			,@WetGrains_10LbBag AS INT = 29
			,@WetGrains_Ton AS INT = 36

	-- Arrange
	DECLARE	@intItemUOMId AS INT = @WetGrains_Kg
			,@intWeightUOMId AS INT = @WetGrains_Ton
			,@intLotUOMId AS INT = @WetGrains_10LbBag
			,@dblCostPerItemUOMId AS NUMERIC(38, 20) = 13.35

	DECLARE @result AS NUMERIC(38, 20)
	DECLARE @expected AS NUMERIC(38, 20) = 60.554653409658 -- 60.5546534096579

	-- Act
	SELECT @result = dbo.fnCalculateCostPerLot(
			@intItemUOMId
			,@intWeightUOMId
			,@intLotUOMId
			,@dblCostPerItemUOMId
	);

	-- Assert 
	-- Result is the samve value of the current average cost. In this case, it is NULL. 
	EXEC tSQLt.AssertEquals @expected, @result;
END