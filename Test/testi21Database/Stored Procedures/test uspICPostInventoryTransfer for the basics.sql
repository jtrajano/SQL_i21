﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransfer for the basics]
AS
BEGIN
	-- Constant for Transfer types
	DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
		,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 13

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
		EXEC dbo.uspICPostInventoryTransfer 
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
