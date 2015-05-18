CREATE PROCEDURE testi21Database.[test fnCalculateAverageCost for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @Qty AS FLOAT 
	DECLARE @NewCost AS FLOAT 
	DECLARE @OnHandQty AS FLOAT 
	DECLARE @CurrentAverageCost AS FLOAT 
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateAverageCost(@Qty, @NewCost, @OnHandQty, @CurrentAverageCost);

	-- Assert 
	-- Result is the samve value of the current average cost. In this case, it is NULL. 
	EXEC tSQLt.AssertEquals @expected, @result;
END 