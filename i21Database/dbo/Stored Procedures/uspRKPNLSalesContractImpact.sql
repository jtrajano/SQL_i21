﻿CREATE PROCEDURE uspRKPNLSalesContractImpact 
	@intSContractDetailId	INT,
	@intUnitMeasureId		INT
AS			--declare @intSContractDetailId INT = 2752
			--,@intUnitMeasureId INT = 16
	DECLARE	@intPContractDetailId INT
	declare @dtmToDate datetime 
	SET @dtmToDate = convert(datetime,CONVERT(VARCHAR(10),getdate(),110),110)
	SELECT	@intPContractDetailId = intPContractDetailId FROM   tblLGAllocationDetail WHERE intSContractDetailId	=	@intSContractDetailId

DECLARE @ContractImpact TABLE ( 
		intRowNum int identity(1,1),
		strContractType nvarchar(50),
		strContractNumber nvarchar(50),
		intContractHeaderId int,
		dblQuantity numeric(24,10),
		dblSAllocatedQty numeric(24,10),
		dblContractPercentage numeric(24,10),
		strFutureMonth nvarchar(100),
		strInternalTradeNo  nvarchar(100),
		dblAssignedLots numeric(24,10),
		dblContractPrice numeric(24,10),
		intNoOfLots numeric(24,10),
		dblPrice numeric(24,10),
		intFutureMarketId int,
		intFutureMonthId int,
		dblLatestSettlementPrice numeric(24,10),
		dblContractSize numeric(24,10),
		intFutOptTransactionHeaderId int,
		dblFutureImpact  numeric(24,10)
		  )
Insert into @ContractImpact
	SELECT *,((isnull(dblLatestSettlementPrice,0)-isnull(dblPrice,0))*(isnull(intNoOfLots,0)*isnull(dblContractSize,0))) dblFutureImpact from (
		SELECT	distinct TP.strContractType,
				CH.strContractNumber +' - ' + convert(nvarchar(100),CD.intContractSeq) AS	strContractNumber,
				CD.intContractHeaderId,CD.dblQuantity,AD.dblSAllocatedQty,(AD.dblSAllocatedQty/CD.dblQuantity)*100	as dblContractPercentage
				,fm.strFutureMonth + ' - ' + strBuySell strFutureMonth
				,strInternalTradeNo,dblAssignedLots, t.dblPrice dblContractPrice,	
				((isnull(cs.dblAssignedLots,0)+isnull(cs.intHedgedLots,0))*(AD.dblSAllocatedQty/CD.dblQuantity)*100)/100 intNoOfLots	
				,t.dblPrice,t.intFutureMarketId,t.intFutureMonthId,                              
				dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId,t.intFutureMonthId,@dtmToDate) dblLatestSettlementPrice,m.dblContractSize,intFutOptTransactionHeaderId	
		FROM	tblLGAllocationDetail	AD 
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	AD.intPContractDetailId 
											AND intSContractDetailId	=	@intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId			
		LEFT JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																					THEN PF.intContractDetailId
																					ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId	=	CD.intContractHeaderId	
	   	LEFT JOIN tblRKAssignFuturesToContractSummary cs on cs.intContractDetailId=CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t on t.intFutOptTransactionId=cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=t.intFutureMonthId
		WHERE	intSContractDetailId	=	@intSContractDetailId-- and t.intFutureMonthId is not null

	
		UNION ALL

		SELECT	distinct TP.strContractType,
				CH.strContractNumber  +' - ' + convert(nvarchar(100),CD.intContractSeq) as strContractNumber,
				CD.intContractHeaderId,CD.dblQuantity,	
				sum(dblSAllocatedQty) over  (PARTITION BY CD.intContractDetailId ) dblSAllocatedQty,
				(sum(dblSAllocatedQty) over  (PARTITION BY CD.intContractDetailId)/CD.dblQuantity)*100 as dblContractPercentage
				,fm.strFutureMonth + ' - ' + strBuySell strFutureMonth,
				strInternalTradeNo,dblAssignedLots,t.dblPrice dblContractPrice,
				((isnull(cs.dblAssignedLots,0)+isnull(cs.intHedgedLots,0))*(sum(dblSAllocatedQty) over  (PARTITION BY CD.intContractDetailId)/CD.dblQuantity*100))/100 intNoOfLots,
				t.dblPrice,t.intFutureMarketId,t.intFutureMonthId,
				dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId,t.intFutureMonthId,@dtmToDate) dblLatestSettlementPrice,m.dblContractSize,intFutOptTransactionHeaderId
		FROM	tblLGAllocationDetail	AD 
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	@intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTContractType		TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
		LEFT JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																					THEN PF.intContractDetailId
																					ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId	=	CD.intContractHeaderId	
		LEFT JOIN tblRKAssignFuturesToContractSummary cs on cs.intContractDetailId=CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t on t.intFutOptTransactionId=cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=t.intFutureMonthId																				
		WHERE	intSContractDetailId	=	@intSContractDetailId )t

INSERT INTO @ContractImpact(strContractNumber,strFutureMonth,intNoOfLots,dblPrice,dblLatestSettlementPrice,dblFutureImpact   )
SELECT 'Total' strContractType,strFutureMonth,sum(intNoOfLots) intNoOfLots,sum(dblPrice) dblPrice,max(dblLatestSettlementPrice) dblLatestSettlementPrice,sum(dblFutureImpact) dblFutureImpact   
FROM @ContractImpact where isnull(strFutureMonth,'') <> ''  GROUP BY strFutureMonth
ORDER BY case when isnull(strFutureMonth,'')='' then '' else CONVERT(DATETIME,'01 '+left(strFutureMonth,6)) end ASC 

SELECT intRowNum,strContractType,strContractNumber,intContractHeaderId,dblQuantity,dblSAllocatedQty,dblContractPercentage,strFutureMonth,strInternalTradeNo,dblAssignedLots,
dblContractPrice,intNoOfLots,dblPrice,intFutureMarketId,intFutureMonthId,dblLatestSettlementPrice,dblContractSize,intFutOptTransactionHeaderId,dblFutureImpact   
FROM @ContractImpact ORDER BY intRowNum
