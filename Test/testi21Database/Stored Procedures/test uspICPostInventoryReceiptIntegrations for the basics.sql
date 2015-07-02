CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceiptIntegrations for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE	@ysnPost BIT = 0
				,@intTransactionId NVARCHAR(40) = NULL 
				,@intUserId  INT  = NULL 
				,@intEntityId INT  = NULL
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.ExpectNoException; 
	END 
		
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceiptIntegrations 
				@ysnPost
				,@intTransactionId
				,@intUserId
				,@intEntityId
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedLot', 'actualLot';
		EXEC tSQLt.AssertEqualsTable 'expectedTransactionToReverse', 'actualTransactionToReverse';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END