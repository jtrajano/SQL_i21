CREATE PROCEDURE [testi21Database].[test uspICCreateLotNumberOnInventoryReceipt for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]

		CREATE TABLE expected(
			intItemId INT
			,intItemLocationId INT
			,intItemUOMId INT
		)

		CREATE TABLE actual(
			intItemId INT
			,intItemLocationId INT		
			,intItemUOMId INT
		)
	END 
	
	-- Act
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(20) 				

		EXEC dbo.uspICCreateLotNumberOnInventoryReceipt
			@strTransactionId
			,1
			,1
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END