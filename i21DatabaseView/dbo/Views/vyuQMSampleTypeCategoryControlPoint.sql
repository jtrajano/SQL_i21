CREATE VIEW vyuQMSampleTypeCategoryControlPoint
AS
SELECT ST.intControlPointId
	,ST.intSampleTypeId
	,ST.strSampleTypeName
	,ST.strDescription
	,PC.intProductId
	,CAST(ROW_NUMBER() OVER (
			ORDER BY PC.intProductId
			) AS INT) AS intRowNo
	,2 AS intProductTypeId -- Configuring as 2 to not to change client filter
	--,P.intProductValueId
	,P.ysnActive
	,I.intItemId AS intProductValueId
FROM tblQMProductControlPoint PC
JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId
JOIN tblQMProduct P ON P.intProductId = PC.intProductId
JOIN tblICItem I ON I.intCategoryId = P.intProductValueId
	AND P.intProductTypeId = 1
