﻿CREATE PROC [dbo].[uspRKM2MInquiryTransaction]  
                  @intM2MBasisId int = null,
                  @intFutureSettlementPriceId int = null,
                  @intQuantityUOMId int = null,
                  @intPriceUOMId int = null,
                  @intCurrencyUOMId int= null,
                  @dtmTransactionDateUpTo datetime= null,
                  @strRateType nvarchar(200)= null,
                  @intCommodityId int=Null,
                  @intLocationId int= null,
                  @intMarketZoneId int= null
AS

DECLARE @ysnIncludeBasisDifferentialsInResults bit
DECLARE @dtmPriceDate DATETIME    
DECLARE @dtmSettlemntPriceDate DATETIME  
DECLARE @strLocationName nvarchar(200)
DECLARE @ysnIncludeInventoryM2M bit
DECLARE @ysnEnterForwardCurveForMarketBasisDifferential bit
DECLARE @ysnCanadianCustomer bit

SELECT @dtmPriceDate=dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId=@intM2MBasisId  
SELECT @ysnIncludeBasisDifferentialsInResults=ysnIncludeBasisDifferentialsInResults FROM tblRKCompanyPreference
SELECT @ysnEnterForwardCurveForMarketBasisDifferential=ysnEnterForwardCurveForMarketBasisDifferential FROM tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId
SELECT @strLocationName=strLocationName from tblSMCompanyLocation where intCompanyLocationId=@intLocationId
SELECT @ysnIncludeInventoryM2M= ysnIncludeInventoryM2M from tblRKCompanyPreference
SELECT @ysnCanadianCustomer = isnull(ysnCanadianCustomer,0) FROM tblRKCompanyPreference

set @dtmTransactionDateUpTo = left(convert(varchar, @dtmTransactionDateUpTo, 101),10)

DECLARE @tblFinalDetail TABLE (
       intContractHeaderId int,   
       intContractDetailId int
       ,strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intEntityId int
       ,strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intFutureMarketId int
       ,strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intFutureMonthId int
       ,strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intCommodityId int
       ,strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intItemId int
       ,strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intOriginId int
       ,strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intPricingTypeId int
       ,strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,dblFutures NUMERIC(24, 10)      
       ,dblCash NUMERIC(24, 10)
       ,dblCosts NUMERIC(24, 10)
       ,dblMarketBasis1 NUMERIC(24, 10)
       ,dblMarketBasisUOM  NUMERIC(24, 10)
       ,dblContractBasis NUMERIC(24, 10)
	   ,dblDummyContractBasis NUMERIC(24, 10)
       ,dblFuturePrice1 NUMERIC(24, 10)
       ,dblFuturesClosingPrice1 NUMERIC(24, 10)
       ,intContractTypeId int
       ,intConcurrencyId int
       ,dblOpenQty NUMERIC(24, 10)
       ,dblRate NUMERIC(24, 10)
       ,intCommodityUnitMeasureId int
       ,intQuantityUOMId INT
       ,intPriceUOMId INT
       ,intCurrencyId INT
       ,PriceSourceUOMId INT
       ,intltemPrice INT
       ,dblMarketBasis NUMERIC(24, 10)
       ,dblCashPrice NUMERIC(24, 10)
       ,dblAdjustedContractPrice NUMERIC(24, 10)
       ,dblFuturesClosingPrice NUMERIC(24, 10)
       ,dblFuturePrice NUMERIC(24, 10)
       ,dblMarketPrice NUMERIC(24, 10)
       ,dblResult NUMERIC(24, 10)
       ,dblResultBasis1 NUMERIC(24, 10)
       ,dblMarketFuturesResult NUMERIC(24, 10)
       ,dblResultCash1 NUMERIC(24, 10)
       ,dblContractPrice NUMERIC(24, 10)
       ,dblResultCash NUMERIC(24, 10)
       ,dblResultBasis NUMERIC(24, 10)
       ,dblShipQty numeric(24,10)
       ,ysnSubCurrency bit
       ,intMainCurrencyId int
       ,intCent int
       ,dtmPlannedAvailabilityDate datetime

       )

DECLARE @GetContractDetailView TABLE (
intCommodityUnitMeasureId int, strLocationName nvarchar(100),strCommodityDescription nvarchar(100),intMainCurrencyId int,intCent int,dblDetailQuantity numeric(24,10),
intContractTypeId int,intContractHeaderId int,strContractType nvarchar(100),strContractNumber nvarchar(100),strEntityName nvarchar(100),intEntityId int,strCommodityCode nvarchar(100),
intCommodityId int,strPosition nvarchar(100),dtmContractDate datetime,intContractBasisId int,intContractSeq int,dtmStartDate datetime,dtmEndDate datetime,
intPricingTypeId int,dblBasis numeric(24,10),dblFutures numeric(24,10),intContractStatusId int,dblCashPrice numeric(24,10),intContractDetailId int,intFutureMarketId int,
intFutureMonthId int,intItemId int,dblBalance numeric(24,10),intCurrencyId int,dblRate numeric(24,10),
intMarketZoneId int,dtmPlannedAvailabilityDate datetime,strItemNo nvarchar(100),strPricingType nvarchar(100),intPriceUnitMeasureId int,intUnitMeasureId int,strFutureMonth nvarchar(100),
strFutMarketName nvarchar(100),intOriginId int,strLotTracking nvarchar(100),dblNoOfLots numeric(24,10),dblHeaderNoOfLots numeric(24,10),ysnSubCurrency bit,
intCompanyLocationId int,ysnExpired bit,strPricingStatus nvarchar(100), strOrgin nvarchar(100),ysnMultiplePriceFixation bit,intMarketUOMId int,intMarketCurrencyId int
,dblInvoicedQuantity numeric(24,10)   
)

INSERT INTO @GetContractDetailView (
intCommodityUnitMeasureId, strLocationName,strCommodityDescription,intMainCurrencyId,intCent,dblDetailQuantity,intContractTypeId,intContractHeaderId,strContractType,
strContractNumber,strEntityName,intEntityId,strCommodityCode,intCommodityId,strPosition,dtmContractDate,intContractBasisId,intContractSeq,dtmStartDate,dtmEndDate,
intPricingTypeId,dblBasis,dblFutures,intContractStatusId,dblCashPrice,intContractDetailId,intFutureMarketId,intFutureMonthId,intItemId,dblBalance,intCurrencyId,dblRate,
intMarketZoneId,dtmPlannedAvailabilityDate,strItemNo,strPricingType,intPriceUnitMeasureId,intUnitMeasureId,strFutureMonth,strFutMarketName,intOriginId,strLotTracking,
dblNoOfLots,dblHeaderNoOfLots,ysnSubCurrency,intCompanyLocationId,ysnExpired,strPricingStatus, strOrgin,ysnMultiplePriceFixation,intMarketUOMId,intMarketCurrencyId    
,dblInvoicedQuantity
)

SELECT     
CH.intCommodityUOMId intCommodityUnitMeasureId,    
CL.strLocationName,    
CY.strDescription strCommodityDescription,    
CU.intMainCurrencyId,    
CU.intCent,    
CD.dblQuantity AS    dblDetailQuantity,    
CH.intContractTypeId,    
CH.intContractHeaderId,    
TP.strContractType strContractType,    
CH.strContractNumber,    
EY.strName strEntityName,    
CH.intEntityId,          
CY.strCommodityCode,    
CH.intCommodityId,    
PO.strPosition strPosition,    
convert(datetime,convert(varchar, CH.dtmContractDate, 101),101) dtmContractDate,      
CH.intContractBasisId,    
CD.intContractSeq,    
CD.dtmStartDate,         
CD.dtmEndDate,    
CD.intPricingTypeId,   
CD.dblConvertedBasis dblBasis,    
CD.dblFutures,    
CD.intContractStatusId,        
CD.dblCashPrice,    
CD.intContractDetailId,        
CD.intFutureMarketId,    
CD.intFutureMonthId,    
CD.intItemId,    
CD.dblBalance,    
CD.intCurrencyId,              
CD.dblRate,    
CD.intMarketZoneId,      
CD.dtmPlannedAvailabilityDate,    
IM.strItemNo,    
PT.strPricingType,    
PU.intUnitMeasureId  AS  intPriceUnitMeasureId,         
IU.intUnitMeasureId,    
MO.strFutureMonth,    
FM.strFutMarketName,    
IM.intOriginId,    
IM.strLotTracking,    
CD.dblNoOfLots,    
CH.dblNoOfLots dblHeaderNoOfLots    
,CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) AS ysnSubCurrency,    
       CD.intCompanyLocationId,       
       MO.ysnExpired,    
CASE   WHEN   CD.intPricingTypeId = 2 THEN   
				CASE WHEN ISNULL(ysnMultiplePriceFixation,0)=0 THEN
					CASE   WHEN   ISNULL(PF.[dblTotalLots],0) = 0  THEN   'Unpriced'    
						ELSE    
							CASE   WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(PF.[dblLotsFixed],0) = 0 THEN 'Fully Priced' 
									WHEN ISNULL(PF.[dblLotsFixed],0) = 0 THEN 'Unpriced' 
									ELSE 'Partially Priced'     
                             END    
                     END 
				 ELSE
					  CASE   WHEN   ISNULL(PFA.[dblTotalLots],0) = 0  THEN   'Unpriced'    
						ELSE    
							CASE   WHEN ISNULL(PFA.[dblTotalLots],0)-ISNULL(PFA.[dblLotsFixed],0) = 0 THEN 'Fully Priced' 
									WHEN ISNULL(PFA.[dblLotsFixed],0) = 0 THEN 'Unpriced' 
									ELSE 'Partially Priced'     
                             END    
					  END   
				 END                                     
        WHEN   CD.intPricingTypeId = 1 THEN   'Priced' ELSE   ''    
END           
AS strPricingStatus, CA.strDescription as strOrgin,isnull(ysnMultiplePriceFixation,0) as ysnMultiplePriceFixation ,FM.intUnitMeasureId  intMarketUOMId,FM.intCurrencyId intMarketCurrencyId
,dblInvoicedQty  AS    dblInvoicedQuantity       

FROM    tblCTContractHeader                        CH     
       JOIN   tblICCommodity                           CY     ON     CY.intCommodityId                 =      CH.intCommodityId        
       JOIN   tblCTContractType                        TP     ON     TP.intContractTypeId              =      CH.intContractTypeId    
       JOIN   tblEMEntity                              EY     ON     EY.intEntityId                    =      CH.intEntityId  
       JOIN   tblCTContractDetail                      CD     ON     CH.intContractHeaderId            =      CD.intContractHeaderId  
												
       JOIN     tblRKFutureMarket                 FM     ON     FM.intFutureMarketId              =      CD.intFutureMarketId           
       JOIN     tblRKFuturesMonth                 MO     ON     MO.intFutureMonthId               =      CD.intFutureMonthId  
	   JOIN   tblSMCurrency                            CU     ON     CU.intCurrencyID                  =      CD.intCurrencyId     
       JOIN   tblICItem                                IM     ON     IM.intItemId                      =      CD.intItemId                          
       JOIN   tblICItemUOM                             IU     ON     IU.intItemUOMId                   =      CD.intItemUOMId          
       JOIN   tblSMCompanyLocation                     CL     ON     CL.intCompanyLocationId           =      CD.intCompanyLocationId  
										   AND CL.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CL.intCompanyLocationId else @intLocationId end   
       JOIN   tblCTPricingType                         PT     ON     PT.intPricingTypeId               =      CD.intPricingTypeId 
       JOIN   tblICItemUOM                             PU     ON     PU.intItemUOMId                   =      CD.intPriceItemUOMId
	   LEFT JOIN     tblCTPosition                     PO     ON     PO.intPositionId                  =      CH.intPositionId   
       LEFT JOIN     tblICCommodityAttribute           CA     on  CA.intCommodityAttributeId           =      IM.intOriginId                 
                               
       LEFT JOIN     tblCTPriceFixation                PF     ON    PF.intContractDetailId			=  CD .intContractDetailId
	   LEFT JOIN     tblCTPriceFixation                PFA     ON    PFA.intContractHeaderId			=  CD .intContractHeaderId
WHERE  CH.intCommodityId= @intCommodityId and CD.dblQuantity > isnull(CD.dblInvoicedQty,0)
            AND CL.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CL.intCompanyLocationId else @intLocationId end
            AND isnull(intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(intMarketZoneId,0) else @intMarketZoneId end
            AND intContractStatusId not in(2,3,6) and dtmContractDate <= @dtmTransactionDateUpTo

DECLARE @tblContractCost TABLE (     
       intContractDetailId int 
       ,dblCosts NUMERIC(24, 10)  
       )
insert into @tblContractCost
SELECT intContractDetailId,sum(dblCosts) dblCosts FROM    
(
SELECT case when strAdjustmentType = 'Add' then abs(sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0)))) 
    WHEN strAdjustmentType = 'Reduce' then -sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
    ELSE 0 END dblCosts,strAdjustmentType,dc.intContractDetailId
FROM @GetContractDetailView cd
JOIN vyuRKM2MContractCost dc on dc.intContractDetailId=cd.intContractDetailId 
JOIN tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId
JOIN tblRKM2MConfiguration M2M on dc.intItemId= M2M.intItemId and ch.intContractBasisId=M2M.intContractBasisId and dc.intItemId= M2M.intItemId 
JOIN tblICCommodityUnitMeasure cu1 on cu1.intCommodityId=@intCommodityId and cu1.intUnitMeasureId=dc.intUnitMeasureId
JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId  
GROUP BY cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,strAdjustmentType,dc.intContractDetailId
)t group by intContractDetailId

DECLARE @tblSettlementPrice TABLE (     
        intContractDetailId int,
        dblFuturePrice NUMERIC(24, 10),
		dblFuturePriceForExMonth NUMERIC(24, 10),
		dblFutures NUMERIC(24, 10)
       )

INSERT INTO @tblSettlementPrice 
SELECT DISTINCT intContractDetailId
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId, 												
												(	SELECT TOP 1  dblLastSettle
												FROM tblRKFuturesSettlementPrice p
												INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
												WHERE p.intFutureMarketId = intFutureMarketId AND pm.intFutureMonthId = intFutureMonthId
													AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmSettlemntPriceDate, 111)
												ORDER BY dtmPriceDate DESC)	/ CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END),
	dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId,
		case WHEN ffm.ysnExpired = 0 THEN cd.intFutureMonthId else (
									SELECT TOP 1 intFutureMonthId
									FROM tblRKFuturesMonth FuMo
									WHERE dtmFutureMonthsDate > (
											SELECT top 1 dtmFutureMonthsDate
											FROM tblRKFuturesMonth mo
											WHERE mo.intFutureMonthId = ffm.intFutureMonthId AND ffm.ysnExpired = 0 AND mo.intFutureMarketId = cd.intFutureMarketId
											) AND FuMo.ysnExpired = 0 AND FuMo.intFutureMarketId = cd.intFutureMarketId
									ORDER BY intFutureMarketId,dtmFutureMonthsDate ASC
									) end

	 / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END),
	dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, PUOM.intCommodityUnitMeasureId, 
								cd.dblFutures / CASE WHEN c1.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
FROM @GetContractDetailView cd
JOIN tblRKFuturesMonth ffm on ffm.intFutureMonthId= cd.intFutureMonthId 
JOIN tblSMCurrency c on cd.intMarketCurrencyId=c.intCurrencyID and  cd.intCommodityId= @intCommodityId
JOIN tblSMCurrency c1 on cd.intCurrencyId=c1.intCurrencyID 
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intMarketUOMId 
JOIN tblICCommodityUnitMeasure PUOM on cd.intCommodityId=PUOM.intCommodityId and PUOM.intUnitMeasureId=cd.intPriceUnitMeasureId 
JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId   
WHERE   cd.intCommodityId= @intCommodityId 
		
DECLARE @tblContractFuture TABLE (     
       intContractDetailId int 
       ,dblFuture NUMERIC(24, 10)  
       )

insert into @tblContractFuture
SELECT intContractDetailId
	,(avgLot / intTotLot)
FROM (
	SELECT 
	sum(isnull(pfd.[dblNoOfLots], 0)*
	dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cdv.intPriceUnitMeasureId,isnull(dblFixationPrice, 0)))
	/max(CASE WHEN cdv.ysnSubCurrency = 1 then 100 else 1 end) +	((max(isnull(CASE WHEN ISNULL(cdv.ysnMultiplePriceFixation, 0) = 1 
							THEN cdv.dblNoOfLots ELSE cdv.dblNoOfLots END, 0)) - sum(isnull(pfd.[dblNoOfLots], 0))) 
	* max(dblFuturePrice)) avgLot,max(CASE WHEN ISNULL(cdv.ysnMultiplePriceFixation, 0) = 1 THEN cdv.dblNoOfLots ELSE cdv.dblNoOfLots END)intTotLot
		,cdv.intContractDetailId
	FROM @GetContractDetailView cdv
	JOIN @tblSettlementPrice p ON cdv.intContractDetailId = p.intContractDetailId
	JOIN tblCTPriceFixation pf ON CASE WHEN isnull(cdv.ysnMultiplePriceFixation, 0) = 1 THEN pf.intContractHeaderId ELSE pf.intContractDetailId END = CASE WHEN isnull(cdv.ysnMultiplePriceFixation, 0) = 1 THEN cdv.intContractHeaderId ELSE cdv.intContractDetailId END
	JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND cdv.intPricingTypeId <> 1 AND cdv.intFutureMarketId = pfd.intFutureMarketId AND cdv.intFutureMonthId = pfd.intFutureMonthId AND cdv.intContractStatusId NOT IN (2, 3, 6)
	JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId
	GROUP BY cdv.intContractDetailId
	) t

DECLARE @tblOpenContractList TABLE (     
                 intContractHeaderId int,
				 intContractDetailId int,
                 strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intEntityId int,
                 strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intFutureMarketId int,
                 strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intFutureMonthId int,
                 strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intCommodityId int,
                 strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intItemId int,
                 strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intOriginId int,
                 strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS, 
                 strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intPricingTypeId int,
                 strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
				 dblContractBasis NUMERIC(24, 10),
				 dblDummyContractBasis NUMERIC(24, 10),
                 dblCash NUMERIC(24, 10),
				 dblFuturesClosingPrice1 NUMERIC(24, 10),
				 dblFutures NUMERIC(24, 10),                
                 dblMarketBasis1 NUMERIC(24, 10),                            
				 dblMarketBasisUOM NUMERIC(24, 10),      
				 dblFuturePrice1 NUMERIC(24, 10),                         
                 intContractTypeId int ,
				 dblRate NUMERIC(24, 10),
				 intCommodityUnitMeasureId int,
				 intQuantityUOMId int,
				 intPriceUOMId int,
				 intCurrencyId int,
                 PriceSourceUOMId int,
				 dblCosts NUMERIC(24, 10),
				 dblContractOriginalQty NUMERIC(24, 10),
                 ysnSubCurrency bit,
				 intMainCurrencyId int,
				 intCent int,
				 dtmPlannedAvailabilityDate datetime,
                 intCompanyLocationId int,
				 intMarketZoneId int,
				 intContractStatusId int,
				 dtmContractDate datetime,
				 ysnExpired bit,
				 dblInvoicedQuantity numeric(24,10)
)

INSERT INTO @tblOpenContractList (intContractHeaderId, intContractDetailId,strContractOrInventoryType,strContractSeq,strEntityName,intEntityId,strFutMarketName,
intFutureMarketId,strFutureMonth,intFutureMonthId,strCommodityCode,intCommodityId,strItemNo,intItemId,strOrgin,intOriginId,strPosition, strPeriod,strPriOrNotPriOrParPriced,
intPricingTypeId,strPricingType,dblContractBasis,dblDummyContractBasis,dblCash,dblFuturesClosingPrice1,dblFutures ,dblMarketBasis1, dblMarketBasisUOM, dblFuturePrice1,                         
intContractTypeId ,dblRate,intCommodityUnitMeasureId,intQuantityUOMId,intPriceUOMId,intCurrencyId,PriceSourceUOMId,dblCosts,dblContractOriginalQty,
ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate,intCompanyLocationId,intMarketZoneId,intContractStatusId,dtmContractDate,ysnExpired,dblInvoicedQuantity)		

SELECT distinct cd.intContractHeaderId, cd.intContractDetailId,
                  'Contract'+'('+LEFT(cd.strContractType,1)+')' as strContractOrInventoryType,
                  cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq,
                  cd.strEntityName strEntityName,
                  cd.intEntityId,
                  cd.strFutMarketName,
                  cd.intFutureMarketId,
                  cd.strFutureMonth,
                  cd.intFutureMonthId,
                  cd.strCommodityCode,
                  cd.intCommodityId,
                  cd.strItemNo,
                  cd.intItemId as intItemId,
                  cd.strOrgin,
                  cd.intOriginId,
                  cd.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
				  isnull(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END,0) dblContractBasis,
				  isnull(cd.dblBasis,0) dblDummyContractBasis,
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
				 dblFuturePriceForExMonth as dblFuturesClosingPrice1,	

	  CASE WHEN isnull(strPricingStatus,'')='Unpriced' then 
          dblFuturePrice   else                                                        
          CASE WHEN cd.intPricingTypeId=1 THEN isnull(p.dblFutures,0) ELSE dblFuture end end as dblFutures,        
                                              
			isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
				WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
				AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
			),0) AS dblMarketBasis1,                            

			isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
			JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
			WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
			and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
			and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
			AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
			AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
			),0) AS dblMarketBasisUOM,      
                                                                    
          dblFuturePrice as dblFuturePrice1,                         
          CONVERT(int,cd.intContractTypeId) intContractTypeId ,
          cd.dblRate,
          cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
          convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId,

		isnull(dblCosts,0) dblCosts, 

		 cd.dblBalance  as dblContractOriginalQty,
              cd.ysnSubCurrency,cd.intMainCurrencyId,cd.intCent,cd.dtmPlannedAvailabilityDate
              ,cd.intCompanyLocationId,cd.intMarketZoneId,cd.intContractStatusId,dtmContractDate,
              ffm.ysnExpired,cd.dblInvoicedQuantity
FROM @GetContractDetailView  cd
JOIN @tblSettlementPrice p on cd.intContractDetailId=p.intContractDetailId
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId and  cd.intCommodityId= @intCommodityId --and dblBalance>0
JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and  cuc2.intUnitMeasureId  = @intPriceUOMId
LEFT JOIN @tblContractCost cc on cd.intContractDetailId=cc.intContractDetailId
LEFT JOIN @tblContractFuture cf on cf.intContractDetailId=cd.intContractDetailId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblRKFuturesMonth ffm on ffm.intFutureMonthId= cd.intFutureMonthId 
WHERE   cd.intCommodityId= @intCommodityId 

-- intransit
INSERT INTO @tblFinalDetail (intContractHeaderId,
              intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblDummyContractBasis,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 
SELECT DISTINCT intContractHeaderId, intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblDummyContractBasis,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
    dblResultBasis,0 as dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate  FROM(
SELECT *,   
       isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
       ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+isnull(dblFutures,0) dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 
convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
            end) + 
              isnull(dblCosts,0)
              end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturePrice1) as dblFuturePrice,
        (isnull(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblOpenQty1,0))end),0))
		-(isnull(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblInvoicedQuantity else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblInvoicedQuantity,0))end),0))
         as dblOpenQty
  FROM
(
SELECT  distinct  cd.intContractHeaderId,cd.intContractDetailId,
                  case when L.intPurchaseSale=2 then 'In-transit'+'(S)' else 'In-transit'+'(P)' end as strContractOrInventoryType,
                  cd.strContractSeq,
                  cd.strEntityName,
                  cd.intEntityId,
                  cd.strFutMarketName,
                  cd.intFutureMarketId,
                  cd.strFutureMonth,
                  cd.intFutureMonthId,
                  cd.strCommodityCode,
                  cd.intCommodityId,
                  cd.strItemNo,
                  cd.intItemId,
                  cd.strOrgin,
                  cd.intOriginId,
                  cd.strPosition, 
                  cd.strPeriod,
                  cd.strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  cd.dblContractBasis,dblDummyContractBasis,
                  cd.dblFutures ,
				  cd.dblCash,
                  cd.dblMarketBasis1,    
                  cd.dblMarketBasisUOM,                                                              
                  cd.dblFuturePrice1,
                  cd.dblFuturesClosingPrice1,                              
                  cd.intContractTypeId ,
				  0 as intConcurrencyId ,
				  LD.dblQuantity dblOpenQty1,
                  cd.dblRate,
                  cd.intCommodityUnitMeasureId,cd.intQuantityUOMId,cd.intPriceUOMId,cd.intCurrencyId,
                  cd.PriceSourceUOMId ,
				  cd.dblCosts,
				  cd.ysnSubCurrency,
				  cd.intMainCurrencyId,
				  cd.intCent,
				  cd.dtmPlannedAvailabilityDate,
				  cd.dblInvoicedQuantity 
FROM 
tblLGLoad L 
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = CASE L.intPurchaseSale WHEN 1 THEN LD.intPContractDetailId WHEN 2 THEN LD.intSContractDetailId END
						and PCT.intContractDetailId in(select intContractDetailId from @tblOpenContractList)
JOIN @tblOpenContractList cd on cd.intContractDetailId = PCT.intContractDetailId
JOIN vyuRKPurchaseIntransitView si on cd.intContractDetailId=si.intContractDetailId)t       
)t)t2

IF ISNULL(@ysnIncludeInventoryM2M,0) = 1
BEGIN

INSERT INTO @tblFinalDetail (intContractHeaderId,
        intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblDummyContractBasis,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 
SELECT DISTINCT     intContractHeaderId,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblDummyContractBasis,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
    dblResultBasis,0 as dblShipQty,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate FROM(
SELECT *,
   isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty1,0))) dblResultCash1
       ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+isnull(dblFutures,0) dblContractPrice
FROM 
 (SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 
convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dblFutures*dblRate 
            else dblFutures end 
            end) + 
              isnull(dblCosts,0)
              end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dblFuturePrice1  as dblFuturePrice,         
       isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty1)end),0)              
              as dblOpenQty
  FROM
(SELECT   DISTINCT  cd.intContractHeaderId, cd.intContractDetailId,'Inventory (P)' as strContractOrInventoryType,cd.strContractSeq,cd.strEntityName,
				cd.intEntityId,cd.strFutMarketName,cd.intFutureMarketId,cd.strFutureMonth,cd.intFutureMonthId,cd.strCommodityCode,cd.intCommodityId,cd.strItemNo,cd.intItemId,
				cd.strOrgin,cd.intOriginId,cd.strPosition, cd.strPeriod,cd.strPriOrNotPriOrParPriced,cd.intPricingTypeId,cd.strPricingType,cd.dblContractBasis,cd.dblDummyContractBasis,cd.dblFutures,
				cd.dblCash,cd.dblMarketBasis1,cd.dblMarketBasisUOM,cd.dblFuturePrice1,cd.dblFuturesClosingPrice1,cd.intContractTypeId ,0 as intConcurrencyId ,
				dblLotQty dblOpenQty1,
				cd.dblRate,cd.intCommodityUnitMeasureId,cd.intQuantityUOMId,cd.intPriceUOMId,cd.intCurrencyId,
				cd.PriceSourceUOMId,cd.dblCosts,			
				cd.dblInvoicedQuantity dblInvoiceQty,
				cd.ysnSubCurrency,cd.intMainCurrencyId,cd.intCent,cd.dtmPlannedAvailabilityDate
FROM @tblOpenContractList cd
JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId =l.intContractDetailId
JOIN tblICItem i on cd.intItemId= i.intItemId and i.strLotTracking<>'No'
WHERE cd.intCommodityId= @intCommodityId
)t 
)t1)t2 WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory (P)' else '' end 
END
---- contract
INSERT INTO @tblFinalDetail (intContractHeaderId,
    intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis,dblDummyContractBasis ,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice ,dblFuturesClosingPrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,dblResultCash ,dblResultBasis,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate) 

SELECT distinct   intContractHeaderId,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,strEntityName ,intEntityId ,strFutMarketName ,intFutureMarketId ,strFutureMonth ,intFutureMonthId 
       ,strCommodityCode ,intCommodityId ,strItemNo ,intItemId ,strOrgin ,intOriginId ,strPosition ,strPeriod ,strPriOrNotPriOrParPriced ,intPricingTypeId ,strPricingType 
       ,dblFutures,dblCash,dblCosts,dblMarketBasis1,dblMarketBasisUOM,dblContractBasis ,dblDummyContractBasis,dblFuturePrice1 ,dblFuturesClosingPrice1 ,intContractTypeId 
       ,0 as intConcurrencyId ,dblOpenQty ,dblRate ,intCommodityUnitMeasureId ,intQuantityUOMId ,intPriceUOMId ,intCurrencyId ,PriceSourceUOMId ,dblMarketBasis 
       ,dblCashPrice ,dblAdjustedContractPrice,dblFuturePrice ,dblFuturePrice ,dblMarketPrice ,dblResult ,dblMarketFuturesResult ,dblResultCash1 ,dblContractPrice 
       ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
      dblResultBasis,ysnSubCurrency,intMainCurrencyId,intCent,dtmPlannedAvailabilityDate FROM(
SELECT *,   
       isnull(dblFuturePrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis,
       dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult,
       (isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
       ,0 dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
CASE when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,

CASE WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
ELSE 
CONVERT(DECIMAL(24,6),
CASE WHEN ISNULL(dblRate,0)=0 THEN 
               dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
ELSE
CASE WHEN case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*isnull(dblRate,0) 
ELSE                                            dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end 
END) 
+ 
convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
else
case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dblFutures*isnull(dblRate,0) 
else dblFutures end 
end) + 
isnull(dblCosts,0)
END AS dblAdjustedContractPrice,
dblFuturePrice1 as dblFuturePrice,    
    
convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblContractOriginalQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblContractOriginalQty) end )
    -isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then InTransQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,InTransQty)end),0)
	-isnull( convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblInvoicedQuantity else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblInvoicedQuantity)end),0)
    as dblOpenQty
  FROM
(SELECT 
		cd.intContractHeaderId,cd.intContractDetailId, cd.strContractOrInventoryType,cd.strContractSeq,cd.strEntityName,cd.intEntityId,cd.strFutMarketName,
		cd.intFutureMarketId,cd.strFutureMonth,cd.intFutureMonthId,cd.strCommodityCode,cd.intCommodityId,cd.strItemNo,cd.intItemId,cd.strOrgin,cd.intOriginId,cd.strPosition, 
		cd.strPeriod,cd.strPriOrNotPriOrParPriced,cd.intPricingTypeId,cd.strPricingType,cd.dblContractBasis,cd.dblDummyContractBasis,cd.dblCash,cd.dblFuturesClosingPrice1,cd.dblFutures , cd.dblMarketBasis1,                            
		cd.dblMarketBasisUOM,cd.dblFuturePrice1,cd.intContractTypeId ,cd.dblRate,cd.intCommodityUnitMeasureId,cd.intQuantityUOMId,cd.intPriceUOMId,cd.intCurrencyId,
		convert(int,cd.PriceSourceUOMId) PriceSourceUOMId,cd.dblCosts, cd.dblContractOriginalQty,
		LG.dblQuantity as InTransQty,cd.dblInvoicedQuantity,
		cd.ysnSubCurrency,cd.intMainCurrencyId,cd.intCent,cd.dtmPlannedAvailabilityDate,cd.intCompanyLocationId,cd.intMarketZoneId,cd.intContractStatusId,cd.dtmContractDate,cd.ysnExpired
FROM @tblOpenContractList cd
LEFT JOIN (	select sum(LD.dblQuantity)dblQuantity, PCT.intContractDetailId from tblLGLoad L 
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
	JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId and  PCT.dblQuantity > isnull(PCT.dblInvoicedQty,0)
	GROUP BY PCT.intContractDetailId
	UNION 
	select sum(LD.dblQuantity)dblQuantity, PCT.intContractDetailId from tblLGLoad L 
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
	JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId and  PCT.dblQuantity > PCT.dblInvoicedQty
	GROUP BY PCT.intContractDetailId) AS LG ON LG.intContractDetailId = cd.intContractDetailId
)t 
)t where  isnull(dblOpenQty,0) >0 )t1 

if isnull(@ysnIncludeInventoryM2M,0) = 1
BEGIN
DECLARE @RunningQtyBalance AS TABLE 
              (
              RowNum int  , 
              intItemId  INT,
              dblRunningQtyBalance numeric(24,10)
              )
INSERT INTO @RunningQtyBalance (RowNum,intItemId,dblRunningQtyBalance)
SELECT RowNum,intItemId,dblRunningQtyBalance from
          (
          SELECT iv.intItemId,dblRunningQtyBalance,iv.dtmDate,ROW_NUMBER()
          over(Partition by iv.intItemId ORDER BY iv.dtmDate desc)RowNum FROM
          vyuICGetInventoryValuation iv 
JOIN tblICInventoryTransaction it on iv.intInventoryTransactionId=it.intInventoryTransactionId
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No'
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId and c.intCommodityId=@intCommodityId
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=it.intTransactionId and intTransactionTypeId=4 AND ir.strReceiptType = 'Purchase Contract' 
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
JOIN tblCTContractDetail cd on cd.intContractDetailId=intLineNo AND intPricingTypeId in(2,5) and cd.intContractStatusId not in(2,3,6)
JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE  cd.dblQuantity > isnull(cd.dblInvoicedQty,0) and convert(datetime,convert(varchar,iv.dtmDate, 101),101) <= left(convert(varchar, getdate(), 101),10) )sr WHERE RowNum=1

INSERT INTO @tblFinalDetail (
    strContractOrInventoryType 
       ,strCommodityCode 
       ,intCommodityId 
       ,strItemNo 
       ,intItemId 
       ,intConcurrencyId 
       ,dblOpenQty 
       ,PriceSourceUOMId 
       ,intltemPrice 
       ,dblResult )

SELECT strContractOrInventoryType 
       ,strCommodityCode 
       ,intCommodityId 
       ,strItemNo 
       ,intItemId 
       ,intConcurrencyId 
       ,dblOpenQty 
       ,PriceSourceUOMId 
       ,intltemPrice 
       ,dblResult 
FROM(SELECT *,0 as intConcurrencyId, isnull(dblOpenQty,0) * isnull(intltemPrice,0) as dblResult,0 as PriceSourceUOMId
FROM 
(SELECT DISTINCT  'Inventory' as strContractOrInventoryType,                  
                  c.strCommodityCode,
                  c.intCommodityId,
                  i.strItemNo,
                  i.intItemId as intItemId,                 
                           isnull((select sum (isnull(giv.dblRunningQtyBalance,0)) from  @RunningQtyBalance giv where giv.intItemId=iv.intItemId),0) dblOpenQty,                 
                  isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId),0) as intltemPrice
FROM vyuICGetInventoryValuation iv 
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No' and i.intCommodityId= @intCommodityId
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE i.intCommodityId= @intCommodityId
AND strLocationName= case when isnull(@strLocationName,'')='' then strLocationName else @strLocationName end

UNION

SELECT strContractOrInventoryType,strCommodityCode,intCommodityId,strItemNo,intItemId,sum(dblOpenQty) dblOpenQty,intltemPrice from(
              SELECT DISTINCT      'Inventory - '+ strPricingType as strContractOrInventoryType,                  
                  c.strCommodityCode,
                  c.intCommodityId,
                  i.strItemNo,
                  iv.intItemId as intItemId,                 
                          isnull(ri.dblReceived, 0) dblOpenQty,strPricingType ,                
                  isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId),0) as intltemPrice
FROM vyuICGetInventoryValuation iv 
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No' and i.intCommodityId= @intCommodityId
JOIN tblICInventoryTransaction it on iv.intInventoryTransactionId=it.intInventoryTransactionId
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=it.intTransactionId and intTransactionTypeId=4 AND ir.strReceiptType = 'Purchase Contract' 
JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
JOIN tblCTContractDetail cd on cd.intContractDetailId=intLineNo AND intPricingTypeId in(2,5)  and cd.intContractStatusId not in(2,3,6)
JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE cd.dblQuantity > isnull(cd.dblInvoicedQty,0) and i.intCommodityId= @intCommodityId
AND strLocationName= case when isnull(@strLocationName,'')='' then strLocationName else @strLocationName end)t1
group by  strContractOrInventoryType,strCommodityCode,intCommodityId, strItemNo, intItemId,strPricingType,intltemPrice

)t WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then strContractOrInventoryType else '' end )t2

END

IF (@strRateType='Configuration')
BEGIN
SELECT intContractHeaderId,
    convert(decimal(24,6),dblFuturePrice) as dblFuturePrice,
      intContractDetailId,strContractOrInventoryType,
      strContractSeq,strEntityName,intEntityId,strFutMarketName,
      intFutureMarketId,intFutureMonthId,strFutureMonth,
      strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
    case when convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty)end) -
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblShipQty)end) < 0  THEN 0 else
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty)end) -
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblShipQty)end)
            end as dblOpenQty,
      intPricingTypeId,strPricingType, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))) as dblContractBasis,
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures)
	    as dblFutures,    
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash, 
         dblCosts,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblMarketBasis)) as dblMarketBasis, 
      convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblContractPrice)) as dblContractPrice, 
      CONVERT(int,intContractTypeId) as intContractTypeId,
      CONVERT(int,0) as intConcurrencyId,
      dblMarketFuturesResult as dblAdjustedContractPrice,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCashPrice)) as dblCashPrice, 
      
	  dblMarketPrice dblMarketPrice,
              dblCashPrice as dblCashPrice,
              dblResult as dblResult1,
              dblResultBasis as dblResultBasis1,
              dblMarketFuturesResult as dblMarketFuturesResult1,
            intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate,
				CONVERT(decimal(24,6), case when isnull(dblRate,0)=0 then 
			dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)
			else
			case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures)*dblRate 
			else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblFutures) end 
			end) dblCanadianFutures	   
FROM @tblFinalDetail ORDER BY intCommodityId
END
ELSE
BEGIN
SELECT *,isnull(dblContractBasis,0) + isnull(dblFutures,0) as dblContractPrice,
              convert(decimal(24,6),(isnull(dblAdjustedContractPrice,0)-isnull(dblMarketPrice,0))*isnull(dblResult1,0)) dblResult,
              convert(decimal(24,6),((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))*isnull(dblResultBasis1,0)) dblResultBasis,
              convert(decimal(24,6),((isnull(dblFutures,0)- isnull(dblFuturePrice,0))*isnull(dblMarketFuturesResult1,0))) dblMarketFuturesResult,
              case when strPricingType='Cash' THEN convert(decimal(24,6),(isnull(dblAdjustedContractPrice,0)-isnull(dblMarketPrice,0))*isnull(dblResult1,0))
              else null end as dblResultCash into #Temp   
 FROM(
      SELECT intContractHeaderId,
                     intContractDetailId,strContractOrInventoryType,
            strContractSeq,strEntityName,intEntityId,strFutMarketName,
            intFutureMarketId,intFutureMonthId,strFutureMonth,
            strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
                     case when intContractTypeId =1 then  dblOpenQty else -dblOpenQty end dblOpenQty ,                    
            intPricingTypeId,strPricingType,
			convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblDummyContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblDummyContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblDummyContractBasis,0)) end end)
            as dblDummyContractBasis,
            convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end end)
            as dblContractBasis,
			convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) end end)
            as dblCanadianContractBasis,

 			case when @ysnCanadianCustomer= 1 then dblFutures else 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
            else
            case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dblFutures*dblRate 
            else dblFutures end 
            end) end
            as 	dblFutures,          
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash, 
                     dblCosts,
                     dbo.fnRKGetCurrencyConvertion(CASE WHEN ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* 
                                                 dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblMarketBasis)
                     AS dblMarketBasis,
                    dblFuturePrice1 as dblFuturePrice,

            convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice,              
            CONVERT(int,intContractTypeId) as intContractTypeId,CONVERT(int,0) as intConcurrencyId,            
             dblAdjustedContractPrice, 
                              
            dblMarketPrice as dblMarketPrice,                       
           
                     dblCashPrice as dblCashPrice, 
                     case when  ysnSubCurrency=1 then (convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash)))/isnull(intCent,0) else convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash)) end as dblResultCash1,
                     dblResult as dblResult1,
                     case when isnull(@ysnIncludeBasisDifferentialsInResults,0) =0 then 0 else  dblResultBasis  end as dblResultBasis1,
                     dblMarketFuturesResult  as dblMarketFuturesResult1            
                                   ,intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate,
					CONVERT(decimal(24,6), case when isnull(dblRate,0)=0 then 
					dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
					else
					case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end<>@intCurrencyUOMId THEN dblFutures*dblRate 
					else dblFutures end 
					end) dblCanadianFutures	
      FROM @tblFinalDetail )t 
      ORDER BY intCommodityId,strContractSeq desc    

	  
END

------------- Calculation of Results ----------------------
   UPDATE #Temp set dblResult=
             CASE WHEN intContractTypeId = 1 and (dblAdjustedContractPrice <= dblMarketPrice) 
                  THEN abs(dblResult)
                  WHEN intContractTypeId = 1 and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN -abs(dblResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice >= dblMarketPrice) 
                  THEN abs(dblResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN -abs(dblResult)
               END ,
              dblResultCash=
             CASE WHEN intContractTypeId = 1 and (dblAdjustedContractPrice <= dblMarketPrice) 
                  THEN abs(dblResultCash)
                  WHEN intContractTypeId = 1 and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN -abs(dblResultCash)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice >= dblMarketPrice) 
                  THEN abs(dblResultCash)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN -abs(dblResultCash)
               END ,
               dblResultBasis=
             CASE WHEN intContractTypeId = 1 and (isnull(dblContractBasis,0) <= dblMarketBasis) 
                  THEN abs(dblResultBasis)
                  WHEN intContractTypeId = 1 and (isnull(dblContractBasis,0) > dblMarketBasis) 
                  THEN -abs(dblResultBasis)
                  WHEN intContractTypeId = 2  and (isnull(dblContractBasis,0) >= dblMarketBasis) 
                  THEN abs(dblResultBasis)
                  WHEN intContractTypeId = 2  and (isnull(dblContractBasis,0) < dblMarketBasis) 
                  THEN -abs(dblResultBasis)
               END ,
               dblMarketFuturesResult=
             CASE WHEN intContractTypeId = 1 and (isnull(dblFutures,0) <= isnull(dblFuturesClosingPrice,0)) 
                  THEN abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 1 and (isnull(dblFutures,0) > isnull(dblFuturesClosingPrice,0)) 
                  THEN -abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 2  and (isnull(dblFutures,0) >= isnull(dblFuturesClosingPrice,0)) 
                  THEN abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 2  and (isnull(dblFutures,0) < isnull(dblFuturesClosingPrice,0)) 
                  THEN -abs(dblMarketFuturesResult)
               END 
              
--------------END ---------------

SELECT  CONVERT(INT,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,* FROM (
SELECT DISTINCT 0 as intConcurrencyId,intContractHeaderId,intContractDetailId,
strContractOrInventoryType,strContractSeq,strEntityName,intEntityId,intFutureMarketId,strFutMarketName,intFutureMonthId,
strFutureMonth,dblOpenQty dblOpenQty,strCommodityCode,intCommodityId,intItemId,strItemNo,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,intPricingTypeId,strPricingType,
case when isnull(@ysnIncludeBasisDifferentialsInResults,0) = 0 then 0 else	case when @ysnCanadianCustomer= 1 then dblCanadianFutures+dblCanadianContractBasis-isnull(dblFutures,0) else dblContractBasis end end dblContractBasis,
dblFutures dblFutures, dblCash dblCash ,abs(dblCosts) dblCosts,
dblMarketBasis dblMarketBasis,dblFuturePrice dblFuturePrice,intContractTypeId,dblAdjustedContractPrice dblAdjustedContractPrice ,
dblCashPrice dblCashPrice,dblMarketPrice dblMarketPrice,case when isnull(@ysnIncludeBasisDifferentialsInResults,0) =0 then isnull(dblResultBasis,0)+isnull(dblMarketFuturesResult,0)+isnull(dblResultCash,0) ELSE dblResult END dblResult,dblResultBasis dblResultBasis,
dblMarketFuturesResult dblMarketFuturesResult,dblResultCash dblResultCash,
CASE WHEN @ysnCanadianCustomer = 1 then dblCanadianFutures+case when isnull(@ysnIncludeBasisDifferentialsInResults,0) = 0 then dblDummyContractBasis else dblCanadianContractBasis end+dblCash
ELSE dblContractBasis + dblFutures + dblCash end dblContractPrice
,intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate FROM #Temp 
WHERE strContractOrInventoryType  like '%(P)%' and dblOpenQty > 0 
UNION
SELECT DISTINCT 0 as intConcurrencyId,intContractHeaderId,intContractDetailId,
strContractOrInventoryType,strContractSeq,strEntityName,intEntityId,intFutureMarketId,strFutMarketName,intFutureMonthId,
strFutureMonth,dblOpenQty dblOpenQty,strCommodityCode,intCommodityId,intItemId,strItemNo,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,intPricingTypeId,strPricingType,
case when isnull(@ysnIncludeBasisDifferentialsInResults,0) = 0 then 0 else	case when @ysnCanadianCustomer= 1 then dblCanadianFutures+dblCanadianContractBasis-isnull(dblFutures,0) else dblContractBasis end end dblContractBasis,dblFutures dblFutures, dblCash dblCash ,abs(dblCosts) dblCosts,
dblMarketBasis dblMarketBasis,dblFuturePrice dblFuturePrice,intContractTypeId,dblAdjustedContractPrice dblAdjustedContractPrice ,
dblCashPrice dblCashPrice,dblMarketPrice dblMarketPrice,
case when isnull(@ysnIncludeBasisDifferentialsInResults,0) =0 then isnull(dblResultBasis,0)+isnull(dblMarketFuturesResult,0)+isnull(dblResultCash,0) ELSE dblResult END  dblResult,
dblResultBasis dblResultBasis,
dblMarketFuturesResult dblMarketFuturesResult,dblResultCash dblResultCash,
case when @ysnCanadianCustomer = 1 then dblCanadianFutures+case when isnull(@ysnIncludeBasisDifferentialsInResults,0) = 0 then 0 else dblCanadianContractBasis end+dblCash else dblContractBasis + dblFutures + dblCash end dblContractPrice,
intQuantityUOMId,intCommodityUnitMeasureId,intPriceUOMId,intCent,dtmPlannedAvailabilityDate FROM #Temp 
WHERE strContractOrInventoryType  like '%(S)%' and dblOpenQty <> 0 )t ORDER BY intContractHeaderId DESC