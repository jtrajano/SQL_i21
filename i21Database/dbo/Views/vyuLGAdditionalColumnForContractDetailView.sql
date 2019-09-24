/* 
	This is the SQL View version of fnCTGetAdditionalColumnForDetailView 
	Any changes on that function should be apply to this view 
*/

CREATE VIEW [dbo].[vyuLGAdditionalColumnForContractDetailView]
AS
SELECT
	intContractDetailId = AD.intContractDetailId,
	intSeqCurrencyId	= CASE WHEN (AD.ysnValidFX = 1) THEN ISNULL(FFX.intCurrencyId, TFX.intCurrencyId) ELSE AD.intCurrencyId END,
	ysnSeqSubCurrency	= CASE WHEN (AD.ysnValidFX = 1) THEN 0 ELSE AD.ysnSubCurrency END,
	intSeqPriceUOMId	= CASE WHEN (AD.ysnValidFX = 1) THEN intFXPriceUOMId ELSE AD.intPriceItemUOMId END,
	dblSeqPrice			= CASE WHEN (AD.ysnValidFX = 1) THEN 
							dbo.fnCTConvertQtyToTargetItemUOM(intFXPriceUOMId,AD.intPriceItemUOMId,AD.dblMainCashPrice) 
							* CASE WHEN (FFX.intCurrencyId IS NOT NULL) THEN 1 / (CASE WHEN ISNULL(AD.dblRate,0) = 0 THEN 1 ELSE AD.dblRate END)
							  ELSE AD.dblRate END
						  ELSE AD.dblCashPrice END,
	strSeqCurrency		= CASE WHEN (AD.ysnValidFX = 1) THEN FXC.strCurrency ELSE AD.strCurrency END,
	strSeqPriceUOM		= CASE WHEN (AD.ysnValidFX = 1) THEN AD.strFXPriceUOM ELSE AD.strPriceUOM END,
	dblQtyToPriceUOMConvFactor = CASE WHEN (AD.ysnValidFX = 1) THEN dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,AD.intFXPriceUOMId,1) 
								 ELSE dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,AD.intPriceItemUOMId,1) END,
	dblNetWtToPriceUOMConvFactor = CASE WHEN (AD.ysnValidFX = 1) THEN dbo.fnCTConvertQtyToTargetItemUOM(AD.intNetWeightUOMId,AD.intFXPriceUOMId,1) 
								 ELSE dbo.fnCTConvertQtyToTargetItemUOM(AD.intNetWeightUOMId,AD.intPriceItemUOMId,1) END,
	dblCostUnitQty		= CASE WHEN (AD.ysnValidFX = 1) THEN AD.dblFXCostUnitQty ELSE AD.dblCostUnitQty END,
	dblSeqBasis			= CASE WHEN (AD.ysnValidFX = 1) THEN 
							dbo.fnCTConvertQtyToTargetItemUOM(intFXPriceUOMId,AD.intBasisUOMId,AD.dblMainBasis) 
							* CASE WHEN (FFX.intCurrencyId IS NOT NULL) THEN 1 / (CASE WHEN ISNULL(AD.dblRate,0) = 0 THEN 1 ELSE AD.dblRate END)
							  ELSE AD.dblRate END
						  ELSE AD.dblBasis END,
	intSeqBasisCurrencyId = CASE WHEN (AD.ysnValidFX = 1) THEN ISNULL(FFX.intCurrencyId, TFX.intCurrencyId) ELSE AD.intBasisCurrencyId END,
	intSeqBasisUOMId	= CASE WHEN (AD.ysnValidFX = 1) THEN AD.intFXPriceUOMId ELSE AD.intBasisUOMId END,
	ysnValidFX			= AD.ysnValidFX,
	dblSeqFutures		= CASE WHEN (AD.ysnValidFX = 1) THEN 
							dbo.fnCTConvertQtyToTargetItemUOM(intFXPriceUOMId,AD.intPriceItemUOMId,AD.dblMainFutures) 
							* CASE WHEN (FFX.intCurrencyId IS NOT NULL) THEN 1 / (CASE WHEN ISNULL(AD.dblRate,0) = 0 THEN 1 ELSE AD.dblRate END)
							  ELSE AD.dblRate END
						  ELSE AD.dblFutures END
FROM
	(SELECT
		intContractDetailId =	CD.intContractDetailId,
		dblCashPrice		=	CD.dblCashPrice,
		dblMainCashPrice	=	CD.dblCashPrice / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END,
		intCurrencyId		=	CD.intCurrencyId,
		intMainCurrencyId	=	ISNULL(CY.intMainCurrencyId,CD.intCurrencyId),
		ysnSubCurrency		=	CY.ysnSubCurrency,
		intPriceItemUOMId	=	ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),
		dblRate				=	CD.dblRate,
		intFXPriceUOMId		=	CD.intFXPriceUOMId,
		intExchangeRateId	=	CD.intCurrencyExchangeRateId,
		intItemUOMId		=	CD.intItemUOMId,
		strCurrency			=	CY.strCurrency,
		strPriceUOM			=	UM.strUnitMeasure,
		strFXPriceUOM		=	FM.strUnitMeasure,
		ysnUseFXPrice		=	ysnUseFXPrice,
		intNetWeightUOMId	=	CD.intNetWeightUOMId,
		dblCostUnitQty		=	ISNULL(IU.dblUnitQty,1),
		dblFXCostUnitQty	=	ISNULL(FU.dblUnitQty,1),
		dblBasis			=	CD.dblBasis,
		dblMainBasis		=	CD.dblBasis / CASE WHEN AY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(AY.intCent,0) = 0 THEN 1 ELSE AY.intCent END ELSE 1 END,
		intBasisCurrencyId	=	CD.intBasisCurrencyId,
		intBasisUOMId		=	CD.intBasisUOMId,
		dblFutures			=	CD.dblFutures,
		dblMainFutures		=	CD.dblFutures / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END,
		ysnValidFX			=	CASE WHEN (ISNULL(CD.ysnUseFXPrice,0) = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL) THEN 1 ELSE 0 END
	FROM tblCTContractDetail CD
		LEFT JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID	= CD.intCurrencyId
		LEFT JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId		= CD.intPriceItemUOMId
		LEFT JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN	tblICItemUOM		FU	ON	FU.intItemUOMId		= CD.intFXPriceUOMId
		LEFT JOIN	tblICUnitMeasure	FM	ON	FM.intUnitMeasureId = FU.intUnitMeasureId
		LEFT JOIN	tblSMCurrency		AY	ON	AY.intCurrencyID	= CD.intBasisCurrencyId
	) AD
	OUTER APPLY (SELECT TOP 1 intCurrencyId = intFromCurrencyId FROM tblSMCurrencyExchangeRate 
						WHERE intCurrencyExchangeRateId = AD.intExchangeRateId 
						AND intFromCurrencyId = AD.intMainCurrencyId) FFX
	OUTER APPLY (SELECT TOP 1 intCurrencyId = intToCurrencyId FROM tblSMCurrencyExchangeRate 
				WHERE intCurrencyExchangeRateId =  AD.intExchangeRateId
				AND intToCurrencyId = AD.intMainCurrencyId) TFX
	OUTER APPLY (SELECT TOP 1 strCurrency FROM tblSMCurrency 
				WHERE intCurrencyID = CASE WHEN (AD.ysnValidFX = 1) THEN ISNULL(FFX.intCurrencyId, TFX.intCurrencyId) ELSE AD.intCurrencyId END) FXC

GO