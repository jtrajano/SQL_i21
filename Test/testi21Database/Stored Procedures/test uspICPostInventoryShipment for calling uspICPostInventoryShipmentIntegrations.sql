CREATE PROCEDURE [testi21Database].[test uspICPostInventoryShipment for calling uspICPostInventoryShipmentIntegrations]
AS

BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory shipment table];
END 

BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 1
		DECLARE @strTransactionId AS NVARCHAR(40) = 'INVSHIP-XXXXX1'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT  = 1

		-- Add a spy for test uspICPostInventoryShipment for calling uspICPostInventoryShipmentIntegrations
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostInventoryShipmentIntegrations';		
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryShipment
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intUserId
			,@intEntityId
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.AssertObjectExists 'uspICPostInventoryShipmentIntegrations_SpyProcedureLog'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END 