﻿CREATE FUNCTION [dbo].[fnGetForexRate]
(
	 @TransactionDate	DATETIME 
	,@CurrencyId		INT
	,@ForexRateTypeId	INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN


DECLARE @ForexRate NUMERIC(18,6)
SET @ForexRate = CAST(1 AS NUMERIC(18,6))

DECLARE @FunctionalCurrencyId INT

SET @ForexRate = ISNULL((SELECT TOP 1 [dblRate] FROM [vyuSMForex] WHERE [intFromCurrencyId] = @CurrencyId AND [intCurrencyExchangeRateTypeId] = @ForexRateTypeId AND [intFunctionalCurrencyId] = [intToCurrencyId] AND CAST(@TransactionDate AS DATE) > CAST([dtmValidFromDate] AS DATE) ORDER BY [dtmValidFromDate]), CAST(1 AS NUMERIC(18,6)))

RETURN @ForexRate;

END