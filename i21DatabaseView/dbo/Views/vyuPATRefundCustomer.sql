CREATE VIEW [dbo].[vyuPATRefundCustomer]
	AS
SELECT	RC.intRefundCustomerId,
        RC.intRefundId,
        RC.intCustomerId,
		R.strRefundNo,
		R.dtmRefundDate,
		R.intFiscalYearId,
		FY.strFiscalYear,
		E.strEntityNo,
		strCustomerName = E.strName,
		C.strStockStatus,
		ysnVendor = CAST(EMType.Vendor AS BIT),
		C.dtmLastActivityDate,
		TC.strTaxCode,
		dblTotalPurchases = SUM(CASE WHEN RCatPCat.strPurchaseSale = 'Purchase' AND RCatPCat.intRefundTypeId = RC.intRefundTypeId THEN RCatPCat.dblVolume ELSE 0 END),
		dblTotalSales = SUM(CASE WHEN RCatPCat.strPurchaseSale = 'Sale'  AND RCatPCat.intRefundTypeId = RC.intRefundTypeId THEN RCatPCat.dblVolume ELSE 0 END),
        RC.ysnEligibleRefund,
        RC.intRefundTypeId,
        RC.dblCashPayout,
        RC.ysnQualified,
        RC.dblRefundAmount,
		RC.dblNonRefundAmount,
        RC.dblCashRefund,
        RC.dblEquityRefund,
		ysnVouchered = CASE WHEN RC.intBillId IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		dblLessFWT = CASE WHEN ISNULL(APV.ysnWithholding, 0) = 0 OR RC.dblCashRefund = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END,
		dblLessServiceFee = CASE WHEN ISNULL(RC.ysnEligibleRefund,0) = 1 AND RC.dblCashRefund > 0 THEN R.dblServiceFee ELSE 0 END,
		RC.intBillId,
		APB.strBillId,
		APP.intPaymentId,
		APP.strPaymentRecordNum,
		dblCheckAmount = CASE WHEN (RC.dblCashRefund - (CASE WHEN ISNULL(APV.ysnWithholding, 0) = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (R.dblServiceFee) < 0) AND RC.dblCashRefund = 0 THEN 0 ELSE RC.dblCashRefund - (CASE WHEN ISNULL(APV.ysnWithholding,0) = 0 THEN 0 ELSE RC.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (R.dblServiceFee) END,
		RC.intConcurrencyId
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RC.intRefundId
	INNER JOIN tblEMEntity E
		ON E.intEntityId = RC.intCustomerId
	INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = R.intFiscalYearId
	INNER JOIN vyuEMEntityType EMType
		ON EMType.intEntityId = E.intEntityId
	INNER JOIN tblARCustomer C
		ON C.intEntityId = RC.intCustomerId
	LEFT OUTER JOIN tblAPVendor APV
		ON APV.intEntityId = RC.intCustomerId
	LEFT OUTER JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = C.intTaxCodeId
	LEFT OUTER JOIN tblAPBill APB
		ON APB.intBillId = RC.intBillId
	LEFT OUTER JOIN tblAPPaymentDetail APPD
		ON APPD.intBillId = APB.intBillId
	LEFT OUTER JOIN tblAPPayment APP
		ON APP.intPaymentId = APPD.intPaymentId
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
	GROUP BY RC.intRefundCustomerId,
        RC.intRefundId,
        RC.intCustomerId,
		R.strRefundNo,
		R.dtmRefundDate,
		APB.strBillId,
		APP.intPaymentId,
		APP.strPaymentRecordNum,
		R.intFiscalYearId,
		FY.strFiscalYear,
		E.strEntityNo,
		E.strName,
		C.strStockStatus,
		EMType.Vendor,
		C.dtmLastActivityDate,
		TC.strTaxCode,
		RC.ysnEligibleRefund,
        RC.intRefundTypeId,
        RC.dblCashPayout,
        RC.ysnQualified,
		RC.dblRefundAmount,
		RC.dblNonRefundAmount,
        RC.dblCashRefund,
        RC.dblEquityRefund,
		APV.ysnWithholding,
		R.dblFedWithholdingPercentage,
		R.dblServiceFee,
		RC.intBillId,
		RC.intConcurrencyId