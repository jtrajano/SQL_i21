CREATE FUNCTION [dbo].[fnAPGetFiscalPeriod](@date AS DATETIME)
RETURNS NVARCHAR(255)
AS
BEGIN

DECLARE @fiscalPeriod AS NVARCHAR(255)

	SELECT @fiscalPeriod = strPeriod FROM tblGLFiscalYearPeriod FP WHERE '10/7/2021' BETWEEN FP.dtmStartDate AND FP.dtmEndDate OR '10/7/2021' = FP.dtmStartDate OR '10/7/2021' = FP.dtmEndDate
	RETURN @fiscalPeriod
END