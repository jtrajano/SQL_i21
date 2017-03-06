CREATE VIEW vyuQMSampleTypeControlPoint
AS
SELECT ST.intControlPointId
	,ST.intSampleTypeId
	,ST.strSampleTypeName
	,ST.strDescription
	,PC.intProductId
	,CAST(ROW_NUMBER() OVER (
			ORDER BY PC.intProductId
			) AS INT) AS intRowNo
	,P.intProductTypeId
	,P.intProductValueId
	,P.ysnActive
FROM tblQMProductControlPoint PC
JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId
JOIN tblQMProduct P ON P.intProductId = PC.intProductId
