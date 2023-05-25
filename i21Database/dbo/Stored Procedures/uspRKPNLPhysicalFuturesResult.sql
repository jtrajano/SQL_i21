CREATE PROCEDURE [dbo].[uspRKPNLPhysicalFuturesResult]
	@intSContractDetailId	INT,
	@intCurrencyId			INT,-- currency
	@intUnitMeasureId		INT,--- Price uom	
	@intWeightUOMId			INT -- weight 
AS

BEGIN
	DECLARE	@strPContractDetailId NVARCHAR(MAX)
		, @strDetailIds NVARCHAR(MAX)
		, @ysnSubCurrency BIT

 	IF OBJECT_ID('tempdb..#tempM2MBasisDetail') IS NOT NULL
 		DROP TABLE #tempM2MBasisDetail
	
	SELECT @ysnSubCurrency = ysnSubCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId

	DECLARE @tblLGAllocationDetail TABLE (intPUnitMeasureId INT
		, dblPAllocatedQty NUMERIC(18,6)
		, dtmAllocatedDate DATETIME
		, intPContractDetailId INT
		, intSContractDetailId INT)
	
	IF EXISTS(SELECT * FROM tblLGAllocationDetail WHERE intSContractDetailId = @intSContractDetailId) -- Replace this condition with Risk setting
	BEGIN
		INSERT INTO @tblLGAllocationDetail
		SELECT AD.intPUnitMeasureId
			, AD.dblPAllocatedQty
			, AD.dtmAllocatedDate
			, AD.intPContractDetailId
			, AD.intSContractDetailId
		FROM tblLGAllocationDetail AD
		WHERE AD.intSContractDetailId = @intSContractDetailId
	END
	ELSE
	BEGIN
		INSERT INTO @tblLGAllocationDetail
		SELECT DISTINCT intPUnitMeasureId = IU.intUnitMeasureId
			, dblPAllocatedQty = DL.dblLotQuantity
			, dtmAllocatedDate = LD.dtmProductionDate
			, intPContractDetailId = RI.intLineNo
			, LD.intSContractDetailId
		FROM tblLGLoadDetail LD
		JOIN tblLGLoadDetailLot DL ON LD.intLoadDetailId = DL.intLoadDetailId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = DL.intItemUOMId
		JOIN tblICInventoryReceiptItemLot IL ON	IL.intLotId = DL.intLotId
		JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = IL.intInventoryReceiptItemId
		WHERE LD.intSContractDetailId = @intSContractDetailId
	END
	
	SELECT @strPContractDetailId = COALESCE(@strPContractDetailId + ',', '') + CAST(intPContractDetailId AS NVARCHAR(50)) FROM @tblLGAllocationDetail WHERE intSContractDetailId = @intSContractDetailId
	SELECT @strDetailIds = @strPContractDetailId + ',' + LTRIM(@intSContractDetailId)
	
 	-- Company Preference values
 	DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT
			, @strEvaluationBy NVARCHAR(50)
 			, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
			, @ysnEvaluationByLocation BIT
			, @ysnEvaluationByMarketZone BIT
			, @ysnEvaluationByOriginPort BIT
			, @ysnEvaluationByDestinationPort BIT
			, @ysnEvaluationByCropYear BIT
			, @ysnEvaluationByStorageLocation BIT
			, @ysnEvaluationByStorageUnit BIT
			, @ysnEnableMTMPoint BIT
		
 	SELECT TOP 1
 		  @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
 		, @strEvaluationBy = strEvaluationBy
 		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
		, @ysnEvaluationByLocation = ysnEvaluationByLocation 
        , @ysnEvaluationByMarketZone = ysnEvaluationByMarketZone 
        , @ysnEvaluationByOriginPort = ysnEvaluationByOriginPort 
        , @ysnEvaluationByDestinationPort = ysnEvaluationByDestinationPort 
        , @ysnEvaluationByCropYear = ysnEvaluationByCropYear 
        , @ysnEvaluationByStorageLocation = ysnEvaluationByStorageLocation 
        , @ysnEvaluationByStorageUnit = ysnEvaluationByStorageUnit 
 	FROM tblRKCompanyPreference

	SELECT TOP 1 @ysnEnableMTMPoint = ysnEnableMTMPoint FROM tblCTCompanyPreference
	
 	-- Get Latest Market Basis
 	DECLARE @intM2MBasisId INT = NULL

 	SELECT TOP 1 @intM2MBasisId = intM2MBasisId 
 	FROM tblRKM2MBasis 
 	WHERE strPricingType = 'Mark to Market' 
 	ORDER BY dtmM2MBasisDate DESC

 	SELECT dblRatio
 		, dblMarketBasis = (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
 		, intMarketBasisUOM = intCommodityUnitMeasureId
 		, intMarketBasisCurrencyId = c.intCurrencyID
 		, strMarketBasisCurrency = c.strCurrency
 		, intFutureMarketId = temp.intFutureMarketId
 		, intFutureMonthId = temp.intFutureMonthId
 		, intItemId = temp.intItemId
 		, intContractTypeId = temp.intContractTypeId
 		, intCompanyLocationId = temp.intCompanyLocationId
 		, strPeriodTo = ISNULL(temp.strPeriodTo, '')
 		, temp.strContractInventory
 		, temp.intUnitMeasureId
 		, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
 		, temp.intCurrencyId
 		, temp.intCommodityId
		, temp.intMarketZoneId
		, temp.intOriginPortId
		, temp.intDestinationPortId
		, temp.intCropYearId
		, temp.intStorageLocationId
		, temp.intStorageUnitId
		, temp.intMTMPointId
 	INTO #tempM2MBasisDetail
 	FROM tblRKM2MBasisDetail temp
 	LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
 	JOIN tblICCommodityUnitMeasure cum 
 		ON cum.intCommodityId = temp.intCommodityId 
 		AND temp.intUnitMeasureId = cum.intUnitMeasureId
 	WHERE temp.intM2MBasisId = @intM2MBasisId 

	
	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strContractType)) intRowNum
		, strContractType
		, strNumber
		, strDescription
		, strConfirmed
		, dblAllocatedQty
		, dblPrice
		, strCurrency
		, dblFX
		, dblBooked
		, dblAccounting
		, dtmDate
		, strType
		, dblTranValue
		, intSort
		, ysnPosted = CAST(ysnPosted AS BIT)
		, dblTransactionValue = CASE WHEN strType IN ('2 Invoice') THEN dblAccounting
									WHEN strType IN ('Amount', 'Per Unit') THEN dblTranValue
									WHEN strType IN ('4 Supp. Invoice') AND strDescription <> 'Supp. Invoice' THEN dblPrice * -1
									WHEN strType IN ('4 Supp. Invoice') AND strDescription = 'Supp. Invoice' THEN dblTranValue * -1
									ELSE ISNULL(dblAllocatedQtyPrice, dblBookedPrice) * dblPrice / CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END END
		, dblForecast = CASE WHEN strType IN ('Amount') THEN dblTranValue / dblFX
							WHEN strType IN ('Per Unit') THEN ISNULL(dblAllocatedQtyPrice, dblBookedPrice) * dblPrice / dblFX / CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END
							ELSE ISNULL(dblAllocatedQtyPrice, dblBookedPrice) * dblPrice * dblFX / CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END END
		, intContractDetailId = @intSContractDetailId
	FROM (
		SELECT strContractType = TP.strContractType + ' - ' + CH.strContractNumber
			, strNumber = 'Sales - ' + SH.strContractNumber
			, strDescription = 'Allocated'
			, strConfirmed = NULL
			, dblAllocatedQty = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, AD.intPUnitMeasureId, @intWeightUOMId, AD.dblPAllocatedQty) * -1
			, dblAllocatedQtyPrice = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, AD.intPUnitMeasureId, @intUnitMeasureId, AD.dblPAllocatedQty) * -1
			, dblPrice = CASE WHEN CD.dblCashPrice IS NULL THEN 
										-- BASIS and ETC.
										CASE WHEN CH.intPricingTypeId <> 3
										THEN (((ISNULL(PF.dblLotsFixed, 0) * ISNULL(FD.dblFutures, 0)) + ((ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) - ISNULL(PF.dblLotsFixed, 0))
													* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, @intUnitMeasureId, MA.intUnitMeasureId, dbo.fnCTCalculateAmountBetweenCurrency(MA.intCurrencyId, @intCurrencyId, dbo.fnRKGetLastSettlementPrice(CD.intFutureMarketId, CD.intFutureMonthId),0)))))
													/ ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) + dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId, PU.intUnitMeasureId, CD.dblConvertedBasis)
										-- HTA
										ELSE (((ISNULL(PF.dblLotsFixed, 0) * ISNULL(HTAFD.dblBasis, 0)) + ((ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) - ISNULL(PF.dblLotsFixed, 0))
													* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, marketBasis.intUnitMeasureId, @intUnitMeasureId, dbo.fnCTCalculateAmountBetweenCurrency(marketBasis.intMarketBasisCurrencyId, @intCurrencyId, marketBasis.dblMarketBasis, 0)))))
													/ ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) + dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId, PU.intUnitMeasureId, CD.dblFutures)
										END
					ELSE dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, @intUnitMeasureId, PU.intUnitMeasureId, CD.dblCashPrice) END
				* dbo.fnRKGetCurrencyConvertion(CD.intCurrencyId,@intCurrencyId,null)
			, strCurrency= ISNULL(MY.strCurrency, CY.strCurrency)
			, dblFX = CASE WHEN @intCurrencyId <>  CD.intCurrencyId THEN ISNULL(dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0), 1) ELSE 1 END
			, dblBooked = NULL
			, dblBookedPrice = NULL
			, dblAccounting = NULL
			, dtmDate = AD.dtmAllocatedDate
			, strType = '3 Purchase Allocated'
			, dblTranValue = 0.00
			, intSort = 9999999 + AD.intPContractDetailId
			, ysnPosted = CAST(0 AS BIT)
		FROM @tblLGAllocationDetail AD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intPContractDetailId AND intSContractDetailId = @intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractDetail SD ON SD.intContractDetailId = @intSContractDetailId
		JOIN tblCTContractHeader SH ON SH.intContractHeaderId = SD.intContractHeaderId
		JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
		JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = CD.intFutureMarketId
		JOIN tblSMCurrency CY ON CY.intCurrencyID = @intCurrencyId
		LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
		LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																		ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
		--LEFT JOIN (
		--	SELECT intPriceFixationId
		--		, dblFutures = SUM(dblFutures)
		--	FROM tblCTPriceFixationDetail
		--	GROUP BY intPriceFixationId
		--) FD ON FD.intPriceFixationId = PF.intPriceFixationId
		OUTER APPLY (
			SELECT dblFutures = SUM(dblFutures) 
				FROM
				(
					SELECT dblFutures = (pfd.dblFutures) * (pfd.dblQuantity / CD.dblQuantity)
					FROM tblCTPriceFixation pfh
					INNER JOIN tblCTPriceFixationDetail pfd
						ON pfh.intPriceFixationId = PF.intPriceFixationId
					WHERE pfh.intContractDetailId = CD.intContractDetailId
						AND CD.intPricingTypeId = 2 
			) t
		) FD
		OUTER APPLY (
		-- Weighted Average Futures Price for HTA (Priced Qty) in Multiple Price Fixations
			SELECT dblBasis = SUM(dblBasis) 
			FROM
			(
				SELECT dblBasis = (pfd.dblBasis) * (pfd.dblQuantity / CD.dblQuantity)
				FROM tblCTPriceFixation pfh
				INNER JOIN tblCTPriceFixationDetail pfd
					ON pfh.intPriceFixationId = PF.intPriceFixationId
				WHERE pfh.intContractDetailId = CD.intContractDetailId
					AND CD.intPricingTypeId = 3 
			) t
		) HTAFD
		OUTER APPLY (
 			SELECT TOP 1 dblRatio
 					, dblMarketBasis
 					, intMarketBasisUOM
 					, intMarketBasisCurrencyId
 					, strMarketBasisCurrency
					, intUnitMeasureId
 			FROM #tempM2MBasisDetail tmp
			WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(CD.intFutureMarketId, ISNULL(tmp.intFutureMarketId,0))	
				AND ISNULL(tmp.intItemId,0) = CASE WHEN @strEvaluationBy = 'Item' 
													THEN ISNULL(CD.intItemId, 0)
													ELSE ISNULL(tmp.intItemId, 0)
													END
				AND ISNULL(tmp.intContractTypeId, 0) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
																				THEN ISNULL(CH.intContractTypeId, 0)
																				ELSE ISNULL(tmp.intContractTypeId, 0) END
				AND ISNULL(tmp.intCompanyLocationId, 0) = CASE WHEN @ysnEvaluationByLocation = 1 
																				THEN ISNULL(CD.intCompanyLocationId, 0)
																				ELSE ISNULL(tmp.intCompanyLocationId, 0) END
				AND ISNULL(tmp.intMarketZoneId, 0) = CASE WHEN @ysnEvaluationByMarketZone = 1 
																				THEN ISNULL(CD.intMarketZoneId, 0)
																				ELSE ISNULL(tmp.intMarketZoneId, 0) END
				AND ISNULL(tmp.intOriginPortId, 0) = CASE WHEN @ysnEvaluationByOriginPort = 1 
																				THEN ISNULL(CD.intLoadingPortId, 0)
																				ELSE ISNULL(tmp.intOriginPortId, 0) END
				AND ISNULL(tmp.intDestinationPortId, 0) = CASE WHEN @ysnEvaluationByDestinationPort = 1 
																				THEN ISNULL(CD.intDestinationPortId, 0)
																				ELSE ISNULL(tmp.intDestinationPortId, 0) END
				AND ISNULL(tmp.intCropYearId, 0) = CASE WHEN @ysnEvaluationByCropYear = 1 
																				THEN ISNULL(CH.intCropYearId, 0)
																				ELSE ISNULL(tmp.intCropYearId, 0) END
				AND ISNULL(tmp.intStorageLocationId, 0) = CASE WHEN @ysnEvaluationByStorageLocation = 1 
																				THEN ISNULL(CD.intStorageLocationId, 0)
																				ELSE ISNULL(tmp.intStorageLocationId, 0) END
				AND ISNULL(tmp.intStorageUnitId, 0) = CASE WHEN @ysnEvaluationByStorageUnit = 1 
																				THEN ISNULL(CD.intStorageLocationId, 0)
																				ELSE ISNULL(tmp.intStorageUnitId, 0) END
				AND ISNULL(tmp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
													THEN dbo.fnRKFormatDate(CD.dtmEndDate, 'MMM yyyy')
													ELSE ISNULL(tmp.strPeriodTo, '')
													END
				AND ISNULL(tmp.intMTMPointId, 0) = CASE WHEN @ysnEnableMTMPoint = 1 
																				THEN ISNULL(CD.intMTMPointId, 0)
																				ELSE ISNULL(tmp.intMTMPointId, 0) END
				AND tmp.strContractInventory = 'Contract' 
 		) marketBasis
		WHERE intSContractDetailId = @intSContractDetailId
		
		UNION ALL SELECT *
			, intSort = ROW_NUMBER() OVER (ORDER BY dblPrice ASC)
		FROM (
			SELECT DISTINCT strContractType = NULL
				, IV.strInvoiceNumber
				, strDescription = 'Invoice'
				, strConfirmed = NULL
				, dblAllocatedQty = NULL
				, dblAllocatedQtyPrice = NULL
				, dblPrice = dbo.[fnCTConvertQuantityToTargetItemUOM](ID.intItemId,@intUnitMeasureId,QU.intUnitMeasureId,ID.dblPrice) * CASE WHEN CD.intCurrencyId = SY.intCurrencyID THEN 1
																																WHEN SY.ysnSubCurrency = 1 THEN 100
																																ELSE 0.01 END
				, strCurrency = ISNULL(MY.strCurrency, CY.strCurrency)
				, dblFX = NULL
				, dblBooked = dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intWeightUOMId, ID.dblQtyShipped)
				, dblBookedPrice = dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,QU.intUnitMeasureId,@intUnitMeasureId, ID.dblQtyShipped)
				, dblAccounting = ID.dblTotal
				, dtmDate = IV.dtmDate
				, strType = '2 Invoice'
				, dblTranValue = 0.00
				, IV.ysnPosted
			FROM tblARInvoiceDetail ID
			JOIN tblARInvoice IV ON IV.intInvoiceId = ID.intInvoiceId 
			JOIN tblCTContractDetail CD	ON CD.intContractDetailId = ID.intContractDetailId 
			JOIN tblCTContractHeader CH	ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			JOIN tblICItemUOM QU ON QU.intItemUOMId = ID.intItemUOMId	
			JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId	
			JOIN tblSMCurrency CY ON CY.intCurrencyID = IV.intCurrencyId
			JOIN tblSMCurrency SY ON SY.intCurrencyID = @intCurrencyId
			JOIN @tblLGAllocationDetail AD ON AD.intSContractDetailId = ID.intContractDetailId
			LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
			WHERE ID.intContractDetailId = @intSContractDetailId
				AND NOT EXISTS(SELECT * FROM tblARInvoiceDetail WHERE strDocumentNumber = IV.strInvoiceNumber)
				AND IV.strTransactionType <> 'Proforma Invoice'
		) d
		
		UNION ALL SELECT DISTINCT strContractType = NULL
			, IV.strBillId
			, strDescription = CASE WHEN IM.strType = 'Other Charge' THEN IM.strItemNo ELSE 'Supp. Invoice' END
			, strConfirmed = NULL
			, dblAllocatedQty = NULL
			, dblAllocatedQtyPrice = NULL
			, dblPrice = CASE WHEN IM.strType = 'Other Charge' THEN ID.dblCost * AD.dblPAllocatedQty / ISNULL(TA.dblTotalAllocation, 1)
								ELSE dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, @intUnitMeasureId, QUCost.intUnitMeasureId, ID.dblCost) END
			, strCurrency = CY.strCurrency
			, dblFX = NULL
			, dblBooked = CASE WHEN IM.strType = 'Other Charge' THEN dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, CD.intUnitMeasureId, @intWeightUOMId, AD.dblPAllocatedQty) * -1
								ELSE dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, QU.intUnitMeasureId, @intWeightUOMId, ID.dblQtyReceived) * AD.dblPAllocatedQty / ISNULL(TA.dblTotalAllocation, 1) * -1 END
			, dblBookedPrice = CASE WHEN IM.strType = 'Other Charge' THEN dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, CD.intUnitMeasureId, @intWeightUOMId, AD.dblPAllocatedQty) * -1
									ELSE dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, QU.intUnitMeasureId, @intUnitMeasureId, ID.dblQtyReceived) * AD.dblPAllocatedQty / ISNULL(TA.dblTotalAllocation, 1) * -1 END
			, dblAccounting = CASE WHEN IV.intTransactionType IN (11, 3) -- CLAIM/DEBIT MEMO (RM-5034)
								THEN IV.dblTotal 
								ELSE CASE WHEN IM.strType <> 'Other Charge' AND ISNULL(ID.dblQtyReceived, 0) <> 0 THEN ID.dblTotal / (dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, QU.intUnitMeasureId, @intWeightUOMId, ID.dblQtyReceived) * AD.dblPAllocatedQty / ISNULL(TA.dblTotalAllocation, 1) * -1)
												* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, AD.intPUnitMeasureId, @intWeightUOMId, AD.dblPAllocatedQty) ELSE 0.0 END
								END
			, dtmDate = IV.dtmDate
			, strType = '4 Supp. Invoice'
			, dblTranValue = CASE WHEN IV.intTransactionType IN (11, 3) -- CLAIM/DEBIT MEMO (RM-5034)
								THEN IV.dblTotal * -1
								ELSE CASE WHEN IM.strType <> 'Other Charge' AND ISNULL(ID.dblQtyReceived, 0) <> 0 THEN ID.dblTotal / (dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId, QU.intUnitMeasureId, @intWeightUOMId, ID.dblQtyReceived) * AD.dblPAllocatedQty / ISNULL(TA.dblTotalAllocation, 1) * -1)
												* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, AD.intPUnitMeasureId, @intWeightUOMId, AD.dblPAllocatedQty) * -1 ELSE 0.0 END
								END
			, intSort = 9999999 + AD.intPContractDetailId
			, IV.ysnPosted
		FROM @tblLGAllocationDetail AD
		JOIN tblAPBillDetail ID ON ID.intContractDetailId= AD.intPContractDetailId
		JOIN tblAPBill IV ON IV.intBillId = ID.intBillId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = ID.intContractDetailId 
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		JOIN tblICItem IM ON IM.intItemId = ID.intItemId	
		JOIN tblICItemUOM QU ON QU.intItemUOMId = ISNULL(ID.intUnitOfMeasureId, AD.intPUnitMeasureId)
		LEFT JOIN tblICItemUOM QUCost ON QUCost.intItemUOMId = ID.intCostUOMId
		JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId	
		JOIN tblSMCurrency CY ON CY.intCurrencyID = IV.intCurrencyId
		LEFT JOIN (
			SELECT dblTotalAllocation = SUM(dblPAllocatedQty)
				, intPContractDetailId
			FROM tblLGAllocationDetail
			GROUP BY intPContractDetailId
		) TA ON TA.intPContractDetailId = AD.intPContractDetailId
		WHERE AD.intSContractDetailId = @intSContractDetailId
			AND ID.intContractCostId IS NULL
			AND ((IV.intTransactionType <> 3 AND QUCost.intItemUOMId IS NOT NULL)
					OR
				 (IV.intTransactionType = 3)
				)
			

		UNION ALL SELECT *
			, intSort = ROW_NUMBER() OVER (ORDER BY dblAllocatedQty ASC)
		FROM (
			SELECT strContractType = TP.strContractType + ' - ' + CH.strContractNumber
				, strNumber = 'Purchase - ' + PH.strContractNumber
				, strDescription = 'Allocated'
				, strConfirmed = NULL
				, dblAllocatedQty = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty)
				, dblAllocatedQtyPrice = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty)
				, dblPrice = CASE WHEN CD.dblCashPrice IS NULL THEN 
										-- BASIS and ETC.
										CASE WHEN CH.intPricingTypeId <> 3 
										THEN (((ISNULL(PF.dblLotsFixed, 0) * ISNULL(FD.dblFutures, 0)) + ((ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) - ISNULL(PF.dblLotsFixed, 0))
													* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, @intUnitMeasureId, MA.intUnitMeasureId, dbo.fnCTCalculateAmountBetweenCurrency(MA.intCurrencyId, @intCurrencyId, dbo.fnRKGetLastSettlementPrice(CD.intFutureMarketId, CD.intFutureMonthId),0)))))
													/ ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) + dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId, PU.intUnitMeasureId, CD.dblConvertedBasis)
										-- HTA
										ELSE (((ISNULL(PF.dblLotsFixed, 0) * ISNULL(HTAFD.dblBasis, 0)) + ((ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) - ISNULL(PF.dblLotsFixed, 0))
													* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, marketBasis.intUnitMeasureId, @intUnitMeasureId, dbo.fnCTCalculateAmountBetweenCurrency(marketBasis.intMarketBasisCurrencyId, @intCurrencyId, marketBasis.dblMarketBasis, 0)))))
													/ ISNULL(PF.dblTotalLots, ISNULL(CD.dblNoOfLots, ISNULL(CH.dblNoOfLots, 0))) + dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,@intUnitMeasureId, PU.intUnitMeasureId, CD.dblFutures)
										END
							ELSE dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, @intUnitMeasureId, PU.intUnitMeasureId, CD.dblCashPrice) END
							* dbo.fnRKGetCurrencyConvertion(CD.intCurrencyId,@intCurrencyId,null)
				, strCurrency = ISNULL(MY.strCurrency, CY.strCurrency)
				, dblFX = CASE WHEN @intCurrencyId <>  CD.intCurrencyId THEN ISNULL(dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0), 1) ELSE 1 END
				, dblBooked = NULL
				, dblBookedPrice = NULL
				, dblAccounting = NULL
				, dtmDate = AD.dtmAllocatedDate
				, strType = '1 Sales Allocated'
				, dblTranValue = 0.0
				, ysnPosted = CAST(0 AS BIT)
			FROM @tblLGAllocationDetail AD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = @intSContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			JOIN tblCTContractDetail PD ON PD.intContractDetailId = AD.intPContractDetailId
			JOIN tblCTContractHeader PH ON PH.intContractHeaderId = PD.intContractHeaderId
			JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId	
			JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = CD.intFutureMarketId
			JOIN tblSMCurrency CY ON CY.intCurrencyID = @intCurrencyId
			LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
			LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																			ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
			--LEFT JOIN (
			--	SELECT intPriceFixationId
			--		, dblFutures = SUM(dblFutures)
			--	FROM tblCTPriceFixationDetail
			--	GROUP BY intPriceFixationId
			--) FD ON FD.intPriceFixationId = PF.intPriceFixationId
			OUTER APPLY (
			SELECT dblFutures = SUM(dblFutures) 
					FROM
					(
						SELECT dblFutures = (pfd.dblFutures) * (pfd.dblQuantity / CD.dblQuantity)
						FROM tblCTPriceFixation pfh
						INNER JOIN tblCTPriceFixationDetail pfd
							ON pfh.intPriceFixationId = PF.intPriceFixationId
						WHERE pfh.intContractDetailId = CD.intContractDetailId
							AND CD.intPricingTypeId = 2 
				) t
			) FD
			OUTER APPLY (
			-- Weighted Average Futures Price for HTA (Priced Qty) in Multiple Price Fixations
				SELECT dblBasis = SUM(dblBasis) 
				FROM
				(
					SELECT dblBasis = (pfd.dblBasis) * (pfd.dblQuantity / CD.dblQuantity)
					FROM tblCTPriceFixation pfh
					INNER JOIN tblCTPriceFixationDetail pfd
						ON pfh.intPriceFixationId = PF.intPriceFixationId
					WHERE pfh.intContractDetailId = CD.intContractDetailId
						AND CD.intPricingTypeId = 3 
				) t
			) HTAFD
			OUTER APPLY (
 				SELECT TOP 1 dblRatio
 						, dblMarketBasis
 						, intMarketBasisUOM
 						, intMarketBasisCurrencyId
 						, strMarketBasisCurrency
						, intUnitMeasureId
 				FROM #tempM2MBasisDetail tmp
				WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(CD.intFutureMarketId, ISNULL(tmp.intFutureMarketId,0))	
					AND ISNULL(tmp.intItemId,0) = CASE WHEN @strEvaluationBy = 'Item' 
														THEN ISNULL(CD.intItemId, 0)
														ELSE ISNULL(tmp.intItemId, 0)
														END
					AND ISNULL(tmp.intContractTypeId, 0) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
																					THEN ISNULL(CH.intContractTypeId, 0)
																					ELSE ISNULL(tmp.intContractTypeId, 0) END
					AND ISNULL(tmp.intCompanyLocationId, 0) = CASE WHEN @ysnEvaluationByLocation = 1 
																					THEN ISNULL(CD.intCompanyLocationId, 0)
																					ELSE ISNULL(tmp.intCompanyLocationId, 0) END
					AND ISNULL(tmp.intMarketZoneId, 0) = CASE WHEN @ysnEvaluationByMarketZone = 1 
																					THEN ISNULL(CD.intMarketZoneId, 0)
																					ELSE ISNULL(tmp.intMarketZoneId, 0) END
					AND ISNULL(tmp.intOriginPortId, 0) = CASE WHEN @ysnEvaluationByOriginPort = 1 
																					THEN ISNULL(CD.intLoadingPortId, 0)
																					ELSE ISNULL(tmp.intOriginPortId, 0) END
					AND ISNULL(tmp.intDestinationPortId, 0) = CASE WHEN @ysnEvaluationByDestinationPort = 1 
																					THEN ISNULL(CD.intDestinationPortId, 0)
																					ELSE ISNULL(tmp.intDestinationPortId, 0) END
					AND ISNULL(tmp.intCropYearId, 0) = CASE WHEN @ysnEvaluationByCropYear = 1 
																					THEN ISNULL(CH.intCropYearId, 0)
																					ELSE ISNULL(tmp.intCropYearId, 0) END
					AND ISNULL(tmp.intStorageLocationId, 0) = CASE WHEN @ysnEvaluationByStorageLocation = 1 
																					THEN ISNULL(CD.intStorageLocationId, 0)
																					ELSE ISNULL(tmp.intStorageLocationId, 0) END
					AND ISNULL(tmp.intStorageUnitId, 0) = CASE WHEN @ysnEvaluationByStorageUnit = 1 
																					THEN ISNULL(CD.intStorageLocationId, 0)
																					ELSE ISNULL(tmp.intStorageUnitId, 0) END
					AND ISNULL(tmp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
														THEN dbo.fnRKFormatDate(CD.dtmEndDate, 'MMM yyyy')
														ELSE ISNULL(tmp.strPeriodTo, '')
														END
					AND ISNULL(tmp.intMTMPointId, 0) = CASE WHEN @ysnEnableMTMPoint = 1 
																					THEN ISNULL(CD.intMTMPointId, 0)
																					ELSE ISNULL(tmp.intMTMPointId, 0) END
					AND tmp.strContractInventory = 'Contract' 
 				) marketBasis
				WHERE intSContractDetailId = @intSContractDetailId
			) d
		
		UNION ALL SELECT TOP 100 PERCENT strItemNo
			, strBillId
			, strDescription
			, strConfirmed
			, dblAllocatedQty = SUM(dblAllocatedQty)
			, dblAllocatedQtyPrice = SUM(dblAllocatedQtyPrice)
			, dblPrice
			, strCurrency
			, dblFX
			, dblBooked
			, dblBookedPrice
			, dblAccounting
			, dtmContractDate
			, strType
			, dblTranValue
			, intSort
			, ysnPosted
		FROM (
			SELECT IM.strItemNo
				, strBillId
				, strDescription = TP.strContractType + ' - ' + CH.strContractNumber
				, strConfirmed = NULL
				, dblAllocatedQty = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intWeightUOMId, AD.dblPAllocatedQty)
				, dblAllocatedQtyPrice = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty)
				, dblPrice = CASE WHEN CC.strCostMethod = 'Per Unit' THEN dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId, @intUnitMeasureId, CU.intUnitMeasureId, 1) * CC.dblRate
									WHEN CC.strCostMethod = 'Amount' THEN CC.dblRate / dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, CIU.intUnitMeasureId, @intUnitMeasureId, CD.dblQuantity) END
							* CASE WHEN CC.intCurrencyId = OY.intCurrencyID THEN 1
									WHEN OY.ysnSubCurrency = 1 THEN 100
									ELSE 0.01 END * -1
				, strCurrency = ISNULL(MY.strCurrency,CY.strCurrency)
				, dblFX = CASE WHEN 
								(CASE WHEN OY.ysnSubCurrency = 1 
									THEN OY.intMainCurrencyId 
									ELSE @intCurrencyId END
								) <> 
								(CASE WHEN CY.ysnSubCurrency = 1
									THEN CY.intMainCurrencyId
									ELSE CC.intCurrencyId 
									END)
							THEN ISNULL(dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId, 1), 1) ELSE 1 END
				, dblBooked = NULL
				, dblBookedPrice = NULL
				, dblAccounting = (BL.dblAccounting / (CD.dblQuantity / AD.dblPAllocatedQty)) * -1
				, CH.dtmContractDate
				, strType = CC.strCostMethod
				, dblTranValue = CASE WHEN CC.strCostMethod = 'Amount' 
										THEN CC.dblRate / CD.dblQuantity * AD.dblPAllocatedQty 
									WHEN CC.strCostMethod = 'Per Unit' 
										THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId, @intUnitMeasureId, CU.intUnitMeasureId, 1) * CC.dblRate) 
											* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,@intUnitMeasureId, AD.dblPAllocatedQty)
									ELSE dblTranValue 
									END * -1
				, intSort = 99999999 + AD.intPContractDetailId
				, ysnPosted = CAST(0 AS BIT)
			FROM @tblLGAllocationDetail AD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId IN (AD.intPContractDetailId, AD.intSContractDetailId)
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId= CD.intContractHeaderId
			JOIN tblCTContractCost CC ON CC.intContractDetailId= CD.intContractDetailId AND ISNULL(ysnBasis, 0) = 0
			JOIN tblICItem IM ON IM.intItemId = CC.intItemId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
			LEFT JOIN tblICItemUOM CU ON CU.intItemUOMId = CC.intItemUOMId
			LEFT JOIN tblICItemUOM CIU ON CIU.intItemUOMId = CD.intItemUOMId
			LEFT JOIN tblSMCurrency OY ON OY.intCurrencyID = @intCurrencyId
			LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CC.intCurrencyId
			LEFT JOIN tblICM2MComputation MC ON MC.intM2MComputationId = IM.intM2MComputationId
			LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
			LEFT JOIN (
				SELECT intContractCostId
					, BL.strBillId
					, dblBooked = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId,IU.intUnitMeasureId,@intUnitMeasureId, BD.dblQtyReceived))
					, dblAccounting = SUM(BD.dblTotal)
					, dblTranValue = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(BD.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, BD.dblQtyReceived) * dblCost / CASE WHEN BD.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
				FROM tblAPBillDetail BD
				JOIN tblAPBill BL ON BL.intBillId = BD.intBillId
				LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = BD.intUnitOfMeasureId
				WHERE intContractDetailId IN (SELECT * FROM dbo.fnSplitString(@strDetailIds, ','))
					AND intContractCostId IS NOT NULL
				GROUP BY intContractCostId
					, BL.strBillId
			) BL ON BL.intContractCostId = CC.intContractCostId
			WHERE intSContractDetailId IN (SELECT * FROM dbo.fnSplitString(@strDetailIds, ','))
				AND ISNULL(MC.strM2MComputation, 'No') = 'No'
		) d
		GROUP BY strItemNo
			, strBillId
			, strDescription
			, strConfirmed
			, dblPrice
			, strCurrency
			, dblFX
			, dblBooked
			, dblBookedPrice
			, dblAccounting
			, dtmContractDate
			, intSort
			, strType
			, dblTranValue
			, ysnPosted
		ORDER BY strItemNo
	) t
	ORDER by intSort
		, strType
END