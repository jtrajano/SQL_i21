CREATE PROCEDURE testi21Database.[test the fnGetCostingMethod function]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
	DECLARE @intLocationId AS INT

	DECLARE @expected AS NVARCHAR(40);
	SET @expected = NULL;

	EXEC tSQLt.FakeTable 'dbo.tblCMBankTransactionDetail';

	DECLARE @actual AS NVARCHAR(40);

	-- Act
	SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

	-- Assert
	EXEC tSQLt.AssertEquals @expected, @actual;
END 