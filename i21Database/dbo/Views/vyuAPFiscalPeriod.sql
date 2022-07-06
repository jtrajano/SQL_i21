CREATE VIEW [dbo].[vyuAPFiscalPeriod]

AS
SELECT
    A.intGLFiscalYearPeriodId,
    A.strPeriod,
    A.dtmStartDate,
    A.dtmEndDate,
    MONTH(A.dtmStartDate) AS intMonth,
    YEAR(A.dtmStartDate) AS intYear
FROM 
    dbo.tblGLFiscalYearPeriod A