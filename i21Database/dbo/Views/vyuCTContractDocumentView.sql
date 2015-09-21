CREATE VIEW [dbo].[vyuCTContractDocumentView]
	
AS 
	SELECT	CD.intContractDocumentId,
			CD.intContractHeaderId,
			CD.intDocumentId,
			ID.strDocumentName,
			ID.strDescription,
			ID.ysnStandard,
			ID.intCommodityId

	FROM	tblCTContractDocument	CD
	JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICDocument		ID	ON	ID.intDocumentId		=	CD.intDocumentId
