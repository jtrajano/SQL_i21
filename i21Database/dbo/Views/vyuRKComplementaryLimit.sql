CREATE VIEW [dbo].[vyuRKComplementaryLimit]
	AS 
	SELECT 
		CMLimit.intComplementaryLimitId,
		CMLimit.dblTopOffAmount,
		CMLimit.intCurrencyID,
		CMLimit.strCurrency,
		CMLimit.dtmTopOffDateFrom,
		CMLimit.dtmTopOffDateTo,
		CMLimit.intCreditLineId,
		CMLimit.intCreditInsuranceId,
		CMLimit.intConcurrencyId,
		CInsurance.intEntityId,
		CInsurance.strEntityName,
		CInsurance.intInsuranceTypeId,
		CInsurance.strInsuranceType,
		CInsurance.strPolicyNumber,
		CInsurance.dblAggregatedPolicyAmount,
		dblRate = CASE WHEN CMLimit.intCurrencyID = CInsurance.intCurrencyID THEN 1
								ELSE dbo.fnRKGetCurrencyConvertion(CInsurance.intCurrencyID, CMLimit.intCurrencyID) END 
		FROM tblRKComplementaryLimit CMLimit
		LEFT JOIN tblRKCreditInsurance CInsurance ON CInsurance.intCreditInsuranceId = CMLimit.intCreditInsuranceId