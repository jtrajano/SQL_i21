CREATE VIEW [dbo].[vyuICGetCommodityGrade]
AS
SELECT ca.intCommodityAttributeId, ca.intCommodityId, ca.strDescription strGrade, c.strCommodityCode, c.strDescription AS strCommodityDescription
FROM tblICCommodityAttribute ca
	INNER JOIN tblICCommodity c ON c.intCommodityId = ca.intCommodityId
WHERE strType = 'Grade'