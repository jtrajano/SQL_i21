CREATE VIEW [dbo].[vyuPATCalculateRefundSummaryHistory]
	AS
WITH ComPref AS(
	SELECT TOP(1) dblMinimumRefund = ISNULL(dblMinimumRefund,0) FROM tblPATCompanyPreference
)
SELECT	NEWID() AS id,
		R.intRefundId,
		R.intFiscalYearId,
		ARC.strStockStatus,
		RCatPCat.intRefundTypeId,
		RCatPCat.strRefundType,
		RCatPCat.strRefundDescription,
		RCatPCat.dblCashPayout,
		RCatPCat.ysnQualified,
		ysnEligibleRefund = (CASE WHEN RCus.dblRefundAmount >= R.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END),
		RCatPCat.dblVolume,
		dblRefundAmount = RCus.dblRefundAmount ,
		dblNonRefundAmount = CASE WHEN RCus.dblRefundAmount < ComPref.dblMinimumRefund THEN RCus.dblRefundAmount ELSE 0 END,
		RCus.dblCashRefund,
		dblEquityRefund = CASE WHEN RCus.dblEquityRefund <= 0 THEN 0 ELSE RCus.dblEquityRefund END
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
	CROSS APPLY ComPref