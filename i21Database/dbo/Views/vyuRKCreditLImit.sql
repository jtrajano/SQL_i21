CREATE VIEW [dbo].[vyuRKCreditLimit]
	AS 
	SELECT 
		CLimit.intCreditLimitId,
		CLimit.dblAmountInsurance,
		CLimit.intCurrencyID,
		CLimit.strCurrency,
		CLimit.dtmDateInsuranceFrom,
		CLimit.dtmDateInsuranceTo,
		CLimit.intCreditLineId,
		CLimit.intCreditInsuranceId,
		CLimit.intConcurrencyId,
		CInsurance.intEntityId,
		CInsurance.strEntityName,
		CInsurance.intInsuranceTypeId,
		CInsurance.strInsuranceType,
		CInsurance.strPolicyNumber,
		CInsurance.dblAggregatedPolicyAmount,
		dblRate = CASE WHEN CLimit.intCurrencyID = CInsurance.intCurrencyID THEN 1
					ELSE dbo.fnRKGetCurrencyConvertion(CLimit.intCurrencyID, CInsurance.intCurrencyID, DEFAULT) END
		FROM tblRKCreditLimit CLimit
		LEFT JOIN tblRKCreditInsurance CInsurance ON CInsurance.intCreditInsuranceId = CLimit.intCreditInsuranceId