CREATE PROCEDURE testi21Database.[test fnRecalculateAverageCost for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @itemId AS INT
	DECLARE @locationId AS INT 
	DECLARE @stockAverageCost AS NUMERIC(18,6) 

	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnRecalculateAverageCost(@itemId, @locationId, @stockAverageCost);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals NULL, @result 
END 
GO
