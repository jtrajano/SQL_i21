CREATE PROCEDURE testi21Database.[test fnRecalculateAverageCost for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @itemId AS INT
	DECLARE @locationId AS INT 

	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnRecalculateAverageCost(@itemId, @locationId);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals NULL, @result 
END 
GO
