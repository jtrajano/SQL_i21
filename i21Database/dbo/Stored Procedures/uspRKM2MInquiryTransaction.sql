CREATE PROC uspRKM2MInquiryTransaction  
                  @intM2MBasisId int = null,
                  @intFutureSettlementPriceId int = null,
                  @intQuantityUOMId int = null,
                  @intPriceUOMId int = null,
                  @intCurrencyUOMId int= null,
                  @dtmTransactionDateUpTo datetime= null,
                  @strRateType nvarchar(50)= null,
                  @intCommodityId int=Null,
                  @intLocationId int= null,
                  @intMarketZoneId int= null
AS

DECLARE @ysnIncludeBasisDifferentialsInResults bit
DECLARE @dtmPriceDate DATETIME    
DECLARE @dtmSettlemntPriceDate DATETIME  
DECLARE @strLocationName nvarchar(50)
DECLARE @ysnIncludeInventoryM2M bit
DECLARE @ysnEnterForwardCurveForMarketBasisDifferential bit

SELECT @dtmPriceDate=dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId=@intM2MBasisId  
SELECT @ysnIncludeBasisDifferentialsInResults=ysnIncludeBasisDifferentialsInResults FROM tblRKCompanyPreference
SELECT @ysnEnterForwardCurveForMarketBasisDifferential=ysnEnterForwardCurveForMarketBasisDifferential FROM tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId
SELECT @strLocationName=strLocationName from tblSMCompanyLocation where intCompanyLocationId=@intLocationId
SELECT @ysnIncludeInventoryM2M= ysnIncludeInventoryM2M from tblRKCompanyPreference

DECLARE @tblFinalDetail TABLE (	
	intContractDetailId int
	,strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContractSeq NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strEntityName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intEntityId int
	,strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intFutureMarketId int
	,strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intFutureMonthId int
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intCommodityId int
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intItemId int
	,strOrgin NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intOriginId int
	,strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intPricingTypeId int
	,strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblFutures NUMERIC(24, 10)
	,avgLot NUMERIC(24, 10)
	,intTotLot NUMERIC(24, 10)
	,dblCash NUMERIC(24, 10)
	,dblCosts NUMERIC(24, 10)
	,dblMarketBasis1 NUMERIC(24, 10)
	,dblMarketBasisUOM  NUMERIC(24, 10)
	,dblContractBasis NUMERIC(24, 10)
	,dblFuturePrice1 NUMERIC(24, 10)
	,dblFuturesClosingPrice1 NUMERIC(24, 10)
	,intContractTypeId int
	,intConcurrencyId int
	,dblOpenQty NUMERIC(24, 10)
	,dblShipQty NUMERIC(24, 10)
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
	)

 INSERT INTO @tblFinalDetail (
    intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,dblResultCash 
	,dblResultBasis) 
SELECT  intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,
    dblResultBasis FROM(
SELECT *,   
	isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty1) as dblResult,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty1) as dblResultBasis,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty1) as dblMarketFuturesResult,
	(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty1) dblResultCash1
	,0 dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
CASE when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
CASE WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
ELSE 
CONVERT(DECIMAL(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)
            ELSE
            CASE WHEN intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis) end 
            END) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures) end 
            end) + 
            isnull(dblCosts,0)
 end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturePrice1) as dblFuturePrice,
        convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty1)end) 
       -(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then InTransQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,InTransQty) end)
        -convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblShipQty) end))
             as dblOpenQty
  FROM
(SELECT           cd.intContractDetailId,
                  'Contract'+'('+LEFT(ch.strContractType,1)+')' as strContractOrInventoryType,
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
                  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  ch.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END dblContractBasis,
                  --isnull(cd.dblBasis,0) dblContractBasis,
                  (CASE WHEN cd.intPricingTypeId=1 THEN
                  (SELECT     (isnull(dblFutures,0)) 
                        FROM tblCTContractDetail  cdv                         
                        WHERE intPricingTypeId=1 AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                  )t) end
                  ) dblFutures ,
                
                  (SELECT avgLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) avgLot, 
                  
                  (SELECT intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) intTotLot, 
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
                  
                  isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1, 
                  
                       isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,
                                                                                   
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,                                
                  convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,

                  (case when ISNULL((SELECT TOP 1 dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId,dblNewValue) from tblCTSequenceUsageHistory uh 
                        WHERE cd.intContractDetailId=uh.intContractDetailId and strScreenName='Inventory Receipt' 
                        and convert(datetime,convert(varchar, dtmTransactionDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        ORDER BY dtmTransactionDate desc),0) =0  then cd.dblBalance else 
                        (SELECT TOP 1 dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId,dblNewValue) from tblCTSequenceUsageHistory uh 
                        WHERE cd.intContractDetailId=uh.intContractDetailId and strScreenName='Inventory Receipt' 
                        AND convert(datetime,convert(varchar, dtmTransactionDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) 
                        ORDER BY dtmTransactionDate desc) end)  dblOpenQty1,
                  
                (SELECT SUM(isnull(ri.dblOpenReceive,0))-- OVER (PARTITION BY cd1.intContractDetailId) 
				FROM vyuCTContractDetailView  cd1
				JOIN vyuCTContractHeaderView ch on cd1.intContractHeaderId= ch.intContractHeaderId and cd1.dblBalance > 0 
							AND cd1.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd1.intCommodityId else @intCommodityId end
							AND cd1.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd1.intCompanyLocationId else @intLocationId end
							AND isnull(cd1.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd1.intMarketZoneId,0) else @intMarketZoneId end
				JOIN tblICItem i on cd1.intItemId= i.intItemId 
				JOIN tblICInventoryReceiptItem ri ON ch.intContractHeaderId = ri.intOrderId
				JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ri.intInventoryReceiptId
				WHERE  strReceiptType ='Purchase Contract' and intSourceType=2 and intContractStatusId<>3 and cd1.intContractDetailId=cd.intContractDetailId
				AND convert(datetime,convert(varchar, ir.dtmReceiptDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )
				 as dblShipQty,                                            
                                                
                  cd.dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId ,null as intltemPrice,
 (SELECT SUM(iv.dblPurchaseContractShippedQty)-- OVER (PARTITION BY iv.intContractDetailId)                       
	FROM vyuLGInboundShipmentView iv WHERE iv.intContractDetailId=cd.intContractDetailId
	AND intContractStatusId<>3 AND convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)) as 
	 InTransQty,

	  (select CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,SUM(cv.dblRate))
					WHEN	CC.strCostMethod = 'Amount'		THEN
						SUM(cv.dblRate)/dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)*cd.dblCashPrice*SUM(cv.dblRate)/100)/
						dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)
					END -- * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1)
					 from vyuCTContractCostView cv WHERE cd.intContractDetailId=cv.intContractDetailId 
			   AND cd.intContractDetailId=cd.intContractDetailId and ysnMTM = 1) dblCosts
	                    
FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
            AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
JOIN tblICItem i on cd.intItemId= i.intItemId
LEFT JOIN vyuCTContractCostView CC on CC.intContractDetailId=cd.intContractDetailId 
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId 
WHERE  intContractStatusId<>3 and convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10))t
)t)t1


INSERT INTO @tblFinalDetail (
     intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,dblResultCash 
	,dblResultBasis)
SELECT intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,0 as dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,dblResultBasis FROM(
SELECT *,
   isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) as dblResult,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) as dblResultBasis,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) as dblMarketFuturesResult,
	(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) dblResultCash1
	,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis),0)+isnull(dblFutures,0) dblContractPrice
FROM 
 (SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 

convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures) end 
            end) + 
              isnull(dblCosts,0)
			end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturePrice1) as dblFuturePrice,
        convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end) as dblOpenQty1
  FROM
(SELECT   distinct  cd.intContractDetailId,
                  'Inventory'+'(P)' as strContractOrInventoryType,
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
                  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  ch.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END dblContractBasis,
                  --isnull(cd.dblBasis,0) dblContractBasis,
                  (CASE WHEN cd.intPricingTypeId=1 THEN
                  (SELECT     (isnull(dblFutures,0)) 
                        FROM tblCTContractDetail  cdv                         
                        WHERE intPricingTypeId=1 AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                  )t) end
                  ) dblFutures ,
                  (SELECT avgLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) avgLot, 
                  
                  (SELECT intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) intTotLot, 
                  
                  CASE WHEN cd.intPricingTypeId=6 then dblCashPrice else null end dblCash,
                            
                  isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1,          
                  
                         isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,
                                                                          
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,                              
                  convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,
                  SUM(isnull(ri.dblOpenReceive,0)) OVER (PARTITION BY cd.intContractDetailId) dblOpenQty,                  
                  cd.dblRate,
                  cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId,null as intltemPrice,

				    (select
				  	CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId,CC.intUnitMeasureId,@intPriceUOMId,SUM(cv.dblRate))
					WHEN	CC.strCostMethod = 'Amount'		THEN
						SUM(cv.dblRate)/dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)*cd.dblCashPrice*SUM(cv.dblRate)/100)/
						dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)
					END  
					FROM vyuCTContractCostView cv WHERE cd.intContractDetailId=cv.intContractDetailId 
			   AND cd.intContractDetailId=cd.intContractDetailId and ysnMTM = 1) dblCosts

FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId 
            AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end
JOIN tblICItem i on cd.intItemId= i.intItemId and i.strLotTracking<>'No'
JOIN tblICInventoryReceiptItem ri ON ch.intContractHeaderId = ri.intOrderId
JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ri.intInventoryReceiptId
LEFT JOIN vyuCTContractCostView CC on CC.intContractDetailId=cd.intContractDetailId
LEFT JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId  
WHERE  strReceiptType ='Purchase Contract' and intSourceType=2 and intContractStatusId<>3 
            AND convert(datetime,convert(varchar, ir.dtmReceiptDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t
)t)t2 WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory(P)' else '' end 

INSERT INTO @tblFinalDetail (
    intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,dblResultCash 
	,dblResultBasis)

SELECT intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,0 dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash,dblResultBasis FROM(
SELECT *,   
	isnull(dblFuturesClosingPrice,0)+isnull(dblMarketBasis,0) dblMarketPrice,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) as dblResult,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) as dblResultBasis,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) as dblMarketFuturesResult,
	(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intPriceUOMId,dblOpenQty) dblResultCash1
	,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis),0)+isnull(dblFutures,0) dblContractPrice
FROM (
SELECT *,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis,
case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice,
case WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) 
else 
convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis) end 
            end) + 
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures) end 
            end) + 
              isnull(dblCosts,0)
		end dblAdjustedContractPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturesClosingPrice1) as dblFuturesClosingPrice,
        dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,dblMarketBasisUOM,dblFuturePrice1) as dblFuturePrice,
        (convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty1)end) - 
        convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblShipQty)end))
               
        as dblOpenQty
  FROM
(SELECT           cd.intContractDetailId,
                  'In-transit' as strContractOrInventoryType,
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
                  ca.strDescription as strOrgin,
                  ca.intCommodityAttributeId intOriginId,
                  ch.strPosition, 
                  RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5) AS strPeriod,
                  cd.strPricingStatus as strPriOrNotPriOrParPriced,
                  cd.intPricingTypeId,
                  cd.strPricingType,
                  CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN isnull(cd.dblBasis,0) ELSE 0 END dblContractBasis,
                  --isnull(cd.dblBasis,0) dblContractBasis,
                  (CASE WHEN cd.intPricingTypeId=1 THEN
                  (SELECT     (isnull(dblFutures,0)) 
                        FROM tblCTContractDetail  cdv                         
                        WHERE intPricingTypeId=1 AND cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId) 
                  ELSE 
                  (SELECT avgLot/intTotLot FROM(
                        SELECT      sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId and intPricingTypeId<>1
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                  )t) end
                  ) dblFutures ,
                  (SELECT avgLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) avgLot, 
                  
                  (SELECT intTotLot FROM(
                        SELECT
                              sum(isnull(intNoOfLots,0) *isnull(dblFixationPrice,0))+ ((max(isnull(cdv.dblNoOfLots,0))-sum(isnull(intNoOfLots,0)))*max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId,cdv.intFutureMonthId,@dtmSettlemntPriceDate))) avgLot,max(cdv.dblNoOfLots) intTotLot
                        FROM tblCTContractDetail  cdv
                        LEFT JOIN tblCTPriceFixation pf on cdv.intContractDetailId=pf.intContractDetailId and cdv.intContractHeaderId=pf.intContractHeaderId
                        LEFT JOIN tblCTPriceFixationDetail pfd on pf.intPriceFixationId=pfd.intPriceFixationId 
                        and cdv.intFutureMarketId= pfd.intFutureMarketId and cdv.intFutureMonthId=pfd.intFutureMonthId
                        AND convert(datetime,convert(varchar, dtmFixationDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10)
                        WHERE cdv.intContractHeaderId=cd.intContractHeaderId AND cd.intContractDetailId=cdv.intContractDetailId 
                        )t 
                  ) intTotLot, 
                  
                  CASE WHEN cd.intPricingTypeId=6 then cd.dblCashPrice else null end dblCash,
            
                  (SELECT SUM(isnull(ri.dblOpenReceive,0)) dblOpenQty
						FROM vyuCTContractDetailView  cd1
						JOIN vyuCTContractHeaderView ch on cd1.intContractHeaderId= ch.intContractHeaderId and cd1.dblBalance > 0 
									AND cd1.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd1.intCommodityId else @intCommodityId end
									AND cd1.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd1.intCompanyLocationId else @intLocationId end
									AND isnull(cd1.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd1.intMarketZoneId,0) else @intMarketZoneId end
						JOIN tblICItem i on cd1.intItemId= i.intItemId 
						JOIN tblICInventoryReceiptItem ri ON ch.intContractHeaderId = ri.intOrderId
						JOIN tblICInventoryReceipt ir on ir.intInventoryReceiptId=ri.intInventoryReceiptId
						WHERE  strReceiptType ='Purchase Contract' and intSourceType=2 and intContractStatusId<>3 and cd1.intContractDetailId=cd.intContractDetailId
						AND convert(datetime,convert(varchar, ir.dtmReceiptDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) ) as dblShipQty, 
                 
                  isnull((SELECT top 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasis1,    
                  isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
                       JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
                        WHERE temp.intM2MBasisId=@intM2MBasisId 
                        and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
                        and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE ch.intContractTypeId  END
                        AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
                        AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8))  END else isnull(temp.strPeriodTo,'') end
                  ),0) AS dblMarketBasisUOM,                                                              
                  dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturePrice1,
                dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId,cd.intFutureMonthId,@dtmSettlemntPriceDate) as dblFuturesClosingPrice1,                              
                  convert(int,ch.intContractTypeId) intContractTypeId ,0 as intConcurrencyId ,

                  SUM(iv.dblPurchaseContractShippedQty) OVER (PARTITION BY cd.intContractDetailId) dblOpenQty1,cd.dblRate,
                      cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId intQuantityUOMId,cuc2.intCommodityUnitMeasureId intPriceUOMId,cd.intCurrencyId,
                  convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId ,null as intltemPrice,

				    (select 
				  	CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,SUM(cv.dblRate))
					WHEN	CC.strCostMethod = 'Amount'		THEN
						SUM(cv.dblRate)/dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)*cd.dblCashPrice*SUM(cv.dblRate)/100)/
						dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc2.intCommodityUnitMeasureId,cd.dblDetailQuantity)
					END   from vyuCTContractCostView cv WHERE cd.intContractDetailId=cv.intContractDetailId 
			   AND cd.intContractDetailId=cd.intContractDetailId and ysnMTM = 1) dblCosts

FROM vyuCTContractDetailView  cd
JOIN vyuCTContractHeaderView ch on cd.intContractHeaderId= ch.intContractHeaderId and cd.dblBalance > 0 
            AND cd.intCommodityId= case when isnull(@intCommodityId,0)=0 then cd.intCommodityId else @intCommodityId end
            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
            AND isnull(cd.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0)=0 then isnull(cd.intMarketZoneId,0) else @intMarketZoneId end       
JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intUnitMeasureId
JOIN vyuLGInboundShipmentView iv on iv.intContractDetailId=cd.intContractDetailId 
LEFT JOIN vyuCTContractCostView CC on CC.intContractDetailId=cd.intContractDetailId
LEFT JOIN tblICCommodityUnitMeasure cuc1 on cd.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=@intQuantityUOMId
LEFT JOIN tblICCommodityUnitMeasure cuc3 on cd.intCommodityId=cuc3.intCommodityId and cuc3.intUnitMeasureId=cd.intPriceUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cuc2 on cd.intCommodityId=cuc2.intCommodityId and cuc2.intUnitMeasureId=@intPriceUOMId
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=cd.intOriginId  
WHERE intContractStatusId<>3 AND convert(datetime,convert(varchar, ch.dtmContractDate, 101),101) <= left(convert(varchar, @dtmTransactionDateUpTo, 101),10) )t       
)t)t2

---------------- Lot Not Controlled
DECLARE @RunningQtyBalance AS TABLE 
		(
		RowNum int  , 
		intItemId  INT,
		dblRunningQtyBalance numeric(24,10)
		)
INSERT INTO @RunningQtyBalance (RowNum,intItemId,dblRunningQtyBalance)
SELECT RowNum,intItemId,dblRunningQtyBalance from
          (
          SELECT intItemId,dblRunningQtyBalance,ROW_NUMBER()
          over(Partition by intItemId order by dtmDate desc)RowNum FROM
          vyuICGetInventoryValuation  
          )sr WHERE RowNum=1

INSERT INTO @tblFinalDetail (
    intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,dblResultCash 
	,dblResultBasis)

SELECT intContractDetailId 
	,strContractOrInventoryType 
	,strContractSeq 
	,strEntityName 
	,intEntityId 
	,strFutMarketName 
	,intFutureMarketId 
	,strFutureMonth 
	,intFutureMonthId 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 
	,strOrgin 
	,intOriginId 
	,strPosition 
	,strPeriod 
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
	,dblFutures
	,avgLot
	,intTotLot
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,dblContractBasis 
	,dblFuturePrice1 
	,dblFuturesClosingPrice1 
	,intContractTypeId 
	,intConcurrencyId 
	,dblOpenQty 
	,dblShipQty
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,intltemPrice 
	,dblMarketBasis 
	,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblMarketPrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
	,dblResultCash 
	,dblResultBasis FROM(
SELECT *, null AS dblAdjustedContractPrice,0 AS dblMarketBasisUOM,0 as dblResultBasis1,0 AS dblShipQty,
            NUll AS dblCashPrice,
            null as dblMarketPrice,
           isnull(dblOpenQty,0) * isnull(intltemPrice,0) as   dblResult,          
          null as dblResultBasis,              
            null as dblMarketFuturesResult,     
            null as dblResultCash
         ,null as dblContractPrice 
         ,null as dblMarketBasis,null as dblResultCash1, 0 as PriceSourceUOMId
FROM 
(SELECT     DISTINCT      null intContractDetailId,
                  'Inventory' as strContractOrInventoryType,
                  '' as strContractSeq,
                  '' as strEntityName,
                  null as intEntityId,
                  '' as strFutMarketName,
                  null as intFutureMarketId,
                  '' as strFutureMonth,
                  null as intFutureMonthId,
                  c.strCommodityCode,
                  c.intCommodityId,
                  i.strItemNo,
                  i.intItemId as intItemId,
                  '' as strOrgin,
                  null as intOriginId,
                  '' as strPosition, 
                  '' AS strPeriod,
                  '' as strPriOrNotPriOrParPriced,
                  null as intPricingTypeId,
                  '' as strPricingType,
                  null dblContractBasis,
                  null dblFutures ,       
                  null dblCash,     
                  null dblCosts,
                  null AS avgLot,
                  null AS intTotLot,
                  null AS dblMarketBasis1 ,
                  null AS dblFuturePrice,
                  null as dblFuturesClosingPrice, 
                  null AS dblFuturePrice1,
                  null as dblFuturesClosingPrice1,                               
                  null as intContractTypeId ,
                  0 as intConcurrencyId ,
			      (select sum (isnull(giv.dblRunningQtyBalance,0)) from  @RunningQtyBalance giv where giv.intItemId=iv.intItemId) dblOpenQty,
                  null dblRate,
                  null as intCommodityUnitMeasureId,
                  null as  intQuantityUOMId,
                  null  intPriceUOMId,
                  null intCurrencyId,
                  isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId),0) as intltemPrice
FROM vyuICGetInventoryValuation iv 
JOIN tblICItem i on iv.intItemId=i.intItemId and i.strLotTracking='No'
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure cuc on c.intCommodityId=cuc.intCommodityId 
WHERE i.intCommodityId= case when isnull(@intCommodityId,0)=0 then i.intCommodityId else @intCommodityId end
AND strLocationName= case when isnull(@strLocationName,0)=0 then strLocationName else @strLocationName end
)t WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory' else '' end )t2


IF (@strRateType='Exchange')
BEGIN
SELECT Convert(int,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,
    convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFuturePrice)) as dblFuturePrice,
	intContractDetailId,strContractOrInventoryType,
      strContractSeq,strEntityName,intEntityId,strFutMarketName,
      intFutureMarketId,intFutureMonthId,strFutureMonth,
      strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
    case when convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end) -
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblShipQty)end) < 0  THEN 0 else
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblOpenQty)end) -
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblShipQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,intQuantityUOMId,dblShipQty)end)
            end as dblOpenQty,
      intPricingTypeId,strPricingType, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)) as dblContractBasis,
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)) as dblFutures,    
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCash)) as dblCash, 

	  dblCosts,

      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketBasis)) as dblMarketBasis, 
      convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice, 
      convert(decimal(24,6),dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractPrice)) as dblContractPrice, 
      CONVERT(int,intContractTypeId) as intContractTypeId,
      CONVERT(int,0) as intConcurrencyId,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblAdjustedContractPrice)) as dblAdjustedContractPrice,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCashPrice)) as dblCashPrice, 
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketPrice)) as dblMarketPrice,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblOpenQty)) as dblResult ,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblOpenQty)) as dblResultBasis,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblOpenQty)) as dblMarketFuturesResult,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResultCash)) as dblResultCash
FROM @tblFinalDetail ORDER BY intCommodityId
END
ELSE
BEGIN
SELECT *,isnull(dblContractBasis,0) + isnull(dblFutures,0) as dblContractPrice,
		(round(isnull(dblAdjustedContractPrice,0),4)-round(isnull(dblMarketPrice,0),4))*round(isnull(dblResult1,0),4) dblResult,
		((round(isnull(dblContractBasis,0),4)+round(isnull(dblCosts,0),4))-round(isnull(dblMarketBasis,0),4))*round(isnull(dblResultBasis1,0),4) dblResultBasis,
		((round(isnull(dblFutures,0),4)- round(isnull(dblFuturePrice,0),4))*round(isnull(dblMarketFuturesResult1,0),4)) dblMarketFuturesResult,
	 isnull(dblResultCash1,0) as dblResultCash   into #Temp   
 FROM(
      SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC)) AS intRowNum,
      convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFuturePrice)) as dblFuturePrice
                  ,intContractDetailId,strContractOrInventoryType,
            strContractSeq,strEntityName,intEntityId,strFutMarketName,
            intFutureMarketId,intFutureMonthId,strFutureMonth,
            strCommodityCode,intCommodityId,strItemNo,intItemId,intOriginId,strOrgin,strPosition,strPeriod,strPriOrNotPriOrParPriced,
			dblOpenQty,			 
            intPricingTypeId,strPricingType,
            convert(decimal(24,6),
            case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblContractBasis) end end)
            as dblContractBasis,
            convert(decimal(24,6), case when isnull(dblRate,0)=0 then 
            dbo.fnRKGetCurrencyConvertion(intCurrencyId,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)
            else
            case when intCurrencyId<>@intCurrencyUOMId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures)*dblRate 
            else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblFutures) end 
            end)
            as dblFutures,             
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCash)) as dblCash, 
           	dblCosts,
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketBasis)) as dblMarketBasis, 
            convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice,              
            CONVERT(int,intContractTypeId) as intContractTypeId,CONVERT(int,0) as intConcurrencyId,            
             dblAdjustedContractPrice,           
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblCashPrice)) as dblCashPrice, 
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblMarketPrice)) as dblMarketPrice,                       
            convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblResultCash)) as dblResultCash1,
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblResult else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblOpenQty) end) as dblResult1,     
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblOpenQty) end) as dblResultBasis1,    
            convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblMarketFuturesResult else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,PriceSourceUOMId,dblOpenQty) end) as dblMarketFuturesResult1     


      FROM @tblFinalDetail )t 
      ORDER BY intCommodityId,strContractSeq desc    
END

------------- Calculation of Results ----------------------
   UPDATE #Temp set dblResult=
             CASE WHEN intContractTypeId = 1 and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN abs(dblResult)
                  WHEN intContractTypeId = 1 and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN -abs(dblResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN abs(dblResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN -abs(dblResult)
               END ,
               dblResultBasis=
             CASE WHEN intContractTypeId = 1 and (dblContractBasis < dblMarketBasis) 
                  THEN abs(dblResultBasis)
                  WHEN intContractTypeId = 1 and (dblContractBasis > dblMarketBasis) 
                  THEN -abs(dblResultBasis)
                  WHEN intContractTypeId = 2  and (dblContractBasis > dblMarketBasis) 
                  THEN abs(dblResultBasis)
                  WHEN intContractTypeId = 2  and (dblContractBasis < dblMarketBasis) 
                  THEN -abs(dblResultBasis)
               END ,
               dblMarketFuturesResult=
             CASE WHEN intContractTypeId = 1 and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 1 and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN -abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice > dblMarketPrice) 
                  THEN abs(dblMarketFuturesResult)
                  WHEN intContractTypeId = 2  and (dblAdjustedContractPrice < dblMarketPrice) 
                  THEN -abs(dblMarketFuturesResult)
               END 
		
--------------END ---------------
select * from #Temp --where strContractSeq='P1008-1'