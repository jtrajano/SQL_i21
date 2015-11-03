CREATE VIEW [dbo].[vyuCTContractCostEnquiryCost]
	
AS

	SELECT	CC.intContractCostId,
			CC.intContractDetailId,
			CC.strItemNo,
			CC.strVendorName,
			CC.strCostMethod,
			CC.dblRate,
			CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblDetailQuantity)*CC.dblRate
					WHEN	CC.strCostMethod = 'Amount'		THEN
						CC.dblRate
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblDetailQuantity)*CD.dblCashPrice*CC.dblRate/100
			END  * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1) dblAmount,
			CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CC.intUnitMeasureId,PU.intUnitMeasureId,CC.dblRate)
					WHEN	CC.strCostMethod = 'Amount'		THEN
						CC.dblRate/dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblDetailQuantity)
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblDetailQuantity)*CD.dblCashPrice*CC.dblRate/100)/
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CD.intPriceUnitMeasureId,CD.dblDetailQuantity)
			END  * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1) dblAmountPer,
			(SELECT SUM(dblTotal) FROM tblAPBillDetail BD WHERE BD.intContractHeaderId = CC.intContractHeaderId AND BD.intItemId = CC.intItemId) * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1) dblActual,
			(SELECT SUM(dblTotal) FROM tblAPBillDetail BD WHERE BD.intContractHeaderId = CC.intContractHeaderId AND BD.intItemId = CC.intItemId)/ 
			dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CD.intPriceUnitMeasureId,CD.dblDetailQuantity) * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1)dblActualPer
	FROM	vyuCTContractCostView		CC 
	JOIN	vyuCTContractDetailView		CD	ON	CD.intContractDetailId	=	CC.intContractDetailId	
	JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICItemUOM				CU	ON	CU.intItemUOMId			=	CC.intItemUOMId			LEFT	
	JOIN	tblICItemUOM				CM	ON	CM.intUnitMeasureId		=	CC.intUnitMeasureId
											AND	CM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId			=	CD.intItemUOMId	
