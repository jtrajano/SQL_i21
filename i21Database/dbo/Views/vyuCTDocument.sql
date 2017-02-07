CREATE VIEW [dbo].[vyuCTDocument]
	
AS 
	SELECT	DO.intDocumentId,
			DO.strDocumentName,
			DO.strDescription,
			DO.intDocumentType,
			CASE	WHEN DO.intDocumentType = 1	THEN 'Contract'
					WHEN DO.intDocumentType = 2	THEN 'Bill Of Lading'
					WHEN DO.intDocumentType = 3	THEN 'Container'
					ELSE ''
			END AS strDocumentType,
			DO.intCommodityId,
			DO.ysnStandard,
			CO.strCommodityCode,
			CO.strDescription AS strCommodityDesc
	FROM	tblICDocument	DO
	JOIN	tblICCommodity	CO	ON	CO.intCommodityId	=	DO.intCommodityId
