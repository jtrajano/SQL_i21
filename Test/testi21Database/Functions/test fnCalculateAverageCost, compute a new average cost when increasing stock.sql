CREATE PROCEDURE testi21Database.[test fnCalculateAverageCost, compute a new average cost when increasing stock]
AS 
BEGIN
	-- Arrange
	DECLARE @Qty AS FLOAT = 20
	DECLARE @NewCost AS FLOAT = 10
	DECLARE @OnHandQty AS FLOAT = 100
	DECLARE @CurrentAverageCost AS FLOAT = 11.00
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6) = ((@Qty * @NewCost) + (@OnHandQty * @CurrentAverageCost)) / (@Qty + @OnHandQty)

	-- Act
	SELECT @result = dbo.fnCalculateAverageCost(@Qty, @NewCost, @OnHandQty, @CurrentAverageCost);

	-- Assert 
	-- It should compute a new average cost when increasing the stock. 
	EXEC tSQLt.AssertEquals @expected, @result;
END 