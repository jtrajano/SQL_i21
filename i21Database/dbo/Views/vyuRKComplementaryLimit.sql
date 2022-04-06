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
		CInsurance.dblAggregatedPolicyAmount
		FROM tblRKComplementaryLimit CMLimit
		LEFT JOIN tblRKCreditInsurance CInsurance ON CInsurance.intCreditInsuranceId = CMLimit.intCreditInsuranceId