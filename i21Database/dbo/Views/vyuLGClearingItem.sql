CREATE VIEW [dbo].[vyuLGClearingItem]
AS
SELECT
	[strLoadNumber] = L.strLoadNumber
	,[intLoadId] = L.intLoadId
	,[dtmDate] = DATEADD(dd, DATEDIFF(dd, 0, L.dtmScheduledDate), 0)
	,[intLoadDetailId] = LD.intLoadDetailId
	,[intUnitMeasureId] = ISNULL(L.intWeightUnitMeasureId, LDUM.intUnitMeasureId)
	,[strUnitMeasure] = ISNULL(UM.strUnitMeasure, LDUM.strUnitMeasure)
	,[intItemId] = LD.intItemId
	,[dblQty] = LD.dblNet
	,[dblAmount] = ROUND((CASE WHEN intPurchaseSale = 3 THEN COALESCE(AD.dblSeqPrice, dbo.fnCTGetSequencePrice(AD.intContractDetailId, NULL), 0) 
						ELSE COALESCE(LD.dblUnitPrice, AD.dblSeqPrice, dbo.fnCTGetSequencePrice(AD.intContractDetailId, NULL), 0) END)
					/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
					* dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LD.intPriceUOMId, AD.intSeqPriceUOMId), LD.dblNet), 2)
	,[dblAmountForeign] = CASE WHEN AD.ysnValidFX = 1 THEN 
							ROUND(dbo.fnMultiply(
								(CASE WHEN intPurchaseSale = 3 THEN COALESCE(AD.dblSeqPrice, dbo.fnCTGetSequencePrice(AD.intContractDetailId, NULL), 0) 
									ELSE COALESCE(LD.dblUnitPrice, AD.dblSeqPrice, dbo.fnCTGetSequencePrice(AD.intContractDetailId, NULL), 0) END)
								/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
								* dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LD.intPriceUOMId, AD.intSeqPriceUOMId), LD.dblNet)
								,CASE 
									WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> DC.intDefaultCurrencyId AND CD.intInvoiceCurrencyId <> DC.intDefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1)
											ELSE 1 END
									ELSE
										CASE WHEN (DC.intDefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE 1 END
									END), 2)
							ELSE 
								CONVERT(NUMERIC(18, 6), 0)
							END
	,[dblTaxForeign] = CONVERT(NUMERIC(18, 6), 0)
	,[intLocationId] = CL.intCompanyLocationId
	,[strLocationName] = CL.strLocationName 
	,[intAccountId] = apClearing.intAccountId
	,[strAccountId] = apClearing.strAccountId
FROM 
	tblLGLoad L
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemUOM LDUOM ON LDUOM.intItemUOMId = ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId)
	LEFT JOIN tblICUnitMeasure LDUM ON LDUM.intUnitMeasureId = LDUOM.intUnitMeasureId
	LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId and ItemLoc.intLocationId = LD.intPCompanyLocationId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	OUTER APPLY (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference) DC
	OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = DC.intDefaultCurrencyId
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER
						JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE DC.intDefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
							AND ((ER.intFromCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) AND ER.intToCurrencyId = DC.intDefaultCurrencyId) 
								OR (ER.intFromCurrencyId = DC.intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)))
						ORDER BY RD.dtmValidFromDate DESC) FX
WHERE L.ysnPosted = 1 AND ISNULL(L.ysnCancelled, 0) = 0
	AND (L.intFreightTermId IS NULL OR L.intFreightTermId IN (SELECT intFreightTermId FROM tblSMFreightTerms WHERE strFobPoint = 'Origin'))
	AND L.strBatchId IS NOT NULL

GO