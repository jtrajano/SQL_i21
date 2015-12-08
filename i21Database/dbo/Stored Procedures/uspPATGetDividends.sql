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
				   dblDividendAmount = Total.dblDividendAmount,
				   dblLessFWT = CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 
									 ELSE (CASE WHEN Total.dblDividendAmount < @dblMinimumDividend THEN 0 
												ELSE Total.dblDividendAmount * (@FWT / 100) END) END,
				   dblCheckAmount = CASE WHEN Total.dblDividendAmount < @dblMinimumDividend THEN 0
										 ELSE Total.dblDividendAmount - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 
									 ELSE (CASE WHEN Total.dblDividendAmount < @dblMinimumDividend THEN 0 
												ELSE Total.dblDividendAmount * (@FWT / 100) END) END) END
			 FROM tblPATStockClassification SC
	   INNER JOIN tblPATCustomerStock CS
			   ON CS.intStockId = SC.intStockId
	   INNER JOIN tblEntity ENT
			   ON ENT.intEntityId = CS.intCustomerPatronId
	   INNER JOIN tblARCustomer ARC
			   ON ARC.intEntityCustomerId = ENT.intEntityId
		LEFT JOIN tblSMTaxCode TC
			   ON TC.intTaxCodeId = ARC.intTaxCodeId
	  CROSS APPLY (
	  	 
				  SELECT DISTINCT intCustomerId = B.intCustomerPatronId,
								  dblDividendAmount = SUM(CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL THEN 
												  ((B.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays ELSE
												  ((B.dblSharesNo * SC.intDividendsPerShare)/365) * 
												  CASE WHEN B.dtmIssueDate > @dtmCutoffDate 
													 THEN DATEDIFF(day, B.dtmIssueDate, @dtmProcessingDateTo) 
													 ELSE @dblProcessingDays END END)
							 FROM tblPATStockClassification SC
					   INNER JOIN tblPATCustomerStock B
							   ON B.intStockId = SC.intStockId
					   INNER JOIN tblEntity ENT
							   ON ENT.intEntityId = B.intCustomerPatronId
					   INNER JOIN tblARCustomer ARC
							   ON ARC.intEntityCustomerId = ENT.intEntityId
						LEFT JOIN tblSMTaxCode TC
							   ON TC.intTaxCodeId = ARC.intTaxCodeId
							WHERE B.intCustomerPatronId = CS.intCustomerPatronId
						 GROUP BY B.intCustomerPatronId
			) Total
		    WHERE CS.strActivityStatus <> 'Retired'
         GROUP BY CS.intCustomerPatronId,
				  ENT.strName, 
				  ARC.strStockStatus, 
				  TC.strTaxCode, 
				  CS.dblSharesNo, 
				  SC.intDividendsPerShare, 
				  CS.dtmIssueDate, 
				  ARC.ysnSubjectToFWT,
				  Total.dblDividendAmount,
				  CS.dblCheckAmount
END
GO