CREATE VIEW [dbo].[vyuSMForex]
AS
SELECT 
	 [intCurrencyExchangeRateTypeId]	= SMCERT.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCERT.[strCurrencyExchangeRateType]
	,[strDescription]					= SMCERT.[strDescription]	
	,[intFunctionalCurrencyId]			= (SELECT TOP 1 [intDefaultCurrencyId] FROM tblSMCompanyPreference)
	,[intFromCurrencyId]				= SMCER.[intFromCurrencyId]
	,[intToCurrencyId]					= SMCER.[intToCurrencyId]
	,[intCurrencyExchangeRateId]		= SMCER.[intCurrencyExchangeRateId]
	,[intCurrencyExchangeRateDetailId]	= SMCERD.[intCurrencyExchangeRateDetailId]
	,[dblRate]							= SMCERD.[dblRate]
	,[dtmValidFromDate]					= SMCERD.[dtmValidFromDate]
FROM
	tblSMCurrencyExchangeRateType SMCERT
INNER JOIN
	tblSMCurrencyExchangeRateDetail SMCERD
		ON SMCERT.[intCurrencyExchangeRateTypeId] = SMCERD.[intRateTypeId]
INNER JOIN
	tblSMCurrencyExchangeRate SMCER
		ON SMCERD.[intCurrencyExchangeRateId] = SMCER.[intCurrencyExchangeRateId]