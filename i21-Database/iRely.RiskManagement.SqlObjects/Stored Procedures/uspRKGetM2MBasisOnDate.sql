﻿CREATE PROC [dbo].[uspRKGetM2MBasisOnDate]
		@intM2MBasisId INT,
		@intFutureSettlementPriceId int = null,
        @intQuantityUOMId int = null,
        @intPriceUOMId int = null,
        @intCurrencyUOMId int= null,
        @dtmTransactionDateUpTo datetime= null,
        @strRateType nvarchar(200)= null,
		@strPricingType nvarchar(50),
        @intCommodityId int=Null,
        @intLocationId int= null,
        @intMarketZoneId int= null

AS
	DECLARE @#tempInquiryTransaction TABLE (
							intRowNum INT,
							intConcurrencyId INT,	
							intContractHeaderId INT,	
							intContractDetailId INT,	
							strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							intEntityId INT,
							intFutureMarketId INT,
							strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS,	
							intFutureMonthId INT,
							strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							dblOpenQty NUMERIC(24, 10),
							strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							intCommodityId INT,
							intItemId INT,	
							strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,	
							strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS,		
							strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
							strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							intPricingTypeId INT,
							strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							dblContractRatio NUMERIC(24, 10), 
							dblContractBasis NUMERIC(24, 10),
							dblFutures NUMERIC(24, 10),
							dblCash NUMERIC(24, 10), 
							dblCosts NUMERIC(24, 10),
							dblMarketBasis NUMERIC(24, 10), 
							dblMarketRatio NUMERIC(24, 10), 
							dblFuturePrice NUMERIC(24, 10),
							intContractTypeId INT,
							dblAdjustedContractPrice NUMERIC(24, 10),
							dblCashPrice NUMERIC(24, 10), 
							dblMarketPrice NUMERIC(24, 10),
							dblResultBasis NUMERIC(24, 10),
							dblResultCash NUMERIC(24, 10),
							dblContractPrice NUMERIC(24, 10)
							,intQuantityUOMId INT
							,intCommodityUnitMeasureId INT
							,intPriceUOMId INT
							,intCent int
							,dtmPlannedAvailabilityDate datetime
							,dblPricedQty numeric(24,10),dblUnPricedQty numeric(24,10)
							,dblPricedAmount numeric(24,10)
							,intCompanyLocationId int
							,intMarketZoneId int 
							,strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
							,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
							,dblResult NUMERIC(24, 10)
							,dblMarketFuturesResult NUMERIC(24, 10)
							,dblResultRatio NUMERIC(24, 10)
						)


INSERT INTO @#tempInquiryTransaction 
exec uspRKM2MInquiryTransaction 
	 @intM2MBasisId= @intM2MBasisId
	,@intFutureSettlementPriceId= @intFutureSettlementPriceId
	,@intQuantityUOMId= @intQuantityUOMId
	,@intPriceUOMId= @intPriceUOMId
	,@intCurrencyUOMId= @intCurrencyUOMId
	,@dtmTransactionDateUpTo= @dtmTransactionDateUpTo
	,@strRateType=@strRateType
	,@intCommodityId= @intCommodityId
	,@intLocationId= @intLocationId
	,@intMarketZoneId= @intMarketZoneId 


DECLARE
		  @strItemIds nvarchar(max)
		 ,@strPeriodTos nvarchar(max) 
		 ,@strLocationIds nvarchar(max)
		 ,@strZoneIds nvarchar(max) 

	--Get the unique items from transactions
	SELECT @strItemIds = COALESCE(@strItemIds+',' ,'') + ISNULL(intItemId,'') FROM(
		SELECT DISTINCT  CASE WHEN intItemId = NULL THEN '' ELSE CONVERT(NVARCHAR(50),intItemId) END as intItemId FROM @#tempInquiryTransaction
	) tbl
	
	SELECT @strPeriodTos = COALESCE(@strPeriodTos+',' ,'') + CONVERT(NVARCHAR(50),strPeriodTo) FROM(
		SELECT DISTINCT strPeriodTo FROM @#tempInquiryTransaction
	) tbl

	SELECT @strLocationIds = COALESCE(@strLocationIds+',' ,'') + ISNULL(intCompanyLocationId,'') FROM(
		SELECT DISTINCT  CASE WHEN intCompanyLocationId = NULL THEN '' ELSE CONVERT(NVARCHAR(50),intCompanyLocationId) END as intCompanyLocationId FROM @#tempInquiryTransaction
	) tbl

	SELECT @strZoneIds = COALESCE(@strZoneIds+',' ,'') + ISNULL(intMarketZoneId,'') FROM(
		SELECT DISTINCT  CASE WHEN intMarketZoneId = NULL THEN '' ELSE CONVERT(NVARCHAR(50),intMarketZoneId) END as intMarketZoneId FROM @#tempInquiryTransaction
	) tbl


DECLARE @strEvaluationBy NVARCHAR(50)
		,@strEvaluationByZone NVARCHAR(50)
		,@ysnEnterForwardCurveForMarketBasisDifferential BIT

SELECT TOP 1
	 @strEvaluationBy =  strEvaluationBy
	,@strEvaluationByZone = strEvaluationByZone  
	,@ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
FROM tblRKCompanyPreference



IF @strEvaluationBy = 'Commodity'
BEGIN
	SET @strItemIds = ''
END

IF @strEvaluationByZone = 'Location'
BEGIN
	SET @strZoneIds = ''
END

IF @strEvaluationByZone = 'Company'
BEGIN
	SET @strZoneIds = ''
	SET @strLocationIds = ''
END

IF @ysnEnterForwardCurveForMarketBasisDifferential = 0
BEGIN
	SET @strPeriodTos = ''
END


SELECT 
	 bd.intM2MBasisDetailId
	,c.strCommodityCode
	,i.strItemNo
	,ca.strDescription as strOriginDest
	,fm.strFutMarketName
	,'' as strFutureMonth
	,bd.strPeriodTo
	,strLocationName
	,strMarketZoneCode
	,strCurrency
	,b.strPricingType
	,strContractInventory
	,strContractType
	,strUnitMeasure
	,bd.intCommodityId
	,bd.intItemId
	,bd.intFutureMarketId
	,bd.intFutureMonthId
	,bd.intCompanyLocationId
	,bd.intMarketZoneId
	,bd.intCurrencyId
	,bd.intPricingTypeId
	,bd.intContractTypeId
	,bd.dblCashOrFuture
	,bd.dblBasisOrDiscount
	,bd.dblRatio
	,bd.intUnitMeasureId
	,i.strMarketValuation
	,0 as intConcurrencyId	
FROM tblRKM2MBasis b
JOIN tblRKM2MBasisDetail bd on b.intM2MBasisId=bd.intM2MBasisId
LEFT JOIN tblICCommodity c on c.intCommodityId=bd.intCommodityId
LEFT JOIN tblICItem i on i.intItemId=bd.intItemId	
LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = bd.intFutureMarketId
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = bd.intCompanyLocationId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = bd.intCurrencyId
LEFT JOIN tblCTPricingType pt on pt.intPricingTypeId=bd.intPricingTypeId
LEFT JOIN tblCTContractType ct on ct.intContractTypeId=bd.intContractTypeId
LEFT JOIN tblARMarketZone mz on mz.intMarketZoneId=bd.intMarketZoneId
LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=bd.intUnitMeasureId
WHERE b.intM2MBasisId= @intM2MBasisId
 and  c.intCommodityId=case when isnull(@intCommodityId,0) = 0 then c.intCommodityId else @intCommodityId end 
 and b.strPricingType = @strPricingType
 and ISNULL(bd.intItemId,0) IN(select case when @strItemIds = '' then ISNULL(bd.intItemId,0) else case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS  end end as Item from [dbo].[fnSplitString](@strItemIds, ',')) --added this be able to filter by item (RM-739)
 and ISNULL(bd.strPeriodTo,'') IN(select case when @strPeriodTos = '' then ISNULL(bd.strPeriodTo,'') else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS end from [dbo].[fnSplitString](@strPeriodTos, ',')) --added this be able to filter by period to (RM-739)
 and ISNULL(bd.intCompanyLocationId,0) IN(select case when @strLocationIds = '' then ISNULL(bd.intCompanyLocationId,0) else case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS  end end as Item from [dbo].[fnSplitString](@strLocationIds, ',')) --added this be able to filter by item (RM-739)
 and ISNULL(bd.intMarketZoneId,0) IN(select case when @strZoneIds = '' then ISNULL(bd.intMarketZoneId,0) else case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS  end end as Item from [dbo].[fnSplitString](@strZoneIds, ',')) --added this be able to filter by item (RM-739)
 or
 ( bd.strContractInventory = 'Inventory' and b.intM2MBasisId= @intM2MBasisId
	and  c.intCommodityId=case when isnull(@intCommodityId,0) = 0 then c.intCommodityId else @intCommodityId end 
	and b.strPricingType = @strPricingType
 ) 
order by i.strMarketValuation,fm.strFutMarketName,strCommodityCode,strItemNo,strLocationName, convert(datetime,'01 '+strPeriodTo)
