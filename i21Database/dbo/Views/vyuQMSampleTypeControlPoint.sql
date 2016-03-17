CREATE VIEW vyuQMSampleTypeControlPoint
AS
SELECT ST.intControlPointId
	,ST.intSampleTypeId
	,ST.strSampleTypeName
	,ST.strDescription
	,PC.intProductId
	,ROW_NUMBER() OVER (
		ORDER BY PC.intProductId
		) AS intRowNo
FROM tblQMProductControlPoint PC
JOIN tblQMSampleType ST ON ST.intControlPointId = PC.intControlPointId
