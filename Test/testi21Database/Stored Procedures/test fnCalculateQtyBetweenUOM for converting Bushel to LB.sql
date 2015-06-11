CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting Bushel to LB]
AS 
BEGIN
	-- Call the fake data
	EXEC [testi21Database].[Fake data for item uom table, bushel scenario]

	DECLARE @BUSHEL AS INT = 1 
			,@LB AS INT = 2

	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 1

	DECLARE @result AS NUMERIC(38,20) 
	DECLARE @expected AS NUMERIC(38,20) = 56.00 -- One bushel is 56 pounds. 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@BUSHEL, @LB, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END