CREATE FUNCTION [dbo].[fn_geti21PeriodFromOriginPeriod](@Year NVARCHAR(10),@Period NVARCHAR(10))
RETURNS DATETIME
AS
BEGIN
	
	DECLARE @FiscalYear			INT			=	(SELECT TOP 1 intFiscalYearID FROM tblGLFiscalYear WHERE strFiscalYear = @Year)
    DECLARE @PeriodStartDate	DATETIME	=	(SELECT TOP 1 dtmStartDate FROM (
														SELECT ROW_NUMBER() OVER (ORDER BY intGLFiscalYearPeriodID) AS RowNum,* FROM tblGLFiscalYearPeriod WHERE intFiscalYearID = @FiscalYear) AS FiscalYearPeriod 
													WHERE FiscalYearPeriod.RowNum = CONVERT(INT,@Period))
	RETURN @PeriodStartDate
END