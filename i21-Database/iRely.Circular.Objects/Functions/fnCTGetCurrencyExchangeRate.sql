CREATE FUNCTION [dbo].[fnCTGetCurrencyExchangeRate]
(
	@IntId		INT,
	@ysnCost	BIT = 0
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE @intCurrencyExchangeRateId INT,@dblRate NUMERIC(18,6),@intCurrencyId INT,
	@intCurrencyToConvertId INT,@intFromCurrencyId INT,@intToCurrencyId INT,@dblResult NUMERIC(18,6)
	
	IF @ysnCost = 0
	BEGIN
		SELECT	@intCurrencyExchangeRateId = intCurrencyExchangeRateId,
				@dblRate = 	dblRate,
				@intCurrencyId = intCurrencyId 
		FROM	tblCTContractDetail
		WHERE	intContractDetailId = @IntId
	END
	ELSE
	BEGIN
		SELECT	@dblRate = 	dblFX,
				@intCurrencyId = intCurrencyId 
		FROM	tblCTContractCost
		WHERE	intContractCostId = @IntId
	END
	
	SELECT	@intCurrencyToConvertId = intDefaultCurrencyId FROM tblSMCompanyPreference

	SELECT	@intFromCurrencyId = intFromCurrencyId, 
			@intToCurrencyId = intToCurrencyId
	FROM	tblSMCurrencyExchangeRate 
	WHERE	intCurrencyExchangeRateId = ISNULL(@intCurrencyExchangeRateId ,0)

	IF @intCurrencyId = @intCurrencyToConvertId
	BEGIN
		 SET @dblResult = 1
	END
	ELSE IF @ysnCost = 1 AND ISNULL(@dblRate,0) > 0
	BEGIN
		SET @dblResult = 1/@dblRate
	END
	ELSE IF @intCurrencyToConvertId = @intFromCurrencyId AND ISNULL(@dblRate,0) > 0
	BEGIN
		SELECT @dblResult = 1/@dblRate
	END
	ELSE IF @intCurrencyToConvertId = @intToCurrencyId AND ISNULL(@dblRate,0) > 0
	BEGIN
		SET @dblResult = @dblRate
	END
	ELSE
	BEGIN
		SELECT	TOP 1 @dblResult = 
				CASE	WHEN ER.intFromCurrencyId = @intCurrencyToConvertId  
						THEN 1/RD.[dblRate] 
						ELSE RD.[dblRate]
				END 
		FROM	tblSMCurrencyExchangeRate ER
		JOIN	tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
		WHERE	(ER.intFromCurrencyId = @intCurrencyId AND ER.intToCurrencyId = @intCurrencyToConvertId) 
		OR		(ER.intFromCurrencyId = @intCurrencyToConvertId AND ER.intToCurrencyId = @intCurrencyId)
		ORDER BY RD.dtmValidFromDate DESC
	END
	
	RETURN @dblResult
	
END