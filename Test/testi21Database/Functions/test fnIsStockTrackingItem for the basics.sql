CREATE PROCEDURE testi21Database.[test fnIsStockTrackingItem for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
	DECLARE @result AS BIT

	-- Act
	SELECT @result = dbo.fnIsStockTrackingItem(@intItemId);

	-- Assert. Invalid items will return 0. 
	EXEC tSQLt.AssertEquals 0, @result;
END 
