﻿CREATE VIEW [dbo].[vyuCTContractDocumentView]
	
AS 
	SELECT	CD.intContractDocumentId,
			CD.intContractHeaderId,
			CD.intDocumentId,
			ID.strDocumentName,
			ID.strDescription,
			ID.ysnStandard,
			ID.intCommodityId,
			CASE	WHEN ID.intDocumentType = 1	THEN 'Contract'
					WHEN ID.intDocumentType = 2	THEN 'Bill Of Lading'
					WHEN ID.intDocumentType = 3	THEN 'Container'
					ELSE ''
			END AS strDocumentType
	FROM	tblCTContractDocument	CD
	JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICDocument		ID	ON	ID.intDocumentId		=	CD.intDocumentId
