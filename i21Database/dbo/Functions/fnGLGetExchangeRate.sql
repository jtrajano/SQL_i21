CREATE FUNCTION [dbo].[fnGLGetExchangeRate]
(
	@intFromCurrencyId INT,
	@intToCurrencyId INT,
	@intCurrencyExchangeRateTypeId INT,
	@dtmDate DATETIME
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @dblRate NUMERIC(18,6)
	SELECT TOP 1 @dblRate = dblRate FROM vyuGLExchangeRate
	WHERE intFromCurrencyId = @intFromCurrencyId AND intToCurrencyId = @intToCurrencyId
	AND intCurrencyExchangeRateTypeId = @intCurrencyExchangeRateTypeId
	AND dtmValidFromDate<=@dtmDate
	ORDER BY dtmValidFromDate DESC
	RETURN ISNULL(@dblRate,0)
END
