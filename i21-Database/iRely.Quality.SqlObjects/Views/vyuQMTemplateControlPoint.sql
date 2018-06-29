CREATE VIEW vyuQMTemplateControlPoint
AS
SELECT DISTINCT ST.intSampleTypeId
	,ST.strSampleTypeName
	,ST.strDescription
	,CP.intControlPointId
	,CP.strControlPointName
FROM tblQMSampleType ST
JOIN tblQMControlPoint CP ON CP.intControlPointId = ST.intControlPointId
