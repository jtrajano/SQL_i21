CREATE VIEW [dbo].[vyuRKCreditTempLimit]
	AS 
	SELECT 
		CTLimit.intCreditTempLimitId,
		CTLimit.dblTempAmount,
		CTLimit.intCurrencyID,
		CTLimit.strCurrency,
		CTLimit.dtmTempDateFrom,
		CTLimit.dtmTempDateTo,
		CTLimit.intCreditLineId,
		CTLimit.intCreditInsuranceId,
		CTLimit.intConcurrencyId,
		CInsurance.intEntityId,
		CInsurance.strEntityName,
		CInsurance.intInsuranceTypeId,
		CInsurance.strInsuranceType,
		CInsurance.strPolicyNumber,
		CInsurance.dblAggregatedPolicyAmount
		FROM tblRKCreditTempLimit CTLimit
		LEFT JOIN tblRKCreditInsurance CInsurance ON CInsurance.intCreditInsuranceId = CTLimit.intCreditInsuranceId
