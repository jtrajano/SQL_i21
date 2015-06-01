CREATE PROCEDURE testi21Database.[test the fnGetGLAccountIdFromProfitCenter function on multiple account segments]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intAccounId AS INT
		DECLARE @intAccountSegmentId AS INT

		DECLARE @expected AS INT
		DECLARE @actual AS INT
		
		EXEC [testi21Database].[Fake COA with multiple account segments]
	END	

	-- Test case 1: GL Account id and Profit Center ID are both invalid (or NULL)
	BEGIN 	
		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](NULL, NULL);
		SET @expected = NULL;
		
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;
	END

	-- Test case 2: GL Account id is valid while Profit Center id is invalid 
	BEGIN 	
		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](1000, NULL);
		SET @expected = 1000; -- Returns the same g/l account id 
		
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;

		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](1000, 145568);
		SET @expected = 1000; -- Returns the same g/l account id 
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;

	END

	-- Test case 3: GL Account id is invalid while Profit Center Id is valid
	BEGIN 	
		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](NULL, 101);
		SET @expected = NULL;
		
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;
	END
			
	-- Test case 4: GL Account id and Profit center id are both valid. 
	--		1. Base g/l account id is 12040-1000-ABC-FOO ('INVENTORY WHEAT--ABCs-FOOs')
	--		2. Profit center segment id is 101 ('NEW HAVEN')
	--		3. Expected g/l account id is '12040-1001-ABC-FOO' ('INVENTORY WHEAT-NEW HAVEN-ABCs-FOOs')
	BEGIN 	
		-- Act 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromProfitCenter](1000, 101);
		SET @expected = 1001;
		
		-- Assert
		EXEC tSQLt.AssertEquals @expected, @actual;
	END
END