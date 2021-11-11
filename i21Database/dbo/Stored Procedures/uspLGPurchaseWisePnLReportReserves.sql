CREATE PROCEDURE [dbo].[uspLGPurchaseWisePnLReportReserves]
	@intAllocationDetailId INT
	,@intUnitMeasureId INT = NULL
	,@intReserves INT = 1 /* 1= Reserves A, 2 = Reserves B */
AS

DECLARE @intDefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@intMarketUnitMeasureId INT
		,@strUnitMeasure AS NVARCHAR(200)
		,@strCurrency AS NVARCHAR(200)
		,@intFutureMarketCurrency AS NVARCHAR(200)

SELECT @intMarketUnitMeasureId = FM.intUnitMeasureId, @intFutureMarketCurrency = FM.intCurrencyId
FROM tblLGAllocationDetail ALD
	INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
	INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = PCD.intFutureMarketId
WHERE intAllocationDetailId = @intAllocationDetailId

SELECT @strUnitMeasure = CASE WHEN ISNULL(strSymbol, '') <> '' THEN strSymbol ELSE strUnitMeasure END
FROM tblICUnitMeasure WHERE intUnitMeasureId = @intMarketUnitMeasureId

SELECT @strCurrency = CASE WHEN ISNULL(strSymbol, '') <> '' THEN strSymbol ELSE strCurrency END
FROM tblSMCurrency WHERE intCurrencyID = @intFutureMarketCurrency

SELECT
	I.strItemNo
	,dblRate = ISNULL(CC.dblRate, 0)
	,dblEstimatedAmount = ISNULL(CC.dblAmount, 0) * -1
	,dblInvoicedAmount = CASE WHEN @intReserves = 1 THEN ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0) ELSE 0 END * -1
	,dblVariance = CASE WHEN @intReserves = 1 THEN 
						CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) <> 0 
							THEN ((ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) * -1) 
							- (ISNULL(CC.dblAmount, 0) * -1)
							ELSE 0 END
					ELSE 0 END
	,dblRecalcValue = CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) <> 0 
							THEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) 
							ELSE ISNULL(CC.dblAmount, 0) END * -1 
	,strUnitCurrency = @strCurrency + '/' + @strUnitMeasure
FROM tblICItem I
	OUTER APPLY (SELECT intPContractDetailId, intSContractDetailId, dblPAllocatedQty, dblSAllocatedQty
					FROM tblLGAllocationDetail WHERE intAllocationDetailId = @intAllocationDetailId) ALD
	OUTER APPLY (SELECT dblShippedNetQty = SUM(dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId,LD.intItemUOMId,LD.dblNet))
					FROM tblLGLoadDetail LD INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.ysnPosted = 1
					WHERE intAllocationDetailId = @intAllocationDetailId) LS
	OUTER APPLY (SELECT TOP 1 CD.intItemId, CD.intNetWeightUOMId, IU.intItemUOMId 
					FROM tblCTContractDetail CD INNER JOIN tblICItemUOM IU ON IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = @intUnitMeasureId
					WHERE CD.intContractDetailId = ALD.intPContractDetailId) PCD
	OUTER APPLY (SELECT TOP 1 intPnLReportReserveBCategoryId, intPnLReportReserveACategoryId FROM tblLGCompanyPreference) CP
	/* P-Tonnage */
	OUTER APPLY 
		(SELECT 
			dblNetShippedWt = SUM(BLD.dblQtyReceived)
		FROM 
			(SELECT bl.intBillId, bld.intItemId, bld.intContractDetailId, bl.ysnPosted, bl.intTransactionType
				,dblQtyReceived = CASE WHEN (bld.intItemId <> PCD.intItemId) THEN 0 
										ELSE 
											CASE WHEN bl.intTransactionType IN (11) 
												THEN dbo.fnCalculateQtyBetweenUOM (bld.intUnitOfMeasureId, PCD.intItemUOMId, bld.dblQtyOrdered)
												ELSE dbo.fnCalculateQtyBetweenUOM (bld.intWeightUOMId, PCD.intItemUOMId, bld.dblNetWeight)  
											END
										END
									* CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
				FROM tblAPBillDetail bld
				INNER JOIN tblAPBill bl on bl.intBillId = bld.intBillId) BLD
			INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
		WHERE (BLD.ysnPosted = 1 OR BLD.intTransactionType = 11) 
			AND BLD.intContractDetailId = ALD.intPContractDetailId
			AND BLDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) PTON
	/* P-Tonnage Adjustment */
	OUTER APPLY 
		(SELECT 
			dblWtAdjustment = SUM(BLD.dblWeightAdj)
		FROM 
			(SELECT bl.intBillId, bld.intItemId, bld.intContractDetailId, bl.ysnPosted, bl.intTransactionType
				,dblWeightAdj = dbo.fnCalculateQtyBetweenUOM (PCD.intNetWeightUOMId, PCD.intItemUOMId, bld.dblWeight) 
								* CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
				FROM tblAPBillDetail bld
				INNER JOIN tblAPBill bl on bl.intBillId = bld.intBillId) BLD
			INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
		WHERE (BLD.ysnPosted = 1 OR BLD.intTransactionType = 11) 
			AND BLD.intContractDetailId = ALD.intPContractDetailId
			AND BLDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) PTONAdj
	/* Reserves Rate and Amount */
	OUTER APPLY (SELECT CC.intContractCostId
						,dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
											CC.dblRate
										WHEN CC.strCostMethod = 'Amount' THEN
											CC.dblRate 
											/ CASE WHEN ISNULL(PTON.dblNetShippedWt, 0) <> 0 THEN PTON.dblNetShippedWt + ISNULL(PTONAdj.dblWtAdjustment, 0)
													WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
													ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
										ELSE CC.dblRate END * COALESCE(CC.dblFX, FX.dblFXRate, 1)
						,dblAmount = CASE WHEN CC.strCostMethod = 'Per Unit' THEN
											CASE WHEN ISNULL(PTON.dblNetShippedWt, 0) <> 0 THEN PTON.dblNetShippedWt + ISNULL(PTONAdj.dblWtAdjustment, 0)
													WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
													ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
											* dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,CToUOM.intItemUOMId,CC.dblRate) / ISNULL(CCUR.intCent, 1)
										WHEN CC.strCostMethod = 'Amount' THEN
											CC.dblRate
										WHEN CC.strCostMethod = 'Per Container'	THEN
											CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers,1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers,1) END)
										WHEN CC.strCostMethod = 'Percentage' THEN 
											CASE WHEN ISNULL(PTON.dblNetShippedWt, 0) <> 0 THEN PTON.dblNetShippedWt + ISNULL(PTONAdj.dblWtAdjustment, 0)
													WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
													ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
											* CD.dblCashPrice * CC.dblRate/100
										END 
									* COALESCE(CC.dblFX, FX.dblFXRate, 1)
					FROM tblCTContractCost CC
						LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
						LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = CC.intCurrencyId
						OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = CD.intItemId AND intUnitMeasureId = @intUnitMeasureId) ToUOM
						OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) CToUOM
						OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
									FROM tblSMCurrencyExchangeRate ER
									JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
									WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
										AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
											OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
									ORDER BY RD.dtmValidFromDate DESC) FX
					 WHERE CC.intItemId = I.intItemId AND CD.intContractDetailId = ALD.intSContractDetailId) CC
	/* Reserves Voucher Amount */
	OUTER APPLY (SELECT dblTotal = SUM(CASE WHEN BL.intTransactionType IN (3, 11) 
										THEN (BLD.dblTotal * -1) * COALESCE(BLD.dblRate, FX.dblFXRate, 1) 
										ELSE BLD.dblTotal * COALESCE(BLD.dblRate, FX.dblFXRate, 1) END) 
				FROM tblAPBillDetail BLD 
					INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
					INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
					LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = BLD.intCurrencyId
					OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
								FROM tblSMCurrencyExchangeRate ER
								JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
								WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
									AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
										OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
								ORDER BY RD.dtmValidFromDate DESC) FX
				WHERE BL.ysnPosted = 1
					AND BLD.intContractDetailId IN (ALD.intPContractDetailId, ALD.intSContractDetailId)
					AND BLD.intItemId = I.intItemId 
				) VCHR
	/* Reserves Invoice Amount */
	OUTER APPLY (SELECT dblTotal = SUM(CASE WHEN IV.strTransactionType IN ('Credit Memo') 
										THEN (IVD.dblTotal * -1) * ISNULL(FX.dblFXRate, 1)
										ELSE IVD.dblTotal * ISNULL(FX.dblFXRate, 1) END)
				FROM tblARInvoiceDetail IVD 
					INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
					INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
					LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = IV.intCurrencyId
					OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
								FROM tblSMCurrencyExchangeRate ER
								JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
								WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
									AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
										OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
								ORDER BY RD.dtmValidFromDate DESC) FX
				WHERE IV.ysnPosted = 1
					AND IVD.intContractDetailId IN (ALD.intPContractDetailId, ALD.intSContractDetailId)
					AND IVD.intItemId = I.intItemId 
				) INVC
WHERE I.intCategoryId = CASE WHEN @intReserves <> 1 THEN CP.intPnLReportReserveBCategoryId ELSE CP.intPnLReportReserveACategoryId END

GO