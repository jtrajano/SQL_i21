﻿CREATE FUNCTION [dbo].[fnRKGetSequencePrice] 
(
		 @intContractDetailId INT
		,@dblSettlementPrice NUMERIC(24, 6) = NULL
)
RETURNS NUMERIC(24, 6)
AS
BEGIN
	DECLARE
		 @intPriceFixationId INT
		,@intPricingTypeId INT
		,@dblWtdAvg NUMERIC(18, 6)
		,@dblLotsFixed NUMERIC(18, 6)
		,@dbldblNoOfLots NUMERIC(18, 6)
		,@intFutureMarketId INT
		,@intFutureMonthId INT
		,@dblSeqPrice NUMERIC(18, 6)
		,@dblBasis NUMERIC(18, 6)
		,@ysnUseFXPrice BIT
		,@dblRate NUMERIC(18, 6)
		,@intFXPriceUOMId INT
		,@intExchangeRateId INT
		,@ysnSubCurrency BIT
		,@intMainCurrencyId INT
		,@intPriceItemUOMId INT
		,@ysnValidFX BIT = 0
		,@intItemId  INT
		,@intFutureMarketUnitMeasureId INT
		,@intBasisUnitMeasureId INT

	SELECT @intPricingTypeId			= CD.intPricingTypeId
		,@dbldblNoOfLots				= CD.dblNoOfLots
		,@intFutureMarketId				= CD.intFutureMarketId
		,@intFutureMonthId				= CD.intFutureMonthId
		,@dblBasis						= CD.dblBasis
		,@intItemId						= CD.intItemId
		,@intFutureMarketUnitMeasureId  = Market.intUnitMeasureId
		,@intBasisUnitMeasureId			= BASISUOM.intUnitMeasureId
	FROM tblCTContractDetail CD
	LEFT JOIN tblRKFutureMarket Market    ON  Market.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblICItemUOM	    BASISUOM  ON  BASISUOM.intItemUOMId	   = CD.intBasisUOMId
	WHERE CD.intContractDetailId = @intContractDetailId

	SELECT @intPriceFixationId = intPriceFixationId
		,@dblLotsFixed = dblLotsFixed
	FROM tblCTPriceFixation
	WHERE intContractDetailId = @intContractDetailId

	SELECT @ysnSubCurrency = CY.ysnSubCurrency
		,@dblRate = CD.dblRate
		,@intFXPriceUOMId = CD.intFXPriceUOMId
		,@intExchangeRateId = CD.intCurrencyExchangeRateId
		,@ysnUseFXPrice = ysnUseFXPrice
		,@intMainCurrencyId = ISNULL(CY.intMainCurrencyId, CD.intCurrencyId)
		,@intPriceItemUOMId = ISNULL(CD.intPriceItemUOMId, CD.intAdjItemUOMId)
	FROM tblCTContractDetail CD
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CD.intCurrencyId
	WHERE intContractDetailId = @intContractDetailId

	IF ISNULL(@ysnUseFXPrice, 0) = 1
				AND @intExchangeRateId IS NOT NULL
				AND @dblRate IS NOT NULL
				AND @intFXPriceUOMId IS NOT NULL
	BEGIN
		SET @ysnValidFX = 1
	END

	IF @intPricingTypeId IN (
			1
			,6
			)
	BEGIN
		SELECT @dblSeqPrice = dblSeqPrice
		FROM dbo.fnRKGetAdditionalColumnForDetailView(@intContractDetailId)
	END
	ELSE IF @intPricingTypeId = 2
	BEGIN
		IF @intPriceFixationId IS NOT NULL
		BEGIN
			SELECT @dblWtdAvg = SUM(dblNoOfLots * dblFutures)
			FROM tblCTPriceFixationDetail
			WHERE intPriceFixationId = @intPriceFixationId

			IF @dblSettlementPrice IS NULL
			BEGIN
					SELECT @dblSeqPrice = ((@dbldblNoOfLots - @dblLotsFixed) * dbo.fnRKGetLatestClosingPrice(@intFutureMarketId, @intFutureMonthId, GETDATE()) + @dblWtdAvg) / @dbldblNoOfLots
			END
			ELSE
			BEGIN
					SELECT @dblSeqPrice = ((@dbldblNoOfLots - @dblLotsFixed) * @dblSettlementPrice + @dblWtdAvg) / @dbldblNoOfLots
			END

			SELECT @dblSeqPrice = @dblSeqPrice + @dblBasis

			IF @ysnValidFX = 1
			BEGIN
				IF EXISTS (SELECT TOP 1 1 FROM tblSMCurrencyExchangeRate
							WHERE intCurrencyExchangeRateId = @intExchangeRateId
							AND intToCurrencyId = @intMainCurrencyId
						)
				BEGIN
					SELECT @dblRate = 1 / CASE 
							WHEN ISNULL(@dblRate, 0) = 0
								THEN 1
							ELSE @dblRate
							END
				END

				SELECT @dblSeqPrice = dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId, @intPriceItemUOMId, CASE 
							WHEN @ysnSubCurrency = 1
								THEN @dblSeqPrice / 100
							ELSE @dblSeqPrice
							END) * @dblRate
			END
		END
		ELSE
		BEGIN
			IF @dblSettlementPrice IS NULL
				SELECT @dblSeqPrice = dbo.fnRKGetLatestClosingPrice(@intFutureMarketId,@intFutureMonthId,GETDATE()) + @dblBasis
			ELSE 
				SELECT @dblSeqPrice = @dblSettlementPrice + dbo.fnGRConvertQuantityToTargetItemUOM(@intItemId,@intFutureMarketUnitMeasureId,@intBasisUnitMeasureId,@dblBasis)

			SELECT @dblSeqPrice = CASE 
								  WHEN @ysnSubCurrency = 1 AND @ysnValidFX = 1
									 THEN @dblSeqPrice / 100
								  ELSE @dblSeqPrice
								  END
		END
	END

	RETURN @dblSeqPrice
END
