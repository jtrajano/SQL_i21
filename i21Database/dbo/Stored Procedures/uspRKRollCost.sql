CREATE PROC uspRKRollCost
	@dtmFromDate datetime = null,
	@dtmToDate datetime = null
AS

SELECT  Convert(int,ROW_NUMBER() OVER(ORDER BY strFutureMonth ASC)) intRowNumber, strFutMarketName,strCommodityCode,strFutureMonth,intFutureMarketId,intCommodityId,intFutureMonthId,
	SUM(dblContratPrice)/SUM(intOpenContract) dblWtAvgOpenLongPosition 
	,SUM(isnull(dblContratPrice,0)+isnull(dblMatchedPrice,0)+isnull(dblRollQtyPrice,0))/
				SUM(isnull(intOpenContract,0)+isnull(dblMatchedQty,0)+isnull(dblRollQty,0)) dblAvgPriceOld

	,sum(isnull(dblLongPrice,0))/sum(isnull(dblLongQty,1)) as dblLongQty
	,sum(isnull(dblShortPrice,0))/sum(isnull(dblShortQty,1)) as dblShortQty
	,sum(isnull(dblOriginalPrice,0))/sum(isnull(dblOriginalQty,1)) as dblOriginalQty

	, sum(isnull(dblLongPrice,0))/sum(isnull(dblLongQty,1)) + 
	CASE WHEN (sum(isnull(dblShortPrice,0))/sum(isnull(dblShortQty,1)) - sum(isnull(dblLongPrice,0))/sum(isnull(dblLongQty,1))) < 0 
			THEN (sum(isnull(dblShortPrice,0))/sum(isnull(dblShortQty,1)) - sum(isnull(dblLongPrice,0))/sum(isnull(dblLongQty,1)))
			ELSE -(sum(isnull(dblShortPrice,0))/sum(isnull(dblShortQty,1)) - sum(isnull(dblLongPrice,0))/sum(isnull(dblLongQty,1))) end dblWtAvgPosition

FROM (
SELECT ft.intFutOptTransactionId,ft.intFutureMarketId,m.strFutMarketName,ft.intCommodityId,c.strCommodityCode,fm.strFutureMonth,ft.intFutureMonthId,
		

(SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
		WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0)*isnull(ft.dblPrice,0) dblContratPrice

,(SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
		WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0) intOpenContract

,isnull((SELECT sum(isnull(dblMatchQty,0) * isnull(t.dblPrice,0)) FROM tblRKMatchFuturesPSDetail f 
	Join tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	join tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0 
	join tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and isnull(t1.intRollingMonthId,0) = 0
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId),0) dblMatchedPrice

,isnull((SELECT sum(isnull(dblMatchQty,0))  FROM tblRKMatchFuturesPSDetail f 
	Join tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	join tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0 
	join tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and isnull(t1.intRollingMonthId,0) = 0
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId),0) dblMatchedQty

,(SELECT sum(dblMatchQty * t.dblPrice) FROM tblRKMatchFuturesPSDetail f 
	Join tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	join tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId and t.intFutureMonthId = t.intRollingMonthId and t.intRollingMonthId is not null
	join tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and isnull(t1.intRollingMonthId,0) = 0 
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId) dblRollQtyPrice

,(SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail f 
		Join tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	join tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId and t.intFutureMonthId = t.intRollingMonthId and t.intRollingMonthId is not null
	join tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and isnull(t1.intRollingMonthId,0) = 0
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId) dblRollQty

,(SELECT sum(dblMatchQty * t.dblPrice) FROM tblRKMatchFuturesPSDetail f 
Join tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	join tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0 
	join tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and t1.intFutureMonthId <> t1.intRollingMonthId and t1.intRollingMonthId is not null
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId) dblSellMonthNotMatchPrice

,(SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail f 
Join tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	join tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0 
	join tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and t1.intFutureMonthId <> t1.intRollingMonthId and t1.intRollingMonthId is not null
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId) dblSellMonthNotMatchQty

 , isnull((SELECT sum(isnull(dblMatchQty,0)) FROM tblRKMatchFuturesPSDetail f 
	JOIN tblRKMatchFuturesPSHeader h on h.intMatchFuturesPSHeaderId=f.intMatchFuturesPSHeaderId
	JOIN tblRKFutOptTransaction t on t.intFutOptTransactionId= f.intLFutOptTransactionId 
				AND isnull(t.intFutureMonthId,0) = t.intRollingMonthId and t.intRollingMonthId is not null
	JOIN tblRKFutOptTransaction t1 on t1.intFutOptTransactionId= f.intSFutOptTransactionId and isnull(t1.intRollingMonthId,0) = 0
	WHERE t.intFutOptTransactionId=ft.intFutOptTransactionId and h.intFutureMonthId=fm.intFutureMonthId),0) dblAvgQty

	,(select sum(dblPrice*intNoOfContract) from(
		SELECT intNoOfContract,dblPrice  FROM  
			tblRKFutOptTransaction t 
		WHERE  isnull(t.intFutureMonthId,0) = t.intRollingMonthId AND t.intRollingMonthId IS NOT NULL
	AND t.intFutOptTransactionId=ft.intFutOptTransactionId and ft.intFutureMonthId=fm.intFutureMonthId)t )dblLongPrice

	,(select sum(intNoOfContract) from(
		SELECT intNoOfContract,dblPrice  FROM   
			tblRKFutOptTransaction t 
		WHERE  isnull(t.intFutureMonthId,0) = t.intRollingMonthId AND t.intRollingMonthId IS NOT NULL
	AND t.intFutOptTransactionId=ft.intFutOptTransactionId and ft.intFutureMonthId=fm.intFutureMonthId)t )dblLongQty 
	
	,(select sum(intNoOfContract * dblPrice) from(	
		SELECT distinct strInternalTradeNo,intNoOfContract,dblPrice 
		FROM tblRKFutOptTransaction WHERE intFutOptTransactionId in(
								SELECT intFutOptTransactionId FROM  tblRKFutOptTransaction st 
								WHERE intFutOptTransactionId in(
								select intFutOptTransactionId from tblRKFutOptTransaction t 
						WHERE  isnull(t.intFutureMonthId,0) = t.intRollingMonthId AND t.intRollingMonthId IS NOT NULL 
								AND t.intFutOptTransactionId=ft.intFutOptTransactionId and ft.intFutureMonthId=fm.intFutureMonthId and strBuySell= 'Buy')))t) 
	dblShortPrice

	,(select sum(intNoOfContract) dblQtyPrice from(	
	SELECT distinct strInternalTradeNo,intNoOfContract,dblPrice 
	FROM tblRKFutOptTransaction WHERE intFutOptTransactionId in(
							SELECT intFutOptTransactionId FROM  tblRKFutOptTransaction st 
							WHERE intFutOptTransactionId in(
							select intFutOptTransactionId from tblRKFutOptTransaction t 
					WHERE  isnull(t.intFutureMonthId,0) = t.intRollingMonthId AND t.intRollingMonthId IS NOT NULL 
							AND t.intFutOptTransactionId=ft.intFutOptTransactionId and ft.intFutureMonthId=fm.intFutureMonthId and strBuySell= 'Buy')))t) 
	dblShortQty

,(SELECT SUM(dblQtyPrice) FROM(
SELECT distinct strInternalTradeNo,intNoOfContract,dblPrice,
	(SELECT SUM(dblMatchQty) FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId=t.intFutOptTransactionId) dblMatchedLot,
	(SELECT SUM(dblMatchQty) FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId=t.intFutOptTransactionId)*dblPrice  dblQtyPrice
	 FROM tblRKFutOptTransaction t
	WHERE intFutOptTransactionId in(SELECT intLFutOptTransactionId FROM tblRKMatchFuturesPSDetail
										WHERE intSFutOptTransactionId in(SELECT intFutOptTransactionId FROM tblRKFutOptTransaction  
										WHERE strBuySell='Sell' and  intRollingMonthId in(
												SELECT 	intRollingMonthId
												FROM  
												tblRKFutOptTransaction t 
												WHERE  isnull(t.intFutureMonthId,0) = t.intRollingMonthId AND t.intRollingMonthId IS NOT NULL  
										AND t.intFutOptTransactionId=ft.intFutOptTransactionId and ft.intFutureMonthId=fm.intFutureMonthId and strBuySell= 'Buy'))))t) 													
AS dblOriginalPrice,

(SELECT sum(dblMatchedLot) FROM(
SELECT distinct strInternalTradeNo,intNoOfContract,dblPrice,
	(SELECT SUM(dblMatchQty) FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId=t.intFutOptTransactionId) dblMatchedLot,
	(SELECT SUM(dblMatchQty) FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId=t.intFutOptTransactionId)*dblPrice  dblQtyPrice
	 FROM tblRKFutOptTransaction t
	WHERE intFutOptTransactionId in(SELECT intLFutOptTransactionId FROM tblRKMatchFuturesPSDetail
										WHERE intSFutOptTransactionId in(SELECT intFutOptTransactionId FROM tblRKFutOptTransaction  
										WHERE strBuySell='Sell' and  intRollingMonthId in(
												SELECT 	intRollingMonthId
												FROM  
												tblRKFutOptTransaction t 
												WHERE  isnull(t.intFutureMonthId,0) = t.intRollingMonthId AND t.intRollingMonthId IS NOT NULL  
										AND t.intFutOptTransactionId=ft.intFutOptTransactionId and ft.intFutureMonthId=fm.intFutureMonthId and strBuySell= 'Buy'))))t) 													
AS dblOriginalQty


FROM tblRKFutOptTransaction ft
JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId
JOIN tblRKFuturesMonth fm on ft.intFutureMarketId=fm.intFutureMarketId and ft.intFutureMonthId=fm.intFutureMonthId
WHERE intSelectedInstrumentTypeId=1  AND intInstrumentTypeId=1
and convert(datetime,CONVERT(VARCHAR(10),ft.dtmFilledDate,110)) BETWEEN @dtmFromDate and @dtmToDate
)t 
WHERE (isnull(intOpenContract,0) >0 OR isnull(dblMatchedQty,0) >0 OR isnull(dblRollQty,0) >0) 
 GROUP BY  strFutMarketName,strCommodityCode,strFutureMonth,intFutureMarketId,intCommodityId,intFutureMonthId