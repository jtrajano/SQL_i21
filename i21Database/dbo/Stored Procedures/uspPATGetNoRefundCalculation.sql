CREATE PROCEDURE [dbo].[uspPATGetNoRefundCalculation]
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
			   AC.strStockStatus,
			   dblTotalPurchases = Total.dblTotalPurchases,
			   dblTotalSales = Total.dblTotalSales,
			   dblRefundAmount = Total.dblRefundAmount,
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

		SELECT DISTINCT B.intCustomerPatronId AS intCustomerId,
						(CASE WHEN PC.strPurchaseSale = 'Purchase' THEN SUM(dblVolume) ELSE 0 END) AS dblTotalPurchases,
						(CASE WHEN PC.strPurchaseSale = 'Sale' THEN SUM(dblVolume) ELSE 0 END) AS dblTotalSales,
						(CASE WHEN SUM(RRD.dblRate) * SUM(dblVolume) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate) * SUM(dblVolume) END) AS dblRefundAmount,
						((SUM(RRD.dblRate) * SUM(dblVolume)) * (RR.dblCashPayout/100)) AS dblCashRefund
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
			   GROUP BY B.intCustomerPatronId, PC.strPurchaseSale, RR.dblCashPayout
			) Total
		  WHERE CV.intFiscalYear = @intFiscalYearId
		    AND AC.strStockStatus NOT IN (SELECT strStockStatus FROM #statusTable)
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
				Total.dblTotalPurchases,
				Total.dblTotalSales,
				Total.dblRefundAmount,
				Total.dblCashRefund


	DROP TABLE #statusTable
	-- ==================================================================
	-- End Transaction
	-- ==================================================================
END
GO