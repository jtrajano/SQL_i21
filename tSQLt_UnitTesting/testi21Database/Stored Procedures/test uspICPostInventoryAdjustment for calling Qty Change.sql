﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for calling Qty Change]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'ADJ-1'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1

		-- Add a spy for uspICPostInventoryAdjustmentQtyChange
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostInventoryAdjustmentQtyChange';	

		EXEC [testi21Database].[Fake data for inventory adjustment table];
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustment 
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intUserId
			,@intEntityId
	END 

	-- Assert
	BEGIN 
		--Assert uspICPostInventoryAdjustmentQtyChange is called 
		IF @ysnPost = 1 AND NOT EXISTS (SELECT 1 FROM dbo.uspICPostInventoryAdjustmentQtyChange_SpyProcedureLog)
			EXEC tSQLt.Fail 'A helper stored procedure uspICPostInventoryAdjustmentQtyChange is expected to be called.'
	END
END 