CREATE PROCEDURE [dbo].[uspRKGetCreditLineCurrencyRate]
	@intFromCurrencyId INT = NULL
	, @intToCurrencyId INT = NULL
AS
BEGIN	
	DECLARE @tempResult AS TABLE (
		dblRate NUMERIC(18,6)
	)

	IF @intFromCurrencyId <> @intToCurrencyId
	BEGIN
		SELECT TOP 1 dblRate
		FROM tblSMCurrencyExchangeRate er
		JOIN tblSMCurrencyExchangeRateDetail rd ON er.intCurrencyExchangeRateId = rd.intCurrencyExchangeRateId
		WHERE intFromCurrencyId = @intFromCurrencyId
		AND intToCurrencyId = @intToCurrencyId
		AND dtmValidFromDate <= GETDATE()
		ORDER BY dtmValidFromDate DESC
	END
	ELSE 
	BEGIN  
		INSERT INTO @tempResult
		SELECT 1

		IF EXISTS (SELECT dblRate FROM @tempResult)
		BEGIN
			SELECT dblRate FROM @tempResult
		END
	END	

END