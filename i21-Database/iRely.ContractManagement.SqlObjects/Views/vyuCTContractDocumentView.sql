CREATE VIEW [dbo].[vyuCTContractDocumentView]
	
AS 
	SELECT	CD.intContractDocumentId,
			CD.intContractHeaderId,
			CD.intDocumentId,
			ID.strDocumentName,
			ID.strDescription,
			ID.ysnStandard,
			ID.intCommodityId,
			--ISNULL(ID.intOriginal,0) intOriginal,
			--ISNULL(ID.intCopies,0) intCopies,
			0 intOriginal,
			0 intCopies,
			CASE	WHEN ID.intDocumentType = 1	THEN 'Contract'
					WHEN ID.intDocumentType = 2	THEN 'Bill Of Lading'
					WHEN ID.intDocumentType = 3	THEN 'Container'
					ELSE ''
			END AS strDocumentType
	FROM	tblCTContractDocument	CD
	JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICDocument		ID	ON	ID.intDocumentId		=	CD.intDocumentId
