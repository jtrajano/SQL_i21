CREATE FUNCTION [dbo].[fnRKConvertUOMCurrency]
(
	@IDType NVARCHAR(50),
	@FromUOMId INT,
	@ToUOMId INT,
	@ConvertCurrency BIT,
	@FromCurrencyId INT,
	@ToCurrencyId INT,
	@dblValue NUMERIC(26, 12),
	@intContractDetailId INT
)
RETURNS NUMERIC(26, 6)
AS
BEGIN
	DECLARE @FinalValue NUMERIC(26, 12)
		, @FromUOMRate NUMERIC(26, 12)
		, @ToUOMRate NUMERIC(26, 12)

	----------------------------------
	---------- @Type Values ----------
	----------------------------------
	-- 'ItemUOM'					--
	-- 'CommodityUOM'				--
	-- 'UOM'						--
	----------------------------------
	IF (@FromUOMId != @ToUOMId)
	BEGIN
		IF (@IDType = 'ItemUOM')
		BEGIN
			SELECT @FromUOMRate = dblUnitQty
			FROM tblICItemUOM
			WHERE intItemUOMId = @FromUOMId

			SELECT @ToUOMRate = dblUnitQty
			FROM tblICItemUOM
			WHERE intItemUOMId = @ToUOMId
		END
		ELSE IF (@IDType = 'CommodityUOM')
		BEGIN
			SELECT @FromUOMRate = dblUnitQty
			FROM tblICCommodityUnitMeasure
			WHERE intCommodityUnitMeasureId = @FromUOMId

			SELECT @ToUOMRate = dblUnitQty
			FROM tblICCommodityUnitMeasure
			WHERE intCommodityUnitMeasureId = @ToUOMId
		END
		ELSE IF (@IDType = 'UOM')
		BEGIN
			SELECT @FromUOMRate = dblConversionToStock
			FROM tblICUnitMeasureConversion
			WHERE intUnitMeasureId = @FromUOMId

			SELECT @ToUOMRate = dblConversionToStock
			FROM tblICUnitMeasureConversion
			WHERE intUnitMeasureId = @ToUOMId
		END

		IF (@FromUOMRate = @ToUOMRate)
		BEGIN			
			SET @FinalValue = @dblValue
		END
		ELSE IF (@FromUOMRate < @ToUOMRate)
		BEGIN
			SET @FinalValue = @dblValue * @FromUOMRate
		END
		ELSE IF (@FromUOMRate > @ToUOMRate)
		BEGIN
			SET @FinalValue = @dblValue / @FromUOMRate
		END

		IF (@ToUOMRate = @FromUOMRate)
		BEGIN
			SET @FinalValue = @FinalValue
		END
		ELSE IF (@ToUOMRate < @FromUOMRate)
		BEGIN
			SET @FinalValue = @FinalValue * @ToUOMRate
		END
		ELSE IF (@ToUOMRate > @FromUOMRate)
		BEGIN
			SET @FinalValue = @FinalValue / @ToUOMRate
		END
	END
	ELSE
	BEGIN
		SET @FinalValue = @dblValue
	END

	IF (@ConvertCurrency = 1)
	BEGIN
		DECLARE @SubFromCurrency BIT = 0
			, @SubToCurrency BIT = 0
			, @intCurrencyExchangeRateId INT
			, @intExchangeRateFromId INT
			, @intExchangeRateToId INT
			, @dblRate NUMERIC(26, 12)

		IF @intContractDetailId IS NOT NULL
		BEGIN
			SELECT @dblRate = dblRate
				, @intCurrencyExchangeRateId = intCurrencyExchangeRateId
			FROM tblCTContractDetail d
			JOIN tblICItemUOM PU ON PU.intItemUOMId = d.intPriceItemUOMId
			WHERE intContractDetailId = @intContractDetailId
		END
		ELSE
		BEGIN
			SET @dblRate = 1
		END

		IF (@intCurrencyExchangeRateId IS NULL)
		BEGIN
			SELECT TOP 1 @SubFromCurrency = 1
			FROM tblSMCurrency
			WHERE intCurrencyID = @FromCurrencyId AND ysnSubCurrency = 1

			SELECT TOP 1 @SubToCurrency = 1
			FROM tblSMCurrency WHERE intCurrencyID = @ToCurrencyId AND ysnSubCurrency = 1

			IF (@SubFromCurrency = 1 AND @SubToCurrency = 0)
			BEGIN
				SELECT @FinalValue = @FinalValue / intCent
					, @FromCurrencyId = intMainCurrencyId
				FROM tblSMCurrency WHERE intCurrencyID = @FromCurrencyId
			END
			ELSE IF (@SubFromCurrency = 0 AND @SubToCurrency = 1)
			BEGIN
				SELECT @FinalValue = @FinalValue * intCent
					, @ToCurrencyId = intMainCurrencyId
				FROM tblSMCurrency WHERE intCurrencyID = @ToCurrencyId
			END
		END

		SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
		FROM tblSMCurrencyExchangeRate
		WHERE intFromCurrencyId = @FromCurrencyId
			AND intToCurrencyId = @ToCurrencyId

		IF (ISNULL(@intCurrencyExchangeRateId, 0) = 0)
		BEGIN
			SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
			FROM tblSMCurrencyExchangeRate
			WHERE intFromCurrencyId = @ToCurrencyId
				AND intToCurrencyId = @FromCurrencyId
		END
		
		SELECT @intExchangeRateFromId = intFromCurrencyId
			, @intExchangeRateToId = intToCurrencyId
		FROM tblSMCurrencyExchangeRate
		WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId

		IF (@FromCurrencyId <> @ToCurrencyId)
		BEGIN
			IF (@intExchangeRateFromId = @FromCurrencyId)
			BEGIN
				IF (ISNULL(@dblRate, 0) <> 0)
				BEGIN
					SELECT @FinalValue = @FinalValue * @dblRate
				END
				ELSE
				BEGIN
					SELECT TOP 1 @FinalValue = @FinalValue * RD.dblRate
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE ER.intCurrencyExchangeRateId = @intCurrencyExchangeRateId
					ORDER BY RD.dtmValidFromDate DESC				
				END
			END
			ELSE
			BEGIN
				IF (ISNULL(@dblRate, 0) <> 0)
				BEGIN
					SELECT @FinalValue = @FinalValue * @dblRate
				END
				ELSE
				BEGIN
					SELECT TOP 1 @FinalValue = @FinalValue / RD.dblRate
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE ER.intCurrencyExchangeRateId = @intCurrencyExchangeRateId
					ORDER BY RD.dtmValidFromDate DESC
				END
			END
		END
	END

	RETURN @FinalValue;
END