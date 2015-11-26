CREATE PROCEDURE [dbo].[uspPATGetFiscalSummary] 
	@intFiscalYearId INT = NULL,
	@strStockStatus CHAR(1) = NULL,
	@dblMinimumRefund NUMERIC(18,6) = NULL,
	@dblCashCutoffAmount NUMERIC(18,6) = NULL,
	@FWT NUMERIC(18,6) = NULL,
	@LessService NUMERIC(18,6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- ==================================================================
	-- Begin Transaction
	-- ==================================================================
		
	  
SELECT DISTINCT CV.intFiscalYear,
				dblVolume =  (CASE WHEN @strStockStatus = AC.strStockStatus THEN ISNULL(SUM(CV.dblVolume),0) ELSE 0 END),
				dblRefundAmount = (CASE WHEN @strStockStatus = AC.strStockStatus THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END),
				dblNonRefundAmount = (CASE WHEN @strStockStatus <> AC.strStockStatus THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END),
				dblCashRefund = (SUM(RRD.dblRate) * (RR.dblCashPayout/100)),
				dbLessFWT =	((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @FWT),
				dblLessServiceFee = ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @LessService),
				dblCheckAmount =  (SUM(RRD.dblRate) * (RR.dblCashPayout/100)) - ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @FWT) - ((SUM(RRD.dblRate) * (RR.dblCashPayout/100)) * @LessService),
				dblEquityRefund = (SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))),
				intVoting = (SELECT ISNULL(Count(*),0) 
							   FROM tblPATCustomerVolume CVV
					     INNER JOIN tblARCustomer ARR
								 ON ARR.intEntityCustomerId = CVV.intCustomerPatronId
							  WHERE ARR.strStockStatus = 'Voting'),
				intNonVoting = (SELECT ISNULL(Count(*),0) 
							   FROM tblPATCustomerVolume CVV
					     INNER JOIN tblARCustomer ARR
								 ON ARR.intEntityCustomerId = CVV.intCustomerPatronId
							  WHERE ARR.strStockStatus = 'Non-Voting'),
				intProducers = (SELECT ISNULL(Count(*),0) 
							   FROM tblPATCustomerVolume CVV
					     INNER JOIN tblARCustomer ARR
								 ON ARR.intEntityCustomerId = CVV.intCustomerPatronId
							  WHERE ARR.strStockStatus = 'Producer'),
				intOthers = (SELECT ISNULL(Count(*),0) 
							   FROM tblPATCustomerVolume CVV
					     INNER JOIN tblARCustomer ARR
								 ON ARR.intEntityCustomerId = CVV.intCustomerPatronId
							  WHERE ARR.strStockStatus = 'Other')
		   INTO #temptable		   
		   FROM tblPATEstateCorporation EC
     INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = EC.intRefundTypeId
	 INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = EC.intCorporateCustomerId
	  LEFT JOIN tblSMTaxCode TC
			 ON TC.intTaxCodeId = AC.intTaxCodeId
	 INNER JOIN tblEntity ENT
			 ON ENT.intEntityId = EC.intCorporateCustomerId
	 INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intRefundTypeId = RR.intRefundTypeId
	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
	  LEFT JOIN tblPATCustomerVolume CV
			 ON CV.intCustomerPatronId = EC.intCorporateCustomerId
		  WHERE CV.intFiscalYear = @intFiscalYearId 
	   GROUP BY EC.intCorporateCustomerId, 
				ENT.strName, 
				AC.strStockStatus, 
				RR.strRefundType, 
				RR.strRefundDescription, 
				RR.dblCashPayout, 
				RR.ysnQualified, 
				PC.strCategoryCode, 
				RRD.dblRate, 
				CV.dblVolume, 
				RRD.intPatronageCategoryId, 
				CV.intPatronageCategoryId, 
				PC.intPatronageCategoryId, 
				TC.strTaxCode, 
				CV.dtmLastActivityDate,
				PC.strPurchaseSale,
				CV.intFiscalYear 


	SELECT intFiscalYear,
		   dblVolume = SUM(dblVolume), 
		   dblRefundAmount = SUM(dblRefundAmount),
		   dblNonRefundAmount = SUM(dblNonRefundAmount),
		   dblCashRefund = SUM(dblCashRefund),
		   dbLessFWT = SUM(dbLessFWT),
		   dblLessServiceFee = SUM(dblLessServiceFee),
		   dblCheckAmount = SUM(dblCheckAmount),
		   dblEquityRefund = SUM(dblEquityRefund),
		   intVoting,
		   intNonVoting,
		   intProducers,
		   intOthers
	   FROM #temptable
   GROUP BY intFiscalYear, intVoting, intNonVoting, intProducers, intOthers


   DROP TABLE #temptable

	-- ==================================================================
	-- End Transaction
	-- ==================================================================

END
GO