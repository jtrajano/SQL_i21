CREATE VIEW vyuLGGetInventoryDocumentList
AS
SELECT intDocumentId
	,strDocumentName
	,D.strDescription
	,intDocumentType
	,strDocumentType = CASE intDocumentType
		WHEN 1
			THEN 'Contract'
		WHEN 2
			THEN 'Bill Of Lading'
		WHEN 3
			THEN 'Container'
		END
	,C.intCommodityId
	,ysnStandard
	,intCertificationId
	,intOriginal
	,intCopies
	,C.strCommodityCode
FROM tblICDocument D
JOIN tblICCommodity C ON C.intCommodityId = D.intCommodityId