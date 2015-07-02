CREATE PROCEDURE [testi21Database].[test uspICPostInventoryShipmentIntegrations for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE	@ysnPost BIT = NULL 
				,@intTransactionId INT = NULL 
				,@intUserId  INT  = NULL 
				,@intEntityId INT  = NULL
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.ExpectNoException; 
	END 
		
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryShipmentIntegrations 
				@ysnPost
				,@intTransactionId
				,@intUserId
				,@intEntityId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END