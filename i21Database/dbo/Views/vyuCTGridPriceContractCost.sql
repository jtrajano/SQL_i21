CREATE VIEW [dbo].[vyuCTGridPriceContractCost]

AS 

	SELECT	PF.intPriceFixationId,
			PF.intPriceContractId,
			CC.intContractCostId,
			CC.intContractDetailId,
			CC.intConcurrencyId,
			CC.intItemId,
			CC.intVendorId,
			CC.strCostMethod,
			CC.intCurrencyId,
			CC.dblRate,
			CC.intItemUOMId,
			CC.dblFX,
			CC.ysnAccrue,
			CC.ysnMTM,
			CC.ysnPrice,
			CC.ysnAdditionalCost,
			CC.strItemNo,
			CC.strItemDescription,
			CC.strUOM,
			CC.strVendorName,
			CC.intContractHeaderId,
			CC.intUnitMeasureId,
			CC.intContractSeq,
			CC.strCurrency,
			CC.strContractSeq,
			CC.ysnBasis

	FROM	tblCTPriceFixation		PF
	JOIN	vyuCTContractCostView	CC	ON	CC.intContractDetailId	=	PF.intContractDetailId
	WHERE	PF.intContractDetailId IS NOT NULL

	UNION ALL

	SELECT	PF.intPriceFixationId,
			PF.intPriceContractId,
			CC.intContractCostId,
			CC.intContractDetailId,
			CC.intConcurrencyId,
			CC.intItemId,
			CC.intVendorId,
			CC.strCostMethod,
			CC.intCurrencyId,
			CC.dblRate,
			CC.intItemUOMId,
			CC.dblFX,
			CC.ysnAccrue,
			CC.ysnMTM,
			CC.ysnPrice,
			CC.ysnAdditionalCost,
			CC.strItemNo,
			CC.strItemDescription,
			CC.strUOM,
			CC.strVendorName,
			CC.intContractHeaderId,
			CC.intUnitMeasureId,
			CC.intContractSeq,
			CC.strCurrency,
			CC.strContractSeq,
			CC.ysnBasis

	FROM	tblCTPriceFixation		PF
	JOIN	vyuCTContractCostView	CC	ON	CC.intContractHeaderId	=	PF.intContractHeaderId
	WHERE	PF.intContractDetailId IS NULL
