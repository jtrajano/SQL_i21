CREATE VIEW [dbo].[vyuPATDividends]
	AS
SELECT	DIV.intDividendId,
		DIV.intFiscalYearId,
		FY.strFiscalYear,
		DIV.dtmProcessDate,
		DIV.dtmProcessingFrom,
		DIV.dtmProcessingTo,
		DIV.dblProcessedDays,
		DIV.strDividendNo,
		DIV.dblMinimumDividend,
		DIV.ysnProrateDividend,
		DIV.dtmCutoffDate,
		DIV.dblFederalTaxWithholding,
		DIV.intStockId,
        SC.strStockName,
        DIV.ysnPosted,
        DIV.intConcurrencyId
FROM tblPATDividends DIV
INNER JOIN tblGLFiscalYear FY
	ON FY.intFiscalYearId = DIV.intFiscalYearId
LEFT JOIN tblPATStockClassification SC
	ON SC.intStockId = DIV.intStockId