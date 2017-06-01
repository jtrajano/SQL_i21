CREATE VIEW [dbo].[vyuRKPnLContractDetailView]

AS

SELECT	DISTINCT
	CD.intContractDetailId,
	CH.intContractTypeId,
	IM.strItemNo,
	IM.intItemId,
	CH.strEntityName,
	CH.intEntityId,
	CD.dblQuantity	AS	dblDetailQuantity,
	CD.dblBasis	
			
FROM	tblCTContractDetail		CD		
JOIN	vyuCTContractHeaderView	CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId					
JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId				
	