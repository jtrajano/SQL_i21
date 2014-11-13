CREATE PROCEDURE testi21Database.[test fnCalculateAverageCost, use the current average cost when reducing stock]
AS 
BEGIN
	-- Arrange
	DECLARE @Qty AS FLOAT = -10
	DECLARE @NewCost AS FLOAT = 10
	DECLARE @OnHandQty AS FLOAT = 100
	DECLARE @CurrentAverageCost AS FLOAT = 11.00
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6) = 11.00

	-- Act
	SELECT @result = dbo.fnCalculateAverageCost(@Qty, @NewCost, @OnHandQty, @CurrentAverageCost);

	-- Assert 
	-- When reducing stock, use the current average cost. 
	EXEC tSQLt.AssertEquals @expected, @result;
END 