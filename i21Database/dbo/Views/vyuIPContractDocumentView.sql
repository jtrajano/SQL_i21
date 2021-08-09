CREATE VIEW [dbo].[vyuIPContractDocumentView]
AS 
	SELECT	CD.intContractDocumentId,
			CD.intContractHeaderId,
			ID.strDocumentName
	FROM	tblCTContractDocument	CD
	JOIN	tblICDocument		ID	ON	ID.intDocumentId		=	CD.intDocumentId
