CREATE PROCEDURE testi21Database.[test isOpenAccountingDate for closed periods]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS BIT
	DECLARE @expected AS BIT = 0

	-- Fake the inventory transaction table 
	EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;
	INSERT INTO tblGLFiscalYearPeriod (dtmStartDate, dtmEndDate, ysnOpen) VALUES (GETDATE(), GETDATE(), 0)

	-- Act
	SELECT @result = dbo.isOpenAccountingDate(GETDATE());

	-- Assert 
	-- Result must be 0 since the date is closed
	EXEC tSQLt.AssertEquals @expected, @result;
END 