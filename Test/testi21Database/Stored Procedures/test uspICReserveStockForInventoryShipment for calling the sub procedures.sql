CREATE PROCEDURE [testi21Database].[test uspICReserveStockForInventoryShipment for calling the sub procedures]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items]
		DECLARE @intTransactionId AS INT

		-- Create the spies for the stored procedures called by uspICReserveStockForInventoryShipment
		EXEC tSQLt.SpyProcedure 'dbo.uspICValidateStockReserves';
		EXEC tSQLt.SpyProcedure 'dbo.uspICCreateStockReservation';
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICReserveStockForInventoryShipment
			@intTransactionId
	END 

	-- Assert
	BEGIN 
		DECLARE @IsUspICValidateStockReservesCalled AS BIT 
		DECLARE @IsUspICCreateStockReservationCalled AS BIT 

		SELECT	@IsUspICValidateStockReservesCalled = 1
		WHERE EXISTS (SELECT TOP 1 1 FROM dbo.uspICValidateStockReserves_SpyProcedureLog)
		
		SELECT	@IsUspICCreateStockReservationCalled = 1
		WHERE EXISTS (SELECT TOP 1 1 FROM dbo.uspICCreateStockReservation_SpyProcedureLog)

		EXEC tSQLt.AssertEquals 1, @IsUspICValidateStockReservesCalled
		EXEC tSQLt.AssertEquals 1, @IsUspICCreateStockReservationCalled

	END
END 
