﻿CREATE PROCEDURE [dbo].[uspPATGetCustomerCalculation] 
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



SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
			   strCustomerName = ENT.strName,
			   strStockStatus = AC.strStockStatus,
			   dtmLastActivityDate = max(CV.dtmLastActivityDate),
			   TC.strTaxCode,
			   ysnEligibleRefund = (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND Total.dblRefundAmount < @dblMinimumRefund  THEN 1 ELSE 0 END),
			   dblTotalPurchases = Total.dblTotalPurchases,
			   dblTotalSales = Total.dblTotalSales,
			   dblRefundAmount = Total.dblRefundAmount,
			   dblEquityRefund = Total.dblRefundAmount - Total.dblCashRefund,
			   dblCashRefund = Total.dblCashRefund,
			   dbLessFWT = Total.dbLessFWT ,
			   dblLessServiceFee = Total.dblLessServiceFee,
			   dblCheckAmount =  CASE WHEN (Total.dblCashRefund - Total.dbLessFWT - Total.dblLessServiceFee < 0) THEN 0 ELSE Total.dblCashRefund - Total.dbLessFWT - Total.dblLessServiceFee END,
			   dblTotalVolume = Total.dblVolume,
			   dblTotalRefund = Total.dblTotalRefund
		  FROM (
		  SELECT DISTINCT B.intCustomerPatronId AS intCustomerId,
				    dblTotalPurchases = SUM(CASE WHEN PC.strPurchaseSale = 'Purchase' THEN dblVolume ELSE 0 END),
					dblTotalSales = SUM(CASE WHEN PC.strPurchaseSale = 'Sale' THEN dblVolume ELSE 0 END),
					(CASE WHEN SUM(RRD.dblRate * dblVolume) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate * dblVolume) END) AS dblRefundAmount,
					(SUM(RRD.dblRate * dblVolume) * (SUM(RR.dblCashPayout)/100)) AS dblCashRefund,
					(((SUM(RRD.dblRate * dblVolume)) * (RR.dblCashPayout/100)) * (@FWT/100)) AS dbLessFWT,
					@LessService AS dblLessServiceFee,
					dblVolume = SUM(dblVolume),
					dblTotalRefund = SUM(RRD.dblRate)
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
			   WHERE B.intCustomerPatronId = B.intCustomerPatronId
		   GROUP BY B.intCustomerPatronId,
					RR.dblCashPayout,
					AC.ysnSubjectToFWT,
					RRD.dblRate
			) Total
	   LEFT JOIN tblPATCustomerVolume CV
		    ON CV.intCustomerPatronId = Total.intCustomerId
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
				TC.strTaxCode, 
				Total.dblTotalPurchases,
				Total.dblTotalSales,
				Total.dblRefundAmount,
				Total.dblCashRefund,
				Total.dbLessFWT,
				Total.dblLessServiceFee,
				Total.dblVolume,
				Total.dblTotalRefund,
				Total.intCustomerId
	   

	   DROP TABLE #statusTable
	-- ==================================================================
	-- End Transaction
	-- ==================================================================
END



GO