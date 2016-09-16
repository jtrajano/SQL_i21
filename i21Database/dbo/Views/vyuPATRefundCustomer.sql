CREATE VIEW [dbo].[vyuPATRefundCustomer]
	AS
SELECT	RC.intRefundCustomerId,
        RC.intRefundId,
        RC.intCustomerId,
		E.strName AS strCustomerName,
		C.strStockStatus,
		C.dtmLastActivityDate,
		TC.strTaxCode,
		dblTotalPurchases = (CASE WHEN RCatPCat.strPurchaseSale = 'Purchase' THEN RCatPCat.dblVolume ELSE 0 END),
		dblTotalSales = (CASE WHEN RCatPCat.strPurchaseSale = 'Sale' THEN RCatPCat.dblVolume ELSE 0 END),
        RC.ysnEligibleRefund,
        RC.intRefundTypeId,
        RC.dblCashPayout,
        RC.ysnQualified,
        RC.dblRefundAmount,
        RC.dblCashRefund,
        RC.dblEquityRefund,
		dbLessFWT = CASE WHEN C.ysnSubjectToFWT = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END,
		dblLessServiceFee = RC.dblCashRefund * (R.dblServiceFee/100),
		dblCheckAmount = CASE WHEN (RC.dblCashRefund - (CASE WHEN C.ysnSubjectToFWT = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RC.dblCashRefund * (R.dblServiceFee/100)) < 0) THEN 0 ELSE RC.dblCashRefund - (CASE WHEN C.ysnSubjectToFWT = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RC.dblCashRefund * (R.dblServiceFee/100)) END,
		dblTotalVolume = RCatPCat.dblVolume,
		dblTotalRefund = RC.dblRefundAmount,
		RC.intConcurrencyId
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RC.intRefundId
	INNER JOIN tblEMEntity E
		ON E.intEntityId = RC.intCustomerId
	INNER JOIN tblARCustomer C
		ON C.intEntityCustomerId = RC.intCustomerId
	LEFT OUTER JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = C.intTaxCodeId
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
		ON RCatPCat.intRefundCustomerId = RC.intRefundCustomerId