CREATE FUNCTION [dbo].[fnRKGetSourcingCurrencyConversion] (
	@intContractDetailId INT
	, @intToCurrencyId INT
	, @Price NUMERIC(18, 6)
	, @intCostCurrencyId INT = NULL
	, @intFromBasisCurrencyId INT = NULL
	, @intFromMarketCurrency INT = NULL
) 
RETURNS NUMERIC(38, 20)

AS

BEGIN
	DECLARE @dblResult NUMERIC(18, 6)
		, @intFromCurrencyId1 INT
		, @intFromCurrencyId INT
		, @dblRate NUMERIC(18, 6)
		, @intCurrencyExchangeRateId INT
		, @intExchangeRateFromId INT
		, @intExchangeRateToId INT
	
	IF @intContractDetailId IS NOT NULL
	BEGIN
		SELECT @intFromCurrencyId = CASE WHEN ISNULL(@intFromBasisCurrencyId, 0) <> 0 THEN @intFromBasisCurrencyId
										WHEN ISNULL(@intFromMarketCurrency, 0)<>0 THEN @intFromMarketCurrency
										ELSE CASE WHEN ISNULL(@intCostCurrencyId, 0)<> 0 THEN @intCostCurrencyId ELSE intCurrencyId END END
			, @dblRate = dblRate
			, @intCurrencyExchangeRateId = intCurrencyExchangeRateId
		FROM tblCTContractDetail d
		JOIN tblICItemUOM PU ON PU.intItemUOMId = d.intPriceItemUOMId
		WHERE intContractDetailId = @intContractDetailId
	END
	ELSE
	BEGIN
		SET @intFromCurrencyId = @intCostCurrencyId
		SET @dblRate = 1
	END

	DECLARE @SubFromCurrency BIT = 0
		, @SubToCurrency BIT = 0

	SELECT TOP 1 @SubFromCurrency = 1
	FROM tblSMCurrency
	WHERE intCurrencyID = @intFromCurrencyId AND ysnSubCurrency = 1

	SELECT TOP 1 @SubToCurrency = 1
	FROM tblSMCurrency WHERE intCurrencyID = @intToCurrencyId AND ysnSubCurrency = 1

	IF (@SubFromCurrency = 1 AND @SubToCurrency = 0)
	BEGIN
		SELECT @Price = @Price / intCent
			, @intFromCurrencyId = intMainCurrencyId
		FROM tblSMCurrency WHERE intCurrencyID = @intFromCurrencyId
	END
	ELSE IF (@SubFromCurrency = 0 AND @SubToCurrency = 1)
	BEGIN
		SELECT @Price = @Price * intCent
			, @intToCurrencyId = intMainCurrencyId
		FROM tblSMCurrency WHERE intCurrencyID = @intToCurrencyId
	END

	IF (ISNULL(@intCurrencyExchangeRateId, 0) <> 0)
	BEGIN
		SELECT @intExchangeRateFromId = intFromCurrencyId
			, @intExchangeRateToId = intToCurrencyId
		FROM tblSMCurrencyExchangeRate
		WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
		FROM tblSMCurrencyExchangeRate
		WHERE intFromCurrencyId = @intFromCurrencyId
			AND intToCurrencyId = @intToCurrencyId
			
		IF (ISNULL(@intCurrencyExchangeRateId, 0) = 0)
		BEGIN
			SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
			FROM tblSMCurrencyExchangeRate
			WHERE intFromCurrencyId = @intToCurrencyId
				AND intToCurrencyId = @intFromCurrencyId
		END
		
		SELECT @intExchangeRateFromId = intFromCurrencyId
			, @intExchangeRateToId = intToCurrencyId
		FROM tblSMCurrencyExchangeRate
		WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId
	END
	
	IF (@intFromCurrencyId <> @intToCurrencyId)
	BEGIN
		IF (@intExchangeRateFromId = @intFromCurrencyId)
		BEGIN
			IF (ISNULL(@dblRate, 0) <> 0)
			BEGIN
				SELECT @dblResult = @Price * @dblRate
			END
			ELSE
			BEGIN
				SELECT TOP 1 @dblResult = @Price * RD.dblRate
				FROM tblSMCurrencyExchangeRate ER
				JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE ER.intCurrencyExchangeRateId = @intCurrencyExchangeRateId
				ORDER BY RD.dtmValidFromDate DESC
			END
		END
		ELSE
		BEGIN
			IF (ISNULL(@dblRate, 0)<> 0)
			BEGIN
				SELECT @dblResult = @Price / @dblRate
			END
			ELSE
			BEGIN
				SELECT TOP 1 @dblResult = @Price / RD.dblRate
				FROM tblSMCurrencyExchangeRate ER
				JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE ER.intCurrencyExchangeRateId = @intCurrencyExchangeRateId
				ORDER BY RD.dtmValidFromDate DESC
			END
		END
	END
	ELSE
	BEGIN
		SELECT @dblResult = @Price
	END
	RETURN @dblResult	
END