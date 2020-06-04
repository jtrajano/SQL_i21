CREATE FUNCTION [dbo].[fnRKGetFutureAndBasisPrice] (
	 @intTicketType INT = 1	,-- 1- purchase. 2- sale.
	 @intCommodityId INT = NULL
	,@strSeqMonth NVARCHAR(10)	,--'Dec 2016'
	 @intSequenceTypeId INT,   -- 1.	‘01’ – Basis 2.	‘02’ – HTA   3. ‘03’ – DP    (PricingType Need to pass)
	 @intFutureMarketId INT= NULL  -- Contract Futre market Name
	,@intFutureMonthId INT= NULL -- Contract Future Month Id
	,@intLocationId INT = NULL
	,@intMarketZoneId INT = NULL
	,@dblBasisCost NUMERIC(18, 6)
	,@intItemId int = null
	,@intCurrencyId int = null --If null, go to company config functional currency
	)
RETURNS @returntable TABLE
(
	dblBasis NUMERIC(18,6),
	intBasisUOMId INT,
	dblSettlementPrice NUMERIC(18,6),
	intSettlementUOMId INT
)  
AS
BEGIN
	
	DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT	
	DECLARE @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT	
	DECLARE @intSettlementUOMId int
	DECLARE	@dblSettlementPrice NUMERIC(18,6)
	DECLARE @intDefaultCurrencyId INT
	DECLARE @strEvaluationBy NVARCHAR(50)
		
	SELECT @ysnEnterForwardCurveForMarketBasisDifferential = isnull(ysnEnterForwardCurveForMarketBasisDifferential, 0)
		  ,@ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = isnull(ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell,0)
		  ,@strEvaluationBy = strEvaluationBy
	FROM tblRKCompanyPreference

	SELECT @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	
	IF(isnull(@intFutureMonthId,0)=0 AND isnull(@intFutureMarketId,0)=0)
	BEGIN
		SELECT TOP 1 @intFutureMarketId=intFutureMarketId FROM tblRKCommodityMarketMapping where intCommodityId=@intCommodityId
				
		SELECT TOP 1 @intFutureMonthId=intFutureMonthId
			FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intFutureMarketId ORDER BY dtmSpotDate DESC ,intYear DESC
			
	END
	IF @intSequenceTypeId in(1,3)
	BEGIN
		
		IF @ysnEnterForwardCurveForMarketBasisDifferential = 0
		BEGIN
			INSERT INTO @returntable(dblBasis,intBasisUOMId)
			SELECT TOP 1  
			CASE WHEN @intCurrencyId IS NULL THEN
				CASE WHEN @intDefaultCurrencyId = bd.intCurrencyId THEN
					ISNULL(dblBasisOrDiscount, 0)
					ELSE
						--Convert
						ISNULL(dblBasisOrDiscount, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = bd.intCurrencyId 
							AND [intToCurrencyId] = @intDefaultCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)
				END
				WHEN @intCurrencyId = bd.intCurrencyId THEN
					ISNULL(dblBasisOrDiscount, 0)
				ELSE
					--Convert
						ISNULL(dblBasisOrDiscount, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = bd.intCurrencyId 
							AND [intToCurrencyId] = @intCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)
			 END AS dblBasisOrDiscount
			,isnull(intUnitMeasureId,0)
			FROM tblRKM2MBasis b
			JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
			WHERE bd.intItemId = @intItemId 
				AND isnull(bd.intCompanyLocationId, 0) = CASE WHEN  isnull(bd.intCompanyLocationId, 0) = 0 THEN  isnull(bd.intCompanyLocationId, 0) ELSE @intLocationId END --AND ISNULL(dblBasisOrDiscount, 0) <> 0 
				AND strContractInventory = 'Contract'
				AND isnull(bd.intMarketZoneId, 0) = CASE WHEN isnull(bd.intMarketZoneId, 0) = 0 THEN isnull(bd.intMarketZoneId, 0) ELSE @intMarketZoneId END
			ORDER BY dtmM2MBasisDate DESC	

		END
		ELSE IF @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 0 --Value 0 means that the intContractTypeId is set to null upon creation of Basis Entry, thus we don't need to filter it
		BEGIN
			INSERT INTO @returntable(dblBasis,intBasisUOMId)
			SELECT TOP 1 
			CASE WHEN @intCurrencyId IS NULL THEN
				CASE WHEN @intDefaultCurrencyId = bd.intCurrencyId THEN
					ISNULL(dblBasisOrDiscount, 0)
					ELSE
						--Convert
						ISNULL(dblBasisOrDiscount, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = bd.intCurrencyId 
							AND [intToCurrencyId] = @intDefaultCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)
				END
				WHEN @intCurrencyId = bd.intCurrencyId THEN
					ISNULL(dblBasisOrDiscount, 0)
				ELSE
					--Convert
						ISNULL(dblBasisOrDiscount, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = bd.intCurrencyId 
							AND [intToCurrencyId] = @intCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)
			 END AS dblBasisOrDiscount
			,isnull(intUnitMeasureId,0)
			FROM tblRKM2MBasis b
			JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
			WHERE intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END 
			AND isnull(bd.intItemId, 0) = CASE WHEN  isnull(bd.intItemId, 0) = 0 AND @strEvaluationBy = 'Commodity' THEN  isnull(bd.intItemId, 0) ELSE @intItemId END 
			AND strPeriodTo = @strSeqMonth 
			AND bd.intFutureMarketId = @intFutureMarketId 
			AND isnull(bd.intCompanyLocationId, 0) = CASE WHEN  isnull(bd.intCompanyLocationId, 0) = 0 THEN  isnull(bd.intCompanyLocationId, 0) ELSE @intLocationId END --AND ISNULL(dblBasisOrDiscount, 0) <> 0 
			AND strContractInventory = 'Contract'
			AND isnull(bd.intMarketZoneId, 0) = CASE WHEN isnull(bd.intMarketZoneId, 0) = 0 THEN isnull(bd.intMarketZoneId, 0) ELSE @intMarketZoneId END
			ORDER BY dtmM2MBasisDate DESC
		END
		ELSE
		BEGIN
			INSERT INTO @returntable(dblBasis,intBasisUOMId)
			SELECT TOP 1 
			CASE WHEN @intCurrencyId IS NULL THEN
				CASE WHEN @intDefaultCurrencyId = bd.intCurrencyId THEN
					ISNULL(dblBasisOrDiscount, 0)
					ELSE
						--Convert
						ISNULL(dblBasisOrDiscount, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = bd.intCurrencyId 
							AND [intToCurrencyId] = @intDefaultCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)
				END
				WHEN @intCurrencyId = bd.intCurrencyId THEN
					ISNULL(dblBasisOrDiscount, 0)
				ELSE
					--Convert
						ISNULL(dblBasisOrDiscount, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = bd.intCurrencyId 
							AND [intToCurrencyId] = @intCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)
			 END AS dblBasisOrDiscount
			,isnull(intUnitMeasureId,0)
			FROM tblRKM2MBasis b
			JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
			WHERE intContractTypeId = @intTicketType 
			AND intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END 
			AND isnull(bd.intItemId, 0) = CASE WHEN  isnull(bd.intItemId, 0) = 0 AND @strEvaluationBy = 'Commodity' THEN  isnull(bd.intItemId, 0) ELSE @intItemId END 
			AND strPeriodTo = @strSeqMonth 
			AND bd.intFutureMarketId = @intFutureMarketId 
			AND isnull(bd.intCompanyLocationId, 0) = CASE WHEN  isnull(bd.intCompanyLocationId, 0) = 0 THEN  isnull(bd.intCompanyLocationId, 0) ELSE @intLocationId END --AND ISNULL(dblBasisOrDiscount, 0) <> 0 
			AND strContractInventory = 'Contract'
			AND isnull(bd.intMarketZoneId, 0) = CASE WHEN isnull(bd.intMarketZoneId, 0) = 0 THEN isnull(bd.intMarketZoneId, 0) ELSE @intMarketZoneId END
			ORDER BY dtmM2MBasisDate DESC
			
		END
	END
	IF @intSequenceTypeId in(2,3)
	BEGIN			
		SELECT TOP 1  
		@dblSettlementPrice = (
		CASE WHEN @intCurrencyId IS NULL THEN
				CASE WHEN @intDefaultCurrencyId = m.intCurrencyId THEN
					isnull(dblLastSettle, 0) + isnull(@dblBasisCost,0)
					ELSE
						--Convert
						ISNULL((isnull(dblLastSettle, 0) * (SELECT TOP 1 
							[dblRate]
						FROM 
							[vyuSMForex] 
						WHERE 
							[intFromCurrencyId] = m.intCurrencyId 
							AND [intToCurrencyId] = @intDefaultCurrencyId 
							AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
						ORDER BY
							[dtmValidFromDate] DESC)),0) + isnull(@dblBasisCost,0)
				END
			WHEN @intCurrencyId = m.intCurrencyId THEN
				ISNULL(isnull(dblLastSettle, 0) + isnull(@dblBasisCost,0), 0)
			ELSE
				--Convert
					ISNULL((isnull(dblLastSettle, 0) * (SELECT TOP 1 
						[dblRate]
					FROM 
						[vyuSMForex] 
					WHERE 
						[intFromCurrencyId] = m.intCurrencyId 
						AND [intToCurrencyId] = @intCurrencyId 
						AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
					ORDER BY
						[dtmValidFromDate] DESC)),0) + isnull(@dblBasisCost,0)
			END)
		,@intSettlementUOMId=isnull(m.intUnitMeasureId,0) 
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKFutSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		INNER JOIN tblRKFutureMarket m ON sp.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblRKFuturesMonth fm ON mm.intFutureMonthId = fm.intFutureMonthId
		WHERE sp.intFutureMarketId = @intFutureMarketId AND fm.intFutureMonthId=@intFutureMonthId  AND dblLastSettle IS NOT NULL
		ORDER BY dtmPriceDate DESC
			IF NOT EXISTS(SELECT 1 FROM @returntable)
			BEGIN
				INSERT INTO @returntable(dblSettlementPrice,intSettlementUOMId) VALUES (@dblSettlementPrice,@intSettlementUOMId)
			END
			ELSE
			BEGIN
				UPDATE @returntable SET dblSettlementPrice=@dblSettlementPrice,intSettlementUOMId = @intSettlementUOMId
			END			
	END	
	RETURN 
END