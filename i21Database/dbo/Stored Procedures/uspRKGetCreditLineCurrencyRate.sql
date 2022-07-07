CREATE PROCEDURE [dbo].[uspRKGetCreditLineCurrencyRate]
	@intFromCurrencyId INT = NULL
	, @intToCurrencyId INT = NULL
AS
BEGIN

	SELECT TOP 1 dblRate
	FROM tblSMCurrencyExchangeRate er
	JOIN tblSMCurrencyExchangeRateDetail rd ON er.intCurrencyExchangeRateId = rd.intCurrencyExchangeRateId
	WHERE intFromCurrencyId = @intFromCurrencyId
	AND intToCurrencyId = @intToCurrencyId
	AND dtmValidFromDate <= GETDATE()
	ORDER BY dtmValidFromDate DESC

END