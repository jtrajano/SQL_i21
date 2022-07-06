CREATE VIEW vyuQMQualityCriteriaList
AS
SELECT QC.intQualityCriteriaId
	,QC.intItemId
	,I.strItemNo
	,ST.strSampleTypeName
FROM tblQMQualityCriteria AS QC
JOIN tblICItem AS I ON I.intItemId = QC.intItemId
LEFT JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = QC.intSampleTypeId
