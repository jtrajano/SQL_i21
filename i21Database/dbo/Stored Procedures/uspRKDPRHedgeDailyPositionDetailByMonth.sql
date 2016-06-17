CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetailByMonth]
		 @intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
AS

BEGIN

if isnull(@strPurchaseSales,'') <> ''
BEGIN
	if @strPurchaseSales='Purchase'
	BEGIN
		SELECT @strPurchaseSales='Sale'
	END
	ELSE
	BEGIN
		SELECT @strPurchaseSales='Purchase'
	END
END

DECLARE @strCommodityCode NVARCHAR(50)

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

DECLARE @List AS TABLE (  
     intRowNumber INT IDENTITY(1,1),
	 intContractHeaderId int,
	 strContractNumber NVARCHAR(200),
	 intFutOptTransactionHeaderId int,
	 strInternalTradeNo NVARCHAR(200),
	 intCommodityId int,
	 strCommodityCode NVARCHAR(200),   
     strType  NVARCHAR(50), 
	 strLocationName NVARCHAR(100),
	 strContractEndMonth NVARCHAR(50),
	 strContractEndMonthNearBy NVARCHAR(50),
	 dblTotal DECIMAL(24,10)
	 ,intSeqNo int
	 ,strUnitMeasure NVARCHAR(50)
	 ,intFromCommodityUnitMeasureId int
	 ,intToCommodityUnitMeasureId int
	 ,strAccountNumber NVARCHAR(100)
	 ,strTranType NVARCHAR(20)
	 ,dblNoOfLot NUMERIC(24, 10)
	 ,dblDelta NUMERIC(24, 10)
	 ,intBrokerageAccountId int
	 ,strInstrumentType nvarchar(50)
     ) 

DECLARE @FinalList AS TABLE (  
     intRowNumber INT IDENTITY(1,1),
	 intContractHeaderId int,
	 strContractNumber NVARCHAR(200),
	 intFutOptTransactionHeaderId int,
	 strInternalTradeNo NVARCHAR(200),
	 intCommodityId int,
	 strCommodityCode NVARCHAR(200),   
     strType  NVARCHAR(50), 
	 strLocationName NVARCHAR(100),
	 strContractEndMonth NVARCHAR(50),
	 strContractEndMonthNearBy NVARCHAR(50),
	 dblTotal DECIMAL(24,10)
	 ,intSeqNo int
	 ,strUnitMeasure NVARCHAR(50)
	 ,intFromCommodityUnitMeasureId int
	 ,intToCommodityUnitMeasureId int
	 ,strAccountNumber NVARCHAR(100)
	 ,strTranType NVARCHAR(20)
	 ,dblNoOfLot NUMERIC(24, 10)
	 ,dblDelta NUMERIC(24, 10)
	 ,intBrokerageAccountId int
	 ,strInstrumentType nvarchar(50)
     ) 


DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intOneCommodityId int
declare @intCommodityUnitMeasureId int
SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
IF  @intCommodityId >0
BEGIN

INSERT INTO @List (strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,intFromCommodityUnitMeasureId)
	SELECT strCommodityCode,CD.intCommodityId,intContractHeaderId,strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,strContractType+ ' ' + strPricingType [strType]
		,strLocationName
		,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) 
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) AS dblTotal,CD.intUnitMeasureId
	FROM vyuCTContractDetailView CD
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId AND CD.intUnitMeasureId=ium.intUnitMeasureId  and CD.intContractStatusId <> 3
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and CD.intCommodityId =@intCommodityId
	AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	 and  CD.intEntityId= CASE WHEN ISNULL(@intVendorId,0)=0 then CD.intEntityId else @intVendorId end 

INSERT INTO @List (strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,intFromCommodityUnitMeasureId
					,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot)
	SELECT strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge',strLocationName, strFutureMonth,dtmFutureMonthsDate,HedgedQty,intUnitMeasureId
	,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot
	FROM (
		SELECT strCommodityCode,f.intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,(ISNULL(intNoOfContract, 0) -  isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intLFutOptTransactionId = f.intFutOptTransactionId), 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) dtmFutureMonthsDate,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType,
		CASE WHEN f.strBuySell = 'Buy' THEN (
			f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail l WHERE l.intLFutOptTransactionId = f.intFutOptTransactionId), 0))
			ELSE - (f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intSFutOptTransactionId = f.intFutOptTransactionId), 0)
		) END AS dblNoOfLot 
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		WHERE f.strBuySell = 'Buy'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end	

		UNION 
		
		SELECT strCommodityCode,f.intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,-(ISNULL(intNoOfContract, 0) -  isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intSFutOptTransactionId = f.intFutOptTransactionId), 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) dtmFutureMonthsDate,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType,
		CASE WHEN f.strBuySell = 'Buy' THEN (
		f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail l WHERE l.intLFutOptTransactionId = f.intFutOptTransactionId), 0))
		ELSE - (f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intSFutOptTransactionId = f.intFutOptTransactionId), 0)
		) END AS dblNoOfLot 
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		WHERE f.strBuySell = 'Sell'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end		
		) t

 --Option NetHEdge
		INSERT INTO @List (strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,
							intFromCommodityUnitMeasureId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)	
		SELECT DISTINCT strCommodityCode,ft.intCommodityId,ft.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,strLocationName,
				 left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth, 	
				 left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) dtmFutureMonthsDate,			
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblTotal, m.intUnitMeasureId,				
		e.strName + '-' + strAccountNumber AS strAccountNumber, 		
		strBuySell AS TranType, 
		CASE WHEN ft.strBuySell = 'Buy' THEN (
					ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
					ELSE - (ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)
				) END AS dblNoOfLot, 
		ISNULL((SELECT TOP 1 dblDelta
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
		AND ft.dblStrike = mm.dblStrike
		ORDER BY dtmPriceDate DESC
		),0) AS dblDelta,ft.intBrokerageAccountId,case when ft.intInstrumentTypeId  = 1 then 'Futures' else 'Options ' end as strInstrumentType
	FROM tblRKFutOptTransaction ft
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end 
	AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
		 --Net Hedge option end
		
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId


INSERT INTO @FinalList (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	   Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
	@strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  FROM @List t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType<>'Net Hedge'
	union
	SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	 isnull(dblTotal,0) dblTotal,
	@strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  FROM @List t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType='Net Hedge'
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END
END

UPDATE @FinalList set strContractEndMonth = 'Near By' where CONVERT(DATETIME,'01 '+ strContractEndMonth) < CONVERT(DATETIME,getdate())
DELETE FROM @List
INSERT INTO @List (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	isnull(dblTotal,0)  dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  FROM @FinalList WHERE strContractEndMonth = 'Near By' 

INSERT INTO @List (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	isnull(dblTotal,0) dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  FROM @FinalList WHERE strContractEndMonth <> 'Near By' 
	ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) asc

UPDATE @List set intSeqNo = 1 where strType='Purchase Priced'
UPDATE @List set intSeqNo = 2 where strType='Purchase Basis'
UPDATE @List set intSeqNo = 3 where strType='Purchase HTA'
UPDATE @List set intSeqNo = 4 where strType='Sale Priced'
UPDATE @List set intSeqNo = 5 where strType='Sale Basis'
UPDATE @List set intSeqNo = 6 where strType='Sale HTA'
UPDATE @List set intSeqNo = 7 where strType='Net Hedge'

IF isnull(@intVendorId,0) = 0
BEGIN
select intSeqNo,intRowNumber,strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
from @List where dblTotal <> 0 order by intRowNumber,intSeqNo

ENd
ELSE
BEGIN
SELECT intSeqNo,intRowNumber,strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
from @List where dblTotal <> 0  and strType NOT like '%'+@strPurchaseSales+'%' and  strType<>'Net Hedge' order by intRowNumber,intSeqNo
END