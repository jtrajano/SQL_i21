CREATE PROC [dbo].[uspRKM2MVendorExposure]  
                  @intM2MBasisId int = null,
                  @intFutureSettlementPriceId int = null,
                  @intQuantityUOMId int = null,
                  @intPriceUOMId int = null,
                  @intCurrencyUOMId int= null,
                  @dtmTransactionDateUpTo datetime= null,
                  @strRateType nvarchar(50)= null,
                  @intCommodityId int=Null,
                  @intLocationId int= null,
                  @intMarketZoneId int= null,
                  @ysnVendorProducer bit = null
AS

DECLARE @tblFinalDetail TABLE (
       intRowNum INT
       ,intConcurrencyId INT
       ,intContractHeaderId INT
       ,intContractDetailId INT
       ,strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strContractSeq NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strEntityName NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intEntityId INT
       ,intFutureMarketId INT
       ,strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intFutureMonthId INT
       ,strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,dblOpenQty NUMERIC(24, 10)
       ,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intCommodityId INT
       ,intItemId INT
       ,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strOrgin NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,strPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,intPricingTypeId INT
       ,strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
       ,dblContractBasis NUMERIC(24, 10)
       ,dblFutures NUMERIC(24, 10)
       ,dblCash NUMERIC(24, 10)
       ,dblCosts NUMERIC(24, 10)
       ,dblMarketBasis NUMERIC(24, 10)
       ,dblFuturePrice NUMERIC(24, 10)
       ,intContractTypeId INT
       ,dblAdjustedContractPrice NUMERIC(24, 10)
       ,dblCashPrice NUMERIC(24, 10)
       ,dblMarketPrice NUMERIC(24, 10)
       ,dblResult NUMERIC(24, 10)
       ,dblResultBasis NUMERIC(24, 10)
       ,dblMarketFuturesResult NUMERIC(24, 10)
       ,dblResultCash NUMERIC(24, 10)
       ,dblContractPrice NUMERIC(24, 10)
       ,intQuantityUOMId INT
       ,intCommodityUnitMeasureId INT
       ,intPriceUOMId INT
       ,intCent int
	   ,dtmPlannedAvailabilityDate datetime)

INSERT INTO @tblFinalDetail
EXEC [uspRKM2MInquiryTransaction]   @intM2MBasisId  = @intM2MBasisId,
                  @intFutureSettlementPriceId  = @intFutureSettlementPriceId,
                  @intQuantityUOMId  = @intQuantityUOMId,
                  @intPriceUOMId  = @intPriceUOMId,
                  @intCurrencyUOMId = @intCurrencyUOMId,
                  @dtmTransactionDateUpTo = @dtmTransactionDateUpTo,
                  @strRateType = @strRateType,
                  @intCommodityId =@intCommodityId,
                  @intLocationId = @intLocationId,
                  @intMarketZoneId = @intMarketZoneId

SELECT cd.*,case when isnull(ysnRiskToProducer,0)=1 then e.strName else null end as strProducer,
			case when isnull(ysnRiskToProducer,0)=1 then ch.intProducerId  else null end intProducerId into #temp FROM @tblFinalDetail cd
JOIN tblCTContractDetail ch on ch.intContractHeaderId=cd.intContractHeaderId
LEFT JOIN tblEMEntity e on e.intEntityId=ch.intProducerId

IF (ISNULL(@ysnVendorProducer,0)=0)
BEGIN
	select convert(int,row_number() OVER(ORDER BY strVendorName)) intRowNum, strVendorName,strRating,
              CONVERT(NUMERIC(16,2),dblFixedPurchaseVolume) dblFixedPurchaseVolume, CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume) dblUnfixedPurchaseVolume
			  , CONVERT(NUMERIC(16,2),dblTotalCommittedVolume) dblTotalCommittedVolume, CONVERT(NUMERIC(16,2),dblFixedPurchaseValue) dblFixedPurchaseValue,
			   CONVERT(NUMERIC(16,2),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue, CONVERT(NUMERIC(16,2),dblTotalCommittedValue) dblTotalCommittedValue,
			    CONVERT(NUMERIC(16,2),dblTotalSpend) dblTotalSpend
			  ,dblShareWithSupplier ,dblMToM,dblCompanyExposurePercentage,
			  case when (isnull(dblPotentialAdditionalVolume,0)-isnull(dblTotalCommittedVolume,0)) < 0 then 0 else (isnull(dblPotentialAdditionalVolume,0)-isnull(dblTotalCommittedVolume,0)) end  dblPotentialAdditionalVolume, 0 as intConcurrencyId
			  from (
       SELECT strVendorName,strRating,
              dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue,
                     CONVERT(NUMERIC(16,2),dblTotalSpend) as dblTotalSpend ,
                     CONVERT(NUMERIC(16,2),dblShareWithSupplier) as dblShareWithSupplier ,dblMToM,dblCompanyExposurePercentage,
                     (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage a,
                     (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage b,

       CASE WHEN  CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end > dblCompanyExposurePercentage then 0
                     when CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end > dblSupplierSalesPercentage then 0
          WHEN  (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage <=
              (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) * dblSupplierSalesPercentage 
       THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage 
       ELSE
              (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage 
       end dblPotentialAdditionalVolume
       FROM(
       SELECT strEntityName strVendorName,strRiskIndicator strRating,
                     dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue
                       ,(isnull(dblTotalCommittedValue,0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue,0)=0 then 1 else dblTotalCommittedValue end) OVER ())*100 as dblTotalSpend
                      , (CASE WHEN ISNULL(dblRiskTotalBusinessVolume,0) =0 then 0 else isnull(dblTotalCommittedVolume,0)/dblRiskTotalBusinessVolume end)*100 as dblShareWithSupplier
                     ,dblResult as dblMToM,dblCompanyExposurePercentage,dblSupplierSalesPercentage
       FROM (
       SELECT strEntityName,dblFixedPurchaseVolume as dblFixedPurchaseVolume,
                                         dblUnfixedPurchaseVolume as dblUnfixedPurchaseVolume,
                                         dblFixedPurchaseVolume + dblUnfixedPurchaseVolume as dblTotalCommittedVolume,
                                         dblFixedPurchaseValue dblFixedPurchaseValue,
                                         dblUnfixedPurchaseValue dblUnfixedPurchaseValue,
                                         dblFixedPurchaseValue + dblUnfixedPurchaseValue as dblTotalCommittedValue,
                                         dblResult as dblResult
                                         ,strRiskIndicator,intRiskUnitOfMeasureId,dblRiskTotalBusinessVolume,dblCompanyExposurePercentage,dblSupplierSalesPercentage                                   
       FROM (
                     SELECT strEntityName,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,
                     sum(dblResult) as dblResult
              ,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage
                     FROM (
                                  SELECT strEntityName,sum(dblOpenQty) as dblOpenQty,sum(dblQtyPrice) dblQtyPrice,sum(dblQtyUnFixedPrice) dblQtyUnFixedPrice,strPriOrNotPriOrParPriced,
                                  sum(dblResult) dblResult,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage from(
                                  
                                  SELECT fd.strEntityName,fd.dblOpenQty as dblOpenQty,

                                  dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                           fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFutures,0)))))/
                                  case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyPrice
       
                                  ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                                  fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFuturePrice,0)))))/
                                  case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyUnFixedPrice                       

                                                ,CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
                                                WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced'
                                                                                  when  strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced' ELSE strPriOrNotPriOrParPriced END strPriOrNotPriOrParPriced
                                                ,round(isnull(dblResult,0),2) dblResult,
                                                strRiskIndicator,
                                                dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,dblRiskTotalBusinessVolume) dblRiskTotalBusinessVolume
                                                ,intRiskUnitOfMeasureId,
                                                round(isnull(dblCompanyExposurePercentage,0),2) as dblCompanyExposurePercentage ,
                                                                                  round(isnull(dblSupplierSalesPercentage,0),2) as dblSupplierSalesPercentage
                                  FROM #temp  fd
                                  JOIN tblCTContractDetail det on fd.intContractDetailId=det.intContractDetailId
                                  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId                                   
                                  JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
                                  JOIN tblAPVendor e on e.intEntityVendorId=fd.intEntityId
                                  LEFT JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=@intCommodityId and cum.intUnitMeasureId=  e.intRiskUnitOfMeasureId
                                  LEFT JOIN tblRKVendorPriceFixationLimit pf on pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId

                                  WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)'
                                  
                                  
                                  ) )t
       GROUP BY strEntityName,strPriOrNotPriOrParPriced,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t1
       GROUP BY strEntityName,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t2)t2 
       )t3)t4
END

ELSE

BEGIN

	select convert(int,row_number() OVER(ORDER BY strVendorName)) intRowNum, strVendorName,strRating,
                   CONVERT(NUMERIC(16,2),dblFixedPurchaseVolume) dblFixedPurchaseVolume, CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume) dblUnfixedPurchaseVolume
			  , CONVERT(NUMERIC(16,2),dblTotalCommittedVolume) dblTotalCommittedVolume, CONVERT(NUMERIC(16,2),dblFixedPurchaseValue) dblFixedPurchaseValue,
			   CONVERT(NUMERIC(16,2),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue, CONVERT(NUMERIC(16,2),dblTotalCommittedValue) dblTotalCommittedValue,
			    CONVERT(NUMERIC(16,2),dblTotalSpend) dblTotalSpend
			  ,dblShareWithSupplier ,dblMToM,dblCompanyExposurePercentage,
			  case when (isnull(dblPotentialAdditionalVolume,0)-isnull(dblTotalCommittedVolume,0)) < 0 then 0 else (isnull(dblPotentialAdditionalVolume,0)-isnull(dblTotalCommittedVolume,0)) end  dblPotentialAdditionalVolume, 0 as intConcurrencyId
			  from (
       SELECT strVendorName,strRating,
              dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue,
                     CONVERT(NUMERIC(16,2),dblTotalSpend) as dblTotalSpend ,
                     CONVERT(NUMERIC(16,2),dblShareWithSupplier) as dblShareWithSupplier ,dblMToM,
                    dblCompanyExposurePercentage,
                     (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage a,
                     (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage b,
       
          CASE WHEN  CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end > dblCompanyExposurePercentage then 0
                     when CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end > dblSupplierSalesPercentage then 0
          WHEN  (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage <=
              (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) * dblSupplierSalesPercentage 
       THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage 
       ELSE
              (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage 
       end dblPotentialAdditionalVolume,
       0 as intConcurrencyId
       FROM(
       SELECT strEntityName strVendorName,strRiskIndicator strRating,
                     dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue
                     ,(isnull(dblTotalCommittedValue,0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue,0)=0 then 1 else dblTotalCommittedValue end) OVER ())*100 as dblTotalSpend

                     , (CASE WHEN ISNULL(dblRiskTotalBusinessVolume,0) =0 then 0 else isnull(dblTotalCommittedVolume,0)/dblRiskTotalBusinessVolume end)*100 as dblShareWithSupplier
                     
					 ,dblResult as dblMToM,dblCompanyExposurePercentage,dblSupplierSalesPercentage
       FROM (
       SELECT strEntityName,CONVERT(NUMERIC(16,2),dblFixedPurchaseVolume) as dblFixedPurchaseVolume,
                                         CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume) as dblUnfixedPurchaseVolume,
                                         CONVERT(NUMERIC(16,2),(dblFixedPurchaseVolume + dblUnfixedPurchaseVolume)) as dblTotalCommittedVolume,
                                         CONVERT(NUMERIC(16,2),dblFixedPurchaseValue) dblFixedPurchaseValue,
                                         CONVERT(NUMERIC(16,2),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue,
                                         CONVERT(NUMERIC(16,2),(dblFixedPurchaseValue + dblUnfixedPurchaseValue)) as dblTotalCommittedValue,
                                        CONVERT(NUMERIC(16,2),(dblResult)) as dblResult
                                         ,strRiskIndicator,intRiskUnitOfMeasureId,dblRiskTotalBusinessVolume,dblCompanyExposurePercentage,dblSupplierSalesPercentage                                   
       FROM (
                     SELECT strEntityName,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
                     SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,
                     sum(dblResult) as dblResult
              ,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage
                     FROM (
                                  SELECT strEntityName,sum(dblOpenQty) as dblOpenQty,sum(dblQtyPrice) dblQtyPrice,sum(dblQtyUnFixedPrice) dblQtyUnFixedPrice,strPriOrNotPriOrParPriced,
                                  sum(dblResult) dblResult,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage 
                                  FROM(
                                  SELECT isnull(strProducer,strEntityName) strEntityName,dblOpenQty as dblOpenQty,

                                  dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                                                       fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFutures,0)))))/
                                  case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyPrice
       
                                  ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                                                         fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFuturePrice,0)))))/
                                  case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyUnFixedPrice   
                                  
                                  ,CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
                                                WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced'
                                                                                  when  strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced' ELSE strPriOrNotPriOrParPriced
                                                                                  END strPriOrNotPriOrParPriced
                                                ,round(isnull(dblResult,0),2) dblResult,
                                                CASE WHEN isnull(strProducer,'')='' THEN pf1.strRiskIndicator ELSE pf.strRiskIndicator END strRiskIndicator,
                                                dbo.fnCTConvertQuantityToTargetCommodityUOM(
                                                                                  case when isnull(strProducer,'')='' then cum1.intCommodityUnitMeasureId else cum.intCommodityUnitMeasureId end,
                                                                                  case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                                                                                  case when isnull(strProducer,'')='' then e1.dblRiskTotalBusinessVolume else e.dblRiskTotalBusinessVolume end) dblRiskTotalBusinessVolume,
                                                                                  e.intRiskUnitOfMeasureId,
                                                round(isnull(pf.dblCompanyExposurePercentage,0),2) as dblCompanyExposurePercentage ,round(isnull(pf.dblSupplierSalesPercentage,0),2) as dblSupplierSalesPercentage
                                  FROM #temp  fd
                                  JOIN tblCTContractDetail det on fd.intContractDetailId=det.intContractDetailId
                                  JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId                                   
                                  JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
                                  LEFT JOIN tblAPVendor e on e.intEntityVendorId=fd.intProducerId
                                                         LEFT join tblICCommodityUnitMeasure cum on cum.intCommodityId=@intCommodityId and cum.intUnitMeasureId=  e.intRiskUnitOfMeasureId 
                                  LEFT JOIN tblRKVendorPriceFixationLimit pf on pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId
                                  LEFT JOIN tblAPVendor e1 on e1.intEntityVendorId=fd.intEntityId 
                                                         LEFT join tblICCommodityUnitMeasure cum1 on cum1.intCommodityId=@intCommodityId and cum1.intUnitMeasureId=  e1.intRiskUnitOfMeasureId        
                                  LEFT JOIN tblRKVendorPriceFixationLimit pf1 on pf1.intVendorPriceFixationLimitId=e1.intRiskVendorPriceFixationLimitId
                                  WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)' ) )t
       GROUP BY strEntityName,strPriOrNotPriOrParPriced,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t1
       GROUP BY strEntityName,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t2)t2 
       )t3)t4
END