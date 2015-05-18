CREATE PROCEDURE testi21Database.[test fnCalculateAverageCost, use new cost when increasing stock but aggregate result is zero]
AS 
BEGIN
	-- Arrange
	DECLARE @Qty AS FLOAT = 20
	DECLARE @NewCost AS FLOAT = 10.00
	DECLARE @OnHandQty AS FLOAT = -20
	DECLARE @CurrentAverageCost AS FLOAT = 11.00
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6) = 10.00

	-- Act
	SELECT @result = dbo.fnCalculateAverageCost(@Qty, @NewCost, @OnHandQty, @CurrentAverageCost);

	-- Assert 
	-- Use the same cost from purchase (@NewCost) when on-hand qty + new qty is zero. 
	EXEC tSQLt.AssertEquals @expected, @result;
END 