CREATE PROCEDURE uspRKPNLSalesContractImpact 
	    @intSContractDetailId	INT,
		@intCurrencyId			INT,-- currency
		@intUnitMeasureId		INT,--- Price uom	
		@intWeightUOMId			INT -- weight 
AS	

BEGIN
	DECLARE	@intPContractDetailId INT
		, @dtmToDate DATETIME

	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)
	SELECT @intPContractDetailId = intPContractDetailId FROM tblLGAllocationDetail WHERE intSContractDetailId = @intSContractDetailId
	
	DECLARE @ContractImpact TABLE (intRowNum INT IDENTITY
		, strContractType NVARCHAR(50)
		, strContractNumber NVARCHAR(50)
		, intContractHeaderId INT
		, dblQuantity NUMERIC(24, 10)
		, dblSAllocatedQty NUMERIC(24, 10)
		, dblContractPercentage NUMERIC(24, 10)
		, strFutureMonth NVARCHAR(100)
		, strInternalTradeNo NVARCHAR(100)
		, dblAssignedLots NUMERIC(24, 10)
		, dblContractPrice NUMERIC(24, 10)
		, dblNoOfLots NUMERIC(24, 10)
		, dblPrice NUMERIC(24, 10)
		, intFutureMarketId INT
		, intFutureMonthId INT
		, dblLatestSettlementPrice NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, intFutOptTransactionHeaderId INT
		, ysnSubCurrency INT
		, dblFutureImpact NUMERIC(24, 10))
	
	INSERT INTO @ContractImpact
	SELECT DISTINCT *
		, dblFutureImpact = ((ISNULL(dblLatestSettlementPrice, 0) - ISNULL(dblPrice, 0)) * (ISNULL(dblNoOfLots, 0) * ISNULL(dblContractSize, 0))) / CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END
	FROM (
		SELECT DISTINCT TP.strContractType
			, strContractNumber = CH.strContractNumber + ' - ' + CONVERT(NVARCHAR(100), CD.intContractSeq)
			, CD.intContractHeaderId
			, CD.dblQuantity
			, AD.dblSAllocatedQty
			, dblContractPercentage = (AD.dblSAllocatedQty / CD.dblQuantity) * 100
			, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
			, strInternalTradeNo
			, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
			, dblContractPrice = t.dblPrice
			, dblNoOfLots = - ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (AD.dblSAllocatedQty / CD.dblQuantity) * 100) / 100
			, t.dblPrice
			, t.intFutureMarketId
			, t.intFutureMonthId
			, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
			, m.dblContractSize
			, intFutOptTransactionHeaderId
			, c.ysnSubCurrency
		FROM tblLGAllocationDetail AD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intPContractDetailId AND intSContractDetailId = @intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																		ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
		LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
		LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
		WHERE intSContractDetailId = @intSContractDetailId
		
		UNION ALL 
		SELECT DISTINCT TP.strContractType
			, strContractNumber = CH.strContractNumber +' - ' + CONVERT(NVARCHAR(100),CD.intContractSeq)
			, CD.intContractHeaderId
			, CD.dblQuantity
			, dblSAllocatedQty = SUM(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId)
			, dblContractPercentage = (SUM(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100
			, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
			, strInternalTradeNo
			, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
			, dblContractPrice = t.dblPrice
			, dblNoOfLots = ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (SUM(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId, t.intFutOptTransactionId) / CD.dblQuantity * 100)) / 100
			, t.dblPrice
			, t.intFutureMarketId
			, t.intFutureMonthId
			, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
			, m.dblContractSize
			, intFutOptTransactionHeaderId
			, c.ysnSubCurrency
		FROM tblLGAllocationDetail AD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = @intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																		ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
		LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
		LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
		WHERE intSContractDetailId = @intSContractDetailId
		
		UNION ALL SELECT DISTINCT TP.strContractType
			, strContractNumber = CH.strContractNumber +' - ' + CONVERT(NVARCHAR(100),CD.intContractSeq)
			, CD.intContractHeaderId
			, CD.dblQuantity
			, dblSAllocatedQty = SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
			, dblContractPercentage = (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100
			, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
			, strInternalTradeNo
			, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
			, dblContractPrice = t.dblPrice
			, dblNoOfLots = ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId, t.intFutOptTransactionId) / CD.dblQuantity * 100)) / 100
			, t.dblPrice
			, t.intFutureMarketId
			, t.intFutureMonthId
			, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
			, m.dblContractSize
			, intFutOptTransactionHeaderId
			, c.ysnSubCurrency
		FROM tblLGLoad AD
		JOIN tblLGLoadDetail LD ON AD.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId AND CD.intContractDetailId = @intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																		ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
		LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
		LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
		WHERE intSContractDetailId = @intSContractDetailId
		AND AD.intShipmentType = 1
		
		UNION ALL SELECT DISTINCT TP.strContractType
			, strContractNumber = CH.strContractNumber + ' - ' + CONVERT(NVARCHAR(100),CD.intContractSeq)
			, CD.intContractHeaderId
			, CD.dblQuantity
			, dblSAllocatedQty = SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
			, dblContractPercentage = (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100
			, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
			, strInternalTradeNo
			, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
			, dblContractPrice = t.dblPrice
			, dblNoOfLots = - ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId, t.intFutOptTransactionId) / CD.dblQuantity * 100)) / 100
			, t.dblPrice
			, t.intFutureMarketId
			, t.intFutureMonthId
			, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
			, m.dblContractSize
			, intFutOptTransactionHeaderId
			, c.ysnSubCurrency
		FROM tblLGLoad AD
		JOIN tblLGLoadDetail LD ON AD.intLoadId = LD.intLoadId
		JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
		JOIN tblICInventoryReceiptItemLot IL ON IL.intLotId = LDL.intLotId
		JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = IL.intInventoryReceiptItemId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intLineNo
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																		ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
		LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
		LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId																					
		WHERE intSContractDetailId = @intSContractDetailId
	) t
	
	INSERT INTO @ContractImpact(strContractNumber
		, strFutureMonth
		, dblNoOfLots
		, dblPrice
		, dblLatestSettlementPrice
		, dblFutureImpact)
	SELECT strContractType = 'Total'
		, strFutureMonth = SUBSTRING(strFutureMonth,0,CHARINDEX(' -',strFutureMonth))
		, dblNoOfLots = SUM(dblNoOfLots)
		, dblPrice = NULL--SUM(dblPrice)
		, dblLatestSettlementPrice = MAX(dblLatestSettlementPrice)
		, dblFutureImpact = SUM(dblFutureImpact)
	FROM @ContractImpact
	WHERE ISNULL(strFutureMonth, '') <> ''
	GROUP BY SUBSTRING(strFutureMonth,0,CHARINDEX(' -',strFutureMonth))
	ORDER BY CASE WHEN ISNULL(SUBSTRING(strFutureMonth,0,CHARINDEX(' -',strFutureMonth)), '') = '' THEN '' ELSE CONVERT(DATETIME, '01 ' + LEFT(SUBSTRING(strFutureMonth,0,CHARINDEX(' -',strFutureMonth)), 6)) END ASC
	
	SELECT intRowNum
		, strContractType
		, strContractNumber
		, intContractHeaderId
		, dblQuantity
		, dblSAllocatedQty
		, dblContractPercentage
		, strFutureMonth
		, strInternalTradeNo
		, dblAssignedLots
		, dblContractPrice
		, dblNoOfLots
		, dblPrice
		, intFutureMarketId
		, intFutureMonthId
		, dblLatestSettlementPrice
		, dblContractSize
		, intFutOptTransactionHeaderId
		, dblFutureImpact
	FROM @ContractImpact
	ORDER BY intRowNum
END