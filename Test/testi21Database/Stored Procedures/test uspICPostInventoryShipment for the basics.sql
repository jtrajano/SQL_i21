﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryShipment for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ysnPost AS BIT
		DECLARE @ysnRecap AS BIT
		DECLARE @strTransactionId AS NVARCHAR(40)
		DECLARE @intEntityUserSecurityId AS INT
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50004
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryShipment
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intEntityUserSecurityId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END 