CREATE PROCEDURE [testi21Database].[test the uspICCreateStockReservation for the basics]
AS
BEGIN
	-- ARRANGE 
	BEGIN 
		-- Create the actual table
		CREATE TABLE actual (
			intItemId INT 
			,intItemLocationId INT 
			,intItemUOMId INT 
			,intLotId INT 
			,dblQty NUMERIC(18,6)
			,intTransactionId INT
			,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,intInventoryTransactionType INT
		)

		-- Create the expected table
		CREATE TABLE expected (
			intItemId INT 
			,intItemLocationId INT 
			,intItemUOMId INT 
			,intLotId INT 
			,dblQty NUMERIC(18,6)
			,intTransactionId INT
			,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,intInventoryTransactionType INT
		)

		DECLARE @ItemsToReserve AS dbo.ItemReservationTableType
	END 

	-- ACT
	BEGIN 
		EXEC dbo.uspICCreateStockReservation 
			@ItemsToReserve
	END 
			
	-- ASSERT
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 
	
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 