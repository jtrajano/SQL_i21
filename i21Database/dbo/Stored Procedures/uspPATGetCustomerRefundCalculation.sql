CREATE PROCEDURE [dbo].[uspPATGetCustomerRefundCalculation]
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

DECLARE @dblMinimumRefund NUMERIC(18,6) = (SELECT DISTINCT dblMinimumRefund FROM tblPATCompanyPreference)

	IF (@intRefundId <= 0)
	BEGIN
		 SELECT *
		 FROM
		 (
			 SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
					strCustomerName = ENT.strName,
					ysnEligibleRefund = (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND Total.dblRefundAmount >= @dblMinimumRefund THEN 1 ELSE 0 END),
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
			   FROM (
					SELECT DISTINCT intCustomerId = B.intCustomerPatronId,
								(CASE WHEN SUM(RRD.dblRate * dblVolume) <= 10 THEN 0 ELSE SUM(RRD.dblRate * dblVolume) END) AS dblRefundAmount,
								SUM((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100)) AS dblCashRefund,
								RRD.intPatronageCategoryId
						   FROM tblPATCustomerVolume B
					 INNER JOIN tblPATRefundRateDetail RRD
							 ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
					 INNER JOIN tblPATRefundRate RR
							 ON RR.intRefundTypeId = RRD.intRefundTypeId
					 INNER JOIN tblARCustomer AC
							 ON AC.intEntityCustomerId = B.intCustomerPatronId
					  LEFT JOIN tblSMTaxCode TC
							 ON TC.intTaxCodeId = AC.intTaxCodeId
					 INNER JOIN tblEMEntity ENT
							 ON ENT.intEntityId = B.intCustomerPatronId
					 INNER JOIN tblPATPatronageCategory PC
							 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
					   GROUP BY B.intCustomerPatronId, RR.dblCashPayout,RRD.intPatronageCategoryId
				  ) Total
		 INNER JOIN tblPATCustomerVolume CV
				ON CV.intCustomerPatronId = Total.intCustomerId AND CV.intPatronageCategoryId = Total.intPatronageCategoryId
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
			  WHERE CV.intFiscalYear = @intFiscalYearId AND CV.dblVolume <> 0.00
		   GROUP BY CV.intCustomerPatronId,
					ENT.strName,
					AC.strStockStatus,
					RR.strRefundType, 
					RR.strRefundDescription, 
					RR.dblCashPayout,
					RR.ysnQualified, 
					RRD.intPatronageCategoryId, 
					CV.intPatronageCategoryId, 
					PC.intPatronageCategoryId, 
					TC.strTaxCode, 
					CV.dtmLastActivityDate,
					PC.strPurchaseSale,
					Total.dblCashRefund,
					Total.dblRefundAmount,
					RR.intRefundTypeId
		) Results
		WHERE Results.ysnEligibleRefund = 1
	END
	ELSE
	BEGIN
		SELECT	intCustomerId = RCus.intCustomerId,
				strCustomerName = EN.strName,
				ysnEligibleRefund = (CASE WHEN ARC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND RCatPCat.dblRefundRate < R.dblMinimumRefund THEN 1 ELSE 0 END),
				ARC.strStockStatus,
				RCatPCat.strPurchaseSale,
				RCatPCat.intPatronageCategoryId,
				TC.strTaxCode,
				RCatPCat.intRefundTypeId,
				RCatPCat.strRefundType,
				RCatPCat.strRefundDescription,
				RCatPCat.dblCashPayout,
				RCatPCat.ysnQualified,
				dtmLastActivityDate = R.dtmRefundDate,
				RCus.dblRefundAmount,
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
					ysnQualified = RR.ysnQualified
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
	DROP TABLE #statusTable
	-- ==================================================================
	-- End Transaction
	-- ==================================================================
END
GO