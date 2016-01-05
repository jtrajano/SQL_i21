CREATE PROCEDURE testi21Database.[test fnGetMatchingItemUOMId for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
			,@intItemUOMIdFromAnotherItem AS INT
			,@result AS INT 
			,@Expected AS INT

	-- Act
	SELECT @result = dbo.fnGetMatchingItemUOMId(@intItemId, @intItemUOMIdFromAnotherItem);

	-- Assert 
	EXEC tSQLt.AssertEquals @Expected, @result;
END