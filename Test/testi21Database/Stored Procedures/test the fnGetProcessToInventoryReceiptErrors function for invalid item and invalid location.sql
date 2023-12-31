﻿CREATE PROCEDURE testi21Database.[test the fnGetProcessToInventoryReceiptErrors function for invalid item and invalid location]
AS 
BEGIN
	-- Arrange
	BEGIN 
		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,strText
				,intErrorCode
		)
		-- Invalid item and invalid location
		SELECT	intItemId = @InvalidItem
				,intItemLocationId = @InvalidLocation
				,strText = FORMATMESSAGE(80001)
				,intErrorCode = 80001
		--UNION ALL
		--SELECT	intItemId = @InvalidItem
		--		,intItemLocationId = @InvalidLocation
		--		,strText = FORMATMESSAGE(80002)
		--		,intErrorCode = 80002

		-- Create the mock data 
		EXEC testi21Database.[Fake inventory items];
	END

	-- Act
	BEGIN 
		INSERT INTO actual	
		-- Invalid item and invalid location
		SELECT * FROM dbo.fnGetProcessToInventoryReceiptErrors(@InvalidItem, @InvalidLocation, NULL, NULL)		
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
	
END