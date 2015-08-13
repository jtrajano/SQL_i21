CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustmentLotMove for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake open fiscal year and accounting periods];
		EXEC testi21Database.[Fake data for inventory adjustment table];

		DECLARE	@intTransactionId AS INT
				,@strBatchId AS NVARCHAR(50)
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50)
				,@intUserId AS INT
				,@strAdjustmentDescription AS NVARCHAR(255)
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentLotMove
				@intTransactionId
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
				,@strAdjustmentDescription
	END 
END 
