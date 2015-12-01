CREATE PROCEDURE [dbo].[uspPATGetDividends] 
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
												THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) 
												ELSE
													 (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * 
													 (CASE WHEN CS.dtmIssueDate > @dtmCutoffDate 
														   THEN DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo) 
														   ELSE @dblProcessingDays END)) 
												END),

				   dblLessFWT = CASE WHEN ARC.ysnSubjectToFWT = 0 
									 THEN 0 
									 ELSE
										SUM(CASE WHEN (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
														    THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) 
															ELSE (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * 
																   (CASE WHEN CS.dtmIssueDate > @dtmCutoffDate 
																	THEN DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo) 
																	ELSE @dblProcessingDays 
																	END))  
															END) < @dblMinimumDividend 
										 THEN 0 
										 ELSE 
												(CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
												 THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) 
												 ELSE (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * 
													  (CASE WHEN CS.dtmIssueDate > @dtmCutoffDate 
													        THEN DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo) 
															ELSE @dblProcessingDays 
														END)) 
												  END * (@FWT / 100)) 
										 END) 
									 END,

				   dblCheckAmount = SUM(CASE WHEN (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
														THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
															 (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * 
															 (CASE WHEN CS.dtmIssueDate > @dtmCutoffDate THEN DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo) ELSE @dblProcessingDays END)) END) < @dblMinimumDividend 
										 THEN 0 ELSE 
												  (CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL 
														THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
															 (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * CASE WHEN CS.dtmIssueDate > @dtmCutoffDate THEN DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo) ELSE @dblProcessingDays END) END - ISNULL(CS.dblCheckAmount,0)) END)

			 FROM tblPATStockClassification SC
	   INNER JOIN tblPATCustomerStock CS
			   ON CS.intStockId = SC.intStockId
	   INNER JOIN tblEntity ENT
			   ON ENT.intEntityId = CS.intCustomerPatronId
	   INNER JOIN tblARCustomer ARC
			   ON ARC.intEntityCustomerId = ENT.intEntityId
		LEFT JOIN tblSMTaxCode TC
			   ON TC.intTaxCodeId = ARC.intTaxCodeId

			   GROUP BY CS.intCustomerPatronId,ENT.strName, ARC.strStockStatus, TC.strTaxCode, CS.dblSharesNo, SC.intDividendsPerShare, CS.dtmIssueDate, ARC.ysnSubjectToFWT
END
GO