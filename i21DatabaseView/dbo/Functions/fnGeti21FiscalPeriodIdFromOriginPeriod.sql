CREATE FUNCTION [dbo].[fnGeti21FiscalPeriodIdFromOriginPeriod](@FiscalYear INT,@Period NVARCHAR(10))

RETURNS INT
AS
BEGIN
	
    DECLARE @intGLFiscalYearPeriodId INT	=(SELECT TOP 1 intGLFiscalYearPeriodId FROM (
														SELECT ROW_NUMBER() OVER (ORDER BY intGLFiscalYearPeriodId) AS RowNum,* FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @FiscalYear) AS FiscalYearPeriod 
													WHERE FiscalYearPeriod.RowNum = CONVERT(INT,@Period))
	RETURN @intGLFiscalYearPeriodId
END