CREATE PROCEDURE [dbo].[uspRKAllocatedContractRiskReport]
	  @intCommodityId INT = NULL

AS
BEGIN
	IF @intCommodityId = 0
	BEGIN	
		SELECT @intCommodityId = NULL
	END

	IF OBJECT_ID('tempdb..#tempAllocatedContracts') IS NOT NULL
		DROP TABLE #tempAllocatedContracts
	IF OBJECT_ID('tempdb..#tempCTSeqHistory') IS NOT NULL
		DROP TABLE #tempCTSeqHistory

	SELECT DISTINCT
		  CD.intContractDetailId
		, CD.intContractHeaderId
		, intContractTypeId = 1
	INTO #tempAllocatedContracts
	FROM tblLGAllocationDetail alloc
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = alloc.intPContractDetailId
	INNER JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)

	INSERT INTO #tempAllocatedContracts
	SELECT DISTINCT
		  CD.intContractDetailId
		, CD.intContractHeaderId
		, intContractTypeId = 2
	FROM tblLGAllocationDetail alloc
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = alloc.intSContractDetailId
	INNER JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)
	
	-- Get Latest Pricing Status
	DECLARE @dblZero DECIMAL(16, 8) = 0
	SELECT 
 		  AC.intContractHeaderId
 		, AC.intContractDetailId
 		, CTSeq.ysnPriced
		, AC.intContractTypeId
		, dblFutures = ISNULL(CASE WHEN CTSeq.ysnPartialPrice = 1 
									AND CTSeq.intPricingTypeId = 2
								THEN priceFixationDetail.dblFutures
								ELSE CTSeq.dblFutures
								END, @dblZero)
		, dblBasis = ISNULL(CASE WHEN CTSeq.ysnPartialPrice = 1 
									AND CTSeq.intPricingTypeId = 3
								THEN priceFixationDetailForHTA.dblBasis
								ELSE CTSeq.dblBasis
								END, @dblZero)
		, CTSeq.dblQtyPriced
		, CTSeq.dblQtyUnpriced
		, CTSeq.dblLotsPriced
		, CTSeq.dblLotsUnpriced
	INTO #tempCTSeqHistory
	FROM #tempAllocatedContracts AC
	OUTER APPLY (
 		SELECT TOP 1 
 				ysnPriced = CASE WHEN cb.strPricingStatus = 'Fully Priced' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				, ysnPartialPrice = CASE WHEN cb.strPricingStatus = 'Partially Priced' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				, cb.dblFutures
				, cb.dblBasis
				, cb.intContractDetailId
				, cb.intPricingTypeId
				, cb.dblQuantity
				, cb.dblQtyPriced
				, cb.dblQtyUnpriced
				, cb.dblLotsPriced
				, cb.dblLotsUnpriced
 		FROM tblCTSequenceHistory cb
 		WHERE cb.intContractDetailId = AC.intContractDetailId
 		ORDER BY cb.dtmHistoryCreated DESC
	) CTSeq
	OUTER APPLY (
		-- Weighted Average Futures Price for Basis (Priced Qty) in Multiple Price Fixations
		SELECT dblFutures = SUM(dblFutures) 
		FROM
		(
			SELECT dblFutures = (pfd.dblFutures) * (pfd.dblQuantity / CTSeq.dblQuantity)
			FROM tblCTPriceFixation pfh
			INNER JOIN tblCTPriceFixationDetail pfd
				ON pfh.intPriceFixationId = pfd.intPriceFixationId
			WHERE pfh.intContractDetailId = CTSeq.intContractDetailId
				AND CTSeq.ysnPartialPrice = 1
				AND CTSeq.intPricingTypeId = 2 
		) t
	) priceFixationDetail
	OUTER APPLY (
		-- Weighted Average Futures Price for HTA (Priced Qty) in Multiple Price Fixations
		SELECT dblBasis = SUM(dblBasis) 
		FROM
		(
			SELECT dblBasis = (pfd.dblBasis) * (pfd.dblQuantity / CTSeq.dblQuantity)
			FROM tblCTPriceFixation pfh
			INNER JOIN tblCTPriceFixationDetail pfd
				ON pfh.intPriceFixationId = pfd.intPriceFixationId
			WHERE pfh.intContractDetailId = CTSeq.intContractDetailId
				AND CTSeq.ysnPartialPrice = 1
				AND CTSeq.intPricingTypeId = 3 
		) t
	) priceFixationDetailForHTA


	--======================================================================================================================================
	-- FINAL TABLE RESULT
	--======================================================================================================================================
	SELECT 
		-- PURCHASE CONTRACT COLUMNS
		  intRowNumber = ROW_NUMBER() OVER (PARTITION BY CDP.intContractDetailId, CDS.intContractDetailId ORDER BY CDP.intContractDetailId)
		, intConcurrencyId = CHP.intConcurrencyId
		, strPContractNumber = CHP.strContractNumber
		, intPContractSeq = CDP.intContractSeq
		, dblPSequenceQuantity = CDP.dblQuantity
		, strPSequenceUOM = PUOM.strUnitMeasure
		, strPFutureMonth = PFMonth.strFutureMonth
		, strPFutureMarket = PFMarket.strFutMarketName
		, dblPNoOfLots = ISNULL(CDP.dblNoOfLots, 0)
		, dblPFixedLots = ISNULL(PSeqHistory.dblLotsPriced, 0)
		, dblPUnfixedLots = ISNULL(PSeqHistory.dblLotsUnpriced, 0)
		, dblPHedgedLots = ISNULL(PHedge.dblPHedgedLots, 0)
		, dblPHedgeLevel = ISNULL(PHedge.dblPWeightedAverageHedgePrice, 0)
		, dblPFutures = ISNULL(CDP.dblFutures, 0)
		, dblPBasis = ISNULL(CDP.dblBasis, 0)
		, dblPCash = ISNULL(CDP.dblFutures, 0) + ISNULL(CDP.dblBasis, 0)
		, dblPHistoricSA = ISNULL(PHistoricSA.dblPHistoricSA, 0)
		, dblPCurrentBasisDiff = ISNULL(CDP.dblBasis, 0) + ISNULL(PHistoricSA.dblPHistoricSA, 0) + 
					ISNULL(PArb.dblSpreadPrice, ISNULL(PArbAssignDer.dblSpreadPrice, 0)) - ISNULL(SArb.dblSpreadPrice, ISNULL(SArbAssignDer.dblSpreadPrice, 0))

		-- PURCHASE SPREAD/ARBITRAGE
		, dblPArbBuyLots = ISNULL(PArb.dblNoOfLots, ISNULL(PArbAssignDer.dblNoOfLots, 0))
		, dblPBuyLevel = ISNULL(PArb.dblSpreadPrice, ISNULL(PArbAssignDer.dblSpreadPrice, 0))
		, strPBuyMonth = ISNULL(PArb.strPArbFutureMonth, PArbAssignDer.strPArbFutureMonth)
		, strPBuyMarket = ISNULL(PArb.strPArbFutureMarket, PArbAssignDer.strPArbFutureMarket)

		-- SALE SPREAD/ARBITRAGE
		, dblSArbBuyLots = ISNULL(SArb.dblNoOfLots, ISNULL(SArbAssignDer.dblNoOfLots, 0))
		, dblSBuyLevel = ISNULL(SArb.dblSpreadPrice, ISNULL(SArbAssignDer.dblSpreadPrice, 0))
		, strSBuyMonth = ISNULL(SArb.strSArbFutureMonth, SArbAssignDer.strSArbFutureMonth)
		, strSBuyMarket = ISNULL(SArb.strSArbFutureMarket, SArbAssignDer.strSArbFutureMarket)

		, dblSpreadArbitrageLevel = ISNULL(PArb.dblSpreadPrice, ISNULL(PArbAssignDer.dblSpreadPrice, 0)) - ISNULL(SArb.dblSpreadPrice, ISNULL(SArbAssignDer.dblSpreadPrice, 0))


		-- SALE CONTRACT COLUMNS
		, strSContractNumber = CHS.strContractNumber
		, intSContractSeq = CDS.intContractSeq
		, dblSSequenceQuantity = CDS.dblQuantity
		, strSSequenceUOM = SUOM.strUnitMeasure
		, strSFutureMonth = SFMonth.strFutureMonth
		, strSFutureMarket = SFMarket.strFutMarketName
		, dblSNoOfLots = ISNULL(CDS.dblNoOfLots, 0)
		, dblSFixedLots = ISNULL(SSeqHistory.dblLotsPriced, 0)
		, dblSUnfixedLots = ISNULL(SSeqHistory.dblLotsUnpriced, 0)
		, dblSHedgedLots = ISNULL(SHedge.dblSHedgedLots, 0)
		, dblSHedgeLevel = ISNULL(SHedge.dblSWeightedAverageHedgePrice, 0)
		, dblSFutures = ISNULL(CDS.dblFutures, 0)
		, dblSBasis = ISNULL(CDS.dblBasis, 0)
		, dblSCash = ISNULL(CDS.dblFutures, 0) + ISNULL(CDS.dblBasis, 0)
		, dblSHistoricSA = ISNULL(SHistoricSA.dblSHistoricSA, 0)
		, dblSCurrentBasisDiff = ISNULL(CDS.dblBasis, 0) + ISNULL(SHistoricSA.dblSHistoricSA, 0) + 
					ISNULL(PArb.dblSpreadPrice, ISNULL(PArbAssignDer.dblSpreadPrice, 0)) - ISNULL(SArb.dblSpreadPrice, ISNULL(SArbAssignDer.dblSpreadPrice, 0))

		-- MISC COLUMNS
		, dblSpreadNeeded = CASE WHEN CDP.intFutureMonthId <> CDS.intFutureMonthId AND CDP.intFutureMarketId = CDS.intFutureMarketId
								THEN CDP.dblNoOfLots - ISNULL(PArb.dblNoOfLots, ISNULL(PArbAssignDer.dblNoOfLots, 0))
								ELSE 0
								END
		, dblArbitrageNeeded = CASE WHEN CDP.intFutureMonthId <> CDS.intFutureMonthId AND CDP.intFutureMarketId <> CDS.intFutureMarketId
								THEN CDP.dblNoOfLots - ISNULL(PArb.dblNoOfLots, ISNULL(PArbAssignDer.dblNoOfLots, 0))
								ELSE 0
								END
		, ysnNaturalHedge =  CASE WHEN CHP.intPricingTypeId = 1 
									AND CHS.intPricingTypeId = 1 
									AND CDP.intFutureMonthId = CDS.intFutureMonthId 
									AND CDP.dblNoOfLots = CDS.dblNoOfLots
								THEN CAST(1 AS BIT)
								ELSE CAST(0 AS BIT)
								END
	FROM tblLGAllocationDetail alloc
	INNER JOIN tblCTContractDetail CDP
		ON CDP.intContractDetailId = alloc.intPContractDetailId
	INNER JOIN tblCTContractHeader CHP
		ON CHP.intContractHeaderId = CDP.intContractHeaderId
	INNER JOIN tblCTContractDetail CDS
		ON CDS.intContractDetailId = alloc.intSContractDetailId
	INNER JOIN tblCTContractHeader CHS
		ON CHS.intContractHeaderId = CDS.intContractHeaderId

	-- PURCHASE CT JOIN TABLES
	LEFT JOIN tblICUnitMeasure PUOM
		ON PUOM.intUnitMeasureId = CDP.intUnitMeasureId
	LEFT JOIN tblRKFuturesMonth PFMonth
		ON PFMonth.intFutureMonthId = CDP.intFutureMonthId
	LEFT JOIN tblRKFutureMarket PFMarket
		ON PFMarket.intFutureMarketId = CDP.intFutureMarketId
	LEFT JOIN #tempCTSeqHistory PSeqHistory
		ON PSeqHistory.intContractDetailId = CDP.intContractDetailId
	LEFT JOIN tblCTPriceFixation PPF
		ON PPF.intContractDetailId = CDP.intContractDetailId
	OUTER APPLY (
		SELECT TOP 1 
			  dblSpreadPrice = PSA.dblSpreadPrice
			, dblNoOfLots = PSA.dblNoOfLots
			, strPArbFutureMarket = PSAFMarket.strFutMarketName
			, strPArbFutureMonth = PSAFMonth.strFutureMonth
		FROM tblCTSpreadArbitrage PSA
		LEFT JOIN tblRKFutureMarket PSAFMarket
			ON PSAFMarket.intFutureMarketId = PSA.intNewFutureMarketId
		LEFT JOIN tblRKFuturesMonth PSAFMonth
			ON PSAFMonth.intFutureMonthId = PSA.intNewFutureMonthId
		WHERE PSA.intPriceFixationId = PPF.intPriceFixationId
		AND PSA.strBuySell = 'Buy'
		ORDER BY PSA.dtmSpreadArbitrageDate DESC
	) PArb
	OUTER APPLY (
		SELECT TOP 1 dblSpreadPrice = D.dblPrice
			, dblNoOfLots = AFS.dblAssignedLots
			, strPArbFutureMarket = PSAFMarket.strFutMarketName
			, strPArbFutureMonth = PSAFMonth.strFutureMonth
		FROM tblRKAssignFuturesToContractSummary AFS
		JOIN tblRKFutOptTransaction D
			ON D.intFutOptTransactionId = AFS.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket PSAFMarket
			ON PSAFMarket.intFutureMarketId = D.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth PSAFMonth
			ON PSAFMonth.intFutureMonthId = D.intFutureMonthId
		WHERE AFS.intContractDetailId = CDP.intContractDetailId
		ORDER BY AFS.dtmMatchDate DESC
	) PArbAssignDer
	OUTER APPLY (
		SELECT dblPHedgedLots = SUM(PAssign.dblHedgedLots)
			, dblPWeightedAverageHedgePrice = SUM(PAssign.dblHedgedLots * ISNULL(PDer.dblPrice, 0)) / CDP.dblNoOfLots
		FROM tblRKAssignFuturesToContractSummary PAssign
		LEFT JOIN tblRKFutOptTransaction PDer
			ON PDer.intFutOptTransactionId = PAssign.intFutOptTransactionId
		WHERE PAssign.intContractDetailId = CDP.intContractDetailId
	) PHedge
	OUTER APPLY (
		SELECT TOP 1 dblPHistoricSA = PDer.dblPrice
		FROM tblRKAssignFuturesToContractSummary PAssign
		JOIN tblRKFutOptTransaction PDer
			ON PDer.intFutOptTransactionId = PAssign.intFutOptTransactionId
		CROSS APPLY (
			SELECT TOP 1 ysnMatched = CAST(1 AS BIT)
			FROM tblRKMatchFuturesPSDetail MD
			WHERE MD.intLFutOptTransactionId = PAssign.intFutOptTransactionId
			UNION
			SELECT TOP 1 ysnMatched = CAST(1 AS BIT)
			FROM tblRKMatchFuturesPSDetail MD2
			WHERE MD2.intSFutOptTransactionId = PAssign.intFutOptTransactionId
		) PDerMatch
		WHERE PAssign.intContractDetailId = CDP.intContractDetailId
		ORDER BY PAssign.intAssignFuturesToContractSummaryId DESC
	) PHistoricSA


	-- SALE CT JOIN TABLES
	LEFT JOIN tblICUnitMeasure SUOM
		ON SUOM.intUnitMeasureId = CDS.intUnitMeasureId
	LEFT JOIN tblRKFuturesMonth SFMonth
		ON SFMonth.intFutureMonthId = CDS.intFutureMonthId
	LEFT JOIN tblRKFutureMarket SFMarket
		ON SFMarket.intFutureMarketId = CDS.intFutureMarketId
	LEFT JOIN #tempCTSeqHistory SSeqHistory
		ON PSeqHistory.intContractDetailId = CDS.intContractDetailId
	LEFT JOIN tblCTPriceFixation SPF
		ON SPF.intContractDetailId = CDS.intContractDetailId
	OUTER APPLY (
		SELECT TOP 1 
			  dblSpreadPrice = ISNULL(SSA.dblSpreadPrice, 0)
			, dblNoOfLots = SSA.dblNoOfLots
			, strSArbFutureMarket = SSAFMarket.strFutMarketName
			, strSArbFutureMonth = SSAFMonth.strFutureMonth
		FROM tblCTSpreadArbitrage SSA
		LEFT JOIN tblRKFutureMarket SSAFMarket
			ON SSAFMarket.intFutureMarketId = SSA.intNewFutureMarketId
		LEFT JOIN tblRKFuturesMonth SSAFMonth
			ON SSAFMonth.intFutureMonthId = SSA.intNewFutureMonthId
		WHERE SSA.intPriceFixationId = SPF.intPriceFixationId
		AND SSA.strBuySell = 'Sell'
		ORDER BY SSA.dtmSpreadArbitrageDate DESC
	) SArb
	OUTER APPLY (
		SELECT TOP 1 dblSpreadPrice = D.dblPrice
			, dblNoOfLots = AFS.dblAssignedLots
			, strSArbFutureMarket = PSAFMarket.strFutMarketName
			, strSArbFutureMonth = PSAFMonth.strFutureMonth
		FROM tblRKAssignFuturesToContractSummary AFS
		JOIN tblRKFutOptTransaction D
			ON D.intFutOptTransactionId = AFS.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket PSAFMarket
			ON PSAFMarket.intFutureMarketId = D.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth PSAFMonth
			ON PSAFMonth.intFutureMonthId = D.intFutureMonthId
		WHERE AFS.intContractDetailId = CDS.intContractDetailId
		ORDER BY AFS.dtmMatchDate DESC
	) SArbAssignDer
	OUTER APPLY (
		SELECT dblSHedgedLots = SUM(SAssign.dblHedgedLots)
			, dblSWeightedAverageHedgePrice = SUM(SAssign.dblHedgedLots * ISNULL(SDer.dblPrice, 0)) / CDS.dblNoOfLots
		FROM tblRKAssignFuturesToContractSummary SAssign
		LEFT JOIN tblRKFutOptTransaction SDer
			ON SDer.intFutOptTransactionId = SAssign.intFutOptTransactionId
		WHERE SAssign.intContractDetailId = CDS.intContractDetailId
	) SHedge
	OUTER APPLY (
		SELECT TOP 1 dblSHistoricSA = SDer.dblPrice
		FROM tblRKAssignFuturesToContractSummary SAssign
		JOIN tblRKFutOptTransaction SDer
			ON SDer.intFutOptTransactionId = SAssign.intFutOptTransactionId
		CROSS APPLY (
			SELECT TOP 1 ysnMatched = CAST(1 AS BIT)
			FROM tblRKMatchFuturesPSDetail MD
			WHERE MD.intLFutOptTransactionId = SAssign.intFutOptTransactionId
			UNION
			SELECT TOP 1 ysnMatched = CAST(1 AS BIT)
			FROM tblRKMatchFuturesPSDetail MD2
			WHERE MD2.intSFutOptTransactionId = SAssign.intFutOptTransactionId
		) SDerMatch
		WHERE SAssign.intContractDetailId = CDS.intContractDetailId
		ORDER BY SAssign.intAssignFuturesToContractSummaryId DESC
	) SHistoricSA
	WHERE CHP.intCommodityId = ISNULL(@intCommodityId, CHP.intCommodityId)
	--AND (PArb.dblNoOfLots IS NOT NULL OR PArbAssignDer.dblNoOfLots IS NOT NULL)	
	--AND (SArb.dblNoOfLots IS NOT NULL OR SArbAssignDer.dblNoOfLots IS NOT NULL)	
END