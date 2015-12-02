CREATE PROCEDURE [dbo].[uspPATGetRefundCalculation]
	@intFiscalYearId INT = NULL,
	@strStockStatus CHAR(1) = NULL
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



SELECT DISTINCT RR.intRefundTypeId,
				RR.strRefundType,
				RR.strRefundDescription,
				RR.dblCashPayout,
				RR.ysnQualified,
				ysnEligibleRefund = (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN 1 ELSE 0 END),
				dblVolume = Total.dblVolume,
				dblRefundAmount = Total.dblRefundAmount ,
				dblNonRefundAmount = Total.dblNonRefundAmount,
				dblCashRefund = Total.dblCashRefund,
				dblEquityRefund = Total.dblEquityRefund
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
	CROSS APPLY (
				SELECT DISTINCT B.intCustomerPatronId AS intCustomerId,
					   (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN SUM(dblVolume) ELSE 0 END) AS dblVolume,
					   (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END) AS dblRefundAmount,
					   (CASE WHEN AC.strStockStatus NOT IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END) AS dblNonRefundAmount,
					   ISNULL((SUM(RRD.dblRate) * (RR.dblCashPayout/100)),0) AS dblCashRefund,
					   ISNULL((SUM(RRD.dblRate) - (SUM(RRD.dblRate) * (RR.dblCashPayout/100))), 0) AS dblEquityRefund
				  FROM tblPATCustomerVolume B
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
				 WHERE B.intCustomerPatronId = CV.intCustomerPatronId
			 GROUP BY B.intCustomerPatronId, AC.strStockStatus, RR.dblCashPayout, RRD.dblRate
			 ) Total
		  WHERE CV.intFiscalYear = @intFiscalYearId 
	   GROUP BY CV.intCustomerPatronId, 
				ENT.strName, 
				AC.strStockStatus, 
				RR.intRefundTypeId,
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
				Total.dblVolume,
				Total.dblRefundAmount,
				Total.dblNonRefundAmount,
				Total.dblCashRefund,
				Total.dblEquityRefund

	-- ==================================================================
	-- End Transaction
	-- ==================================================================

	DROP TABLE #statusTable
END
GO