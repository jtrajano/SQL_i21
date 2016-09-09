CREATE PROCEDURE [dbo].[uspPATGetDividendsCustomer]
	@intCustomerId INT = NULL,
	@dblProcessingDays NUMERIC(18,6) = NULL,
	@ysnProrateDividend BIT = NULL,
	@dtmProcessingDateFrom DATETIME = NULL,
	@dtmProcessingDateTo DATETIME = NULL, 
	@dtmCutoffDate DATETIME = NULL
AS
BEGIN
		SELECT DISTINCT CS.intCustomerPatronId AS intCustomerId,
			   CS.intStockId,
			   SC.strStockName,
			   CS.strCertificateNo,
			   SC.dblParValue,
			   CS.dblSharesNo,
			   SC.intDividendsPerShare,
			   dblDividendAmount = CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> NULL THEN 
										((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays ELSE
										((CS.dblSharesNo * SC.intDividendsPerShare)/365) * 
										CASE WHEN CS.dtmIssueDate > @dtmCutoffDate 
											THEN DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo) 
											ELSE @dblProcessingDays END END
		  FROM tblPATStockClassification SC
	INNER JOIN tblPATCustomerStock CS
			ON CS.intStockId = SC.intStockId
	INNER JOIN tblEMEntity ENT
			ON ENT.intEntityId = CS.intCustomerPatronId
	INNER JOIN tblARCustomer ARC
			ON ARC.intEntityCustomerId = ENT.intEntityId
	 LEFT JOIN tblSMTaxCode TC
			ON TC.intTaxCodeId = ARC.intTaxCodeId
		 WHERE CS.intCustomerPatronId = @intCustomerId
		   AND CS.dtmIssueDate BETWEEN @dtmProcessingDateFrom AND @dtmProcessingDateTo
		   
END
GO