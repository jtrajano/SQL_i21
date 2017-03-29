CREATE VIEW [dbo].[vyuPATCalculateFiscalSummary]
	AS
WITH ComPref AS (
	SELECT TOP(1)
	strRefund,
	dblMinimumRefund,
	dblServiceFee,
	dblCutoffAmount
	FROM tblPATCompanyPreference
),
FiscalSum AS (
SELECT		Total.intFiscalYear,
			Total.intCustomerPatronId,
			Total.strStockStatus,
			CompLoc.intCompanyLocationId,
			Total.dblVolume,
			dblRefundAmount = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN Total.dblRefundAmount ELSE 0 END),
			dblNonRefundAmount = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN 0 ELSE Total.dblRefundAmount END),
			dblCashRefund = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN (Total.dblRefundAmount * (RR.dblCashPayout/100)) ELSE 0 END),
			dblEquityRefund = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN (Total.dblRefundAmount - (Total.dblRefundAmount * (RR.dblCashPayout/100))) ELSE 0 END),
			dblLessFWT = SUM(CASE WHEN Total.ysnEligibleRefund = 1 AND APV.ysnWithholding = 1 THEN (((Total.dblRefundAmount) * (RR.dblCashPayout/100)) * (CompLoc.dblWithholdPercent/100)) ELSE 0 END),
			dblLessServiceFee =  CASE WHEN ysnEligibleRefund = 1 THEN ComPref.dblServiceFee ELSE 0 END,
			dblCheckAmount =  SUM(CASE WHEN ysnEligibleRefund = 1 THEN 
									(
										CASE WHEN APV.ysnWithholding = 1 THEN
												(Total.dblRefundAmount * (RR.dblCashPayout/100)) - ComPref.dblServiceFee -
												(((Total.dblRefundAmount) * (RR.dblCashPayout/100)) * (CompLoc.dblWithholdPercent/100))
										ELSE (Total.dblRefundAmount * (RR.dblCashPayout/100)) - ComPref.dblServiceFee END
									) ELSE 0 END),
			intVoting = [dbo].[fnPATCountStockStatus]('Voting', default),
			intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', default),
			intProducers = [dbo].[fnPATCountStockStatus]('Producer', default),
			intOthers = [dbo].[fnPATCountStockStatus]('Other', default)
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
		ON APV.[intEntityId] = Total.intCustomerPatronId
	INNER JOIN tblARCustomer AC
			 ON AC.intEntityCustomerId = Total.intCustomerPatronId
	CROSS APPLY ComPref
	CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) CompLoc
	GROUP BY Total.intFiscalYear,
			Total.intCustomerPatronId,
			Total.strStockStatus,
			CompLoc.intCompanyLocationId,
			Total.dblVolume,
			Total.intRefundTypeId,
			Total.ysnEligibleRefund,
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
FROM FiscalSum
GROUP BY intFiscalYear, strStockStatus, intCompanyLocationId, intVoting, intNonVoting, intProducers, intOthers