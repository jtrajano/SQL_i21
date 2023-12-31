﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryShipment for calling uspICPostStorage]
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
		DECLARE @intEntityUserSecurityId AS INT = 1

		-- Add a spy for uspICPostStorage
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostStorage';		
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryShipment
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intEntityUserSecurityId
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.AssertObjectExists 'uspICPostStorage_SpyProcedureLog'
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected

END 
