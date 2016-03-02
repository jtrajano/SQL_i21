CREATE VIEW vyuQMTemplateControlPoint
AS
SELECT DISTINCT CP.intControlPointId
	,CP.strControlPointName
	,CP.strDescription
FROM tblQMControlPoint CP
JOIN tblQMSampleType ST ON ST.intControlPointId = CP.intControlPointId
