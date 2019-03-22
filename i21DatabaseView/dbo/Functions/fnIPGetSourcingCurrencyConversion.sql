CREATE FUNCTION [dbo].[fnIPGetSourcingCurrencyConversion] (
	@intContractDetailId INT
	,@intToCurrencyId INT
	,@Price NUMERIC(18, 6)
	)
RETURNS NUMERIC(38, 20)
AS
BEGIN
	DECLARE @dblResult NUMERIC(18, 6)
	DECLARE @intFromCurrencyId1 INT
	DECLARE @ysnSubCurrency BIT
	DECLARE @intFromCurrencyId INT
	DECLARE @intItemId INT
	DECLARE @intFromUom INT
	DECLARE @dblRate NUMERIC(18, 6)
	DECLARE @intCurrencyExchangeRateId INT
	DECLARE @intExchangeRateFromId INT
	DECLARE @intExchangeRateToId INT

	SELECT @intFromCurrencyId = intCurrencyId
		,@intItemId = d.intItemId
		,@intFromUom = PU.intUnitMeasureId
		,@dblRate = dblRate
		,@intCurrencyExchangeRateId = intCurrencyExchangeRateId
	FROM tblCTContractDetail d
	JOIN tblICItemUOM PU ON PU.intItemUOMId = d.intPriceItemUOMId
	WHERE intContractDetailId = @intContractDetailId

	IF (ISNULL(@intCurrencyExchangeRateId, 0) <> 0)
	BEGIN
		SELECT @intExchangeRateFromId = intFromCurrencyId
			,@intExchangeRateToId = intToCurrencyId
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
			,@intExchangeRateToId = intToCurrencyId
		FROM tblSMCurrencyExchangeRate
		WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId
	END

	SELECT @ysnSubCurrency = ysnSubCurrency
	FROM tblSMCurrency
	WHERE intCurrencyID = @intFromCurrencyId
		AND ysnSubCurrency = 1

	IF EXISTS (
			SELECT *
			FROM tblSMCurrency
			WHERE intCurrencyID = @intFromCurrencyId
				AND ysnSubCurrency = 1
			)
		SELECT @Price = @Price / 100

	IF EXISTS (
			SELECT *
			FROM tblSMCurrency
			WHERE intCurrencyID = @intFromCurrencyId
				AND ysnSubCurrency = 1
			)
	BEGIN
		SELECT @intFromCurrencyId = intMainCurrencyId
		FROM tblSMCurrency
		WHERE intCurrencyID = @intFromCurrencyId
	END

	IF (@intFromCurrencyId <> @intToCurrencyId)
	BEGIN
		IF (@intExchangeRateFromId = @intFromCurrencyId)
		BEGIN
			IF (isnull(@dblRate, 0) <> 0)
			BEGIN
				SELECT @dblResult = @Price * @dblRate
			END
			ELSE
			BEGIN
				SELECT TOP 1 @dblResult = @Price * RD.[dblRate]
				FROM tblSMCurrencyExchangeRate ER
				JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE ER.intCurrencyExchangeRateId = @intCurrencyExchangeRateId
				ORDER BY RD.dtmValidFromDate DESC
			END
		END
		ELSE
		BEGIN
			IF (isnull(@dblRate, 0) <> 0)
			BEGIN
				SELECT @dblResult = @Price / @dblRate
			END
			ELSE
			BEGIN
				SELECT TOP 1 @dblResult = @Price / RD.[dblRate]
				FROM tblSMCurrencyExchangeRate ER
				JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE ER.intCurrencyExchangeRateId = @intCurrencyExchangeRateId
				ORDER BY RD.dtmValidFromDate DESC
			END
		END
	END
	ELSE
		SELECT @dblResult = @Price

	RETURN @dblResult
END

