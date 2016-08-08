CREATE PROCEDURE [dbo].[uspPATGetFiscalSummary] 
	@intFiscalYearId INT = 10,
	@strStockStatus CHAR(1) = 'A',
	@dblMinimumRefund NUMERIC(18,6) = 10,
	@dblCashCutoffAmount NUMERIC(18,6) = 10,
	@FWT NUMERIC(18,6) = 5,
	@LessService NUMERIC(18,6) = 25,
	@intRefundId INT = 0
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

IF (@intRefundId > 0)
BEGIN
	SET @intFiscalYearId = (SELECT intFiscalYearId FROM tblPATRefund WHERE intRefundId = @intRefundId)
	SET @strStockStatus = (SELECT strRefund FROM tblPATRefund WHERE intRefundId = @intRefundId)
	SET @dblMinimumRefund =	(SELECT dblMinimumRefund FROM tblPATRefund WHERE intRefundId = @intRefundId)
	SET @dblCashCutoffAmount = (SELECT dblCashCutoffAmount FROM tblPATRefund WHERE intRefundId = @intRefundId)
	SET @FWT = (SELECT dblFedWithholdingPercentage FROM tblPATRefund WHERE intRefundId = @intRefundId)
	SET @LessService = (SELECT dblServiceFee FROM tblPATRefund WHERE intRefundId = @intRefundId)
END

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
				dblVolume =  Total.dblVolume,
				dblRefundAmount = Total.dblRefundAmount,
				dblNonRefundAmount = Total.dblNonRefundAmount,
				dblCashRefund = Total.dblCashRefund,
				dbLessFWT =	Total.dbLessFWT,
				dblLessServiceFee = @LessService,
				dblCheckAmount =  CASE WHEN (Total.dblCashRefund - Total.dbLessFWT - (Total.dblCashRefund * (@LessService/100.0)) < 0) THEN 0 ELSE (Total.dblCashRefund) - (Total.dbLessFWT) - (Total.dblCashRefund * (@LessService/100.0)) END,
				dblEquityRefund = Total.dblRefundAmount - Total.dblCashRefund,
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
	 INNER JOIN tblEMEntity ENT
			 ON ENT.intEntityId = CV.intCustomerPatronId
	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			  CROSS APPLY (
	 SELECT DISTINCT B.intFiscalYear AS intFiscalYear,
				    (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(B.dblVolume,0) ELSE 0 END) AS dblVolume,
					(CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL((RRD.dblRate * dblVolume),0) ELSE 0 END) AS dblRefundAmount,
					(CASE WHEN AC.strStockStatus NOT IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL((RRD.dblRate * dblVolume),0) ELSE 0 END) AS dblNonRefundAmount,
					((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100)) AS dblCashRefund,
					(CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE (((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100)) * (@FWT/100)) END) AS dbLessFWT
			   FROM tblPATCustomerVolume B
		 INNER JOIN tblPATRefundRateDetail RRD
				 ON RRD.intPatronageCategoryId = CV.intPatronageCategoryId 
		 INNER JOIN tblPATRefundRate RR
				 ON RR.intRefundTypeId = RRD.intRefundTypeId
		 INNER JOIN tblARCustomer AC
				 ON AC.intEntityCustomerId = CV.intCustomerPatronId
		  LEFT JOIN tblSMTaxCode TC
				 ON TC.intTaxCodeId = AC.intTaxCodeId
		 INNER JOIN tblEMEntity ENT
				 ON ENT.intEntityId = CV.intCustomerPatronId
		 INNER JOIN tblPATPatronageCategory PC
				 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			   WHERE B.intFiscalYear = CV.intFiscalYear
	 ) Total
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
				CV.intFiscalYear,
				Total.dblVolume,
				Total.dblRefundAmount,
				Total.dblNonRefundAmount,
				Total.dblCashRefund,
				Total.dbLessFWT

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