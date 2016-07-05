CREATE PROCEDURE [dbo].[uspPATGetCustomerCalculation] 
	@intFiscalYearId INT = NULL,
	@strStockStatus CHAR(1) = NULL,
	@dblMinimumRefund NUMERIC(18,6) = NULL,
	@dblCashCutoffAmount NUMERIC(18,6) = NULL,
	@FWT NUMERIC(18,6) = NULL,
	@LessService NUMERIC(18,6) = NULL,
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
		SELECT *
		FROM
		(
			SELECT DISTINCT intCustomerId = CV.intCustomerPatronId,
						   strCustomerName = ENT.strName,
						   strStockStatus = AC.strStockStatus,
						   dtmLastActivityDate = max(CV.dtmLastActivityDate),
						   TC.strTaxCode,
						   ysnEligibleRefund = (CASE WHEN AC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND Total.dblRefundAmount >= @dblMinimumRefund THEN 1 ELSE 0 END),
						   dblTotalPurchases = Total.dblTotalPurchases,
						   dblTotalSales = Total.dblTotalSales,
						   dblRefundAmount = Total.dblRefundAmount,
						   dblEquityRefund = CASE WHEN (Total.dblRefundAmount - Total.dblCashRefund) < 0 THEN 0 ELSE Total.dblRefundAmount - Total.dblCashRefund END,
						   dblCashRefund = Total.dblCashRefund,
						   dbLessFWT = CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE Total.dbLessFWT END,
						   dblLessServiceFee = Total.dblCashRefund * (Total.dblLessServiceFee/100),
						   dblCheckAmount =  CASE WHEN (Total.dblCashRefund - (CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE Total.dbLessFWT END) - (Total.dblCashRefund * (Total.dblLessServiceFee/100)) < 0) THEN 0 ELSE Total.dblCashRefund - (CASE WHEN AC.ysnSubjectToFWT = 0 THEN 0 ELSE Total.dbLessFWT END) - (Total.dblCashRefund * (Total.dblLessServiceFee/100)) END,
						   dblTotalVolume = Total.dblVolume,
						   dblTotalRefund = Total.dblTotalRefund
					  FROM (
					  SELECT DISTINCT B.intCustomerPatronId AS intCustomerId,
								dblTotalPurchases = SUM(CASE WHEN PC.strPurchaseSale = 'Purchase' THEN dblVolume ELSE 0 END),
								dblTotalSales = SUM(CASE WHEN PC.strPurchaseSale = 'Sale' THEN dblVolume ELSE 0 END),
								(CASE WHEN SUM(RRD.dblRate * dblVolume) <= @dblMinimumRefund THEN 0 ELSE SUM(RRD.dblRate * dblVolume) END) AS dblRefundAmount,
								SUM((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100)) AS dblCashRefund,
								SUM((RRD.dblRate * dblVolume) * (RR.dblCashPayout/100) * (@FWT/100)) AS dbLessFWT,
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
					 INNER JOIN tblEMEntity ENT
							 ON ENT.intEntityId = B.intCustomerPatronId
					 INNER JOIN tblPATPatronageCategory PC
							 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
						   WHERE B.intCustomerPatronId = B.intCustomerPatronId
					   GROUP BY B.intCustomerPatronId
						) Total
				 INNER JOIN tblPATCustomerVolume CV
						ON CV.intCustomerPatronId = Total.intCustomerId
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
							AC.ysnSubjectToFWT, 
							TC.strTaxCode, 
							dblTotalPurchases,
							dblTotalSales,
							dblRefundAmount,
							dblCashRefund,
							dbLessFWT,
							dblLessServiceFee,
							Total.dblVolume,
							Total.dblTotalRefund
		) Results
		WHERE Results.ysnEligibleRefund = 1
	END
	ELSE
	BEGIN
		SELECT	intCustomerId = RCus.intCustomerId,
				strCustomerName = EN.strName,
				ARC.strStockStatus,
				dtmLastActivityDate = R.dtmRefundDate,
				TC.strTaxCode,
				ysnEligibleRefund = (CASE WHEN ARC.strStockStatus IN (SELECT strStockStatus FROM #statusTable) AND RCatPCat.dblRefundRate < R.dblMinimumRefund THEN 1 ELSE 0 END),
				dblTotalPurchases = (CASE WHEN RCatPCat.strPurchaseSale = 'Purchase' THEN RCatPCat.dblVolume ELSE 0 END),
				dblTotalSales = (CASE WHEN RCatPCat.strPurchaseSale = 'Sale' THEN RCatPCat.dblVolume ELSE 0 END),
				RCus.dblRefundAmount,
				dblEquityRefund = CASE WHEN RCus.dblEquityRefund < 0 THEN 0 ELSE RCus.dblEquityRefund END,
				RCus.dblCashRefund,
				dbLessFWT = CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END,
				dblLessServiceFee = RCus.dblCashRefund * (R.dblServiceFee/100),
				dblCheckAmount = CASE WHEN (RCus.dblCashRefund - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RCus.dblCashRefund * (R.dblServiceFee/100)) < 0) THEN 0 ELSE RCus.dblCashRefund - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RCus.dblCashRefund * (R.dblServiceFee/100)) END,
				dblTotalVolume = RCatPCat.dblVolume,
				dblTotalRefund = RCus.dblRefundAmount
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
					dblVolume = RCat.dblVolume
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