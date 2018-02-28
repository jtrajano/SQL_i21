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
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN
DECLARE @calculatedValueBasis AS NUMERIC(18, 6);
	DECLARE @calculatedValueFuture AS NUMERIC(18, 6);
	DECLARE @calculatedValue AS NUMERIC(18, 6);
	DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT
		
	SELECT @ysnEnterForwardCurveForMarketBasisDifferential = isnull(ysnEnterForwardCurveForMarketBasisDifferential, 0)
	FROM tblRKCompanyPreference
	
	IF(isnull(@intFutureMonthId,0)=0 AND isnull(@intFutureMarketId,0)=0)
	BEGIN
		SELECT TOP 1 @intFutureMarketId=intFutureMarketId FROM tblRKCommodityMarketMapping where intCommodityId=@intCommodityId
				
		SELECT TOP 1 @intFutureMonthId=intFutureMonthId
			FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intFutureMarketId ORDER BY 1 DESC
			
	END
	IF @intSequenceTypeId in(1,3)
	BEGIN
		
		IF @ysnEnterForwardCurveForMarketBasisDifferential = 0
		BEGIN
		
			SELECT TOP 1 @calculatedValueBasis = ISNULL(dblBasisOrDiscount, 0)
			FROM tblRKM2MBasis b
			JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
			WHERE bd.intItemId = @intItemId AND isnull(bd.intCompanyLocationId, 0) = CASE WHEN isnull(@intLocationId, 0) = 0 THEN isnull(bd.intCompanyLocationId, 0) ELSE @intLocationId END AND ISNULL(dblBasisOrDiscount, 0) <> 0 
				AND strContractInventory = 'Contract'
				AND isnull(bd.intMarketZoneId, 0) = CASE WHEN isnull(@intMarketZoneId, 0) = 0 THEN isnull(bd.intMarketZoneId, 0) ELSE @intMarketZoneId END
			ORDER BY dtmM2MBasisDate DESC

			SET @calculatedValue=@calculatedValueBasis

		END

		BEGIN
		
			SELECT TOP 1 @calculatedValueBasis =ISNULL(dblBasisOrDiscount, 0) 
			FROM tblRKM2MBasis b
			JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
			WHERE intContractTypeId = @intTicketType AND intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END AND strPeriodTo = @strSeqMonth AND bd.intFutureMarketId = @intFutureMarketId AND isnull(bd.intCompanyLocationId, 0) = CASE WHEN isnull(@intLocationId, 0) = 0 THEN isnull(bd.intCompanyLocationId, 0) ELSE @intLocationId END AND ISNULL(dblBasisOrDiscount, 0) <> 0 AND strContractInventory = 'Contract'
			 AND isnull(bd.intMarketZoneId, 0) = CASE WHEN isnull(@intMarketZoneId, 0) = 0 THEN isnull(bd.intMarketZoneId, 0) ELSE @intMarketZoneId END
			 AND strContractInventory = 'Contract'
			ORDER BY dtmM2MBasisDate DESC
			set @calculatedValue=@calculatedValueBasis
		END
	END
	IF @intSequenceTypeId in(2,3)
	BEGIN			
	
			SELECT TOP 1 @calculatedValueFuture = isnull(dblLastSettle, 0) + isnull(@dblBasisCost,0)
			FROM tblRKFuturesSettlementPrice sp
			INNER JOIN tblRKFutSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
			INNER JOIN tblRKFutureMarket m ON sp.intFutureMarketId = m.intFutureMarketId
			INNER JOIN tblRKFuturesMonth fm ON mm.intFutureMonthId = fm.intFutureMonthId
			WHERE sp.intFutureMarketId = @intFutureMarketId AND fm.intFutureMonthId=@intFutureMonthId  AND dblLastSettle IS NOT NULL
			ORDER BY dtmPriceDate DESC
			SET @calculatedValue=@calculatedValueFuture		
	END
	IF @intSequenceTypeId = 3
	BEGIN
		SELECT @calculatedValue= isnull(@calculatedValueBasis,0)+isnull(@calculatedValueFuture,0)
	END
	
	RETURN @calculatedValue
END