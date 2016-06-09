CREATE PROCEDURE [dbo].[uspPATGetRefundCalculation]
	@intFiscalYearId INT = NULL,
	@strStockStatus CHAR(1) = NULL,
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


	IF (@intRefundId <= 0)
	BEGIN
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
			 INNER JOIN tblEMEntity ENT
					 ON ENT.intEntityId = CV.intCustomerPatronId
			 INNER JOIN tblPATPatronageCategory PC
					 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
			CROSS APPLY (
						SELECT DISTINCT B.intCustomerPatronId AS intCustomerId,
							   (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN SUM(dblVolume) ELSE 0 END) AS dblVolume,
							   (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(RRD.dblRate) * SUM(dblVolume),0) ELSE 0 END) AS dblRefundAmount,
							   (CASE WHEN AC.strStockStatus NOT IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(SUM(RRD.dblRate),0) ELSE 0 END) AS dblNonRefundAmount,
							   (SUM(RRD.dblRate) * SUM(dblVolume) * (SUM(RR.dblCashPayout)/100)) AS dblCashRefund
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
						Total.dblCashRefund
	END
	ELSE
	BEGIN
		SELECT	RCatPCat.intRefundTypeId,
				RCatPCat.strRefundType,
				RCatPCat.strRefundDescription,
				RCatPCat.dblCashPayout,
				RCatPCat.ysnQualified,
				ysnEligibleRefund = (CASE WHEN ARC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND RCatPCat.dblRefundRate < R.dblMinimumRefund THEN 1 ELSE 0 END),
				RCatPCat.dblVolume,
				RCus.dblRefundAmount,
				dblNonRefundAmount = (CASE WHEN ARC.strStockStatus NOT IN (SELECT strStockStatus FROM #statusTable) THEN ISNULL(RCatPCat.dblRate,0) ELSE 0 END),
				RCus.dblCashRefund,
				RCus.dblEquityRefund
		FROM tblPATRefundCustomer RCus
		INNER JOIN tblPATRefund R
			ON RCus.intRefundId = R.intRefundId
		INNER JOIN tblEMEntity EN
			ON EN.intEntityId = RCus.intCustomerId
		INNER JOIN tblARCustomer ARC
			ON ARC.intEntityCustomerId = RCus.intCustomerId
		INNER JOIN
		(
			SELECT	intRefundCustomerId = RCat.intRefundCustomerId,
					intPatronageCategoryId = RCat.intPatronageCategoryId,
					dblRefundRate = RCat.dblRefundRate,
					strPurchaseSale = PCat.strPurchaseSale,
					intRefundTypeId = RRD.intRefundTypeId,
					strRefundType = RR.strRefundType,
					strRefundDescription = RR.strRefundDescription,
					dblCashPayout = RR.dblCashPayout,
					ysnQualified = RR.ysnQualified,
					dblVolume = RCat.dblVolume,
					RRD.dblRate
			FROM tblPATRefundCategory RCat
			INNER JOIN tblPATPatronageCategory PCat
				ON RCat.intPatronageCategoryId	 = PCat.intPatronageCategoryId
			INNER JOIN tblPATRefundRateDetail RRD
				ON RRD.intPatronageCategoryId = RCat.intPatronageCategoryId
			INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = RRD.intRefundTypeId
		) RCatPCat
			ON RCatPCat.intRefundCustomerId = RCus.intRefundCustomerId
		LEFT JOIN tblSMTaxCode TC
			ON TC.intTaxCodeId = ARC.intTaxCodeId
		WHERE R.intRefundId = @intRefundId
	END
	-- ==================================================================
	-- End Transaction
	-- ==================================================================

	DROP TABLE #statusTable
END
GO