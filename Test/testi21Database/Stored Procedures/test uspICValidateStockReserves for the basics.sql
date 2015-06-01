CREATE PROCEDURE [testi21Database].[test uspICValidateStockReserves for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items]

		DECLARE @ItemsToValidate AS ItemReservationTableType
		DECLARE @strItemNo AS NVARCHAR(50) 
		DECLARE @intItemId AS INT 
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICValidateStockReserves
			@ItemsToValidate
			,@strItemNo OUTPUT 
			,@intItemId OUTPUT 
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals NULL, @intItemId;
	END
END 
