CREATE PROCEDURE testi21Database.[test the fnGetNegativeInventoryOptions function]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
	DECLARE @intLocationId AS INT
	
	DECLARE @Yes AS INT = 1
			,@YesWithAutoWriteOff AS INT = 2
			,@No AS INT = 3

	DECLARE @actual AS INT;

	-- Setup the fake table and data 
	BEGIN 
		EXEC [testi21Database].[Fake data for simple Items]
	END
	
	-- Test Yes - allow negative inventory
	BEGIN		
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 1
		SELECT @actual = [dbo].[fnGetNegativeInventoryOptions](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @Yes, @actual;
	END
	
	-- Test Yes - with auto write-off
	BEGIN 
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 2
		SELECT @actual = [dbo].[fnGetNegativeInventoryOptions](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @YesWithAutoWriteOff, @actual;
	END
	
	-- Test No
	BEGIN 
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 3
		SELECT @actual = [dbo].[fnGetNegativeInventoryOptions](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @No, @actual;
	END
	
	-- Test Bad Input
	BEGIN 
		-- Act
		SET @intItemId = 1
		SET @intLocationId = NULL 
		SELECT @actual = [dbo].[fnGetNegativeInventoryOptions](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals NULL, @actual;
	END	
	
END 