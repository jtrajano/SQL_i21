CREATE FUNCTION [dbo].[fnCMGetForexRateFromCurrency]
(
	@intFromCurrencyId AS INT
	,@intToCurrencyId AS INT
	,@intForexRateTypeId AS INT
	,@dtmDate AS DATETIME
)
RETURNS NUMERIC(18 , 6)
AS 
BEGIN
	DECLARE 
		@dblRate NUMERIC(18, 6),
		@intCurrencyExchangeRateId INT = NULL

	SELECT TOP 1 
		@intCurrencyExchangeRateId = intCurrencyExchangeRateId 
	FROM tblSMCurrencyExchangeRate
	WHERE 
		intFromCurrencyId = @intFromCurrencyId
		AND intToCurrencyId = @intToCurrencyId
	ORDER BY intCurrencyExchangeRateId DESC

	IF (@intCurrencyExchangeRateId IS NOT NULL)
	BEGIN
		SELECT TOP 1 
			@dblRate = [dblRate]
		FROM tblSMCurrencyExchangeRateDetail
		WHERE 
			intCurrencyExchangeRateId = @intCurrencyExchangeRateId
			AND intRateTypeId = @intForexRateTypeId
			AND dbo.fnDateLessThanEquals(dtmValidFromDate, @dtmDate) = 1
		ORDER BY
			[dtmValidFromDate] DESC
	END
	ELSE
		SET @dblRate = 1

	RETURN CASE WHEN ISNULL(@dblRate, 0) > 0 THEN @dblRate ELSE 1 END
END