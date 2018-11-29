﻿CREATE PROCEDURE [dbo].[uspRKM2MInquiryTransaction]  
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
DECLARE @intDefaultCurrencyId int

SELECT @dtmPriceDate=dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId=@intM2MBasisId  
SELECT @ysnIncludeBasisDifferentialsInResults=ysnIncludeBasisDifferentialsInResults FROM tblRKCompanyPreference
SELECT @ysnEnterForwardCurveForMarketBasisDifferential=ysnEnterForwardCurveForMarketBasisDifferential FROM tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId
SELECT @strLocationName=strLocationName from tblSMCompanyLocation where intCompanyLocationId=@intLocationId
SELECT @ysnIncludeInventoryM2M= ysnIncludeInventoryM2M from tblRKCompanyPreference
SELECT @ysnCanadianCustomer = isnull(ysnCanadianCustomer,0) FROM tblRKCompanyPreference
select top 1 @intDefaultCurrencyId=intDefaultCurrencyId from tblSMCompanyPreference 
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
	   ,strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
       ,strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intPricingTypeId int
       ,strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,dblFutures NUMERIC(24, 10)      
       ,dblCash NUMERIC(24, 10)
       ,dblCosts NUMERIC(24, 10)
       ,dblMarketBasis1 NUMERIC(24, 10)
       ,dblMarketBasisUOM  NUMERIC(24, 10)
	   ,intMarketBasisCurrencyId INT
	   ,dblContractRatio NUMERIC(24, 10)
       ,dblContractBasis NUMERIC(24, 10)
	   ,dblDummyContractBasis NUMERIC(24, 10)
       ,dblFuturePrice1 NUMERIC(24, 10)
	   ,intFuturePriceCurrencyId INT
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
       ,dblltemPrice NUMERIC(24, 10)
       ,dblMarketBasis NUMERIC(24, 10)
	   ,dblMarketRatio NUMERIC(24, 10)
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
	   ,dblPricedQty numeric(24,10),dblUnPricedQty numeric(24,10),dblPricedAmount numeric(24,10)
	    ,intMarketZoneId int  ,intCompanyLocationId int
		,strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblNotLotTrackedPrice NUMERIC(24, 10)
		,dblInvFuturePrice NUMERIC(24, 10)
		,dblInvMarketBasis NUMERIC(24, 10)
		,dblNoOfLots numeric(24,10)
		,dblLotsFixed numeric(24,10)
		,dblPriceWORollArb numeric(24,10)
       )

DECLARE @GetContractDetailView TABLE (
	intCommodityUnitMeasureId int
	,strLocationName nvarchar(100)
	,strCommodityDescription nvarchar(100)
	,intMainCurrencyId int
	,intCent int
	,dblDetailQuantity numeric(24,10)
	,intContractTypeId int
	,intContractHeaderId int
	,strContractType nvarchar(100)
	,strContractNumber nvarchar(100)
	,strEntityName nvarchar(100)
	,intEntityId int
	,strCommodityCode nvarchar(100)
	,intCommodityId int
	,strPosition nvarchar(100)
	,dtmContractDate datetime
	,intContractBasisId int
	,intContractSeq int
	,dtmStartDate datetime
	,dtmEndDate datetime
	,intPricingTypeId int
	,dblRatio numeric(24,10)
	,dblBasis numeric(24,10)
	,dblFutures numeric(24,10)
	,intContractStatusId int
	,dblCashPrice numeric(24,10)
	,intContractDetailId int
	,intFutureMarketId int
	,intFutureMonthId int
	,intItemId int
	,dblBalance numeric(24,10)
	,intCurrencyId int
	,dblRate numeric(24,10)
	,intMarketZoneId int
	,dtmPlannedAvailabilityDate datetime
	,strItemNo nvarchar(100)
	,strPricingType nvarchar(100)
	,intPriceUnitMeasureId int
	,intUnitMeasureId int
	,strFutureMonth nvarchar(100)
	,strFutMarketName nvarchar(100)
	,intOriginId int
	,strLotTracking nvarchar(100)
	,dblNoOfLots numeric(24,10)
	,dblLotsFixed numeric(24,10)
	,dblPriceWORollArb numeric(24,10)
	,dblHeaderNoOfLots numeric(24,10)
	,ysnSubCurrency bit
	,intCompanyLocationId int
	,ysnExpired bit
	,strPricingStatus nvarchar(100)
	,strOrgin nvarchar(100)
	,ysnMultiplePriceFixation bit
	,intMarketUOMId int
	,intMarketCurrencyId int
	,dblInvoicedQuantity numeric(24,10)
	,dblPricedQty numeric(24,10)
	,dblUnPricedQty numeric(24,10)
	,dblPricedAmount numeric(24,10)
	,strMarketZoneCode NVARCHAR(200)
)

--There is an error "An INSERT EXEC statement cannot be nested." that is why we cannot directly call the uspRKDPRContractDetail and insert
DECLARE @tblGetOpenContractDetail TABLE (
		intRowNum int, 
		strCommodityCode  nvarchar(100),
		intCommodityId int, 
		intContractHeaderId int, 
	    strContractNumber  nvarchar(100),
		strLocationName  nvarchar(100),
		dtmEndDate datetime,
		dblBalance DECIMAL(24,10),
		intUnitMeasureId int, 	
		intPricingTypeId int,
		intContractTypeId int,
		intCompanyLocationId int,
		strContractType  nvarchar(100), 
		strPricingType  nvarchar(100),
		intCommodityUnitMeasureId int,
		intContractDetailId int,
		intContractStatusId int,
		intEntityId int,
		intCurrencyId int,
		strType	  nvarchar(100),
		intItemId int,
		strItemNo  nvarchar(100),
		dtmContractDate datetime,
		strEntityName  nvarchar(100),
		strCustomerContract  nvarchar(100)
				,intFutureMarketId int
		,intFutureMonthId int)

INSERT INTO @tblGetOpenContractDetail (intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType,intItemId,strItemNo ,dtmContractDate,strEntityName,strCustomerContract
	   	   ,intFutureMarketId,intFutureMonthId)
SELECT intRowNum	,
strCommodityCode	,
intCommodityId	,
intContractHeaderId	,
strContractNumber	,
strLocationName	,
dtmEndDate	,
dblBalance	,
intUnitMeasureId	,
intPricingTypeId	,
intContractTypeId	,
intCompanyLocationId	,
strContractType	,
strPricingType	,
intCommodityUnitMeasureId	,
intContractDetailId	,
intContractStatusId	,
intEntityId	,
intCurrencyId	,
strType	,
intItemId	,
strItemNo	,
dtmContractDate	,
strEntityName	,
strCustomerContract	,
intFutureMarketId	,
intFutureMonthId	
FROM
(
select * 
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		, dblBalance
		,intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo
		,dtmHistoryCreated dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmTransactionDateUpTo 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
	) a
WHERE a.intRowNum = 1  AND strPricingStatus IN ('Fully Priced') AND intContractStatusId NOT IN (2, 3, 6)

UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		--,isnull(dblQtyUnpriced,dblQuantity) + ISNULL(dblQtyPriced - (dblQuantity - dblBalance),0) dblBalance
		,case when strPricingStatus='Parially Priced' then dblQuantity - ISNULL(dblQtyPriced + (dblQuantity - dblBalance),0) 
				else isnull(dblQtyUnpriced,dblQuantity) end dblBalance 		
		,-- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Basis' AS strType
		,i.intItemId intItemId
		,strItemNo
		,dtmHistoryCreated dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId
		,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmTransactionDateUpTo 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
	
	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId=2 and strPricingStatus in( 'Parially Priced','Unpriced') 

UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		,CASE WHEN dblQtyPriced - (dblQuantity - dblBalance) < 0 THEN 0 ELSE dblQtyPriced - (dblQuantity - dblBalance) END dblBalance
		,-- wrong need to check
		intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' Priced' AS strType
		,i.intItemId intItemId
		,strItemNo
		,dtmHistoryCreated dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId 
		,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110) <= @dtmTransactionDateUpTo 
	AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 

	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and strPricingStatus = 'Parially Priced'  and intPricingTypeId=2


UNION

SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY dtmHistoryCreated DESC
			) intRowNum
		,strCommodity strCommodityCode
		,h.intCommodityId intCommodityId
		,intContractHeaderId
		,strContractNumber + '-' + Convert(NVARCHAR, intContractSeq) strContractNumber
		,strLocation strLocationName
		,dtmEndDate
		,dblBalance dblBalance
		,intDtlQtyUnitMeasureId intUnitMeasureId
		,intPricingTypeId
		,intContractTypeId
		,intCompanyLocationId
		,strContractType
		,strPricingType
		,intDtlQtyInCommodityUOMId intCommodityUnitMeasureId
		,intContractDetailId
		,intContractStatusId
		,e.intEntityId intEntityId
		,intCurrencyId
		,strContractType + ' ' + strPricingType AS strType
		,i.intItemId intItemId
		,strItemNo
		,dtmHistoryCreated dtmContractDate
		,e.strName strEntityName
		,'' strCustomerContract
		,intFutureMarketId
		,intFutureMonthId 
		,strPricingStatus
	FROM tblCTSequenceHistory h
	JOIN tblICItem i ON h.intItemId = i.intItemId
	JOIN tblEMEntity e ON e.intEntityId = h.intEntityId
	WHERE intContractDetailId NOT IN (
			SELECT intContractDetailId
			FROM tblCTPriceFixation
			) AND convert(DATETIME, CONVERT(VARCHAR(10), convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryCreated, 110), 110), 110), 110) <= convert(DATETIME, @dtmTransactionDateUpTo) 
			AND h.intCommodityId = case when isnull(@intCommodityId,0)=0 then h.intCommodityId else @intCommodityId end 
				
	) a
WHERE a.intRowNum = 1  AND intContractStatusId NOT IN (2, 3, 6) and intPricingTypeId not in (1,2)
)t


INSERT INTO @GetContractDetailView (
	intCommodityUnitMeasureId
	,strLocationName
	,strCommodityDescription
	,intMainCurrencyId
	,intCent
	,dblDetailQuantity
	,intContractTypeId
	,intContractHeaderId
	,strContractType
	,strContractNumber
	,strEntityName
	,intEntityId
	,strCommodityCode
	,intCommodityId
	,strPosition
	,dtmContractDate
	,intContractBasisId
	,intContractSeq
	,dtmStartDate
	,dtmEndDate
	,intPricingTypeId
	,dblRatio
	,dblBasis
	,dblFutures
	,intContractStatusId
	,dblCashPrice
	,intContractDetailId
	,intFutureMarketId
	,intFutureMonthId
	,intItemId
	,dblBalance
	,intCurrencyId
	,dblRate
	,intMarketZoneId
	,dtmPlannedAvailabilityDate
	,strItemNo
	,strPricingType
	,intPriceUnitMeasureId
	,intUnitMeasureId,strFutureMonth
	,strFutMarketName
	,intOriginId
	,strLotTracking
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb
	,dblHeaderNoOfLots
	,ysnSubCurrency
	,intCompanyLocationId
	,ysnExpired
	,strPricingStatus
	,strOrgin
	,ysnMultiplePriceFixation
	,intMarketUOMId
	,intMarketCurrencyId    
	,dblInvoicedQuantity
	,dblPricedQty
	,dblUnPricedQty
	,dblPricedAmount
	,strMarketZoneCode
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
	convert(datetime,convert(varchar, OCD.dtmContractDate, 101),101) dtmContractDate,      
	CH.intContractBasisId,    
	CD.intContractSeq,    
	CD.dtmStartDate,         
	CD.dtmEndDate,    
	CD.intPricingTypeId,  
	CD.dblRatio, 
	CD.dblConvertedBasis dblBasis,    
	CD.dblFutures, 
	CD.intContractStatusId,        
	CD.dblCashPrice,    
	CD.intContractDetailId,        
	CD.intFutureMarketId,    
	CD.intFutureMonthId,    
	CD.intItemId,    
	CASE WHEN OCD.dblBalance IS NULL THEN
		CD.dblBalance
		ELSE OCD.dblBalance
	 END as dblBalance,    
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
	PF.dblLotsFixed,  
	PF.dblPriceWORollArb,      
	CH.dblNoOfLots dblHeaderNoOfLots ,
	CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) AS ysnSubCurrency,    
	CD.intCompanyLocationId,       
	MO.ysnExpired,    
	CASE   WHEN   CD.intPricingTypeId = 2 OR CD.intPricingTypeId = 8 THEN   
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
	AS strPricingStatus, 
	CA.strDescription as strOrgin,
	isnull(ysnMultiplePriceFixation,0) as ysnMultiplePriceFixation,
	FM.intUnitMeasureId  intMarketUOMId,
	FM.intCurrencyId intMarketCurrencyId,
	dblInvoicedQty  AS    dblInvoicedQuantity,
	isnull(case when CD.intPricingTypeId =1 and PF.intPriceFixationId is null then CD.dblQuantity else FD.dblQuantity end,0) dblPricedQty,
	isnull(CASE WHEN CD.intPricingTypeId<>1 and PF.intPriceFixationId IS NOT NULL THEN ISNULL(CD.dblQuantity,0)-ISNULL(FD.dblQuantity ,0) 
			when CD.intPricingTypeId<>1 and PF.intPriceFixationId IS NULL then ISNULL(CD.dblQuantity,0)
			ELSE 0 end,0) dblUnPricedQty,
	isnull(case when CD.intPricingTypeId =1 and PF.intPriceFixationId is null then CD.dblCashPrice else PF.dblFinalPrice end,0) dblPricedAmount,
	MZ.strMarketZoneCode
FROM tblCTContractHeader				CH     
	INNER JOIN tblICCommodity			CY	ON	CY.intCommodityId			=	CH.intCommodityId        
	INNER JOIN tblCTContractType		TP	ON	TP.intContractTypeId		=	CH.intContractTypeId    
	INNER JOIN tblEMEntity				EY	ON	EY.intEntityId				=	CH.intEntityId  
	INNER JOIN tblCTContractDetail		CD	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	LEFT JOIN @tblGetOpenContractDetail OCD ON CD.intContractDetailId		=	OCD.intContractDetailId  
	INNER JOIN tblRKFutureMarket		FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId           
	INNER JOIN tblRKFuturesMonth		MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId  
	INNER JOIN tblSMCurrency			CU	ON	CU.intCurrencyID			=	CD.intCurrencyId     
	INNER JOIN tblICItem				IM	ON	IM.intItemId				=	CD.intItemId                          
	INNER JOIN tblICItemUOM				IU	ON	IU.intItemUOMId				=	CD.intItemUOMId          
	INNER JOIN tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId  AND CL.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CL.intCompanyLocationId else @intLocationId end   
	INNER JOIN tblCTPricingType			PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId 
	INNER JOIN tblICItemUOM				PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId
	LEFT JOIN tblCTPosition				PO	ON	PO.intPositionId			=	CH.intPositionId   
	LEFT JOIN tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId  =	IM.intOriginId                 
	LEFT JOIN tblARMarketZone			MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId                        
	LEFT JOIN tblCTPriceFixation		PF	ON	PF.intContractDetailId		=	CD .intContractDetailId
	LEFT JOIN tblCTPriceFixation		PFA	ON	PFA.intContractHeaderId		=	CD .intContractHeaderId
	LEFT JOIN (
		SELECT  
		 intPriceFixationId
		,SUM(dblQuantity) AS  dblQuantity
		FROM tblCTPriceFixationDetail
		GROUP BY  intPriceFixationId
	 )									FD  ON  FD.intPriceFixationId = PF.intPriceFixationId

WHERE  CH.intCommodityId= @intCommodityId 
	AND CD.dblQuantity > isnull(CD.dblInvoicedQty,0)
	AND CL.intCompanyLocationId= case when isnull(@intLocationId,0) = 0 then CL.intCompanyLocationId else @intLocationId end
	AND isnull(CD.intMarketZoneId,0)= case when isnull(@intMarketZoneId,0) = 0 then isnull(CD.intMarketZoneId,0) else @intMarketZoneId end
	AND CD.intContractStatusId not in(2,3,6) 
	AND convert(datetime,convert(varchar, OCD.dtmContractDate, 101),101)  <= @dtmTransactionDateUpTo


DECLARE @tblContractCost TABLE (     
       intContractDetailId int 
       ,dblCosts NUMERIC(24, 10)  
)

INSERT INTO @tblContractCost
SELECT 
	intContractDetailId
	,sum(dblCosts) dblCosts 
FROM    
(
	SELECT 
		CASE WHEN strAdjustmentType = 'Add' THEN 
			abs(case when dc.strCostMethod ='Amount' then 
					sum(dc.dblRate) 
				else 
					sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
				end) 
			WHEN strAdjustmentType = 'Reduce' THEN 
				case when dc.strCostMethod ='Amount' then 
					sum(dc.dblRate) 
				else 
					-sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(dc.dblRate,0))) 
				end
			ELSE 
				0 
		END dblCosts
		,strAdjustmentType
		,dc.intContractDetailId
	FROM @GetContractDetailView					cd
		INNER JOIN vyuRKM2MContractCost			dc	ON dc.intContractDetailId	= cd.intContractDetailId 
		INNER JOIN tblCTContractHeader			ch	ON ch.intContractHeaderId	= cd.intContractHeaderId
		INNER JOIN tblRKM2MConfiguration		M2M	ON dc.intItemId				= M2M.intItemId AND ch.intContractBasisId = M2M.intContractBasisId AND dc.intItemId = M2M.intItemId 
		INNER JOIN tblICCommodityUnitMeasure	cu	ON cu.intCommodityId		= @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId  
		LEFT  JOIN tblICCommodityUnitMeasure	cu1	ON cu1.intCommodityId		= @intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
	GROUP BY 
		cu.intCommodityUnitMeasureId
		,cu1.intCommodityUnitMeasureId
		,strAdjustmentType
		,dc.intContractDetailId
		,dc.strCostMethod
)t 
GROUP BY intContractDetailId

DECLARE @tblSettlementPrice TABLE (     
        intContractDetailId int
		,dblFuturePrice NUMERIC(24, 10)
		,dblFutures NUMERIC(24, 10)
		,intFuturePriceCurrencyId INT
)

DECLARE @tblGetSettlementPrice TABLE (   
		dblLastSettle numeric(24,10) , 
        intFutureMonthId int,
		intFutureMarketId int		
)
DECLARE @ysnM2MAllowExpiredMonth bit=0
SELECT @ysnM2MAllowExpiredMonth=ysnM2MAllowExpiredMonth FROM tblRKCompanyPreference
IF (@ysnM2MAllowExpiredMonth=1)
BEGIN

insert into @tblGetSettlementPrice
SELECT dblLastSettle,intFutureMonthId,intFutureMarketId FROM(
	SELECT  	 ROW_NUMBER() OVER (
			PARTITION BY pm.intFutureMonthId ORDER BY dtmPriceDate DESC
			) intRowNum, dblLastSettle,fm.intFutureMonthId,p.intFutureMarketId,fm.ysnExpired ysnExpired,strFutureMonth
			FROM tblRKFuturesSettlementPrice p
			INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
			join tblRKFuturesMonth fm on fm.intFutureMonthId= pm.intFutureMonthId			
			WHERE 
			p.intFutureMarketId =fm.intFutureMarketId    
				AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmSettlemntPriceDate, 111)		
				
			)t WHERE t.intRowNum = 1 
END
ELSE
BEGIN
insert into @tblGetSettlementPrice
SELECT  dblLastSettle,fm.intFutureMonthId,fm.intFutureMarketId
			FROM tblRKFuturesSettlementPrice p
			INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
			join tblRKFuturesMonth fm on fm.intFutureMonthId= case when  isnull(fm.ysnExpired,0)=0 then pm.intFutureMonthId
															  else 
															  (SELECT TOP 1  intFutureMonthId
																FROM tblRKFuturesMonth fm
																WHERE ysnExpired = 0  AND fm.intFutureMarketId = p.intFutureMarketId 
																and CONVERT(DATETIME,'01 '+strFutureMonth) > getdate()
																ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC)
															  end				
			WHERE 
			p.intFutureMarketId =fm.intFutureMarketId  
				AND CONVERT(Nvarchar, dtmPriceDate, 111) = CONVERT(Nvarchar, @dtmSettlemntPriceDate, 111)
			ORDER BY dtmPriceDate DESC	
END

INSERT INTO @tblSettlementPrice 
SELECT distinct intContractDetailId,dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,cuc.intCommodityUnitMeasureId,
		dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 then 100 else 1 end ),
	dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,PUOM.intCommodityUnitMeasureId,cd.dblFutures/CASE WHEN c1.ysnSubCurrency = 1 then 100 else 1 end)
				,fm.intCurrencyId
FROM @GetContractDetailView cd
	JOIN tblRKFuturesMonth ffm on ffm.intFutureMonthId= cd.intFutureMonthId and ffm.intFutureMarketId=cd.intFutureMarketId
	JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
	JOIN tblSMCurrency c on cd.intMarketCurrencyId=c.intCurrencyID and  cd.intCommodityId= @intCommodityId
	JOIN tblSMCurrency c1 on cd.intCurrencyId=c1.intCurrencyID 
	JOIN tblICCommodityUnitMeasure cuc on cd.intCommodityId=cuc.intCommodityId and cuc.intUnitMeasureId=cd.intMarketUOMId 
	JOIN tblICCommodityUnitMeasure PUOM on cd.intCommodityId=PUOM.intCommodityId and PUOM.intUnitMeasureId=cd.intPriceUnitMeasureId 
	JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId  
	JOIN @tblGetSettlementPrice sm on sm.intFutureMonthId=ffm.intFutureMonthId 
WHERE   cd.intCommodityId= @intCommodityId 


DECLARE @tblContractFuture TABLE (     
		intContractDetailId int 
		,dblFuture NUMERIC(24, 10)  
)

INSERT INTO @tblContractFuture
SELECT intContractDetailId
	,(avgLot / intTotLot)
FROM (
	SELECT sum(isnull(pfd.[dblNoOfLots], 0)*
	dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,PUOM.intCommodityUnitMeasureId,isnull(dblFixationPrice, 0)))
	/max(CASE WHEN c.ysnSubCurrency = 1 then 100 else 1 end) +	((max(isnull(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 
							THEN ch.dblNoOfLots ELSE cdv.dblNoOfLots END, 0)) - sum(isnull(pfd.[dblNoOfLots], 0))) 
	* max(dblFuturePrice)) avgLot,max(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cdv.dblNoOfLots END)intTotLot
		,cdv.intContractDetailId
	FROM tblCTContractDetail cdv
	JOIN @tblSettlementPrice p ON cdv.intContractDetailId = p.intContractDetailId
	JOIN tblSMCurrency c on cdv.intCurrencyId=c.intCurrencyID
	JOIN tblCTContractHeader ch ON cdv.intContractHeaderId = ch.intContractHeaderId AND ch.intCommodityId = @intCommodityId AND cdv.dblBalance > 0
	JOIN tblCTPriceFixation pf ON CASE WHEN isnull(ch.ysnMultiplePriceFixation, 0) = 1 THEN pf.intContractHeaderId ELSE pf.intContractDetailId END = CASE WHEN isnull(ch.ysnMultiplePriceFixation, 0) = 1 THEN cdv.intContractHeaderId ELSE cdv.intContractDetailId END
	JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND cdv.intPricingTypeId <> 1 AND cdv.intFutureMarketId = pfd.intFutureMarketId AND cdv.intFutureMonthId = pfd.intFutureMonthId AND cdv.intContractStatusId NOT IN (2, 3, 6)
		JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=@intCommodityId and cu.intUnitMeasureId=@intPriceUOMId
	JOIN   tblICItemUOM                             PU     ON     PU.intItemUOMId                   =      cdv.intPriceItemUOMId   
	JOIN tblICCommodityUnitMeasure PUOM on ch.intCommodityId=PUOM.intCommodityId and PUOM.intUnitMeasureId=PU.intUnitMeasureId 
	
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
				 strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
                 strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS,
                 intPricingTypeId int,
                 strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
				 dblContractRatio NUMERIC(24, 10),
				 dblContractBasis NUMERIC(24, 10),
				 dblDummyContractBasis NUMERIC(24, 10),
                 dblCash NUMERIC(24, 10),
				 dblFuturesClosingPrice1 NUMERIC(24, 10),
				 dblFutures NUMERIC(24, 10),                
				 dblMarketRatio NUMERIC(24, 10),  
                 dblMarketBasis1 NUMERIC(24, 10),                            
				 dblMarketBasisUOM NUMERIC(24, 10),   
				 intMarketBasisCurrencyId INT,   
				 dblFuturePrice1 NUMERIC(24, 10),
				 intFuturePriceCurrencyId INT,                         
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
				 ,dblPricedQty numeric(24,10),dblUnPricedQty numeric(24,10),dblPricedAmount numeric(24,10)   
				 ,strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
				 ,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
				 ,dblNoOfLots numeric(24,10)
				 ,dblLotsFixed numeric(24,10)
				 ,dblPriceWORollArb numeric(24,10)
)

INSERT INTO @tblOpenContractList (
	intContractHeaderId
	,intContractDetailId
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
	,strPeriodTo
	,strPriOrNotPriOrParPriced
	,intPricingTypeId
	,strPricingType
	,dblContractRatio
	,dblContractBasis
	,dblDummyContractBasis
	,dblCash
	,dblFuturesClosingPrice1
	,dblFutures
	,dblMarketRatio
	,dblMarketBasis1
	,dblMarketBasisUOM
	,intMarketBasisCurrencyId
	,dblFuturePrice1
	,intFuturePriceCurrencyId
	,intContractTypeId
	,dblRate
	,intCommodityUnitMeasureId
	,intQuantityUOMId
	,intPriceUOMId
	,intCurrencyId
	,PriceSourceUOMId
	,dblCosts
	,dblContractOriginalQty
	,ysnSubCurrency
	,intMainCurrencyId
	,intCent
	,dtmPlannedAvailabilityDate
	,intCompanyLocationId
	,intMarketZoneId
	,intContractStatusId
	,dtmContractDate
	,ysnExpired
	,dblInvoicedQuantity
	,dblPricedQty
	,dblUnPricedQty
	,dblPricedAmount
	,strMarketZoneCode
	,strLocationName
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb
)		
select 
	intContractHeaderId
	,intContractDetailId
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
	,strPeriodTo
	,strPriOrNotPriOrParPriced
	,intPricingTypeId
	,strPricingType
	,dblRatio
	,case when isnull(intPricingTypeId,0)=3 then dblMarketBasis1 else dblContractBasis end dblContractBasis
	,dblDummyContractBasis
	,dblCash
	,dblFuturesClosingPrice1
	,dblFutures 
	,dblMarketRatio
	,dblMarketBasis1
	,dblMarketBasisUOM
	,intMarketBasisCurrencyId
	,dblFuturePrice1
	,intFuturePriceCurrencyId
	,intContractTypeId 
	,dblRate
	,intCommodityUnitMeasureId
	,intQuantityUOMId
	,intPriceUOMId
	,intCurrencyId
	,PriceSourceUOMId
	,dblCosts
	,dblContractOriginalQty
	,ysnSubCurrency
	,intMainCurrencyId
	,intCent
	,dtmPlannedAvailabilityDate
	,intCompanyLocationId
	,intMarketZoneId
	,intContractStatusId
	,dtmContractDate
	,ysnExpired
	,dblInvoicedQuantity
	,dblPricedQty
	,dblUnPricedQty
	,dblPricedAmount
	,strMarketZoneCode
	,strLocationName 
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb
FROM(
		SELECT DISTINCT 
			cd.intContractHeaderId
			,cd.intContractDetailId
			,'Contract'+'('+LEFT(cd.strContractType,1)+')' as strContractOrInventoryType
            ,cd.strContractNumber +'-'+CONVERT(nvarchar,cd.intContractSeq) as strContractSeq
            ,cd.strEntityName strEntityName
            ,cd.intEntityId
            ,cd.strFutMarketName
            ,cd.intFutureMarketId
            ,cd.strFutureMonth
            ,cd.intFutureMonthId
            ,cd.strCommodityCode
            ,cd.intCommodityId
            ,cd.strItemNo
            ,cd.intItemId as intItemId
            ,cd.strOrgin
            ,cd.intOriginId
            ,cd.strPosition
            ,RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5)+'-'+RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod
			,SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8) AS strPeriodTo
            ,cd.strPricingStatus as strPriOrNotPriOrParPriced
            ,cd.intPricingTypeId
            ,cd.strPricingType
			,cd.dblRatio
			,isnull(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN 
							isnull(cd.dblBasis,0) 
						ELSE 
							0 
					END,0) / case when ysnSubCurrency = 1 then 100 else 1 end dblContractBasis
			,isnull(cd.dblBasis,0) dblDummyContractBasis
            ,CASE WHEN cd.intPricingTypeId=6 THEN
					dblCashPrice 
				ELSE 
					null 
			 END dblCash
			,dblFuturePrice as dblFuturesClosingPrice1
			,CASE WHEN cd.intPricingTypeId=2 THEN 
					dblFuturePrice
				ELSE                                                        
					case when cd.intPricingTypeId in(1,3) then isnull(p.dblFutures,0) else dblFuture end 
			 END AS dblFutures
			 ,(SELECT TOP 1 dblRatio FROM tblRKM2MBasisDetail temp 
					LEFT JOIN  tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
				WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and isnull(temp.intFutureMarketId,0) = CASE WHEN isnull(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
				AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' 
						THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,cd.dtmEndDate),106),8))  END else isnull(temp.strPeriodTo,'') end
				) AS dblMarketRatio
			,isnull((SELECT top 1 (isnull(dblBasisOrDiscount,0)+isnull(dblCashOrFuture,0))
									/ case when c.ysnSubCurrency= 1 then 100 else 1 end FROM tblRKM2MBasisDetail temp 
					LEFT join  tblSMCurrency c on temp.intCurrencyId=c.intCurrencyID
				WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and isnull(temp.intFutureMarketId,0) = CASE WHEN isnull(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
				AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' 
						THEN NULL ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,cd.dtmEndDate),106),8))  END else isnull(temp.strPeriodTo,'') end
				),0) AS dblMarketBasis1
			,isnull((SELECT top 1 intCommodityUnitMeasureId as dblMarketBasisUOM FROM tblRKM2MBasisDetail temp 
				JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
				WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and isnull(temp.intFutureMarketId,0) = CASE WHEN isnull(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
				AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL 
					   ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,cd.dtmEndDate),106),8))  END else isnull(temp.strPeriodTo,'') end
				),0) AS dblMarketBasisUOM
			,isnull((SELECT top 1 intCurrencyId as intMarketBasisCurrencyId FROM tblRKM2MBasisDetail temp 
				JOIN tblICCommodityUnitMeasure cum on cum.intCommodityId=temp.intCommodityId and temp.intUnitMeasureId=cum.intUnitMeasureId
				WHERE temp.intM2MBasisId=@intM2MBasisId and temp.intCommodityId=@intCommodityId
				and isnull(temp.intFutureMarketId,0) = CASE WHEN isnull(temp.intFutureMarketId,0)= 0 THEN 0 ELSE cd.intFutureMarketId END
				and isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE cd.intItemId END
				and isnull(temp.intContractTypeId,0) = CASE WHEN isnull(temp.intContractTypeId,0)= 0 THEN 0 ELSE cd.intContractTypeId  END
				AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(cd.intCompanyLocationId,0)  END
				AND isnull(temp.strPeriodTo,'') = case when @ysnEnterForwardCurveForMarketBasisDifferential= 1 THEN CASE WHEN isnull(temp.strPeriodTo,0)= '' THEN NULL 
					   ELSE (RIGHT(CONVERT(VARCHAR(11),convert(datetime,cd.dtmEndDate),106),8))  END else isnull(temp.strPeriodTo,'') end
				),0) AS intMarketBasisCurrencyId
			,dblFuturePrice as dblFuturePrice1
			,intFuturePriceCurrencyId
			,CONVERT(int,cd.intContractTypeId) intContractTypeId
			,cd.dblRate
			,cuc.intCommodityUnitMeasureId
			,cuc1.intCommodityUnitMeasureId intQuantityUOMId
			,cuc2.intCommodityUnitMeasureId intPriceUOMId
			,cd.intCurrencyId
			,convert(int,cuc3.intCommodityUnitMeasureId) PriceSourceUOMId
			,isnull(dblCosts,0) dblCosts
			,cd.dblBalance  as dblContractOriginalQty
			,cd.ysnSubCurrency
			,cd.intMainCurrencyId
			,cd.intCent
			,cd.dtmPlannedAvailabilityDate
            ,cd.intCompanyLocationId
			,cd.intMarketZoneId
			,cd.intContractStatusId
			,dtmContractDate
			,ffm.ysnExpired
			,cd.dblInvoicedQuantity
			,dblPricedQty
			,dblUnPricedQty
			,dblPricedAmount
			,strMarketZoneCode
			,strLocationName
			,cd.dblNoOfLots
			,cd.dblLotsFixed
			,cd.dblPriceWORollArb
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
)t

-- intransit
INSERT INTO @tblFinalDetail (
                intContractHeaderId
                ,intContractDetailId
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
                ,strPeriodTo
                ,strPriOrNotPriOrParPriced 
                ,intPricingTypeId 
                ,strPricingType 
    ,dblFutures
                ,dblCash
                ,dblCosts
                ,dblMarketBasis1
                ,dblMarketBasisUOM
                ,intMarketBasisCurrencyId
                ,dblContractRatio
                ,dblContractBasis
                ,dblDummyContractBasis
                ,dblFuturePrice1 
                ,intFuturePriceCurrencyId
                ,dblFuturesClosingPrice1 
                ,intContractTypeId 
    ,intConcurrencyId 
                ,dblOpenQty 
                ,dblRate 
                ,intCommodityUnitMeasureId
                ,intQuantityUOMId 
                ,intPriceUOMId 
                ,intCurrencyId 
                ,PriceSourceUOMId 
                ,dblMarketRatio
                ,dblMarketBasis 
    ,dblCashPrice 
                ,dblAdjustedContractPrice 
                ,dblFuturesClosingPrice 
                ,dblFuturePrice 
                ,dblResult 
                ,dblMarketFuturesResult 
                ,dblResultCash1 
                ,dblContractPrice 
    ,dblResultCash 
                ,dblResultBasis
                ,dblShipQty
                ,ysnSubCurrency
                ,intMainCurrencyId
                ,intCent
                ,dtmPlannedAvailabilityDate
                ,intMarketZoneId  
                ,intCompanyLocationId
                ,strMarketZoneCode
                ,strLocationName 
                ,dblNoOfLots
                ,dblLotsFixed
                ,dblPriceWORollArb
) 
SELECT DISTINCT 
                intContractHeaderId
                ,intContractDetailId 
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
                ,strPeriodTo
                ,strPriOrNotPriOrParPriced 
                ,intPricingTypeId 
                ,strPricingType 
    ,dblFutures
                ,dblCash
                ,dblCosts
                ,dblMarketBasis1
                ,dblMarketBasisUOM
                ,intMarketBasisCurrencyId
                ,dblContractRatio
                ,dblContractBasis 
                ,dblDummyContractBasis
                ,dblFuturePrice1 
                ,intFuturePriceCurrencyId
                ,dblFuturesClosingPrice1
                ,intContractTypeId 
    ,intConcurrencyId 
                ,dblOpenQty 
                ,dblRate 
                ,intCommodityUnitMeasureId 
                ,intQuantityUOMId 
                ,intPriceUOMId 
                ,intCurrencyId 
                ,PriceSourceUOMId 
                ,dblMarketRatio
                ,dblMarketBasis 
    ,dblCashPrice 
                ,dblAdjustedContractPrice 
                ,dblFuturesClosingPrice 
                ,dblFuturePrice 
                ,dblResult 
                ,dblMarketFuturesResult 
                ,dblResultCash1 
                ,dblContractPrice 
    ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
                ,dblResultBasis
                ,0 as dblShipQty
                ,ysnSubCurrency
                ,intMainCurrencyId
                ,intCent
                ,dtmPlannedAvailabilityDate
                ,intMarketZoneId
                ,intCompanyLocationId
                ,strMarketZoneCode
                ,strLocationName
                ,dblNoOfLots
                ,dblLotsFixed
                ,dblPriceWORollArb 
FROM(
                SELECT 
                                *
                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult
                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis
                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult
                                ,(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
                                ,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+(isnull(dblFutures,0)*isnull(dblContractRatio,1)) dblContractPrice
                FROM (
                                SELECT 
                                                *
                                                ,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
                                                ,case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice
                                                ,CASE WHEN intPricingTypeId = 6  then  isnull(dblCosts,0)+(isnull(dblCash,0)) + CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate,0)=0 then dblFutures else dblFutures end) + isnull(dblCosts,0) end dblAdjustedContractPrice
                                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice
                                                ,dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturePrice1) as dblFuturePrice
                                                ,(isnull(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblOpenQty1 else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblOpenQty1,0))end),0))
                                                                -(isnull(convert(decimal(24,6),case when isnull(intCommodityUnitMeasureId,0) = 0 then dblInvoicedQuantity else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,isnull(dblInvoicedQuantity,0))end),0))
                                                as dblOpenQty
                                FROM (
                                                SELECT  distinct  
                                                                cd.intContractHeaderId
                                                                ,cd.intContractDetailId
                                                                ,'In-transit'+'(S)'  as strContractOrInventoryType
                ,cd.strContractSeq
                ,cd.strEntityName
                ,cd.intEntityId
                ,cd.strFutMarketName
                ,cd.intFutureMarketId
                ,cd.strFutureMonth
                ,cd.intFutureMonthId
                ,cd.strCommodityCode
                ,cd.intCommodityId
                ,cd.strItemNo
                ,cd.intItemId
                ,cd.strOrgin
                ,cd.intOriginId
                ,cd.strPosition
                ,cd.strPeriod
                                                                ,cd.strPeriodTo
                ,cd.strPriOrNotPriOrParPriced
                ,cd.intPricingTypeId
                ,cd.strPricingType
                                                                ,cd.dblContractRatio
                ,cd.dblContractBasis
                                                                ,dblDummyContractBasis
                ,cd.dblFutures
                                                                ,cd.dblCash
                                                                ,cd.dblMarketRatio
                ,cd.dblMarketBasis1  
                ,cd.dblMarketBasisUOM
                                                                ,cd.intMarketBasisCurrencyId                                                             
                ,cd.dblFuturePrice1
                                                                ,cd.intFuturePriceCurrencyId
                ,cd.dblFuturesClosingPrice1                         
                ,cd.intContractTypeId 
                                                                ,0 as intConcurrencyId 
                                                                
                                                                

				,(select SUM(dblQuantity) a from tblICInventoryShipmentItem where intLineNo=cd.intContractDetailId) 
				-
				ISNULL((SELECT  SUM(ad.dblQtyShipped) FROM tblARInvoice ia
				JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId 
				WHERE cd.intContractDetailId= ad.intContractDetailId and ysnPosted=1 
				and intInventoryShipmentChargeId IS NULL),0) dblOpenQty1
				
                ,cd.dblRate
                ,cd.intCommodityUnitMeasureId
                                                                ,cd.intQuantityUOMId
                                                                ,cd.intPriceUOMId
                                                                ,cd.intCurrencyId
                ,cd.PriceSourceUOMId 
                                                                ,cd.dblCosts
                                                                ,cd.ysnSubCurrency
                                                                ,cd.intMainCurrencyId
                                                                ,cd.intCent
                                                                ,cd.dtmPlannedAvailabilityDate
                                                                ,cd.dblInvoicedQuantity
                                                                ,cd.intMarketZoneId
                                                                ,cd.intCompanyLocationId
                                                                ,cd.strMarketZoneCode
                                                                ,cd.strLocationName 
                                                                ,cd.dblNoOfLots
                                                                ,cd.dblLotsFixed
                                                                ,cd.dblPriceWORollArb 
                                                FROM tblICInventoryTransaction it
                                JOIN tblICInventoryShipment b on b.strShipmentNumber=it.strTransactionId  
                                JOIN tblICInventoryShipmentItem c on c.intInventoryShipmentId=b.intInventoryShipmentId and b.ysnPosted=1 
                                join tblICItem i on c.intItemId=i.intItemId
                                JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
                                JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
                                JOIN tblICItemLocation il ON it.intItemId = i.intItemId and it.intItemLocationId=il.intItemLocationId and il.strDescription='In-Transit'                
                                JOIN tblEMEntity e on b.intEntityCustomerId=e.intEntityId
                                JOIN tblSMCompanyLocation l on b.intShipFromLocationId = l.intCompanyLocationId       
                                JOIN @tblOpenContractList cd on cd.intContractDetailId = c.intLineNo                                                     
                                LEFT JOIN tblSCTicket t ON c.intSourceId = t.intTicketId AND b.intSourceType = 1 --Source Type is Scale
                             
                                )t       
                )t
)t2

    

IF ISNULL(@ysnIncludeInventoryM2M,0) = 1
BEGIN
	INSERT INTO @tblFinalDetail (
		intContractHeaderId
		,intContractDetailId
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
		,strPeriodTo
		,strPriOrNotPriOrParPriced 
		,intPricingTypeId 
		,strPricingType 
		,dblFutures
		,dblCash
		,dblCosts
		,dblMarketBasis1
		,dblMarketBasisUOM
		,intMarketBasisCurrencyId
		,dblContractRatio
		,dblContractBasis 
		,dblDummyContractBasis
		,dblFuturePrice1 
		,intFuturePriceCurrencyId
		,dblFuturesClosingPrice1 
		,intContractTypeId 
		,intConcurrencyId 
		,dblOpenQty 
		,dblRate 
		,intCommodityUnitMeasureId 
		,intQuantityUOMId 
		,intPriceUOMId 
		,intCurrencyId 
		,PriceSourceUOMId 
		,dblMarketRatio
		,dblMarketBasis 
		,dblCashPrice 
		,dblAdjustedContractPrice 
		,dblFuturesClosingPrice 
		,dblFuturePrice 
		,dblResult 
		,dblMarketFuturesResult 
		,dblResultCash1 
		,dblContractPrice 
		,dblResultCash 
		,dblResultBasis
		,dblShipQty
		,ysnSubCurrency
		,intMainCurrencyId
		,intCent
		,dtmPlannedAvailabilityDate
		,intMarketZoneId  
		,intCompanyLocationId
		,strMarketZoneCode
		,strLocationName 
		,dblNoOfLots
		,dblLotsFixed
		,dblPriceWORollArb
	) 
	SELECT DISTINCT     
		intContractHeaderId
		,intContractDetailId 
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
		, strPeriodTo
		, strPriOrNotPriOrParPriced 
		,intPricingTypeId 
		,strPricingType 
		,dblFutures
		,dblCash
		,dblCosts
		,dblMarketBasis1
		,dblMarketBasisUOM
		,intMarketBasisCurrencyId
		,dblContractRatio
		,dblContractBasis 
		,dblDummyContractBasis
		,dblFuturePrice1 
		,intFuturePriceCurrencyId
		,dblFuturesClosingPrice1 
		,intContractTypeId 
		,intConcurrencyId 
		,dblOpenQty 
		,dblRate 
		,intCommodityUnitMeasureId 
		,intQuantityUOMId 
		,intPriceUOMId 
		,intCurrencyId 
		,PriceSourceUOMId 
		,dblMarketRatio
		,dblMarketBasis 
		,dblCashPrice 
		,dblAdjustedContractPrice 
		,dblFuturesClosingPrice 
		,dblFuturePrice 
		,dblResult 
		,dblMarketFuturesResult 
		,dblResultCash1 
		,dblContractPrice 
		,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
		,dblResultBasis
		,0 as dblShipQty
		,ysnSubCurrency
		,intMainCurrencyId
		,intCent
		,dtmPlannedAvailabilityDate
		,intMarketZoneId 
		,intCompanyLocationId 
		,strMarketZoneCode
		,strLocationName 
		,dblNoOfLots
		,dblLotsFixed
		,dblPriceWORollArb
	FROM(
		SELECT 
			*
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult
			,(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty1,0))) dblResultCash1
			,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)),0)+(isnull(dblFutures,0) * isnull(dblContractRatio,1)) dblContractPrice
		FROM (
			SELECT 
				*
				,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
				,case when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice
				,case WHEN intPricingTypeId = 6  then  
						isnull(dblCosts,0)+(isnull(dblCash,0)) 
					else 
						convert(decimal(24,6),
								case when isnull(dblRate,0)=0 then 
										dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
									else
										case when (case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId THEN 
												dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
											else 
												dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) 
										end 
								end) 
						+ 
						convert(decimal(24,6), 
								case when isnull(dblRate,0)=0 then 
										dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
									else
										case when (case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId THEN 
												dblFutures*dblRate 
											else 
												dblFutures 
										end 
								end) 
						+ 
						isnull(dblCosts,0)
				 end dblAdjustedContractPrice
				,dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,dblFuturesClosingPrice1) as dblFuturesClosingPrice
				,dblFuturePrice1  as dblFuturePrice
				,isnull( convert(decimal(24,6),
									case when isnull(intCommodityUnitMeasureId,0) = 0 then 
											dblOpenQty1 
										else 
											dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblOpenQty1)
									end),0) as dblOpenQty
			FROM (
				SELECT DISTINCT  
					cd.intContractHeaderId
					, cd.intContractDetailId
					,'Inventory (P)' as strContractOrInventoryType
					,cd.strContractSeq
					,cd.strEntityName
					,cd.intEntityId
					,cd.strFutMarketName
					,cd.intFutureMarketId
					,cd.strFutureMonth
					,cd.intFutureMonthId
					,cd.strCommodityCode
					,cd.intCommodityId
					,cd.strItemNo
					,cd.intItemId
					,cd.strOrgin
					,cd.intOriginId
					,cd.strPosition
					, cd.strPeriod
					, cd.strPeriodTo
					, cd.strPriOrNotPriOrParPriced
					,cd.intPricingTypeId
					,cd.strPricingType
					,cd.dblContractRatio
					,cd.dblContractBasis
					,cd.dblDummyContractBasis
					,cd.dblFutures
					,cd.dblCash
					,cd.dblMarketRatio
					,cd.dblMarketBasis1
					,cd.dblMarketBasisUOM
					,cd.intMarketBasisCurrencyId
					,cd.dblFuturePrice1
					,cd.intFuturePriceCurrencyId
					,cd.dblFuturesClosingPrice1
					,cd.intContractTypeId 
					,0 as intConcurrencyId 
					,dblLotQty dblOpenQty1
					,cd.dblRate
					,cd.intCommodityUnitMeasureId
					,cd.intQuantityUOMId
					,cd.intPriceUOMId
					,cd.intCurrencyId
					,cd.PriceSourceUOMId
					,cd.dblCosts
					,cd.dblInvoicedQuantity dblInvoiceQty
					,cd.ysnSubCurrency
					,cd.intMainCurrencyId
					,cd.intCent
					,cd.dtmPlannedAvailabilityDate
					,cd.intMarketZoneId
					,cd.intCompanyLocationId 
					,cd.strMarketZoneCode
					,cd.strLocationName
					,cd.dblNoOfLots
					,cd.dblLotsFixed
					,cd.dblPriceWORollArb
				FROM @tblOpenContractList cd
					JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId =l.intContractDetailId
					JOIN tblICItem i on cd.intItemId= i.intItemId and i.strLotTracking<>'No'
				WHERE cd.intCommodityId= @intCommodityId
			)t 
		)t1
	)t2 
	WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 then 'Inventory (P)' else '' end 

END


---- contract
INSERT INTO @tblFinalDetail (
	intContractHeaderId
	,intContractDetailId 
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
	,strPeriodTo
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
    ,dblFutures
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,intMarketBasisCurrencyId
	,dblContractRatio
	,dblContractBasis
	,dblDummyContractBasis 
	,dblFuturePrice1 
	,intFuturePriceCurrencyId
	,dblFuturesClosingPrice1 
	,intContractTypeId 
    ,intConcurrencyId 
	,dblOpenQty 
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,dblMarketRatio
	,dblMarketBasis 
    ,dblCashPrice 
	,dblAdjustedContractPrice 
	,dblFuturesClosingPrice 
	,dblFuturePrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
    ,dblResultCash 
	,dblResultBasis
	,ysnSubCurrency
	,intMainCurrencyId
	,intCent
	,dtmPlannedAvailabilityDate
	,dblPricedQty
	,dblUnPricedQty
	,dblPricedAmount
	,intMarketZoneId 
	,intCompanyLocationId
	,strMarketZoneCode
	,strLocationName 
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb
) 
SELECT DISTINCT   
	intContractHeaderId
	,intContractDetailId 
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
	,strPeriodTo
	,strPriOrNotPriOrParPriced 
	,intPricingTypeId 
	,strPricingType 
    ,dblFutures
	,dblCash
	,dblCosts
	,dblMarketBasis1
	,dblMarketBasisUOM
	,intMarketBasisCurrencyId
	,dblContractRatio
	,dblContractBasis 
	,dblDummyContractBasis
	,dblFuturePrice1 
	,intFuturePriceCurrencyId
	,dblFuturesClosingPrice1 
	,intContractTypeId 
    ,0 as intConcurrencyId 
	,dblOpenQty 
	,dblRate 
	,intCommodityUnitMeasureId 
	,intQuantityUOMId 
	,intPriceUOMId 
	,intCurrencyId 
	,PriceSourceUOMId 
	,dblMarketRatio
	,dblMarketBasis 
    ,dblCashPrice 
	,dblAdjustedContractPrice
	,dblFuturePrice 
	,dblFuturePrice 
	,dblResult 
	,dblMarketFuturesResult 
	,dblResultCash1 
	,dblContractPrice 
    ,case when intPricingTypeId=6 THEN dblResult else 0 end dblResultCash
	,dblResultBasis
	,ysnSubCurrency
	,intMainCurrencyId
	,intCent
	,dtmPlannedAvailabilityDate
	,dblPricedQty
	,dblUnPricedQty
	,dblPricedAmount
	,intMarketZoneId
	,intCompanyLocationId,
	strMarketZoneCode
	,strLocationName  
	,dblNoOfLots
	,dblLotsFixed
	,dblPriceWORollArb
FROM(
	SELECT 
		*
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResult
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblResultBasis
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) as dblMarketFuturesResult
		,(isnull(dblMarketBasis,0)-isnull(dblCash,0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,isnull(intPriceUOMId,intCommodityUnitMeasureId),isnull(dblOpenQty,0))) dblResultCash1
		,0 dblContractPrice
	FROM (
		SELECT 
			*
			,CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,case when isnull(dblMarketBasisUOM,0)=0 then PriceSourceUOMId else dblMarketBasisUOM end,isnull(dblMarketBasis1,0)) ELSE 0 END dblMarketBasis
			,CASE when intPricingTypeId<>6 then 0 else  isnull(dblFuturesClosingPrice1,0)+isnull(dblMarketBasis1,0) end dblCashPrice
			,CASE WHEN intPricingTypeId = 6  THEN  
					isnull(dblCosts,0)+(isnull(dblCash,0)) 
				ELSE 
					CONVERT(DECIMAL(24,6),
								CASE WHEN ISNULL(dblRate,0)=0 THEN 
										dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
									ELSE
										CASE WHEN (case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end) <> @intCurrencyUOMId THEN 
													dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*isnull(dblRate,0) 
												ELSE
													dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) 
										END 
								END) 
					+ 
					CONVERT(decimal(24,6), 
								case when isnull(dblRate,0)=0 then 
										dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
									else
										case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId THEN 
												dblFutures*isnull(dblRate,0) 
											else 
												dblFutures 
										end 
								end) 
					+ 
					isnull(dblCosts,0)
			 END AS dblAdjustedContractPrice
			 ,dblFuturePrice1 as dblFuturePrice
			 ,convert(decimal(24,6),
						case when isnull(intCommodityUnitMeasureId,0) = 0 then 
								dblContractOriginalQty 
							else 
								dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblContractOriginalQty) 
						end)
				-
				isnull(convert(decimal(24,6),
								case when isnull(intCommodityUnitMeasureId,0) = 0 then 
										InTransQty 
									else 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,InTransQty)
								end),0)
				-
				isnull(convert(decimal(24,6),
								case when isnull(intCommodityUnitMeasureId,0) = 0 then 
										dblInvoicedQuantity 
									else 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,case when isnull(intQuantityUOMId,0)=0 then intCommodityUnitMeasureId else intQuantityUOMId end,dblInvoicedQuantity)
								end),0)
				as dblOpenQty
			FROM(
				SELECT 
					cd.intContractHeaderId
					,cd.intContractDetailId
					,cd.strContractOrInventoryType
					,cd.strContractSeq
					,cd.strEntityName
					,cd.intEntityId
					,cd.strFutMarketName
					,cd.intFutureMarketId
					,cd.strFutureMonth
					,cd.intFutureMonthId
					,cd.strCommodityCode
					,cd.intCommodityId
					,cd.strItemNo
					,cd.intItemId
					,cd.strOrgin
					,cd.intOriginId
					,cd.strPosition
					,cd.strPeriod
					,cd.strPeriodTo
					,cd.strPriOrNotPriOrParPriced
					,cd.intPricingTypeId
					,cd.strPricingType
					,cd.dblContractRatio
					,cd.dblContractBasis
					,cd.dblDummyContractBasis
					,cd.dblCash
					,cd.dblFuturesClosingPrice1
					,cd.dblFutures 
					,cd.dblMarketRatio
					,cd.dblMarketBasis1
					,cd.dblMarketBasisUOM
					,cd.intMarketBasisCurrencyId
					,cd.dblFuturePrice1
					,cd.intFuturePriceCurrencyId
					,cd.intContractTypeId 
					,cd.dblRate
					,cd.intCommodityUnitMeasureId
					,cd.intQuantityUOMId
					,cd.intPriceUOMId
					,cd.intCurrencyId
					,convert(int,cd.PriceSourceUOMId) PriceSourceUOMId
					,cd.dblCosts
					,cd.dblContractOriginalQty
					,LG.dblQuantity as InTransQty
					,cd.dblInvoicedQuantity
					,cd.ysnSubCurrency
					,cd.intMainCurrencyId
					,cd.intCent
					,cd.dtmPlannedAvailabilityDate
					,cd.intCompanyLocationId
					,cd.intMarketZoneId
					,cd.intContractStatusId
					,cd.dtmContractDate
					,cd.ysnExpired
					,dblPricedQty
					,dblUnPricedQty
					,dblPricedAmount
					,strMarketZoneCode
					,strLocationName
					,cd.dblNoOfLots
					,cd.dblLotsFixed
					,cd.dblPriceWORollArb
				FROM @tblOpenContractList cd
					LEFT JOIN (
						select 
							sum(LD.dblQuantity)dblQuantity
							,PCT.intContractDetailId 
						from tblLGLoad L 
							JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
							JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId and  PCT.dblQuantity > isnull(PCT.dblInvoicedQty,0)
						group by PCT.intContractDetailId
						union 
						select 
							sum(LD.dblQuantity)dblQuantity
							,PCT.intContractDetailId 
						from tblLGLoad L 
							JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
							JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId and  PCT.dblQuantity > PCT.dblInvoicedQty
						group by PCT.intContractDetailId
						) AS LG 
							ON LG.intContractDetailId = cd.intContractDetailId
			)t 
		)t where  isnull(dblOpenQty,0) >0 
	)t1 


	SELECT 
		*
		,isnull(dblContractBasis,0) + (isnull(dblFutures,0) * isnull(dblContractRatio,1)) as dblContractPrice
		--,convert(decimal(24,6),(isnull(dblAdjustedContractPrice,0)-isnull(dblMarketPrice,0))*isnull(dblResult1,0)) dblResult
		,convert(decimal(24,6),((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))*isnull(dblResultBasis1,0)) + convert(decimal(24,6),((isnull(dblFutures,0)- isnull(dblFuturePrice,0))*isnull(dblMarketFuturesResult1,0))) dblResult
		,convert(decimal(24,6),((isnull(dblContractBasis,0)+isnull(dblCosts,0))-isnull(dblMarketBasis,0))*isnull(dblResultBasis1,0)) dblResultBasis
		,convert(decimal(24,6),((isnull(dblFutures,0)- isnull(dblFuturePrice,0))*isnull(dblMarketFuturesResult1,0))) dblMarketFuturesResult
		,case when strPricingType='Cash' then 
				convert(decimal(24,6),(isnull(dblCash,0)-isnull(dblCashPrice,0))*isnull(dblResult1,0))
			else 
				null 
		 end as dblResultCash 			  
	INTO #Temp   
	FROM(
		SELECT 
			intContractHeaderId
			,intContractDetailId
			,strContractOrInventoryType
			,strContractSeq
			,strEntityName
			,intEntityId
			,strFutMarketName
			,intFutureMarketId
			,intFutureMonthId
			,strFutureMonth
			,dblContractRatio
			,strCommodityCode
			,intCommodityId
			,strItemNo
			,intItemId
			,intOriginId
			,strOrgin
			,strPosition
			,strPeriod
			,strPeriodTo
			,strPriOrNotPriOrParPriced
			,case when intContractTypeId =2 then  
					-dblOpenQty 
				else 
					dblOpenQty 
			 end dblOpenQty 
			,intPricingTypeId
			,strPricingType
			,convert(decimal(24,6),
						case when isnull(dblRate,0)=0 then 
								dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblDummyContractBasis,0))
							else
								case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblDummyContractBasis,0))*dblRate 
									else 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblDummyContractBasis,0)) 
								end 
						end) as dblDummyContractBasis
			,case when @ysnCanadianCustomer= 1 then 
					dblContractBasis 
				else 
				convert(decimal(24,6),
						case when isnull(dblRate,0)=0 then 
								dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
							else
								case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
									else 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) 
								end 
						end) 
				end as dblContractBasis
				--/case when isnull(ysnSubCurrency,0) = 1  then 100 else 1 end
			,convert(decimal(24,6),
						case when isnull(dblRate,0)=0 then 
								dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))
							else
								case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0))*dblRate 
									else 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblContractBasis,0)) 
								end 
						end) as dblCanadianContractBasis
			,case when @ysnCanadianCustomer= 1 then 
					dblFutures 
				else 
					convert(decimal(24,6), 
								case when isnull(dblRate,0)=0 then 
										dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
									else
										case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then 
												dblFutures*dblRate 
											else 
												dblFutures 
										end 
								end) 
			 end as dblFutures
			,convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCash)) as dblCash
			,convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblCosts)) as dblCosts
			,dblMarketRatio
			,case when @ysnCanadianCustomer= 1 then 
					dblMarketBasis 
				else 
				convert(decimal(24,6),
						case when isnull(dblRate,0)=0 then 
								dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblMarketBasis,0))
							else
								case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblMarketBasis,0))*dblRate 
									else 
										dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,isnull(dblMarketBasis,0)) 
								end 
						end) 
				end as dblMarketBasis
			,intMarketBasisCurrencyId
			,dblFuturePrice1 as dblFuturePrice
			,intFuturePriceCurrencyId
			,convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice
			,CONVERT(int,intContractTypeId) as intContractTypeId,CONVERT(int,0) as intConcurrencyId
			,dblAdjustedContractPrice
			,dblCashPrice as dblCashPrice
			,case when ysnSubCurrency=1 then 
					(convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash))) / isnull(intCent,0) 
				else 
					convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,case when isnull(PriceSourceUOMId,0)=0 then intPriceUOMId else PriceSourceUOMId end,dblResultCash)) 
			 end as dblResultCash1
			,dblResult as dblResult1
			,case when isnull(@ysnIncludeBasisDifferentialsInResults,0) =0 then 0 else  dblResultBasis  end as dblResultBasis1
			,dblMarketFuturesResult  as dblMarketFuturesResult1            
			,intQuantityUOMId
			,intCommodityUnitMeasureId
			,intPriceUOMId
			,intCent
			,dtmPlannedAvailabilityDate
			,CONVERT(decimal(24,6),
						case when isnull(dblRate,0)=0 then 
								dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end,@intCurrencyUOMId)* dblFutures
							else
								case when case when ysnSubCurrency = 1 then intMainCurrencyId else intCurrencyId end <> @intCurrencyUOMId then 
										dblFutures*dblRate 
									else 
										dblFutures 
								end 
						end) dblCanadianFutures	
			,dblPricedQty
			,dblUnPricedQty
			,dblPricedAmount
			,intCompanyLocationId
			,intMarketZoneId
			,strMarketZoneCode
			,strLocationName
			,dblNotLotTrackedPrice
			,dblInvFuturePrice
			,dblInvMarketBasis
			,dblNoOfLots
			,dblLotsFixed
			,dblPriceWORollArb
			,intCurrencyId
		FROM @tblFinalDetail 
	)t 
	ORDER BY intCommodityId,strContractSeq DESC    


------------- Calculation of Results ----------------------
   UPDATE #Temp set 
 
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
if isnull(@ysnIncludeInventoryM2M,0) = 1
BEGIN
INSERT INTO #Temp (
	strContractOrInventoryType 
	,strCommodityCode 
	,intCommodityId 
	,strItemNo 
	,intItemId 						
	,strLocationName
	,strFutureMonth
	,intFutureMonthId
	,intFutureMarketId
	,strFutMarketName
	,dblNotLotTrackedPrice
	,dblInvFuturePrice
	,dblInvMarketBasis
	,dblOpenQty 
	,dblResult
)
select * from(
SELECT 
	strContractOrInventoryType
	,strCommodityCode
	,intCommodityId
	,strItemNo
	,intItemId
	,strLocationName
	,strFutureMonth
	,intFutureMonthId
	,intFutureMarketId
	,strFutMarketName
	,dblNotLotTrackedPrice
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(intToPriceUOM,intFutMarketCurrency,
												(SELECT TOP 1  dblLastSettle
												FROM tblRKFuturesSettlementPrice p
												INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
												WHERE p.intFutureMarketId = t1.intFutureMarketId AND pm.intFutureMonthId = t1.intFutureMonthId													
												ORDER BY dtmPriceDate DESC)) dblInvFuturePrice
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(intToPriceUOM,PriceSourceUOMId,isnull(dblInvMarketBasis, 0) ) dblInvMarketBasis												
	,sum(dblOpenQty) dblOpenQty
	,sum(dblOpenQty1) dblResult --,sum(dblOpenQty1) a
FROM(
	SELECT DISTINCT      
		'Inventory' as strContractOrInventoryType
		,iv.strLocationName
		,c.strCommodityCode
		,iv.intCommodityId
		,iv.strItemNo
		,iv.intItemId as intItemId
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId,cu.intCommodityUnitMeasureId,isnull(iv.dblOnHand, 0) ) dblOpenQty
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId,cu2.intCommodityUnitMeasureId,isnull(iv.dblOnHand, 0) ) dblOpenQty1
		,isnull((SELECT TOP 1 intUnitMeasureId FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId 
				  AND isnull(temp.intFutureMarketId,0) = CASE WHEN isnull(temp.intFutureMarketId,0)= 0 THEN 0 ELSE c.intFutureMarketId END
				  AND isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE iv.intItemId END					
				  AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(iv.intLocationId,0)  END
			  	  AND temp.strContractInventory='Inventory'),0) as PriceSourceUOMId
		,isnull((SELECT TOP 1 isnull(dblBasisOrDiscount,0) FROM tblRKM2MBasisDetail temp 
                  WHERE temp.intM2MBasisId=@intM2MBasisId 
                  AND temp.intItemId = iv.intItemId 
				  AND isnull(temp.intFutureMarketId,0) = CASE WHEN isnull(temp.intFutureMarketId,0)= 0 THEN 0 ELSE c.intFutureMarketId END
				  AND isnull(temp.intItemId,0) = CASE WHEN isnull(temp.intItemId,0)= 0 THEN 0 ELSE iv.intItemId END					
				  AND isnull(temp.intCompanyLocationId,0) = CASE WHEN isnull(temp.intCompanyLocationId,0)= 0 THEN 0 ELSE isnull(iv.intLocationId,0)  END
			  	  AND temp.strContractInventory='Inventory'),0) as dblInvMarketBasis
		,(SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId  ORDER BY 1 DESC) strFutureMonth
		,(SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId  ORDER BY 1 DESC) intFutureMonthId
		,c.intFutureMarketId
		,fm.strFutMarketName
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(cu2.intCommodityUnitMeasureId,cu1.intCommodityUnitMeasureId,isnull(p.dblAverageCost, 0) ) dblNotLotTrackedPrice				
		, cu2.intCommodityUnitMeasureId  intToPriceUOM,cu3.intCommodityUnitMeasureId intFutMarketCurrency
	FROM vyuICGetItemStockUOM iv 
		join tblICCommodity c on iv.intCommodityId=c.intCommodityId and ysnStockUnit=1
		join tblRKFutureMarket fm on c.intFutureMarketId=fm.intFutureMarketId
		JOIN tblICCommodityUnitMeasure cu on cu.intCommodityId=c.intCommodityId and cu.intUnitMeasureId=@intQuantityUOMId    
		JOIN tblICCommodityUnitMeasure cu2 on cu2.intCommodityId=c.intCommodityId and cu2.intUnitMeasureId=@intPriceUOMId  
		JOIN tblICCommodityUnitMeasure cu1 on cu1.intCommodityId=c.intCommodityId and isnull(cu1.ysnStockUOM,0)=1
		JOIN tblICCommodityUnitMeasure cu3 on cu3.intCommodityId=@intCommodityId and cu3.intUnitMeasureId=fm.intUnitMeasureId  
		LEFT JOIN tblICItemPricing p on iv.intItemId = p.intItemId and iv.intItemLocationId=p.intItemLocationId  
	WHERE iv.intCommodityId= @intCommodityId and iv.strLotTracking='No' and iv.dblOnHand <> 0
		AND strLocationName= case when isnull(@strLocationName,'')='' then strLocationName else @strLocationName end
	)t1 
GROUP BY
	strContractOrInventoryType
	,strCommodityCode
	,intCommodityId
	,strItemNo
	,intItemId
	,PriceSourceUOMId
	,strLocationName
	,strFutureMonth
	,intFutureMonthId
	,intFutureMarketId
	,strFutMarketName
	,dblNotLotTrackedPrice
	,dblInvMarketBasis
	,intToPriceUOM
	,PriceSourceUOMId
	,intFutMarketCurrency)t2 WHERE isnull(dblOpenQty,0) >0
				
END

DECLARE @strM2MCurrency NVARCHAR(20),
		@dblRateConfiguration NUMERIC(18,6)

SELECT @strM2MCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyUOMId


SELECT TOP 1 
	@dblRateConfiguration = [dblRate]
FROM 
	[vyuSMForex] 
WHERE 
	[intFromCurrencyId] = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'CAD')
	AND [intToCurrencyId] = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') 
	AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
ORDER BY
	[dtmValidFromDate] DESC

DECLARE @intCurrencyExchangeRateId INT
SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
FROM tblSMCurrencyExchangeRate CER
INNER JOIN tblSMCurrency Cur1 ON CER.intFromCurrencyId = Cur1.intCurrencyID
INNER JOIN tblSMCurrency Cur2 ON CER.intToCurrencyId = Cur2.intCurrencyID
WHERE Cur1.strCurrency = 'CAD' AND Cur2.strCurrency = 'USD'

---------------------------------
SELECT intRowNum = CONVERT(INT,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC))
	, intConcurrencyId = 0
	, intContractHeaderId
	, intContractDetailId
	, strContractOrInventoryType
	, strContractSeq
	, strEntityName
	, intEntityId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dblOpenQty dblOpenQty
	, strCommodityCode
	, intCommodityId
	, intItemId
	, strItemNo
	, strOrgin
	, strPosition
	, strPeriod
	, strPeriodTo
	, strPriOrNotPriOrParPriced
	, intPricingTypeId
	, strPricingType
	, dblContractRatio
	, dblContractBasis
	, dblFutures
	, dblCash
	, dblCosts
	, dblMarketBasis
	, dblMarketRatio
	, dblFuturePrice
	, intContractTypeId
	, dblAdjustedContractPrice
	, dblCashPrice
	, dblMarketPrice
	, dblResultBasis
	, dblResultCash
	, dblContractPrice
	, intQuantityUOMId
	, intCommodityUnitMeasureId
	, intPriceUOMId
	, intCent
	, dtmPlannedAvailabilityDate
	, dblPricedQty
	, dblUnPricedQty
	, dblPricedAmount
	, intCompanyLocationId
	, intMarketZoneId
	, strMarketZoneCode
	, strLocationName 
	, dblResult = (dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty--(dblPricedQty + dblUnPricedQty)
	, dblMarketFuturesResult = (dblFuturePrice - dblActualFutures) * dblOpenQty--(dblPricedQty + dblUnPricedQty)
	, dblResultRatio =  (CASE WHEN dblContractRatio IS NOT NULL AND dblMarketRatio IS NOT NULL
								THEN ((dblMarketPrice - dblContractPrice) * dblOpenQty) -- (dblPricedQty + dblUnPricedQty)
									- ((dblFuturePrice - dblActualFutures) * dblOpenQty) - dblResultBasis --(dblPricedQty + dblUnPricedQty)
							ELSE 0 END)
FROM (
	SELECT DISTINCT intConcurrencyId = 0
		, intContractHeaderId
		, intContractDetailId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dblOpenQty
		, strCommodityCode
		, intCommodityId
		, intItemId
		, strItemNo
		, strOrgin
		, strPosition
		, strPeriod
		, strPeriodTo
		, strPriOrNotPriOrParPriced
		, intPricingTypeId
		, strPricingType
		, dblContractRatio
		--Contract Basis
		, dblContractBasis = (CASE WHEN strPricingType != 'HTA'
									THEN (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
												--CAD/CAD
												THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId THEN dblContractBasis
														--USD/CAD
														WHEN Currency.strCurrency = 'USD'
															THEN (CASE WHEN @strRateType = 'Contract'
																		--Formula: Contract Price - Contract Futures
																		THEN ((ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																			/ ISNULL((SELECT dblRate FROM tblCTContractDetail
																					WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																						AND ISNULL(dblRate, 0) <> 0
																						AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
																						AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration))
																			- (dblCalculatedFutures)
																	--Configuration
																	--Formula: Contract Price - Contract Futures
																	ELSE ((ISNULL(dblContractBasis, 0)
																			+ (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1))
																			+ ISNULL(dblCash, 0)) / @dblRateConfiguration)
																		- dblCalculatedFutures END)
														--Can be used other currency exchange
														ELSE dblContractBasis END)
												ELSE dblContractBasis END)
								ELSE 0 END)
		--Contract Futures
		, dblActualFutures = dblCalculatedFutures
		, dblFutures = (CASE WHEN strPricingType = 'Basis' THEN 0
								ELSE dblCalculatedFutures END)
		, dblCash  --Contract Cash
		, dblCosts = ABS(dblCosts)
		--Market Basis
		, dblMarketBasis = CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
									THEN (CASE WHEN MBCurrency.strCurrency = 'USD' AND FPCurrency.strCurrency = 'USD'
												--USD/CAD
												THEN (CASE WHEN @strRateType = 'Contract'
															--Formula: Market Price - Market Futures
															THEN ((ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice, 0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0))
																/ ISNULL((SELECT dblRate FROM tblCTContractDetail
																		WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																			AND ISNULL(dblRate, 0) <> 0
																			AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
																			AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration))
																- ISNULL(dblFuturePrice, 0)
														--Configuration
														--Formula: Market Price - Market Futures
														ELSE ((ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice, 0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0))
															/ @dblRateConfiguration) - ISNULL(dblFuturePrice, 0) END)
											--When both currencies is not equal to M2M currency
											WHEN intMarketBasisCurrencyId <> @intCurrencyUOMId OR intFuturePriceCurrencyId <> @intCurrencyUOMId
												THEN ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0)
											--Can be used other currency exchange
											ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END)
								ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END
		, dblMarketRatio
		, dblFuturePrice = ISNULL(dblFuturePrice, 0)  --Market Futures
		, intContractTypeId
		, dblAdjustedContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
														--CAD/CAD
														THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts
													WHEN Currency.strCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) +  ISNULL(dblCash, 0) + dblCosts)
																		/ ISNULL((SELECT dblRate FROM tblCTContractDetail
																				WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																					AND ISNULL(dblRate, 0) <> 0
																					AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
																					AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
																--Configuration
																ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts)
																	/ @dblRateConfiguration END)
													--Can be used other currency exchange
													ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts END)
										ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + dblCosts END)
		, dblCashPrice
		--Market Price
		, dblMarketPrice = CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
									THEN (CASE WHEN MBCurrency.strCurrency = 'USD' AND FPCurrency.strCurrency = 'USD'
												--USD/CAD
												THEN (CASE WHEN @strRateType = 'Contract'
															THEN (ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice, 0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0))
																/ ISNULL((SELECT dblRate FROM tblCTContractDetail
																		WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																		AND ISNULL(dblRate, 0) <> 0
																		AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
																		AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
															--Configuration
															ELSE (ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice, 0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0))
																/ @dblRateConfiguration END)
											--When both currencies is not equal to M2M currency
											WHEN intMarketBasisCurrencyId <> @intCurrencyUOMId OR intFuturePriceCurrencyId <> @intCurrencyUOMId
												THEN ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice, 0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0)
											--Can be used other currency exchange
											ELSE ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice, 0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0) END)
								ELSE ISNULL(dblMarketBasis, 0) + (ISNULL(dblFuturePrice,0) * ISNULL(dblMarketRatio, 1)) + ISNULL(dblCashPrice, 0) END
		, dblResultBasis
		, dblResultCash
		--Contract Price
		, dblContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
									THEN (CASE WHEN intCurrencyId = @intCurrencyUOMId
												--CAD/CAD
												THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) +  ISNULL(dblCash, 0)
											WHEN Currency.strCurrency = 'USD'
												--USD/CAD
												THEN (CASE WHEN @strRateType = 'Contract'
															THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																/ ISNULL((SELECT dblRate FROM tblCTContractDetail
																		WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																			AND ISNULL(dblRate, 0) <> 0
																			AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId 
																			AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
														--Configuration
														ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
															/ @dblRateConfiguration END)
											--Can be used other currency exchange
											ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) END)
								ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) END)
		, intQuantityUOMId
		, intCommodityUnitMeasureId
		, intPriceUOMId
		, #Temp.intCent
		, dtmPlannedAvailabilityDate
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, intCompanyLocationId
		, intMarketZoneId
		, strMarketZoneCode
		, strLocationName
	FROM (
		SELECT *
			, dblCalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Unpriced' then dblFuturePrice
										WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
											THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblFuturePrice)) / dblNoOfLots
										ELSE dblFutures END), 0)
		FROM #Temp) #Temp
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = #Temp.intCurrencyId
	LEFT JOIN tblSMCurrency MBCurrency ON MBCurrency.intCurrencyID = #Temp.intMarketBasisCurrencyId
	LEFT JOIN tblSMCurrency FPCurrency ON FPCurrency.intCurrencyID = #Temp.intFuturePriceCurrencyId
	WHERE  dblOpenQty <> 0 and intContractHeaderId is not null 
	
	UNION
	SELECT DISTINCT intConcurrencyId = 0
		, intContractHeaderId
		, intContractDetailId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dblOpenQty dblOpenQty
		, strCommodityCode
		, intCommodityId
		, intItemId
		, strItemNo
		, strOrgin
		, strPosition
		, strPeriod
		, strPeriodTo
		, strPriOrNotPriOrParPriced
		, intPricingTypeId
		, strPricingType
		, dblContractRatio
		, dblContractBasis = (CASE WHEN strPricingType != 'HTA'
									THEN (CASE WHEN ISNULL(@ysnIncludeBasisDifferentialsInResults, 0) = 0 THEN 0
											ELSE (CASE WHEN @ysnCanadianCustomer = 1 THEN dblCanadianFutures + dblCanadianContractBasis - ISNULL(dblFutures, 0)
													ELSE dblContractBasis END) END)
								ELSE 0 END)
		, dblActualFutures = dblFutures
		, dblFutures = (CASE WHEN strPricingType = 'Basis' THEN 0
							ELSE dblFutures END)
		, dblCash
		, dblCosts = ABS(dblCosts)
		, dblMarketBasis = ISNULL(dblInvMarketBasis, 0)
		, dblMarketRatio
		, dblFuturePrice = ISNULL(dblInvFuturePrice, 0)
		, intContractTypeId
		, dblAdjustedContractPrice = NULL
		, dblCashPrice
		, dblMarketPrice = ISNULL(dblInvMarketBasis, 0) + ISNULL(dblInvFuturePrice, 0)
		, dblResultBasis = NULL
		, dblResultCash = NULL
		, dblContractPrice = ISNULL(dblNotLotTrackedPrice, 0)
		, intQuantityUOMId
		, intCommodityUnitMeasureId
		, intPriceUOMId
		, intCent
		, dtmPlannedAvailabilityDate
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, intCompanyLocationId
		, intMarketZoneId
		, strMarketZoneCode
		, strLocationName 
	FROM #Temp 
	WHERE  dblOpenQty <> 0 AND intContractHeaderId IS NULL
)t 
ORDER BY intContractHeaderId DESC