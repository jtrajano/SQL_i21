CREATE PROCEDURE uspRKPnLBySalesContractResult
		@intUOMId int = null,
		@intPriceUOMId int = null,
		@intContractDetailId int = null
AS

--DECLARE @intContractDetailId INT = 2690

DECLARE @Result TABLE
(
  intResultId int IDENTITY(1,1) PRIMARY KEY,
  intContractHeaderId INT,
  intContractDetailId INT,
  strContractNumber NVARCHAR(50),
  strContractType NVARCHAR(50),
  dblQty NUMERIC(18, 6),
  dblUSD NUMERIC(18, 6),
  dblBasis NUMERIC(18, 6),
  dblAllocatedQty NUMERIC(18, 6),
  dblInvoicePrice NUMERIC(18, 6)
)

DECLARE @PhysicalFuturesResult TABLE
(
	intRowNum INT,
	strContractType NVARCHAR(50),
	strNumber NVARCHAR(50),
	strDescription NVARCHAR(50),
	strConfirmed NVARCHAR(50),
	dblAllocatedQty NUMERIC(18, 6),
	dblPrice NUMERIC(18, 6),
	strCurrency NVARCHAR(50),
	dblFX NUMERIC(18, 6),
	dblBooked NUMERIC(18, 6),
	dblAccounting NUMERIC(18, 6),
	dtmDate datetime,
	intSort int,
	dblTransactionValue NUMERIC(18, 6),
	dblForecast NUMERIC(18, 6)
)

INSERT INTO @PhysicalFuturesResult (intRowNum,strContractType,strNumber,strDescription,strConfirmed,dblAllocatedQty,dblPrice,strCurrency,dblFX,dblBooked,dblAccounting,dtmDate,intSort,dblTransactionValue,dblForecast)
EXEC uspRKPNLPhysicalFuturesResult @intContractDetailId,16--- Hard code

DECLARE @dblAllocatedQty  NUMERIC(18, 6)
DECLARE	@intPContractDetailId INT		
DECLARE @dtmToDate datetime 

SET @dtmToDate = convert(datetime,CONVERT(VARCHAR(10),getdate(),110),110)
SELECT	@intPContractDetailId = intPContractDetailId FROM   tblLGAllocationDetail WHERE intSContractDetailId	=	@intContractDetailId

SELECT @dblAllocatedQty=sum(isnull(sa.dblAllocatedQty,0))
FROM vyuRKPnLGetAllocationDetail sa
WHERE sa.intContractTypeId=2 and sa.intContractDetailId=@intContractDetailId


INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty,dblInvoicePrice)
SELECT distinct intContractHeaderId, intContractDetailId,strSequenceNumber,'Invoices',
(SELECT ISNULL(SUM(dblBooked),0) FROM @PhysicalFuturesResult WHERE strDescription='Invoice') dblQty,
sum(dblSaleBasis)/count(dblSaleBasis),@dblAllocatedQty dblAllocatedQty, null,
(SELECT ISNULL(SUM(dblPrice),0) FROM @PhysicalFuturesResult WHERE strDescription='Invoice')/(SELECT case when count(isnull(dblPrice,0))=0 then 1 else count(dblPrice) end  FROM @PhysicalFuturesResult WHERE strDescription='Invoice')
FROM vyuRKPnLGetAllocationDetail 
WHERE intContractTypeId=2 and intContractDetailId=@intContractDetailId
group by intContractHeaderId, intContractDetailId,strSequenceNumber

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty)
SELECT distinct intContractHeaderId, intContractDetailId,strSequenceNumber,'Purchase',null,null,sum(dblPurchaseBasis)/count(dblPurchaseBasis),@dblAllocatedQty dblAllocatedQty
FROM vyuRKPnLGetAllocationDetail 
WHERE intContractTypeId=2 and intContractDetailId=@intContractDetailId
GROUP BY intContractHeaderId, intContractDetailId,strSequenceNumber

DECLARE @dblSaleBasis NUMERIC(18,6)
DECLARE @dblPurchaseBasis NUMERIC(18,6)
SELECT @dblSaleBasis=sum(dblBasis) FROM @Result where strContractType='Invoices'
SELECT @dblPurchaseBasis=sum(dblBasis) FROM @Result where strContractType='Purchase'


--RESULT
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT DISTINCT NULL,NULL,NULL,'Gross Profit - USD',(@dblSaleBasis-@dblPurchaseBasis)*@dblAllocatedQty ,null	
FROM @Result

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT DISTINCT NULL,NULL,NULL,'Gross Profit - Rate',(@dblSaleBasis-@dblPurchaseBasis),null	FROM @Result 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT distinct  NULL,NULL,NULL,'PO Costs', sum(isnull(dblRate,0)),NULL
FROM vyuRKPnLGetAllocationDetail dv
JOIN vyuCTContractCostView cv on cv.intContractDetailId=dv.intPContractDetailId
WHERE intContractTypeId=2 and dv.intContractDetailId=2690

UNION

SELECT DISTINCT  NULL,NULL,NULL,'SO Costs',
(SELECT dblCosts from
(SELECT sum(isnull(dc.dblRate,0)) dblCosts
        FROM vyuCTContractCostView dc 
        WHERE  dc.intContractDetailId=dv.intContractDetailId)t) dblCosts,NULL
FROM vyuRKPnLGetAllocationDetail dv
WHERE intContractTypeId=2 and intContractDetailId=@intContractDetailId

----Rate
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Total Costs USD',sum(dblBasis)*@dblAllocatedQty,null	
FROM @Result WHERE strContractType in('PO Costs','SO Costs') 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Total Costs - Rate',sum(dblBasis),null	
FROM @Result WHERE strContractType in('PO Costs','SO Costs') 

---- Profit
INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Physical Profit - USD',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Total Costs USD' ) ,0)),NULL	
FROM @Result WHERE strContractType='Gross Profit - USD' 

INSERT INTO @Result(intContractHeaderId,intContractDetailId,strContractNumber,strContractType,dblBasis,dblAllocatedQty)
SELECT NULL,NULL,NULL,'Physical Profit - Rate',(dblBasis-ISNULL((SELECT SUM(dblBasis) FROM @Result WHERE strContractType='Total Costs - Rate' ) ,0)),NULL	
FROM @Result WHERE strContractType='Gross Profit - Rate' 
--
INSERT INTO @Result(strContractType,dblUSD)
SELECT 'Futures Impact - USD',sum((isnull(dtmLatestSettlementPrice,0)-isnull(dblPrice,0))*(isnull(intNoOfLots,0)*isnull(dblContractSize,0))) dblFutureImpact from (
		SELECT	distinct TP.strContractType,
				CH.strContractNumber +' - ' + convert(nvarchar(100),CD.intContractSeq) AS	strNumber,
				CD.intContractDetailId,CD.dblQuantity,AD.dblSAllocatedQty,(AD.dblSAllocatedQty/CD.dblQuantity)*100	as dblContractPercentage
				,fm.strFutureMonth + ' - ' + strBuySell strFutureMonth
				,strInternalTradeNo,dblAssignedLots, t.dblPrice dblContractPrice,	
				((isnull(cs.dblAssignedLots,0)+isnull(cs.intHedgedLots,0))*(AD.dblSAllocatedQty/CD.dblQuantity)*100)/100 intNoOfLots	
				,t.dblPrice,t.intFutureMarketId,t.intFutureMonthId,
				dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId,t.intFutureMonthId,@dtmToDate) dtmLatestSettlementPrice,m.dblContractSize	
		FROM	tblLGAllocationDetail	AD 
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	AD.intPContractDetailId 
											AND intSContractDetailId	=	@intContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId			
		LEFT JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																					THEN PF.intContractDetailId
																					ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId	=	CD.intContractHeaderId	
	   	LEFT JOIN tblRKAssignFuturesToContractSummary cs on cs.intContractDetailId=CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t on t.intFutOptTransactionId=cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=t.intFutureMonthId
		WHERE	intSContractDetailId	=	@intContractDetailId

	
		UNION ALL

		SELECT	distinct TP.strContractType,
				CH.strContractNumber  +' - ' + convert(nvarchar(100),CD.intContractSeq),
				CD.intContractDetailId,CD.dblQuantity,	
				sum(dblSAllocatedQty) over  (PARTITION BY CD.intContractDetailId ) dblSAllocatedQty,
				(sum(dblSAllocatedQty) over  (PARTITION BY CD.intContractDetailId)/CD.dblQuantity)*100 as dblContractPercentage
				,fm.strFutureMonth + ' - ' + strBuySell strFutureMonth,
				strInternalTradeNo,dblAssignedLots,t.dblPrice dblContractPrice,
				((isnull(cs.dblAssignedLots,0)+isnull(cs.intHedgedLots,0))*(sum(dblSAllocatedQty) over  (PARTITION BY CD.intContractDetailId)/CD.dblQuantity*100))/100 intNoOfLots,
				t.dblPrice,t.intFutureMarketId,t.intFutureMonthId,
				dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId,t.intFutureMonthId,@dtmToDate) dtmLatestSettlementPrice,m.dblContractSize
		FROM	tblLGAllocationDetail	AD 
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	@intContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
		LEFT JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																					THEN PF.intContractDetailId
																					ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId	=	CD.intContractHeaderId	
		LEFT JOIN tblRKAssignFuturesToContractSummary cs on cs.intContractDetailId=CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t on t.intFutOptTransactionId=cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=t.intFutureMonthId																				
		WHERE	intSContractDetailId	=	@intContractDetailId)t

---- Profit
INSERT INTO @Result(strContractType,dblBasis,dblAllocatedQty)
SELECT 'Net SO Profit - USD',isnull(dblBasis,0),NULL from @Result WHERE strContractType='Physical Profit - USD' 
union
SELECT 'Net SO Profit - Rate',isnull(dblBasis,0),null from @Result WHERE strContractType='Physical Profit - Rate' 

SELECT * FROM @Result ORDER BY intResultId