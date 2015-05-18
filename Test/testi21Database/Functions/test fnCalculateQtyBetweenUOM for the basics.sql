CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for the basics]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]

	-- Arrange
	DECLARE @intItemUOMIdFrom AS INT
	DECLARE @intItemUOMIdTo AS INT
	DECLARE @dblQty AS NUMERIC(18,6)

	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@intItemUOMIdFrom, @intItemUOMIdTo, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 