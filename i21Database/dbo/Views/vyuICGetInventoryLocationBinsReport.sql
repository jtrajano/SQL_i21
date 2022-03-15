CREATE VIEW [dbo].[vyuICGetInventoryLocationBinsReport]
AS 
SELECT 
	A.*
	,Certification.intCertificationId
	,Certification.strCertificationName
	,strGrade		= Grade.strDescription
	,strOrigin 		= Origin.strDescription
	,strProductType	= ProductType.strDescription
	,strRegion 		= Region.strDescription
	,strSeason 		= Season.strDescription
	,strClass 		= Class.strDescription
	,strProductLine = ProductLine.strDescription
FROM 
	tblICLocationBinsReport A
	LEFT JOIN tblICItem i
		ON i.intItemId = A.intItemId
	LEFT JOIN tblICCertification Certification
		ON Certification.intCertificationId = i.intCertificationId
	LEFT JOIN tblICCommodityAttribute Grade
		ON Grade.intCommodityAttributeId = i.intGradeId
	LEFT JOIN tblICCommodityAttribute Origin
		ON Origin.intCommodityAttributeId = i.intOriginId
	LEFT JOIN tblICCommodityAttribute ProductType
		ON ProductType.intCommodityAttributeId = i.intProductTypeId
	LEFT JOIN tblICCommodityAttribute Region
		ON Region.intCommodityAttributeId = i.intRegionId
	LEFT JOIN tblICCommodityAttribute Season
		ON Season.intCommodityAttributeId = i.intSeasonId
	LEFT JOIN tblICCommodityAttribute Class
		ON Class.intCommodityAttributeId = i.intClassVarietyId
	LEFT JOIN tblICCommodityProductLine ProductLine
		ON ProductLine.intCommodityProductLineId = i.intProductLineId