CREATE PROC [dbo].[uspRKPositionChangeAnalysis]
	@strFromBatchId nvarchar(100),
	@strToBatchId nvarchar(100),
	@intQuantityUOMId nvarchar(100),
	@intPriceUOMId nvarchar(100) = NULL
AS

-- Physical
SELECT c.strCommodityCode,t.strPricingType,t.intContractDetailId,strContractOrInventoryType, strContractSeq,t.intContractHeaderId,strName strvendorName,
	strFutureMonth strFutureMonth,strLocationName,strItemNo,
	  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,
	  	  case when @intPriceUOMId = 2 then 
			CASE WHEN intPricingTypeId=8 THEN 
			  dblPricedQty * isnull(cd.dblRatio,0)			
			  ELSE isnull((dblPricedQty),0) end
	  ELSE 
	  isnull((dblPricedQty),0)
	  end
	) dblPricedQty,
	  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,
	  	  case when @intPriceUOMId = 2 then 
			CASE WHEN intPricingTypeId=8 THEN 
			  dblUnPricedQty * isnull(cd.dblRatio,0)			
			  ELSE isnull((dblUnPricedQty),0) end
	  ELSE 
	  isnull((dblUnPricedQty),0)
	  end
	) dblUnPricedQty,
	  dblPricedAmount  INTO #Fromtemp  
FROM tblRKM2MInquiry i
join tblRKM2MInquiryTransaction t on i.intM2MInquiryId=t.intM2MInquiryId
join tblRKFuturesMonth f on f.intFutureMonthId=t.intFutureMonthId
join tblEMEntity e on e.intEntityId=t.intEntityId
join tblICItem it on it.intItemId=t.intItemId
join tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND i.intUnitMeasureId=ium.intUnitMeasureId 
JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=c.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
JOIN tblCTContractDetail cd on cd.intContractDetailId=t.intContractDetailId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=cd.intCompanyLocationId
 WHERE i.strBatchId=@strFromBatchId

SELECT c.strCommodityCode,t.strPricingType,t.intContractDetailId,strContractOrInventoryType, strContractSeq,t.intContractHeaderId,strName strvendorName,strFutureMonth strFutureMonth,
		strLocationName,strItemNo,
	  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,	  case when @intPriceUOMId = 2 then 
			CASE WHEN intPricingTypeId=8 THEN 
			  dblPricedQty * isnull(cd.dblRatio,0)			
			  ELSE isnull((dblPricedQty),0) end
	  ELSE 
	  isnull((dblPricedQty),0)
	  end
	) dblPricedQty,
	  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,
	  	  case when @intPriceUOMId = 2 then 
			CASE WHEN intPricingTypeId=8 THEN 
			  dblUnPricedQty * isnull(cd.dblRatio,0)			
			  ELSE isnull((dblUnPricedQty),0) end
	  ELSE 
	  isnull((dblUnPricedQty),0)
	  end
	) dblUnPricedQty,
	  dblPricedAmount INTO #Totemp 
FROM tblRKM2MInquiry i
JOIN tblRKM2MInquiryTransaction t on i.intM2MInquiryId=t.intM2MInquiryId
JOIN tblRKFuturesMonth f on f.intFutureMonthId=t.intFutureMonthId
JOIN tblEMEntity e on e.intEntityId=t.intEntityId
JOIN tblICItem it on it.intItemId=t.intItemId
JOIN tblICCommodity c on c.intCommodityId=i.intCommodityId
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND i.intUnitMeasureId=ium.intUnitMeasureId 
JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=c.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
join tblCTContractDetail cd on cd.intContractDetailId=t.intContractDetailId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=cd.intCompanyLocationId
WHERE i.strBatchId=@strToBatchId
--Future
SELECT c.strCommodityCode,'' strPricingType,ft.intFutOptTransactionId intContractDetailId,
		'Future '+case when strBuySell = 'Buy' then '(Long)' else '(short)' end strContractOrInventoryType,strInternalTradeNo strContractSeq,intFutOptTransactionHeaderId intContractHeaderId,strName strvendorName,
	  strFutureMonth strFutureMonth,strLocationName,
	  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,(t.dblDebitUnit* m.dblContractSize))  dblQty,t.dblPrice dblPricedAmount
	   INTO #Fromtemp1  
FROM tblRKM2MInquiry i
JOIN tblRKM2MPostRecap t on i.intM2MInquiryId=t.intM2MInquiryId
JOIN tblRKFutOptTransaction ft on ft.intFutOptTransactionId=t.intTransactionId
JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth f on f.intFutureMonthId=ft.intFutureMonthId
JOIN tblEMEntity e on e.intEntityId=ft.intEntityId
JOIN tblICCommodity c on c.intCommodityId=ft.intCommodityId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND m.intUnitMeasureId=ium.intUnitMeasureId 
JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=c.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
WHERE i.strBatchId=@strFromBatchId and strTransactionType ='Mark To Market-Futures Derivative' 

 SELECT c.strCommodityCode,'' strPricingType,ft.intFutOptTransactionId intContractDetailId,
		'Future '+case when strBuySell = 'Buy' then '(Long)' else '(short)' end strContractOrInventoryType,strInternalTradeNo strContractSeq,intFutOptTransactionHeaderId intContractHeaderId,strName strvendorName,
	  strFutureMonth strFutureMonth,strLocationName, 
	  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,(t.dblDebitUnit* m.dblContractSize))  dblQty,t.dblPrice  dblPricedAmount
	  INTO #Totemp1 
FROM tblRKM2MInquiry i
JOIN tblRKM2MPostRecap t on i.intM2MInquiryId=t.intM2MInquiryId
JOIN tblRKFutOptTransaction ft on ft.intFutOptTransactionId=t.intTransactionId
JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth f on f.intFutureMonthId=ft.intFutureMonthId
JOIN tblEMEntity e on e.intEntityId=ft.intEntityId
JOIN tblICCommodity c on c.intCommodityId=ft.intCommodityId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND m.intUnitMeasureId=ium.intUnitMeasureId 
JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=c.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
WHERE i.strBatchId=@strToBatchId and strTransactionType ='Mark To Market-Futures Derivative' 

DECLARE @tblFinal TABLE (

strCommodityCode NVARCHAR(500) COLLATE Latin1_General_CI_AS
,intContractDetailId int
,strContractOrInventoryType NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strContractSeq NVARCHAR(500) COLLATE Latin1_General_CI_AS
,intContractHeaderId int
,strCounterparty NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strLocationName NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strFromItem NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strToItem NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strFromPricingType NVARCHAR(500) COLLATE Latin1_General_CI_AS
,strToPricingType NVARCHAR(500) COLLATE Latin1_General_CI_AS
,dblFromPricedQty DECIMAL(24, 10)
,dblFromUnpricedQty DECIMAL(24, 10)
,dblFromPricedAmount DECIMAL(24, 10)
,dblToPricedQty DECIMAL(24, 10)
,dblToUnpricedQty DECIMAL(24, 10)
,dblToPricedAmount DECIMAL(24, 10)
,dblFromQty DECIMAL(24, 10)
,dblToQty DECIMAL(24, 10)
,dblQtyDifference DECIMAL(24, 10)
,dblDifference DECIMAL(24, 10)
,intContract INT)
 INSERT INTO @tblFinal(strCommodityCode ,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,intContractHeaderId ,strCounterparty ,strFutureMonth 
			,strLocationName ,strFromItem ,strToItem ,strFromPricingType ,strToPricingType ,dblFromPricedQty ,dblFromUnpricedQty ,dblFromPricedAmount 
			,dblToPricedQty ,dblToUnpricedQty ,dblToPricedAmount ,dblFromQty ,dblToQty ,dblQtyDifference ,dblDifference,intContract)
SELECT strCommodityCode ,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,intContractHeaderId ,strCounterparty ,strFutureMonth 
			,strLocationName ,strFromItem ,strToItem ,strFromPricingType ,strToPricingType ,dblFromPricedQty ,dblFromUnpricedQty ,dblFromPricedAmount 
			,dblToPricedQty ,dblToUnpricedQty ,dblToPricedAmount ,dblFromQty ,dblToQty ,dblQtyDifference ,dblDifference ,1 intContract
FROM(
 SELECT isnull(t.strCommodityCode,t1.strCommodityCode) strCommodityCode,
				isnull(t.intContractDetailId,t1.intContractDetailId) intContractDetailId,
				isnull(t.strContractOrInventoryType,t1.strContractOrInventoryType) strContractOrInventoryType,
				isnull(t.strContractSeq,t1.strContractSeq) strContractSeq,
				isnull(t.intContractHeaderId,t1.intContractHeaderId) intContractHeaderId,
				isnull(t.strvendorName,t1.strvendorName) strCounterparty,
				isnull(t.strFutureMonth,t1.strFutureMonth) strFutureMonth,
				isnull(t.strLocationName,t1.strLocationName) strLocationName,
				t.strItemNo strFromItem,
				t1.strItemNo strToItem,
				t.dblPricedQty dblFromPricedQty,
				t.dblUnPricedQty dblFromUnpricedQty,
				t.dblPricedAmount dblFromPricedAmount,  
				t.strPricingType strFromPricingType,
				t1.dblPricedQty dblToPricedQty,
				t1.dblUnPricedQty dblToUnpricedQty,
				t1.dblPricedAmount dblToPricedAmount,				
				t1.strPricingType strToPricingType,		
				(isnull(t.dblUnPricedQty,0) + isnull(t.dblPricedQty,0)) dblFromQty
				,(isnull(t1.dblUnPricedQty,0) + isnull(t1.dblPricedQty,0)) dblToQty 
				,(isnull(t1.dblUnPricedQty,0) + isnull(t1.dblPricedQty,0)) - (isnull(t.dblUnPricedQty,0) + isnull(t.dblPricedQty,0)) dblQtyDifference
				,isnull(t1.dblPricedAmount,0)-isnull(t.dblPricedAmount,0) dblDifference
 FROM #Fromtemp t
 FULL JOIN #Totemp t1 on t.strContractSeq=t1.strContractSeq )t
 order by strContractSeq


  INSERT INTO @tblFinal(strCommodityCode ,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,intContractHeaderId ,strCounterparty ,strFutureMonth 
			,strLocationName ,strFromItem ,strToItem ,strFromPricingType ,strToPricingType ,dblFromPricedQty ,dblFromUnpricedQty ,dblFromPricedAmount 
			,dblToPricedQty ,dblToUnpricedQty ,dblToPricedAmount ,dblFromQty ,dblToQty ,dblQtyDifference ,dblDifference,intContract )
SELECT strCommodityCode ,intContractDetailId ,strContractOrInventoryType ,strContractSeq ,intContractHeaderId ,strCounterparty ,strFutureMonth 
			,strLocationName ,strFromItem ,strToItem ,strFromPricingType ,strToPricingType ,dblFromPricedQty ,dblFromUnpricedQty ,dblFromPricedAmount 
			,dblToPricedQty ,dblToUnpricedQty ,dblToPricedAmount ,dblFromQty ,dblToQty ,dblQtyDifference ,dblDifference,0 intContract
FROM(
 SELECT isnull(t.strCommodityCode,t1.strCommodityCode) strCommodityCode,
				isnull(t.intContractDetailId,t1.intContractDetailId) intContractDetailId,
				isnull(t.strContractOrInventoryType,t1.strContractOrInventoryType) strContractOrInventoryType,
				isnull(t.strContractSeq,t1.strContractSeq) strContractSeq,
				isnull(t.intContractHeaderId,t1.intContractHeaderId) intContractHeaderId,
				isnull(t.strvendorName,t1.strvendorName) strCounterparty,
				isnull(t.strFutureMonth,t1.strFutureMonth) strFutureMonth,
				isnull(t.strLocationName,t1.strLocationName) strLocationName,
				null strFromItem,
				null strToItem,
				null dblFromPricedQty,
				null dblFromUnpricedQty,
				t.dblPricedAmount dblFromPricedAmount,  
				t.strPricingType strFromPricingType,
				t1.strPricingType strToPricingType,	
				null dblToPricedQty,
				null dblToUnpricedQty,
				t1.dblPricedAmount dblToPricedAmount,								
				t.dblQty dblFromQty,
				t1.dblQty	dblToQty,
				isnull(t1.dblQty,0)-isnull(t.dblQty,0) dblQtyDifference,
				isnull(t1.dblPricedAmount,0)-isnull(t.dblPricedAmount,0)  dblDifference
 FROM #Fromtemp1 t
 FULL JOIN #Totemp1 t1 on t.strContractSeq=t1.strContractSeq )t
 ORDER BY strContractSeq

 SELECT * FROM @tblFinal