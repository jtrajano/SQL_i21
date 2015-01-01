CREATE PROCEDURE [testi21Database].[Fake data for the accounting period]
AS
BEGIN
		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYear', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;


		INSERT INTO tblGLFiscalYear (
				strFiscalYear
				,dtmDateFrom
				,dtmDateTo
				,ysnStatus
				,intConcurrencyId
		)
		SELECT 	strFiscalYear = 'TODAY'
				,dtmDateFrom = GETDATE()
				,dtmDateTo = GETDATE()
				,ysnStatus = 1
				,intConcurrencyId = 1

		INSERT INTO tblGLFiscalYearPeriod (
				intFiscalYearId 
				,dtmStartDate
				,dtmEndDate
				,ysnOpen
				,intConcurrencyId
		)
		SELECT 	intFiscalYearId = 1
				,dtmStartDate = GETDATE()
				,dtmEndDate = GETDATE()
				,ysnOpen = 1
				,intConcurrencyId = 1 

END 