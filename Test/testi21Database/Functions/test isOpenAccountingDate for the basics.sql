CREATE PROCEDURE testi21Database.[test isOpenAccountingDate for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS BIT
	DECLARE @expected AS BIT = 0

	-- Fake the inventory transaction table 
	EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;
	INSERT INTO tblGLFiscalYearPeriod (dtmStartDate, dtmEndDate, ysnOpen) VALUES (GETDATE(), GETDATE(), 1)

	-- Act
	SELECT @result = dbo.isOpenAccountingDate(NULL);

	-- Assert 
	-- Result must be 0 since the date is null 
	EXEC tSQLt.AssertEquals @expected, @result;
END 