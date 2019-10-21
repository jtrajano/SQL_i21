CREATE VIEW [dbo].[vyuCTDocument]
	
AS 
	SELECT	DO.intDocumentId,
			DO.intBookId,
			DO.intSubBookId,
			BK.strBook,
			SBK.strSubBook,
			DO.strDocumentName,
			DO.strDescription,
			DO.intDocumentType,
			CASE	WHEN DO.intDocumentType = 1	THEN 'Contract'
					WHEN DO.intDocumentType = 2	THEN 'Bill Of Lading'
					WHEN DO.intDocumentType = 3	THEN 'Container'
					ELSE ''
			END COLLATE Latin1_General_CI_AS AS strDocumentType,
			DO.intCommodityId,
			DO.ysnStandard,
			CO.strCommodityCode,
			CO.strDescription AS strCommodityDesc,
			DO.intCertificationId

	FROM	tblICDocument	DO
	JOIN	tblICCommodity	CO	ON	CO.intCommodityId	=	DO.intCommodityId	LEFT 
	JOIN	tblCTBook		BK	ON	DO.intBookId		=	BK.intBookId		LEFT 
	JOIN	tblCTSubBook	SBK	ON	DO.intSubBookId		=	SBK.intSubBookId
