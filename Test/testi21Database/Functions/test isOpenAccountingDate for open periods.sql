CREATE PROCEDURE testi21Database.[test isOpenAccountingDate for open periods]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS BIT
	DECLARE @expected AS BIT = 1

	-- Fake the inventory transaction table 
	EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;
	INSERT INTO tblGLFiscalYearPeriod (dtmStartDate, dtmEndDate, ysnOpen) VALUES (GETDATE(), GETDATE(), 1)

	-- Act
	SELECT @result = dbo.isOpenAccountingDate(GETDATE());

	-- Assert 
	-- Result must be 1 since the date is open 
	EXEC tSQLt.AssertEquals @expected, @result;
END 