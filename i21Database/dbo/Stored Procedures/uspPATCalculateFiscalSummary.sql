CREATE PROCEDURE [dbo].[uspPATCalculateFiscalSummary]
	@intFiscalYearId AS INT = 0,
	@strStockStatus AS NVARCHAR(10),
	@intCompanyLocationId AS INT = 0
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @tblEligibleStockStatus TABLE(
	[strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS
);

DECLARE @tblCalculatedRefunds TABLE(
		intFiscalYear INT,
		intCustomerPatronId INT,
		strStockStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		intCompanyLocationId INT,
		dblVolume NUMERIC(18,6),
		dblRefundAmount NUMERIC(18,6),
		dblNonRefundAmount NUMERIC(18,6),
		dblCashRefund NUMERIC(18,6),
		dblEquityRefund NUMERIC(18,6),
		dblLessFWTPercentage NUMERIC(18,6)
);

IF(@strStockStatus = 'V')
BEGIN
	INSERT INTO @tblEligibleStockStatus VALUES('Voting');
END
ELSE IF(@strStockStatus = 'S')
BEGIN
	INSERT INTO @tblEligibleStockStatus VALUES('Voting'),('Non-Voting');
END
ELSE
BEGIN
	INSERT INTO @tblEligibleStockStatus VALUES('Voting'),('Non-Voting'),('Producer'),('Other');
END


INSERT INTO @tblCalculatedRefunds
SELECT	Total.intFiscalYear,
		Total.intCustomerPatronId,
		Total.strStockStatus,
		CompLoc.intCompanyLocationId,
		Total.dblVolume,
		dblRefundAmount = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN Total.dblRefundAmount ELSE 0 END),
		dblNonRefundAmount = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN 0 ELSE Total.dblRefundAmount END),
		dblCashRefund = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN (Total.dblRefundAmount * (RR.dblCashPayout/100)) ELSE 0 END),
		dblEquityRefund = SUM(CASE WHEN Total.ysnEligibleRefund = 1 THEN (Total.dblRefundAmount - (Total.dblRefundAmount * (RR.dblCashPayout/100))) ELSE 0 END),
		dblLessFWTPercentage = CASE WHEN Total.ysnEligibleRefund = 1 AND ISNULL(APV.ysnWithholding, 0) = 1 THEN CompLoc.dblWithholdPercent ELSE 0 END
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
				ON ARC.intEntityId = B.intCustomerPatronId
			INNER JOIN vyuEMEntityType EMT
				ON EMT.intEntityId = B.intCustomerPatronId AND EMT.Customer = 1 AND EMT.Vendor = 1
			CROSS APPLY tblPATCompanyPreference ComPref
			WHERE B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0 AND ARC.strStockStatus IN (SELECT strStockStatus FROM @tblEligibleStockStatus) 
			AND B.intFiscalYear = @intFiscalYearId
			GROUP BY	B.intCustomerPatronId,
						ARC.strStockStatus,
						B.intFiscalYear,
						RRD.intRefundTypeId,
						ComPref.dblMinimumRefund
		) Total
INNER JOIN tblPATRefundRate RR
            ON RR.intRefundTypeId = Total.intRefundTypeId
LEFT OUTER JOIN tblAPVendor APV
	ON APV.intEntityId = Total.intCustomerPatronId
CROSS APPLY tblPATCompanyPreference ComPref
CROSS APPLY tblSMCompanyLocation CompLoc WHERE CompLoc.intCompanyLocationId = @intCompanyLocationId
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
UNION
SELECT	Total.intFiscalYear,
		Total.intCustomerPatronId,
		Total.strStockStatus,
		intCompanyLocationId = @intCompanyLocationId,
		Total.dblVolume,
		dblRefundAmount = 0,
		dblNonRefundAmount = SUM(Total.dblRefundAmount),
		dblCashRefund = 0,
		dblEquityRefund = 0,
		dblLessFWTPercentage = 0
		FROM (
			SELECT	B.intCustomerPatronId,
					RRD.intRefundTypeId,
					ARC.strStockStatus,
					intFiscalYear = B.intFiscalYear,
					dblVolume = SUM(B.dblVolume),
					dblRefundAmount = SUM(ROUND(RRD.dblRate * B.dblVolume,2))
			FROM tblPATCustomerVolume B
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intPatronageCategoryId = B.intPatronageCategoryId 
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = RRD.intRefundTypeId
			INNER JOIN tblARCustomer ARC
					ON ARC.intEntityId = B.intCustomerPatronId
			CROSS APPLY tblPATCompanyPreference ComPref
			WHERE B.ysnRefundProcessed <> 1 AND B.dblVolume <> 0 AND ARC.strStockStatus NOT IN (SELECT strStockStatus FROM @tblEligibleStockStatus) 
			AND B.intFiscalYear = @intFiscalYearId
			GROUP BY	B.intCustomerPatronId,
						ARC.strStockStatus,
						B.intFiscalYear,
						RRD.intRefundTypeId,
						ComPref.dblMinimumRefund
		) Total
GROUP BY Total.intFiscalYear,
		Total.intCustomerPatronId,
		Total.strStockStatus,
		Total.dblVolume,
		Total.intRefundTypeId

SELECT	id = CAST(ROW_NUMBER() OVER(ORDER BY intFiscalYear) AS INT),
		intFiscalYear AS intFiscalYearId,
		intCompanyLocationId,
		dblVolume = SUM(dblVolume), 
		dblRefundAmount = ROUND(SUM(dblRefundAmount),2),
		dblNonRefundAmount = ROUND(SUM(dblNonRefundAmount),2),
		dblCashRefund = ROUND(SUM(dblCashRefund),2),
		dblLessFWT = ROUND(SUM(dblLessFWT),2),
		dblLessServiceFee = ROUND(SUM(dblLessServiceFee),2),
		dblCheckAmount = ROUND(SUM(CASE WHEN dblCheckAmount > 0 THEN dblCheckAmount ELSE 0 END),2),
		dblEquityRefund = ROUND(SUM(dblEquityRefund),2),
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
		dblLessFWT = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund THEN (dblCashRefund * (dblLessFWTPercentage/100)) ELSE 0 END,
		dblLessServiceFee = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund OR (dblCashRefund <= ComPref.dblCutoffAmount AND ComPref.strCutoffTo = 'Cash') AND dblNonRefundAmount = 0 THEN ComPref.dblServiceFee ELSE 0 END,
		dblCheckAmount = CASE WHEN dblRefundAmount >= ComPref.dblMinimumRefund THEN 
								(dblCashRefund - (dblCashRefund * (dblLessFWTPercentage/100)) - 
								(CASE WHEN dblRefundAmount >= ComPref.dblServiceFee OR (dblCashRefund <= ComPref.dblCutoffAmount AND ComPref.strCutoffTo = 'Cash') THEN ComPref.dblServiceFee ELSE 0 END))
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
						intVoting = [dbo].[fnPATCountStockStatus]('Voting', default, @intFiscalYearId),
						intNonVoting = [dbo].[fnPATCountStockStatus]('Non-Voting', default, @intFiscalYearId),
						intProducers = [dbo].[fnPATCountStockStatus]('Producer', default, @intFiscalYearId),
						intOthers = [dbo].[fnPATCountStockStatus]('Other', default, @intFiscalYearId)
				FROM @tblCalculatedRefunds
				CROSS APPLY tblPATCompanyPreference ComPref
		) FiscalSum
		CROSS APPLY tblPATCompanyPreference ComPref
) CalculatedFiscalSum
GROUP BY intFiscalYear, intCompanyLocationId, intVoting, intNonVoting, intProducers, intOthers

END