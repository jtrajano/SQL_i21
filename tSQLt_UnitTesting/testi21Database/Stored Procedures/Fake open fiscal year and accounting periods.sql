CREATE PROCEDURE [testi21Database].[Fake open fiscal year and accounting periods]
AS
BEGIN
		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYear';
		EXEC tSQLt.FakeTable 'dbo.tblGLFiscalYearPeriod', @Identity = 1;
		
		DECLARE @FY2014 AS INT = 1
		DECLARE @FY2015 AS INT = 2
		DECLARE @FYTODAY AS INT = 3

		DECLARE @dtmStartDate AS DATETIME
		DECLARE @dtmEndDate AS DATETIME 
		DECLARE @counter AS INT 

		-----------------------------------
		-- Insert the fiscal year
		-----------------------------------
		INSERT INTO tblGLFiscalYear (
				intFiscalYearId
				,strFiscalYear
				,dtmDateFrom
				,dtmDateTo
				,ysnStatus
				,intConcurrencyId
		)
		SELECT 	intFiscalYearId = @FY2014
				,strFiscalYear = '2014'
				,dtmDateFrom = CAST('1/1/2014' AS DATETIME)
				,dtmDateTo = CAST('12/31/2014' AS DATETIME)
				,ysnStatus = 1
				,intConcurrencyId = 1		
		UNION ALL 
		SELECT 	intFiscalYearId = @FY2015
				,strFiscalYear = '2015'
				,dtmDateFrom = CAST('1/1/2015' AS DATETIME)
				,dtmDateTo = CAST('12/31/2015' AS DATETIME)
				,ysnStatus = 1
				,intConcurrencyId = 1		
		UNION ALL 
		SELECT 	intFiscalYearId = @FYTODAY
				,strFiscalYear = 'TODAY'
				,dtmDateFrom = GETDATE()
				,dtmDateTo = GETDATE()
				,ysnStatus = 1
				,intConcurrencyId = 1

		-----------------------------------
		-- Insert the FY periods
		-----------------------------------
		-- 2014 Periods:
		BEGIN 		
			SET @counter = 1
			SET @dtmStartDate = CAST('1/1/2014' AS DATETIME)
			SET @dtmEndDate = CAST('1/31/2014' AS DATETIME)

			WHILE (@counter <= 12) 
			BEGIN 
				INSERT INTO tblGLFiscalYearPeriod (
						intFiscalYearId 
						,dtmStartDate
						,dtmEndDate
						,ysnOpen
						,intConcurrencyId
				)
				SELECT 	intFiscalYearId = @FY2014
						,dtmStartDate = @dtmStartDate
						,dtmEndDate = @dtmEndDate
						,ysnOpen = 1
						,intConcurrencyId = 1 

				SET @dtmStartDate = DATEADD(MONTH, 1, @dtmStartDate)
				SET @dtmEndDate = DATEADD(DAY, -1, DATEADD(MM, 1, @dtmStartDate))					
				SET @counter += 1;
			END 
		END 

		-- 2015 Periods:
		BEGIN 		
			SET @counter = 1
			SET @dtmStartDate = CAST('1/1/2015' AS DATETIME)
			SET @dtmEndDate = CAST('1/31/2015' AS DATETIME)

			WHILE (@counter <= 12) 
			BEGIN 
				INSERT INTO tblGLFiscalYearPeriod (
						intFiscalYearId 
						,dtmStartDate
						,dtmEndDate
						,ysnOpen
						,intConcurrencyId
				)
				SELECT 	intFiscalYearId = @FY2015
						,dtmStartDate = @dtmStartDate
						,dtmEndDate = @dtmEndDate
						,ysnOpen = 1
						,intConcurrencyId = 1 

				SET @dtmStartDate = DATEADD(MONTH, 1, @dtmStartDate)
				SET @dtmEndDate = DATEADD(DAY, -1, DATEADD(MM, 1, @dtmStartDate))					
				SET @counter += 1;
			END 
		END 

		-- Today as special open period:
		INSERT INTO tblGLFiscalYearPeriod (
				intFiscalYearId 
				,dtmStartDate
				,dtmEndDate
				,ysnOpen
				,intConcurrencyId
		)
		SELECT 	intFiscalYearId = @FYTODAY
				,dtmStartDate = GETDATE()
				,dtmEndDate = GETDATE()
				,ysnOpen = 1
				,intConcurrencyId = 1 
END 