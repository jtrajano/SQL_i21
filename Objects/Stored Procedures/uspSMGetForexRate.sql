CREATE PROCEDURE [dbo].[uspSMGetForexRate]
	 @TransactionDate	DATETIME
	,@CurrencyId		INT
	,@ForexRateTypeId	INT
	,@ForexRate			NUMERIC(18,6)	= 1 OUTPUT
	,@ForexRateDetailId	INT				= NULL OUTPUT
AS	

SELECT 
	@ForexRate			=	[dblRate]
	,@ForexRateDetailId	=	[intCurrencyExchangeRateDetailId] 
FROM 
	[vyuSMForex] 
WHERE 
	[intFromCurrencyId] = @CurrencyId 
	AND [intCurrencyExchangeRateTypeId] = @ForexRateTypeId 
	AND [intFunctionalCurrencyId] = [intToCurrencyId] 
	AND CAST(@TransactionDate AS DATE) > CAST([dtmValidFromDate] AS DATE) 
ORDER BY
	[dtmValidFromDate]