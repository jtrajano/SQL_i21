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

-- =======================================================================================================
-- Begin Transaction
-- =======================================================================================================

-- =======================================================================================================
-- Get Stock Status
-- =======================================================================================================

CREATE TABLE #statusTable ( strStockStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL )



IF(@strStockStatus = 'A')
BEGIN
	DELETE FROM #statusTable
	INSERT INTO #statusTable VALUES ('Voting');
	INSERT INTO #statusTable VALUES ('Non-Voting');
	INSERT INTO #statusTable VALUES ('Producer');
	INSERT INTO #statusTable VALUES ('Other');
END
ELSE IF(@strStockStatus = 'S')
BEGIN
	DELETE FROM #statusTable
	INSERT INTO #statusTable VALUES ('Voting');
	INSERT INTO #statusTable VALUES ('Non-Voting');
END
ELSE IF(@strStockStatus = 'V')
BEGIN
	DELETE FROM #statusTable
	INSERT INTO #statusTable VALUES ('Voting');
END

SELECT DISTINCT CV.intFiscalYear,
				dblVolume =  (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(CV.dblVolume),0) ELSE 0 END),
				dblRefundAmount = (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END),
				dblNonRefundAmount = (CASE WHEN AC.strStockStatus NOT IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END),
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
		    FROM tblPATCustomerVolume CV
     INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
     INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = RRD.intRefundTypeId
	 INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = CV.intCustomerPatronId
	  LEFT JOIN tblSMTaxCode TC
			 ON TC.intTaxCodeId = AC.intTaxCodeId
	 INNER JOIN tblEntity ENT
			 ON ENT.intEntityId = CV.intCustomerPatronId
	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
		  WHERE CV.intFiscalYear = @intFiscalYearId 
	   GROUP BY CV.intCustomerPatronId, 
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
   DROP TABLE #statusTable

	-- ==================================================================
	-- End Transaction
	-- ==================================================================

END
GO