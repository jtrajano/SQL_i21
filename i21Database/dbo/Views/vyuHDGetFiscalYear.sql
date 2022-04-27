CREATE VIEW [dbo].[vyuHDGetFiscalYear]
AS
	SELECT  intFiscalYearId = FiscalYear.intFiscalYearId
		   ,strFiscalYear = FiscalYear.strFiscalYear
		   ,intConcurrencyId = FiscalYear.intConcurrencyId
	FROM tblGLFiscalYear FiscalYear
GO