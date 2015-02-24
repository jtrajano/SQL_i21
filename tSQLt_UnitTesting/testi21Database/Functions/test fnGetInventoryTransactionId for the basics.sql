CREATE PROCEDURE testi21Database.[test fnGetInventoryTransactionId for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @strId AS NVARCHAR(50)
	DECLARE @intId AS INT

	DECLARE @WetGrains AS INT = 1
	DECLARE @WetGrains_NewHaven AS INT = 6

	DECLARE @result AS INT

	-- Act
	SELECT @result = intInventoryTransactionId
	FROM dbo.fnGetInventoryTransactionId(@strId, @intId, @WetGrains, @WetGrains_NewHaven);

	-- Assert the null dates are not equal dates
	DECLARE @expected AS INT
	EXEC tSQLt.AssertEquals @expected, @result;
END 