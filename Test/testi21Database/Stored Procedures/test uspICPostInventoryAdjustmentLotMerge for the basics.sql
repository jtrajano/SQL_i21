CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustmentLotMerge for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory adjustment table];
		DECLARE @intTransactionId AS INT
		DECLARE @intUserId AS INT
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentLotMerge
			@intTransactionId
	 		,@intUserId
	END 
END 
