CREATE VIEW [dbo].[vyuCMExchangeRateTypeCombo]
AS
	SELECT A.strCurrencyExchangeRateType, A.intCurrencyExchangeRateTypeId, B.[dblRate],dtmValidFromDate, B.[intFromCurrencyId]
	FROM tblSMCurrencyExchangeRateType A
	CROSS APPLY(
	SELECT TOP 1 [dblRate], dtmValidFromDate,[intFromCurrencyId] 
	FROM 
		[vyuSMForex] 
	WHERE 
		intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
		AND [intFunctionalCurrencyId] = [intToCurrencyId] 
		ORDER BY
		[dtmValidFromDate] DESC
	)B
	
GO

