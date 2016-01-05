CREATE PROCEDURE [dbo].[uspPATGetCustomerRefundCalculation]
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

DECLARE @dblMinimumRefund NUMERIC(18,6) = (SELECT DISTINCT dblMinimumRefund FROM tblPATCompanyPreference)

		 SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
				strCustomerName = ENT.strName,
				ysnEligibleRefund = (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND SUM(RRD.dblRate) < @dblMinimumRefund THEN 1 ELSE 0 END),
				AC.strStockStatus,
				PC.strPurchaseSale,
				PC.intPatronageCategoryId,
				TC.strTaxCode,
				RR.intRefundTypeId,
				RR.strRefundType,
				RR.strRefundDescription,
				RR.dblCashPayout,
				RR.ysnQualified,
				dtmLastActivityDate = CV.dtmLastActivityDate,
				dblRefundAmount = Total.dblRefundAmount,
				dblCashRefund = Total.dblCashRefund,
				dblEquityRefund = Total.dblRefundAmount - Total.dblCashRefund
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
			SELECT DISTINCT intCustomerId = B.intCustomerPatronId,
							(CASE WHEN SUM(RRD.dblRate) * SUM(dblVolume) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate) * SUM(dblVolume) END) AS dblRefundAmount,
							(SUM(RRD.dblRate) * SUM(dblVolume) * (SUM(RR.dblCashPayout)/100)) AS dblCashRefund
					   FROM tblPATCustomerVolume B
				 INNER JOIN tblPATRefundRateDetail RRD
						 ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
				 INNER JOIN tblPATRefundRate RR
						 ON RR.intRefundTypeId = RRD.intRefundTypeId
				 INNER JOIN tblARCustomer AC
						 ON AC.intEntityCustomerId = B.intCustomerPatronId
				  LEFT JOIN tblSMTaxCode TC
						 ON TC.intTaxCodeId = AC.intTaxCodeId
				 INNER JOIN tblEntity ENT
						 ON ENT.intEntityId = B.intCustomerPatronId
				 INNER JOIN tblPATPatronageCategory PC
						 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
				   GROUP BY B.intCustomerPatronId, RR.dblCashPayout
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
				Total.dblCashRefund,
				Total.dblRefundAmount,
				RR.intRefundTypeId
	DROP TABLE #statusTable
	-- ==================================================================
	-- End Transaction
	-- ==================================================================
END
GO