CREATE VIEW [dbo].[vyuRKPnLContractDetailView]

AS

SELECT	DISTINCT
   CH.strContractNumber + '-' + LTRIM(CD.intContractSeq) strSequenceNumber,
	CD.intContractDetailId,
	CH.intContractTypeId,
	IM.strItemNo,
	IM.intItemId,
	CH.strEntityName,
	CH.intEntityId,
	CD.dblQuantity	AS	dblDetailQuantity,
	CD.dblConvertedBasis dblBasis,
	CH.intContractHeaderId, CD.intItemUOMId , C.ysnSubCurrency, intPriceItemUOMId	,um.intUnitMeasureId	intPriceUomId	
FROM	tblCTContractDetail		CD		
JOIN	vyuCTContractHeaderView	CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId					
JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId	
JOIN    tblSMCurrency			C   ON  C.intCurrencyID			    =	CD.intCurrencyId
join tblICItemUOM um on um.intItemUOMId=CD.intPriceItemUOMId
	