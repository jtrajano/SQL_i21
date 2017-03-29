CREATE PROC [dbo].[uspRKM2MVendorExposureDetail]  
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
                  @ysnVendorProducer bit = null,
				  @strDrillDownColumn nvarchar(100) = null,
				  @strVendorName nvarchar(250) = null
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

DECLARE @tblDerivative TABLE (
       intRowNum INT,
	   intContractHeaderId int,
	   strContractSeq nvarchar(100),
	   strEntityName nvarchar(100),
	   dblFixedPurchaseVolume NUMERIC(24, 10),
	   dblUnfixedPurchaseVolume NUMERIC(24, 10),
	   dblTotalValume NUMERIC(24, 10),
	   dblPurchaseOpenQty NUMERIC(24, 10),
	   dblPurchaseContractBasisPrice NUMERIC(24, 10),
	   dblPurchaseFuturesPrice NUMERIC(24, 10),
	   dblPurchaseCashPrice NUMERIC(24, 10),
	   dblFixedPurchaseValue NUMERIC(24, 10),
	   dblUnPurchaseOpenQty NUMERIC(24, 10),
	   dblUnPurchaseContractBasisPrice NUMERIC(24, 10),
	   dblUnPurchaseFuturesPrice NUMERIC(24, 10),
	   dblUnPurchaseCashPrice NUMERIC(24, 10),
	   dblUnfixedPurchaseValue NUMERIC(24, 10),
	   dblTotalCommitedValue NUMERIC(24, 10)
	   )

IF (ISNULL(@ysnVendorProducer,0)=0)
BEGIN	
INSERT INTO @tblDerivative (intRowNum,intContractHeaderId,strContractSeq,strEntityName,dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalValume,dblPurchaseOpenQty,
						dblPurchaseContractBasisPrice,dblPurchaseFuturesPrice,dblPurchaseCashPrice,dblFixedPurchaseValue,dblUnPurchaseOpenQty,
						dblUnPurchaseContractBasisPrice,dblUnPurchaseFuturesPrice,dblUnPurchaseCashPrice,dblUnfixedPurchaseValue,dblTotalCommitedValue)
SELECT convert(int,row_number() OVER(ORDER BY strEntityName)) intRowNum,intContractHeaderId,strContractSeq,
	strEntityName,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
    (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) + 
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblTotalValume,	

	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPValueQty else 0 end) dblPurchaseOpenQty,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPContractBasis else 0 end) dblPurchaseContractBasisPrice,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPFutures else 0 end) dblPurchaseFuturesPrice,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPContractBasis else 0 end) +
	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPFutures else 0 end) as dblPurchaseCashPrice,
    (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
                     
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPValueQty else 0 end) dblUnPurchaseOpenQty,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPContractBasis else 0 end) dblUnPurchaseContractBasisPrice,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPFutures else 0 end) dblUnPurchaseFuturesPrice,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPContractBasis else 0 end) +
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPFutures else 0 end) as dblUnPurchaseCashPrice,
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,

	(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) + 
	(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblTotalCommitedValue
					 		
FROM(                                  
	SELECT ch.intContractHeaderId,fd.strContractSeq, fd.strEntityName,fd.dblOpenQty as dblOpenQty,
		CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
				WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced'
				WHEN  strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced' 
				ELSE strPriOrNotPriOrParPriced END strPriOrNotPriOrParPriced,
				0.0 dblPValueQty,							
				ISNULL(fd.dblContractBasis,0) dblPContractBasis ,
				ISNULL(fd.dblFutures,0) dblPFutures,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                        fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFutures,0)))))/
                        case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyPrice,  
							
				(dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                        fd.dblOpenQty))) dblUPValueQty, 
							
				isnull(fd.dblContractBasis,0) dblUPContractBasis,
								 
				isnull(fd.dblFuturePrice,0) dblUPFutures,
								       
                dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                        fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFuturePrice,0)))))/
                        case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyUnFixedPrice  
	FROM #temp  fd
	JOIN tblCTContractDetail det on fd.intContractDetailId=det.intContractDetailId
	join tblCTContractHeader ch on ch.intContractHeaderId=det.intContractHeaderId
	JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId                                   
	JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
	JOIN tblAPVendor e on e.[intEntityId]=fd.intEntityId
	LEFT JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=@intCommodityId and cum.intUnitMeasureId=  e.intRiskUnitOfMeasureId
	LEFT JOIN tblRKVendorPriceFixationLimit pf on pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId
	WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)') 
)t WHERE  strEntityName = @strVendorName 

END

ELSE

BEGIN
INSERT INTO @tblDerivative (intRowNum,intContractHeaderId,strContractSeq,strEntityName,dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalValume,dblPurchaseOpenQty,
									dblPurchaseContractBasisPrice,dblPurchaseFuturesPrice,dblPurchaseCashPrice,dblFixedPurchaseValue,dblUnPurchaseOpenQty,
									dblUnPurchaseContractBasisPrice,dblUnPurchaseFuturesPrice,dblUnPurchaseCashPrice,dblUnfixedPurchaseValue,dblTotalCommitedValue)
        SELECT convert(int,row_number() OVER(ORDER BY strEntityName)) intRowNum,intContractHeaderId,strContractSeq,
				strEntityName,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
                (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) + 
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblTotalValume,	

				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPValueQty else 0 end) dblPurchaseOpenQty,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPContractBasis else 0 end) dblPurchaseContractBasisPrice,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPFutures else 0 end) dblPurchaseFuturesPrice,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPContractBasis else 0 end) +
				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblPFutures else 0 end) as dblPurchaseCashPrice,
                (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
                     
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPValueQty else 0 end) dblUnPurchaseOpenQty,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPContractBasis else 0 end) dblUnPurchaseContractBasisPrice,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPFutures else 0 end) dblUnPurchaseFuturesPrice,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPContractBasis else 0 end) +
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblUPFutures else 0 end) as dblUnPurchaseCashPrice,
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,

				(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) + 
				(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblTotalCommitedValue
					 		
           FROM(                                  
				SELECT ch.intContractHeaderId,fd.strContractSeq, isnull(strProducer,strEntityName) strEntityName,fd.dblOpenQty as dblOpenQty,
					CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
							WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced'
							WHEN  strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced' 
							ELSE strPriOrNotPriOrParPriced END strPriOrNotPriOrParPriced,

							0.0 dblPValueQty, 
							
							ISNULL(fd.dblContractBasis,0) dblPContractBasis ,

							ISNULL(fd.dblFutures,0) dblPFutures,

				           dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                           fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFutures,0)))))/
                                  case when isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyPrice,  
							
							(dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                           fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty))) dblUPValueQty, 							
							isnull(fd.dblContractBasis,0) dblUPContractBasis,								 
							isnull(fd.dblFuturePrice,0) dblUPFutures,								       
                           dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then fd.intCommodityUnitMeasureId else intQuantityUOMId end,
                           fd.intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId,isnull(intPriceUOMId,fd.intCommodityUnitMeasureId),
                                  fd.dblOpenQty*((isnull(fd.dblContractBasis,0))+(isnull(fd.dblFuturePrice,0)))))/
                                CASE WHEN isnull(ysnSubCurrency,0) = 1 then 100 else 1 end dblQtyUnFixedPrice  
						FROM #temp  fd
                        JOIN tblCTContractDetail det on fd.intContractDetailId=det.intContractDetailId
						join tblCTContractHeader ch on ch.intContractHeaderId=det.intContractHeaderId
                        JOIN tblICItemUOM ic on det.intPriceItemUOMId=ic.intItemUOMId                                   
                        JOIN tblSMCurrency c on det.intCurrencyId=c.intCurrencyID
                        LEFT JOIN tblAPVendor e on e.[intEntityId]=fd.intProducerId
                        LEFT JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=@intCommodityId and cum.intUnitMeasureId=  e.intRiskUnitOfMeasureId 
                        LEFT JOIN tblRKVendorPriceFixationLimit pf on pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId
                        LEFT JOIN tblAPVendor e1 on e1.[intEntityId]=fd.intEntityId 
                        LEFT JOIN tblICCommodityUnitMeasure cum1 on cum1.intCommodityId=@intCommodityId and cum1.intUnitMeasureId=  e1.intRiskUnitOfMeasureId        
                        LEFT JOIN tblRKVendorPriceFixationLimit pf1 on pf1.intVendorPriceFixationLimitId=e1.intRiskVendorPriceFixationLimitId
                        WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)' ) 
			)t WHERE  strEntityName = @strVendorName 

END

IF (@strDrillDownColumn	= 'colFixedPurchaseVolume')
BEGIN
	SELECT * FROM @tblDerivative WHERE dblFixedPurchaseVolume >0
END
ELSE IF (@strDrillDownColumn = 'colUnfixedPurchaseVolume')
BEGIN
	SELECT * FROM @tblDerivative WHERE dblUnfixedPurchaseVolume >0
END
ELSE IF (@strDrillDownColumn = 'colFixedPurchaseValue')
BEGIN
	SELECT * FROM @tblDerivative WHERE dblFixedPurchaseValue >0
END
ELSE IF (@strDrillDownColumn = 'colUnfixedPurchaseValue')
BEGIN
	SELECT * FROM @tblDerivative WHERE dblUnfixedPurchaseValue >0
END	 
ELSE 
BEGIN
SELECT * FROM @tblDerivative
END