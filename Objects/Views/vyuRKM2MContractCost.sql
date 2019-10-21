CREATE VIEW vyuRKM2MContractCost
AS
SELECT CC.intContractDetailId, 		
			case when strCostMethod ='Amount' then CC.dblRate else  case when ysnSubCurrency=1 then CC.dblRate/100 else CC.dblRate end end dblRate,
			IU.intUnitMeasureId,
			CC.intItemId,
			CH.intContractBasisId,
			strCostMethod,
			CC.intCurrencyId 
FROM		tblCTContractCost	CC
JOIN		tblCTContractDetail CD ON CD.intContractDetailId	=	CC.intContractDetailId
join		tblCTContractHeader CH ON CH.intContractHeaderId	=	CD.intContractHeaderId
JOIN		tblSMCurrency C on C.intCurrencyID=CC.intCurrencyId
LEFT JOIN		tblICItemUOM		IU ON IU.intItemUOMId		=	CC.intItemUOMId