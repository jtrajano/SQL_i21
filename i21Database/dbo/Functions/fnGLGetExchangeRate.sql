CREATE FUNCTION [dbo].[fnGLGetExchangeRate]
(
	@intFromCurrencyId INT,
	@intCurrencyExchangeRateTypeId INT,
	@dtmDate DATETIME
)
RETURNS @tbl TABLE
(
  dblRate NUMERIC(18,6)
)
AS
BEGIN
	DECLARE @dblRate NUMERIC(18,6)
	IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE intDefaultCurrencyId = @intFromCurrencyId)
		INSERT INTO @tbl SELECT 1
	ELSE
		INSERT INTO @tbl
		SELECT TOP 1 dblRate FROM vyuGLExchangeRate
		OUTER APPLY(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) tsp
		WHERE intFromCurrencyId = @intFromCurrencyId AND intToCurrencyId = tsp.intDefaultCurrencyId
		AND intCurrencyExchangeRateTypeId = @intCurrencyExchangeRateTypeId
		AND dtmValidFromDate<=@dtmDate
		ORDER BY dtmValidFromDate DESC
	RETURN
END

