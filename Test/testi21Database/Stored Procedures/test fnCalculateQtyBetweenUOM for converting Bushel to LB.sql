CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting Bushel to LB]
AS 
BEGIN
	-- Call the fake data
	EXEC [testi21Database].[Fake data for item uom table, bushel scenario]

	DECLARE @BUSHEL AS INT = 1 
			,@LB AS INT = 2

	-- Arrange
	DECLARE @dblQty AS FLOAT = 1

	DECLARE @result AS NUMERIC(38,20) 
	DECLARE @expected AS NUMERIC(38,20) = 55.99999999999999000000 -- One bushel is 56 LBS but calculations can only compute it as 55.99999999999999000000 lb
	
	-- Act
	SELECT @result = dbo.[fnCalculateQtyBetweenUOM](@BUSHEL, @LB, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END