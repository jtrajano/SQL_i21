CREATE FUNCTION [dbo].[fnRKGetCurrencyConvertion] (
	@intFromCurrencyId INT
	, @intToCurrencyId INT
	,@intRateTypeId INT = NULL)

RETURNS NUMERIC(18, 6)

AS

BEGIN
	DECLARE @dblRate AS NUMERIC(18, 6)
	
	IF (@intFromCurrencyId<>@intToCurrencyId)
	BEGIN
		SELECT TOP 1 @dblRate = dblRate
		FROM tblSMCurrencyExchangeRate er
		JOIN tblSMCurrencyExchangeRateDetail rd ON er.intCurrencyExchangeRateId = rd.intCurrencyExchangeRateId
		WHERE intFromCurrencyId = @intFromCurrencyId AND intToCurrencyId = @intToCurrencyId
			AND dtmValidFromDate <= GETDATE()
			AND intRateTypeId = ISNULL(@intRateTypeId,intRateTypeId)
		ORDER BY dtmValidFromDate DESC
	END
	ELSE
	BEGIN
		SET @dblRate = 1
	END
	 
	RETURN @dblRate
END