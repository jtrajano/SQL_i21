CREATE PROCEDURE [dbo].[uspPATGetDividendsCustomer]
	@intCustomerId INT = NULL,
	@dblProcessingDays NUMERIC(18,6) = NULL,
	@ysnProrateDividend BIT = NULL,
	@dtmCutoffDate DATETIME = NULL,
	@dtmProcessingDateTo DATETIME = NULL
AS
BEGIN
		SELECT DISTINCT CS.intCustomerPatronId,
			   CS.intStockId,
			   SC.strStockName,
			   SC.dblParValue,
			   CS.dblSharesNo,
			   SC.intDividendsPerShare,
			   dblDividendAmount = CASE WHEN @ysnProrateDividend <> 0 AND @dtmCutoffDate <> '' 
										THEN (((CS.dblSharesNo * SC.intDividendsPerShare)/365) * @dblProcessingDays) ELSE
										(((CS.dblSharesNo * SC.intDividendsPerShare)/365) * (DATEDIFF(day, CS.dtmIssueDate, @dtmProcessingDateTo))) END
		  FROM tblPATStockClassification SC
	INNER JOIN tblPATCustomerStock CS
			ON CS.intStockId = SC.intStockId
	INNER JOIN tblEntity ENT
			ON ENT.intEntityId = CS.intCustomerPatronId
	INNER JOIN tblARCustomer ARC
			ON ARC.intEntityCustomerId = ENT.intEntityId
	 LEFT JOIN tblSMTaxCode TC
			ON TC.intTaxCodeId = ARC.intTaxCodeId
		 WHERE CS.intCustomerPatronId = @intCustomerId
END

GO