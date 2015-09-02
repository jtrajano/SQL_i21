CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustmentLotMerge for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory adjustment table];

		DECLARE 
			@intTransactionId INT
			,@strBatchId NVARCHAR(50)
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY NVARCHAR(50)
			,@intUserId INT
			,@strAdjustmentDescription AS NVARCHAR(255)
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentLotMerge
				@intTransactionId
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
				,@strAdjustmentDescription
	END 
END 
