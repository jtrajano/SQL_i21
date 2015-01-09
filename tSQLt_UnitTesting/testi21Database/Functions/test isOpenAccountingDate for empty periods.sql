CREATE PROCEDURE testi21Database.[test isOpenAccountingDate for empty periods]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS BIT
	DECLARE @expected AS BIT = 0

	-- Fake the inventory transaction table 
	EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;

	-- Act
	SELECT @result = dbo.isOpenAccountingDate(GETDATE());

	-- Assert 
	-- Result must be 0 since there is no data in the table 
	EXEC tSQLt.AssertEquals @expected, @result;
END 