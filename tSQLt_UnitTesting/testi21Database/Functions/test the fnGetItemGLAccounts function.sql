CREATE PROCEDURE testi21Database.[test the fnGetItemGLAccounts function]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
	DECLARE @intLocationId AS INT

	DECLARE @actual AS NVARCHAR(40);

	CREATE TABLE expected(
		intGLAccountId INT
		,intGLTypeId INT
	)

	-- Act
	CREATE TABLE actual(
		intGLAccountId INT
		,intGLTypeId INT
	)

	INSERT actual (
		intGLAccountId,
		intGLTypeId
	)
	SELECT * FROM [dbo].[fnGetItemGLAccounts](@intItemId, @intLocationId)

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 