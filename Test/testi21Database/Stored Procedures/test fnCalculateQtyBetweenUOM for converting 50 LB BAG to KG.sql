﻿CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 50 LB BAG to KG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	

		,@LBS_UnitQty AS NUMERIC(38,20) = 1
		,@KGS_UnitQty AS NUMERIC(38,20) = 0.453592
		,@50LBBag_UnitQty AS NUMERIC(38,20) = 50.00
		,@20KGBag_UnitQty AS NUMERIC(38,20) = 44.0925

	-- Arrange
	DECLARE @dblQty AS NUMERIC(38,20) = 12.51

	DECLARE @result AS NUMERIC(38,20)
	DECLARE @expected AS NUMERIC(38,20) = 1378.992574824952820 -- 12.51 * 50 / 0.453592 = 1378.992574824953

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@50LB_BAG, @KGS, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END
GO 
EXEC tSQLt.Run 'testi21Database.[test fnCalculateQtyBetweenUOM for converting 50 LB BAG to KG]'