CREATE FUNCTION [dbo].[fn_geti21PeriodFromOriginPeriod](@Year NVARCHAR(10),@Period NVARCHAR(10))
RETURNS DATETIME
AS
BEGIN
	
	DECLARE @FiscalYear		INT			= (select TOP 1 intFiscalYearID from tblGLFiscalYear WHERE strFiscalYear = @Year)
    DECLARE @PeriodEndDate	DATETIME	= (SELECT TOP 1 dtmEndDate FROM (
												SELECT ROW_NUMBER() OVER (ORDER BY intGLFiscalYearPeriodID) AS RowNum,* FROM tblGLFiscalYearPeriod WHERE intFiscalYearID = @FiscalYear) AS FiscalYearPeriod 
											WHERE FiscalYearPeriod.RowNum = CONVERT(INT,@Period))
	RETURN @PeriodEndDate
END