CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 60 KG BAG to LB]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table, kg scenario]
	
	DECLARE @KGS AS INT = 1
			,@LBS AS INT = 2
			,@60KG_BAG AS INT = 3		

	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 1

	DECLARE @result AS NUMERIC(38,20)
	DECLARE @expected AS NUMERIC(38,20) = 132.27746521102660000000

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@60KG_BAG, @LBS, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END