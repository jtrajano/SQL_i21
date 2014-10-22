CREATE PROCEDURE testi21Database.[test the fnGetGLAccountIdFromProfitCenter function on 8x8 account structure]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intAccounId AS INT
		DECLARE @intAccountSegmentId AS INT

		DECLARE @expected AS INT
		DECLARE @actual AS INT
		
		-- Call the fake data SP for simple COA
		EXEC [testi21Database].[Fake data for simple COA]
	END 	

	-- Test case 1:
	--		1. Base g/l account id is 12040-1000 ('INVENTORY WHEAT-')
	--		2. Profit center segment id is 101 ('NEW HAVEN GRAIN')
	--		3. Expected g/l account id is 12040-1001 ('INVENTORY WHEAT-NEW HAVEN GRAIN')
	BEGIN 
		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](1000, 101);
		SET @expected = 1001;
		
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;
	END
END