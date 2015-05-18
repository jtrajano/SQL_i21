CREATE PROCEDURE testi21Database.[test fnGetGLAccountFromCompanyLocation for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @locationId AS INT
	DECLARE @accountCategory AS NVARCHAR(255) 

	DECLARE @expected AS INT
	DECLARE @result AS INT

	-- Act
	SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, @accountCategory);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 