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
			END dblAmount,
			CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CM.intUnitMeasureId,PU.intUnitMeasureId,
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblDetailQuantity)*CC.dblRate)
					WHEN	CC.strCostMethod = 'Amount'		THEN
						CC.dblRate
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblDetailQuantity)*CD.dblCashPrice*CC.dblRate/100
			END dblAmountPer,
			(SELECT SUM(dblCost) FROM tblAPBillDetail BD WHERE BD.intContractDetailId = CC.intContractDetailId AND BD.intItemId = CC.intItemId) dblActual,
			(SELECT SUM(dblTotal) FROM tblAPBillDetail BD WHERE BD.intContractDetailId = CC.intContractDetailId AND BD.intItemId = CC.intItemId) dblActualPer
	FROM	vyuCTContractCostView		CC 
	JOIN	vyuCTContractDetailView		CD	ON	CD.intContractDetailId	=	CC.intContractDetailId	
	JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICItemUOM				CU	ON	CU.intItemUOMId			=	CC.intItemUOMId			LEFT	
	JOIN	tblICItemUOM				CM	ON	CM.intUnitMeasureId		=	CC.intUnitMeasureId
											AND	CM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId			=	CD.intItemUOMId	
