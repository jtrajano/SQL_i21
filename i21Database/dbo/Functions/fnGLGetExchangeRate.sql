CREATE FUNCTION [dbo].[fnGLGetExchangeRate]
(
	@intFromCurrencyId INT,
	@intCurrencyExchangeRateTypeId INT,
	@dtmDate DATETIME
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @dblRate NUMERIC(18,6)
	SELECT TOP 1 @dblRate = dblRate FROM vyuGLExchangeRate
	CROSS APPLY(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) tsp
	WHERE intFromCurrencyId = @intFromCurrencyId AND intToCurrencyId = tsp.intDefaultCurrencyId
	AND intCurrencyExchangeRateTypeId = @intCurrencyExchangeRateTypeId
	AND dtmValidFromDate<=@dtmDate
	ORDER BY dtmValidFromDate DESC
	RETURN ISNULL(@dblRate,0)
END