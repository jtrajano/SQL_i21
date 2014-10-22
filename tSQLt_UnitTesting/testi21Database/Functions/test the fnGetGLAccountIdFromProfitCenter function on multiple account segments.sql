CREATE PROCEDURE testi21Database.[test the fnGetGLAccountIdFromProfitCenter function on multiple account segments]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intAccounId AS INT
		DECLARE @intAccountSegmentId AS INT

		DECLARE @expected AS INT
		DECLARE @actual AS INT
		
		EXEC [testi21Database].[Fake data for multiple segments COA]
	END	
			
	-- Test case 1:
	--		1. Base g/l account id is 12040-1000-ABC-FOO ('INVENTORY WHEAT--ABCs-FOOs')
	--		2. Profit center segment id is 101 ('NEW HAVEN GRAIN')
	--		3. Expected g/l account id is '12040-1001-ABC-FOO' ('INVENTORY WHEAT-NEW HAVEN GRAIN-ABCs-FOOs')
	BEGIN 	
		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](1000, 101);
		SET @expected = 1001;
		
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;
	END
END