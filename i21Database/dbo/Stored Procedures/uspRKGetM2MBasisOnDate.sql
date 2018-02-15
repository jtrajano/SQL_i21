CREATE PROC [dbo].[uspRKGetM2MBasisOnDate]
	 @intM2MBasisId INT,
	 @intCommodityId INT= NULL,
	 @strPricingType nvarchar(30),
	 @strItemIds nvarchar(max),
	 @strPeriodTos nvarchar(max)  ,
	 @strLocationIds nvarchar(max),
	 @strZoneIds nvarchar(max) 

AS


DECLARE @strEvaluationBy NVARCHAR(50)
		,@strEvaluationByZone NVARCHAR(50)

SELECT TOP 1
	 @strEvaluationBy =  strEvaluationBy
	,@strEvaluationByZone = strEvaluationByZone  
FROM tblRKCompanyPreference



IF @strEvaluationBy = 'Commodity'
BEGIN
	SET @strItemIds = ''
END

IF @strEvaluationByZone = 'Location'
BEGIN
	SET @strZoneIds = ''
END



SELECT bd.intM2MBasisDetailId, c.strCommodityCode,	i.strItemNo,		ca.strDescription as strOriginDest,		fm.strFutMarketName, '' as strFutureMonth,
		bd.strPeriodTo,		strLocationName,		strMarketZoneCode,		strCurrency,		b.strPricingType,
		strContractInventory,		strContractType,strUnitMeasure,
		bd.intCommodityId,		bd.intItemId, bd.strOriginDest,		bd.intFutureMarketId,		bd.intFutureMonthId,
		bd.intCompanyLocationId,		bd.intMarketZoneId,		bd.intCurrencyId,	bd.intPricingTypeId,		bd.strContractInventory,
		bd.intContractTypeId,		bd.dblCashOrFuture,		bd.dblBasisOrDiscount,		bd.intUnitMeasureId	,i.strMarketValuation ,0 as intConcurrencyId	
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
 and ISNULL(bd.intItemId,0) IN(select case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS  end as Item from [dbo].[fnSplitString](@strItemIds, ',')) --added this be able to filter by item (RM-739)
 and bd.strPeriodTo IN(select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](@strPeriodTos, ',')) --added this be able to filter by period to (RM-739)
 and ISNULL(bd.intCompanyLocationId,0) IN(select case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS end  from [dbo].[fnSplitString](@strLocationIds, ',')) --added this be able to filter by location to (RM-739)
 and ISNULL(bd.intMarketZoneId,0) IN(select case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS end  from [dbo].[fnSplitString](@strZoneIds, ',')) --added this be able to filter by zone to (RM-739)
order by i.strMarketValuation,fm.strFutMarketName,strCommodityCode,strItemNo,strLocationName, convert(datetime,'01 '+strPeriodTo)

