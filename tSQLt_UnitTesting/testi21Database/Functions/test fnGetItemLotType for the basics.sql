CREATE PROCEDURE testi21Database.[test fnGetItemLotType for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
	DECLARE @result AS INT

	-- Act
	SELECT @result = dbo.fnGetItemLotType(@intItemId);

	-- Assert the NULL item is NULL lot type 
	EXEC tSQLt.AssertEquals NULL, @result;
END 
