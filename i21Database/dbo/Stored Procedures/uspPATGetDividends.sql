﻿CREATE PROCEDURE uspPATGetDividends 
    @intFiscalYearId INT = NULL,
    @dblProcessingDays NUMERIC(18,6) = NULL,
    @ysnProrateDividend BIT = NULL,
    @dtmCutoffDate DATETIME = NULL,
    @dtmProcessingDateFrom DATETIME = NULL,
    @dtmProcessingDateTo DATETIME = NULL,
    @dblMinimumDividend NUMERIC(18,6) = NULL,
    @FWT NUMERIC(18,6) = NULL
AS
BEGIN
    SET NOCOUNT ON;

        
            SELECT intCustomerId = CS.intCustomerPatronId,
                   ENT.strName,
                   ARC.strStockStatus,
                   TC.strTaxCode,
                   SC.strStockName,
                   SC.dblParValue,
                   CS.dblSharesNo,
                   SC.intDividendsPerShare,
                   dtmLastActivityDate = GETDATE(),
                   dblDividendAmount = CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> '' 
                                        THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
                                        (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END,

                   dblLessFWT = CASE WHEN (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> '' 
                                     THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
                                            (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END) < @dblMinimumDividend 
                                     THEN 0 ELSE (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> '' 
                                     THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
                                            (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END * @FWT) END,

                   dblCheckAmount = CASE WHEN (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> '' 
                                         THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
                                              (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END) < @dblMinimumDividend 
                                         THEN 0 ELSE (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> '' 
                                         THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
                                              (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END - CS.dblCheckAmount) END

             FROM tblPATStockClassification SC
       INNER JOIN tblPATCustomerStock CS
               ON CS.intStockId = SC.intStockId
       INNER JOIN tblEntity ENT
               ON ENT.intEntityId = CS.intCustomerPatronId
       INNER JOIN tblARCustomer ARC
               ON ARC.intEntityCustomerId = ENT.intEntityId
        LEFT JOIN tblSMTaxCode TC
               ON TC.intTaxCodeId = ARC.intTaxCodeId
END
GO