CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetailByMonth]
		 @intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL
AS

BEGIN

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

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
IF  @intCommodityId >0
BEGIN

INSERT INTO @List (strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,intFromCommodityUnitMeasureId)
	SELECT strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
		,strContractType+ ' ' + strPricingType [strType]
		,strLocationName
		,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) 
		,isnull(dblBalance, 0) AS dblTotal,intUnitMeasureId
	FROM vyuCTContractDetailView  
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and intCommodityId =@intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

INSERT INTO @List (strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,intFromCommodityUnitMeasureId
					,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType)
	SELECT strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge',strLocationName, strFutureMonth,dtmFutureMonthsDate,HedgedQty,intUnitMeasureId
	,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType
	FROM (
		SELECT strCommodityCode,f.intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) dtmFutureMonthsDate,intUnitMeasureId
		,e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy'
			AND ic.intCommodityId= @intCommodityId
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end	

		UNION ALL
		
		SELECT strCommodityCode,f.intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,-(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,
		left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) dtmFutureMonthsDate,intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND ic.intCommodityId =@intCommodityId AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end			
		) t

-- Option NetHEdge
		INSERT INTO @List (strCommodityCode,intCommodityId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,
							intFromCommodityUnitMeasureId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)	
		SELECT DISTINCT strCommodityCode,ft.intCommodityId,ft.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,strLocationName,
				 left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth, 	
				 left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) dtmFutureMonthsDate,			
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * (
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						ORDER BY dtmPriceDate DESC
				)*m.dblContractSize AS dblTotal, m.intUnitMeasureId,				
		e.strName + '-' + strAccountNumber AS strAccountNumber, 		
		strBuySell AS TranType, 
		CASE WHEN ft.strBuySell = 'Buy' THEN (
					ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
					ELSE - (ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)
				) END AS dblNoOfLot, 
		(SELECT TOP 1 dblDelta
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
		ORDER BY dtmPriceDate DESC
		) AS dblDelta,ft.intBrokerageAccountId,case when ft.intInstrumentTypeId  = 1 then 'Futures' else 'Options ' end as strInstrumentType
	FROM tblRKFutOptTransaction ft
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
		-- Net Hedge option end
		
DECLARE @intUnitMeasureId int=null
DECLARE @intFromCommodityUnitMeasureId int=null
DECLARE @intToCommodityUnitMeasureId int=null
DECLARE @strUnitMeasure nvarchar(50)=null

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'') <> ''
BEGIN

	SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
END
ELSE
BEGIN

	SELECT @strUnitMeasure=c.strUnitMeasure,@intFromCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId, @intToCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId 
	FROM @List t 
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and cuc1.intUnitMeasureId=t.intFromCommodityUnitMeasureId
	JOIN tblICUnitMeasure c on c.intUnitMeasureId=cuc.intUnitMeasureId 	
	WHERE t.intCommodityId= @intCommodityId

END
UPDATE @List SET intFromCommodityUnitMeasureId=@intFromCommodityUnitMeasureId,intToCommodityUnitMeasureId=@intToCommodityUnitMeasureId,strUnitMeasure=@strUnitMeasure 
WHERE intCommodityId= @intCommodityId
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END
END

UPDATE @List set strContractEndMonth = 'Near By' where CONVERT(DATETIME,'01 '+ strContractEndMonth) < CONVERT(DATETIME,getdate())

INSERT INTO @FinalList (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,isnull(dblTotal,0))  dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  FROM @List WHERE strContractEndMonth = 'Near By' 

INSERT INTO @FinalList (strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )
SELECT strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth, strContractEndMonthNearBy,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,isnull(dblTotal,0)) dblTotal,
	strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  FROM @List WHERE strContractEndMonth <> 'Near By' 
	ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) asc

delete from @List
UPDATE @FinalList set intSeqNo = 1 where strType='Purchase Priced'
UPDATE @FinalList set intSeqNo = 2 where strType='Purchase Basis'
UPDATE @FinalList set intSeqNo = 3 where strType='Purchase HTA'
UPDATE @FinalList set intSeqNo = 4 where strType='Sale Priced'
UPDATE @FinalList set intSeqNo = 5 where strType='Sale Basis'
UPDATE @FinalList set intSeqNo = 6 where strType='Sale HTA'
UPDATE @FinalList set intSeqNo = 7 where strType='Net Hedge'
select intSeqNo,intRowNumber,strCommodityCode ,strContractNumber,intContractHeaderId,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal,strUnitMeasure,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
from @FinalList order by intRowNumber,intSeqNo