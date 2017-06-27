CREATE VIEW [dbo].[vyuPATCalculateFiscalSummary]
	AS
WITH ComPref AS (
	SELECT TOP(1)
	strRefund,
	dblMinimumRefund,
	dblServiceFee,
	dblCutoffAmount,
	strCutoffTo
	FROM tblPATCompanyPreference
),
CalculatedRefunds AS (
SELECT		Total.intFiscalYear,
			Total.intCustomerPatronId,
			Total.strStockStatus,
			CompLoc.intCompanyLocationId,
			Total.dblVolume,
			dblRefundAmount = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN Total.dblRefundAmount ELSE 0 END),
			dblNonRefundAmount = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN 0 ELSE Total.dblRefundAmount END),
			dblCashRefund = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN (Total.dblRefundAmount * (RR.dblCashPayout/100)) ELSE 0 END),
			dblEquityRefund = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN (Total.dblRefundAmount - (Total.dblRefundAmount * (RR.dblCashPayout/100))) ELSE 0 END),
			dblLessFWTPercentage = CASE WHEN Total.ysnEligibleRefund = 1 AND APV.ysnWithholding = 1 THEN CompLoc.dblWithholdPercent ELSE 0 END
		    FROM (
				SELECT	B.intCustomerPatronId,
						RRD.intRefundTypeId,
						ARC.strStockStatus,
						intFiscalYear = B.intFiscalYear,
						dblVolume = SUM(B.dblVolume),
						ysnEligibleRefund = CASE WHEN SUM(RRD.dblRate * B.dblVolume) >= ComPref.dblMinimumRefund THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
						dblRefundAmount = SUM(ROUND(RRD.dblRate * B.dblVolume,2))
				FROM tblPATCustomerVolume B
				INNER JOIN tblPATRefundRateDetail RRD
						ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
				INNER JOIN tblPATRefundRate RR
						ON RR.intRefundTypeId = RRD.intRefundTypeId
				INNER JOIN tblARCustomer ARC
						ON ARC.intEntityCustomerId = B.intCustomerPatronId
				CROSS APPLY ComPref
				WHERE B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0
				GROUP BY	B.intCustomerPatronId,
							ARC.strStockStatus,
							B.dblVolume,
							B.intFiscalYear,
							RRD.intRefundTypeId,
							ComPref.dblMinimumRefund
			) Total
	INNER JOIN tblPATRefundRate RR
             ON RR.intRefundTypeId = Total.intRefundTypeId
	INNER JOIN tblAPVendor APV
		ON APV.intEntityVendorId = Total.intCustomerPatronId
	INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = Total.intCustomerPatronId
	CROSS APPLY ComPref
	CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) CompLoc
	GROUP BY Total.intFiscalYear,
			Total.intCustomerPatronId,
			Total.strStockStatus,
			APV.ysnWithholding,
			CompLoc.dblWithholdPercent,
			CompLoc.intCompanyLocationId,
			Total.dblVolume,
			Total.intRefundTypeId,
			Total.ysnEligibleRefund,
			ComPref.dblCutoffAmount,
			ComPref.dblServiceFee
)

SELECT	NEWID() AS id,
		intFiscalYear AS intFiscalYearId,
		strStockStatus,
		intCompanyLocationId,
		dblVolume = SUM(dblVolume), 
		dblRefundAmount = SUM(dblRefundAmount),
		dblNonRefundAmount = SUM(dblNonRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dblLessFWT = SUM(dblLessFWT),
		dblLessServiceFee = SUM(dblLessServiceFee),
		dblCheckAmount = SUM(CASE WHEN dblCheckAmount > 0 THEN dblCheckAmount ELSE 0 END),
		dblEquityRefund = SUM(dblEquityRefund),
		intVoting,
		intNonVoting,
		intProducers,
		intOthers
FROM (
SELECT intFiscalYear,
		strStockStatus,
		intCompanyLocationId,
		dblVolume, 
		dblRefundAmount,
		dblNonRefundAmount,
		dblCashRefund,
		dblEquityRefund,
		dblLessFWT = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund THEN ROUND(dblCashRefund * (dblLessFWTPercentage/100), 2) ELSE 0 END,
		dblLessServiceFee = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund OR (dblCashRefund <= ComPref.dblCutoffAmount AND ComPref.strCutoffTo = 'Cash') THEN ComPref.dblServiceFee ELSE 0 END,
		dblCheckAmount = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund THEN 
								ROUND(dblCashRefund - ROUND(dblCashRefund * (dblLessFWTPercentage/100), 2) - 
								(CASE WHEN dblRefundAmount >= ComPref.dblServiceFee OR (dblCashRefund <= ComPref.dblCutoffAmount AND ComPref.strCutoffTo = 'Cash') THEN ComPref.dblServiceFee ELSE 0 END), 2)
							ELSE 0 END,
		intVoting,
		intNonVoting,
		intProducers,
		intOthers
		FROM (SELECT	intFiscalYear,
						strStockStatus,
						intCompanyLocationId,
						dblVolume,
						dblRefundAmount,
						dblNonRefundAmount,
						dblCashRefund = CASE WHEN dblCashRefund <= ComPref.dblCutoffAmount THEN
											(CASE WHEN ComPref.strCutoffTo = 'Cash' THEN dblEquityRefund + dblCashRefund ELSE 0 END)
											ELSE dblCashRefund END,
						dblEquityRefund = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund THEN (CASE WHEN dblCashRefund <= ComPref.dblCutoffAmount THEN 
												(CASE WHEN ComPref.strCutoffTo = 'Equity' THEN dblEquityRefund + dblCashRefund ELSE 0 END) 
											ELSE dblEquityRefund END) ELSE 0 END,
						dblLessFWTPercentage,
						intVoting = [dbo].[fnPATCountStockStatus]('Voting', default),
						intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', default),
						intProducers = [dbo].[fnPATCountStockStatus]('Producer', default),
						intOthers = [dbo].[fnPATCountStockStatus]('Other', default)
				FROM CalculatedRefunds
				CROSS APPLY ComPref
		) FiscalSum
		CROSS APPLY ComPref
) CalculatedFiscalSum
GROUP BY intFiscalYear, strStockStatus, intCompanyLocationId, intVoting, intNonVoting, intProducers, intOthers