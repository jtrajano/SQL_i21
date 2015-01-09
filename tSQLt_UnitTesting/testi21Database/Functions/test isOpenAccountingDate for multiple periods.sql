CREATE PROCEDURE testi21Database.[test isOpenAccountingDate for multiple periods]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS BIT
	DECLARE @expected AS BIT = 1

	-- Fake the inventory transaction table 
	EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;
	INSERT INTO tblGLFiscalYearPeriod (dtmStartDate, dtmEndDate, ysnOpen) VALUES (GETDATE(), GETDATE(), 0)
	INSERT INTO tblGLFiscalYearPeriod (dtmStartDate, dtmEndDate, ysnOpen) VALUES (GETDATE(), GETDATE(), 1)
	INSERT INTO tblGLFiscalYearPeriod (dtmStartDate, dtmEndDate, ysnOpen) VALUES (GETDATE(), GETDATE(), 0)

	-- Act
	SELECT @result = dbo.isOpenAccountingDate(GETDATE());

	-- Assert 
	-- Result must be 1 because there is a record with an open period
	EXEC tSQLt.AssertEquals @expected, @result;
END 