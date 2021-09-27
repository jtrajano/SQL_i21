﻿CREATE VIEW [dbo].[vyuCMBankTransferRateType]
AS
SELECT
	 [intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]
	,[strDescription]			
	,[intFunctionalCurrencyId]
	,[intFromCurrencyId]
	,[intToCurrencyId]		
	,[intCurrencyExchangeRateId]	
	,[intCurrencyExchangeRateDetailId]
	,[dblRate]				
	,[dtmValidFromDate]
FROM
	vyuSMForex
UNION
	SELECT 
	[intCurrencyExchangeRateTypeId]	= 99999
	,[strCurrencyExchangeRateType]		= 'Historic Rate'
	,[strDescription]					= 'GL Historic Rate'
	,[intFunctionalCurrencyId]			= (SELECT TOP 1 [intDefaultCurrencyId] FROM tblSMCompanyPreference)
	,[intFromCurrencyId]				= 0
	,[intToCurrencyId]					= 0
	,[intCurrencyExchangeRateId]		= 99999
	,[intCurrencyExchangeRateDetailId]	= 99999
	,[dblRate]							= NULL
	,[dtmValidFromDate]					= GETDATE()	
