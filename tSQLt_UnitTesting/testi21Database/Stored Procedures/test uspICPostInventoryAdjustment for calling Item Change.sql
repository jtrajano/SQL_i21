CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for calling Item Change]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'ADJ-1'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1

		-- Add a spy for uspPOReceived
		EXEC tSQLt.SpyProcedure 'dbo.uspICPostInventoryAdjustmentItemChange';	

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
		--Assert uspICPostInventoryAdjustmentItemChange is called 
		IF @ysnPost = 1 AND NOT EXISTS (SELECT 1 FROM dbo.uspICPostInventoryAdjustmentItemChange_SpyProcedureLog)
			EXEC tSQLt.Fail 'A helper stored procedure uspICPostInventoryAdjustmentItemChange is expected to be called.'
	END
END 