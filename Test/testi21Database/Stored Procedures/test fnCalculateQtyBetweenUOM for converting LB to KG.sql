CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting LB to KG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	

	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 100

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @Expected AS NUMERIC(18,6) = 100 * 1 / 2.2046226218500 --45.3592

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@LBS, @KGS, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @Expected, @result;
END