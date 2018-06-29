CREATE PROC uspRKGetM2MBasis   
   
  @strCopyData nvarchar(50)= NULL  
AS  
IF ISNULL(@strCopyData,'')<>''  
BEGIN  
 DECLARE @dtmCopyData datetime  
 DECLARE @intM2MBasisId int   
 SET @dtmCopyData = convert(datetime,@strCopyData)  
 SELECT @intM2MBasisId = intM2MBasisId FROM tblRKM2MBasis where dtmM2MBasisDate= @dtmCopyData  
   
END  
  
DECLARE @ysnIncludeInventoryM2M bit,  
  @ysnIncludeBasisDifferentialsInResults bit,  
  @ysnValueBasisAndDPDeliveries bit,  
  @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell bit,  
  @ysnEnterForwardCurveForMarketBasisDifferential bit,    
  @strEvaluationBy nvarchar(50),  
  @strEvaluationByZone nvarchar(50)  
    
SELECT TOP 1 @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M,  
    @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell,  
    @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential,      
    @strEvaluationBy =  strEvaluationBy,  
    @strEvaluationByZone =  strEvaluationByZone   
FROM tblRKCompanyPreference           
  
 DECLARE @tempBasis TABLE(  
     strCommodityCode nvarchar(50)  
 ,strItemNo nvarchar(50)  
 ,strOriginDest nvarchar(50)  
 ,strFutMarketName nvarchar(50)  
 ,strFutureMonth nvarchar(50)  
 ,strPeriodTo nvarchar(50) COLLATE Latin1_General_CI_AS  
 ,strLocationName nvarchar(50)  
 ,strMarketZoneCode nvarchar(50)  
 ,strCurrency nvarchar(50)  
 ,strPricingType nvarchar(50)  
 ,strContractInventory nvarchar(50)  
 ,strContractType nvarchar(50)  
 ,dblCashOrFuture numeric(16,10)  
 ,dblBasisOrDiscount numeric(16,10)  
 ,strUnitMeasure nvarchar(50)  
 ,intCommodityId int  
 ,intItemId int  
 ,intOriginId int  
 ,intFutureMarketId int  
 ,intFutureMonthId int  
 ,intCompanyLocationId int  
 ,intMarketZoneId int  
 ,intCurrencyId int  
 ,intPricingTypeId int  
 ,intContractTypeId int  
 ,intUnitMeasureId  int  
 ,intConcurrencyId int
 ,strMarketValuation nvarchar(250)  
  )  
  
IF (@strEvaluationBy='Commodity')  
BEGIN  
 IF (@ysnIncludeInventoryM2M = 0)  
   BEGIN  
     DELETE FROM @tempBasis  
     INSERT INTO @tempBasis  
      SELECT DISTINCT strCommodityCode  
          ,'' strItemNo  
          ,'' strOriginDest  
          ,strFutMarketName  
          ,'' strFutureMonth  
          ,CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential=1 THEN strPeriodTo else NULL end as strPeriodTo  
          ,CASE WHEN @strEvaluationByZone='Location' THEN strLocationName else NULL end as strLocationName  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN strMarketZoneCode else NULL end as strMarketZoneCode  
          ,strCurrency  
          ,'' strPricingType  
          ,strContractInventory  
          ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN strContractType else NULL end as strContractType  
          ,dblCashOrFuture  
          ,dblBasisOrDiscount  
          ,strUnitMeasure  
          ,intCommodityId    
          ,NULL intItemId  
          ,NULL intOriginId  
          ,intFutureMarketId  
          ,NULL intFutureMonthId  
          ,CASE WHEN @strEvaluationByZone='Location' THEN intCompanyLocationId else NULL end as intCompanyLocationId  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN intMarketZoneId else NULL end as intMarketZoneId  
          ,intCurrencyId  
          ,NULL intPricingTypeId  
           ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN intContractTypeId else NULL end as intContractTypeId  
          ,intUnitMeasureId  
          ,intConcurrencyId,isnull(strMarketValuation,'') strMarketValuation                        
      FROM vyuRKGetM2MBasis WHERE strContractInventory <>'Inventory'  
   END  
   ELSE IF (@ysnIncludeInventoryM2M = 1)  
   BEGIN  
     DELETE FROM @tempBasis  
     INSERT INTO @tempBasis  
       SELECT DISTINCT strCommodityCode  
          ,'' strItemNo  
          ,'' strOriginDest  
          ,strFutMarketName  
          ,'' strFutureMonth  
          ,CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential=1 THEN strPeriodTo else NULL end as strPeriodTo  
          ,CASE WHEN @strEvaluationByZone='Location' THEN strLocationName else NULL end as strLocationName  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN strMarketZoneCode else NULL end as strMarketZoneCode  
          ,strCurrency  
          ,'' strPricingType  
          ,strContractInventory  
          ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN strContractType else NULL end as strContractType  
          ,dblCashOrFuture  
          ,dblBasisOrDiscount  
          ,strUnitMeasure  
          ,intCommodityId    
          ,NULL intItemId  
          ,NULL intOriginId  
          ,intFutureMarketId  
          ,NULL intFutureMonthId  
          ,CASE WHEN @strEvaluationByZone='Location' THEN intCompanyLocationId else NULL end as intCompanyLocationId  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN intMarketZoneId else NULL end as intMarketZoneId  
          ,intCurrencyId  
          ,NULL intPricingTypeId  
           ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN intContractTypeId else NULL end as intContractTypeId  
          ,intUnitMeasureId  
          ,intConcurrencyId,isnull(strMarketValuation,'') strMarketValuation              
      FROM vyuRKGetM2MBasis            
   END  
   
 IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null  
  BEGIN  
   UPDATE a   
   SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount  
   FROM @tempBasis a   
    JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId  
    AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0)   
    and isnull(a.intMarketZoneId,0)=isnull(b.intMarketZoneId,0)  
    AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0)   
    and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)  
    and isnull(a.strPeriodTo,0)=isnull(b.strPeriodTo,0)  
     and isnull(a.intContractTypeId,0)=isnull(b.intContractTypeId,0)  
   WHERE b.intM2MBasisId=@intM2MBasisId      
  END  
END  
  
ELSE IF(@strEvaluationBy='Item')  
BEGIN  
 IF (@ysnIncludeInventoryM2M = 0)  
   BEGIN  
     DELETE FROM @tempBasis  
     INSERT INTO @tempBasis  
      SELECT DISTINCT strCommodityCode  
          ,strItemNo  
          ,strOriginDest  
          ,strFutMarketName  
          ,'' strFutureMonth  
          ,CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential=1 THEN strPeriodTo else NULL end as strPeriodTo  
          ,CASE WHEN @strEvaluationByZone='Location' THEN strLocationName else NULL end as strLocationName  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN strMarketZoneCode else NULL end as strMarketZoneCode  
          ,strCurrency  
          ,'' strPricingType  
          ,strContractInventory  
          ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN strContractType else NULL end as strContractType  
          ,dblCashOrFuture  
          ,dblBasisOrDiscount  
          ,strUnitMeasure  
          ,intCommodityId    
          ,intItemId  
          ,intOriginId  
          ,intFutureMarketId  
          ,NULL intFutureMonthId  
          ,CASE WHEN @strEvaluationByZone='Location' THEN intCompanyLocationId else NULL end as intCompanyLocationId  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN intMarketZoneId else NULL end as intMarketZoneId  
          ,intCurrencyId  
          ,NULL intPricingTypeId  
          ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN intContractTypeId else NULL end as intContractTypeId  
          ,intUnitMeasureId  
          ,intConcurrencyId,isnull(strMarketValuation,'') strMarketValuation             
      FROM vyuRKGetM2MBasis WHERE strContractInventory <>'Inventory'  
   END  
   ELSE IF (@ysnIncludeInventoryM2M = 1)  
   BEGIN  
     DELETE FROM @tempBasis  
     INSERT INTO @tempBasis  
       SELECT DISTINCT strCommodityCode  
          ,strItemNo  
          ,strOriginDest  
          ,strFutMarketName  
          ,'' strFutureMonth  
          ,CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential=1 THEN strPeriodTo else NULL end as strPeriodTo  
          ,CASE WHEN @strEvaluationByZone='Location' THEN strLocationName else NULL end as strLocationName  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN strMarketZoneCode else NULL end as strMarketZoneCode  
          ,strCurrency  
          ,'' strPricingType  
          ,strContractInventory  
          ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN strContractType else NULL end as strContractType  
          ,dblCashOrFuture  
          ,dblBasisOrDiscount  
          ,strUnitMeasure  
          ,intCommodityId    
          ,intItemId  
          ,intOriginId  
          ,intFutureMarketId  
          ,NULL intFutureMonthId  
          ,CASE WHEN @strEvaluationByZone='Location' THEN intCompanyLocationId else NULL end as intCompanyLocationId  
          ,CASE WHEN @strEvaluationByZone='Market Zone' THEN intMarketZoneId else NULL end as intMarketZoneId  
          ,intCurrencyId  
          ,NULL intPricingTypeId  
          ,CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell=1 THEN intContractTypeId else NULL end as intContractTypeId  
          ,intUnitMeasureId  
          ,intConcurrencyId,isnull(strMarketValuation,'') strMarketValuation              
      FROM vyuRKGetM2MBasis            
   END  
  
    IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null  
     BEGIN  
      UPDATE a   
      SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount  
      FROM @tempBasis a   
      JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId  
      AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0)   
      and isnull(a.intMarketZoneId,0)=isnull(b.intMarketZoneId,0)  
      AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0)   
      and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)  
      and isnull(a.strPeriodTo,0)=isnull(b.strPeriodTo,0)  
      and isnull(a.intContractTypeId,0)=isnull(b.intContractTypeId,0)  
      WHERE b.intM2MBasisId=@intM2MBasisId      
     END  
END  
  
SELECT  convert(int,ROW_NUMBER() over (ORDER BY strItemNo)) AS intRowNumber,* from @tempBasis   
WHERE intFutureMarketId is not null  
order by strMarketValuation,strFutMarketName,strCommodityCode,strItemNo,strLocationName, convert(datetime,'01 '+strPeriodTo) 