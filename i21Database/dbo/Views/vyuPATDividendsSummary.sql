CREATE VIEW [dbo].[vyuPATDividendsSummary]
AS
SELECT
      d.intDividendId
    , d.intFiscalYearId
    , fy.strFiscalYear
    , d.dtmProcessDate
    , d.dtmProcessingFrom
    , d.dtmProcessingTo
    , d.dblProcessedDays
    , d.strDividendNo
    , d.dblMinimumDividend
    , d.ysnProrateDividend
    , d.dtmCutoffDate
    , d.dblFederalTaxWithholding
    , d.ysnPosted
    , d.intConcurrencyId
    , dblDividendAmount = SUM(ds.dblDividendAmount)
    , dblTotalLessFWT = SUM(dc.dblLessFWT)
    , dblTotalCheckAmount = SUM(dc.dblCheckAmount)
FROM tblPATDividends d
LEFT JOIN tblGLFiscalYear fy ON fy.intFiscalYearId = d.intFiscalYearId
LEFT JOIN tblPATDividendsCustomer dc ON dc.intDividendId = d.intDividendId
OUTER APPLY (
    SELECT SUM(xds.dblDividendAmount) dblDividendAmount
    FROM tblPATDividendsStock xds
    WHERE xds.intDividendCustomerId = dc.intDividendCustomerId
) ds
GROUP BY d.intDividendId
    , d.intFiscalYearId
    , fy.strFiscalYear
    , d.dtmProcessDate
    , d.dtmProcessingFrom
    , d.dtmProcessingTo
    , d.dblProcessedDays
    , d.strDividendNo
    , d.dblMinimumDividend
    , d.ysnProrateDividend
    , d.dtmCutoffDate
    , d.dblFederalTaxWithholding
    , d.ysnPosted
    , d.intConcurrencyId