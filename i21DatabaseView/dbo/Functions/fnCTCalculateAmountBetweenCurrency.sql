CREATE FUNCTION [dbo].[fnCTCalculateAmountBetweenCurrency]
(
	@intFromCurrencyId		INT,
	@intToCurrencyId		INT,
	@dblAmount				NUMERIC(24,6),
	@ysnToDefaultCurrency	BIT = 0
)
RETURNS NUMERIC(24,6)
AS 
BEGIN 
	IF @ysnToDefaultCurrency = 1 AND ISNULL(@intToCurrencyId,0) = 0
	BEGIN
		SELECT TOP 1 @intToCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	END

	IF EXISTS(SELECT * FROM tblSMCurrency WHERE intCurrencyID = @intFromCurrencyId AND ysnSubCurrency = 1) 
	BEGIN
		IF EXISTS(SELECT * FROM tblSMCurrency WHERE intCurrencyID = @intFromCurrencyId AND intMainCurrencyId = @intToCurrencyId)
			RETURN @dblAmount/100
		
		SELECT @intFromCurrencyId = intMainCurrencyId,@dblAmount = @dblAmount/100 FROM tblSMCurrency WHERE intCurrencyID = @intFromCurrencyId
			
	END

	IF EXISTS(SELECT * FROM tblSMCurrency WHERE intCurrencyID = @intToCurrencyId AND ysnSubCurrency = 1) 
	BEGIN
		IF EXISTS(SELECT * FROM tblSMCurrency WHERE intCurrencyID = @intToCurrencyId AND intMainCurrencyId = @intFromCurrencyId)
			RETURN @dblAmount*100
		
		SELECT @intToCurrencyId = intMainCurrencyId,@dblAmount = @dblAmount*100 FROM tblSMCurrency WHERE intCurrencyID = @intToCurrencyId
			
	END

	SELECT	TOP 1 @dblAmount = @dblAmount *
				CASE	WHEN ER.intFromCurrencyId = @intToCurrencyId  
						THEN 1/RD.[dblRate] 
						ELSE RD.[dblRate]
			END 
	FROM	tblSMCurrencyExchangeRate ER
	JOIN	tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
	WHERE	(ER.intFromCurrencyId = @intFromCurrencyId AND ER.intToCurrencyId = @intToCurrencyId) 
	OR		(ER.intFromCurrencyId = @intToCurrencyId AND ER.intToCurrencyId = @intFromCurrencyId)
	ORDER BY RD.dtmValidFromDate DESC
	
	RETURN @dblAmount
	
END
