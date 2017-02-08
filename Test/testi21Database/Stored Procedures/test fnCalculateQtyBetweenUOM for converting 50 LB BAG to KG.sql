CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 50 LB BAG to KG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	

	-- Arrange
	DECLARE @dblQty AS NUMERIC(38,20) = 12.51
	DECLARE @result AS NUMERIC(38,20)
	DECLARE @expected AS NUMERIC(38,20) = 283.7220274340 -- 12.51 * 50 / 2.204622621850 = 283.7220274340

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@50LB_BAG, @KGS, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END