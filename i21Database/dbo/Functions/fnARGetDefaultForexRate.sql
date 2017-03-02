CREATE FUNCTION [dbo].[fnARGetDefaultForexRate]
(
	 @TransactionDate	DATETIME 
	,@CurrencyId		INT
	,@ForexRateTypeId	INT
)
RETURNS @returntable TABLE
(
	 [intCurrencyExchangeRateTypeId]	INT
	,[strCurrencyExchangeRateType]		NVARCHAR(20)
	,[intCurrencyExchangeRateId]		INT
	,[dblCurrencyExchangeRate]			NUMERIC(18,6)	
)
AS
BEGIN

	IF ISNULL(@ForexRateTypeId, 0) = 0
		SET @ForexRateTypeId = (SELECT TOP 1 [intAccountsReceivableRateTypeId] FROM tblSMMultiCurrency ORDER BY [intMultiCurrencyId])
	
	INSERT @returntable(
		 [intCurrencyExchangeRateTypeId]
		,[strCurrencyExchangeRateType]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
	)
	SELECT TOP 1
		 [intCurrencyExchangeRateTypeId]	= [intCurrencyExchangeRateTypeId]
		,[strCurrencyExchangeRateType]		= [strCurrencyExchangeRateType]
		,[intCurrencyExchangeRateId]		= [intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]			= [dblRate]
	FROM 
		vyuSMForex
	WHERE 
		[intFromCurrencyId] = @CurrencyId 
		AND [intCurrencyExchangeRateTypeId] = @ForexRateTypeId 
		AND [intFunctionalCurrencyId] = [intToCurrencyId] 
		AND CAST(@TransactionDate AS DATE) >= CAST([dtmValidFromDate] AS DATE) 
	ORDER BY
		[dtmValidFromDate]
		
	RETURN
END
