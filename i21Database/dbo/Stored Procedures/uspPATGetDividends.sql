﻿CREATE PROCEDURE [dbo].[uspPATGetDividends] 
	@intFiscalYearId INT = NULL,
	@dblProcessingDays NUMERIC(18,6) = NULL,
	@ysnProrateDividend BIT = NULL,
	@dtmProcessingDateFrom DATETIME = NULL,
	@dtmProcessingDateTo DATETIME = NULL,
	@dblMinimumDividend NUMERIC(18,6) = NULL,
	@FWT NUMERIC(18,6) = NULL,
	@dtmCutoffDate DATETIME = NULL
AS
BEGIN
			SET NOCOUNT ON;

			SELECT DISTINCT intCustomerId = CS.intCustomerPatronId,
				   ENT.strName,
				   ARC.strStockStatus,
				   TC.strTaxCode,
				   dtmLastActivityDate = GETDATE(),
				   dblDividendAmount = SUM(CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
										THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
										(((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END),

				   dblLessFWT = SUM(CASE WHEN (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
									 THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
											(((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END) < @dblMinimumDividend 
									 THEN 0 ELSE (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
									 THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
											(((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END * @FWT) END),

				   dblCheckAmount = SUM(CASE WHEN (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
										 THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
											  (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END) < @dblMinimumDividend 
										 THEN 0 ELSE (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
										 THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
											  (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END - CS.dblCheckAmount) END)

			 FROM tblPATStockClassification SC
	   INNER JOIN tblPATCustomerStock CS
			   ON CS.intStockId = SC.intStockId
	   INNER JOIN tblEntity ENT
			   ON ENT.intEntityId = CS.intCustomerPatronId
	   INNER JOIN tblARCustomer ARC
			   ON ARC.intEntityCustomerId = ENT.intEntityId
		LEFT JOIN tblSMTaxCode TC
			   ON TC.intTaxCodeId = ARC.intTaxCodeId

			   GROUP BY CS.intCustomerPatronId,ENT.strName, ARC.strStockStatus, TC.strTaxCode
END
GO