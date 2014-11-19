CREATE PROCEDURE testi21Database.[test fnCalculateAverageCost, use new cost when increasing stock but stock was from negative or zero]
AS 
BEGIN
	-- Arrange
	DECLARE @Qty AS FLOAT = 54
	DECLARE @NewCost AS FLOAT = 8.33
	DECLARE @OnHandQty AS FLOAT = -53
	DECLARE @CurrentAverageCost AS FLOAT = 0
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6) = 8.33

	-- Act
	SELECT @result = dbo.fnCalculateAverageCost(@Qty, @NewCost, @OnHandQty, @CurrentAverageCost);

	-- Assert 
	-- Use the same cost from purchase (@NewCost) when on-hand qty + new qty is zero. 
	EXEC tSQLt.AssertEquals @expected, @result;
END 