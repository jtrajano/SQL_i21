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
	CH.intContractHeaderId			
FROM	tblCTContractDetail		CD		
JOIN	vyuCTContractHeaderView	CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId					
JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId				
	