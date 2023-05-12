CREATE VIEW [dbo].[vyuGLFiscalYear]    
AS    
SELECT (SELECT TOP 1 intGLFiscalYearPeriodId FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = T0.intFiscalYearId  ORDER BY intGLFiscalYearPeriodId DESC ) AS intGLFiscalYearPeriodId,strFiscalYear,ysnCurrent   
FROM  tblGLFiscalYear T0